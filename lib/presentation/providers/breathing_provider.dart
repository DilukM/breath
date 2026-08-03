import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../core/utils/constants.dart';
import '../../data/models/breathing_session.dart';
import '../../data/models/breathing_technique.dart';
import '../../data/storage/local_storage.dart';

/// State management for breathing sessions using Provider
class BreathingProvider extends ChangeNotifier {
  final LocalStorage localStorage;

  // Session state
  bool _isRunning = false;
  int _selectedDuration = 3; // in minutes
  BreathingPhase _currentPhase = BreathingPhase.ready;
  int _remainingTime = 0; // in seconds
  int _totalSeconds = 0;
  int _completedCycles = 0;
  DateTime? _sessionStartTime;
  String? _moodBefore;
  int _phaseSecondsRemaining = 0;
  int _phaseTotalSeconds = 0;

  late BreathingTechnique _technique;
  late String _ambience;

  // Timer
  Timer? _timer;
  Timer? _phaseTimer;

  // Audio players
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _bgMusicPlayer = AudioPlayer();

  // Getters
  bool get isRunning => _isRunning;
  int get selectedDuration => _selectedDuration;
  BreathingPhase get currentPhase => _currentPhase;
  int get remainingTime => _remainingTime;
  int get totalSeconds => _totalSeconds;
  int get completedCycles => _completedCycles;
  double get progress => _totalSeconds > 0 ? (_totalSeconds - _remainingTime) / _totalSeconds : 0.0;
  BreathingTechnique get technique => _technique;
  String get ambience => _ambience;
  String? get moodBefore => _moodBefore;
  int get phaseSecondsRemaining => _phaseSecondsRemaining;
  double get phaseProgress =>
      _phaseTotalSeconds > 0 ? _phaseSecondsRemaining / _phaseTotalSeconds : 0.0;

  BreathingProvider({required this.localStorage}) {
    _technique = techniqueById(localStorage.getSelectedTechniqueId());
    _ambience = localStorage.getSelectedAmbience();
  }

  /// Set selected duration
  void setDuration(int minutes) {
    if (!_isRunning) {
      _selectedDuration = minutes;
      notifyListeners();
    }
  }

  /// Set the active breathing technique (from the Library)
  Future<void> setTechnique(String id) async {
    if (_isRunning) return;
    _technique = techniqueById(id);
    await localStorage.setSelectedTechniqueId(id);
    notifyListeners();
  }

  /// Set the ambience sound chip (decorative)
  Future<void> setAmbience(String label) async {
    _ambience = label;
    await localStorage.setSelectedAmbience(label);
    notifyListeners();
  }

  /// Record how the user felt right before starting the session
  void setMoodBefore(String? mood) {
    _moodBefore = mood;
    notifyListeners();
  }

  /// Record how the user felt after finishing — attaches to the session
  /// that was just saved.
  Future<void> setMoodAfter(String mood) async {
    await localStorage.updateLastSession((s) => s.copyWith(moodAfter: mood));
  }

  /// Start a breathing session
  Future<void> startSession() async {
    if (_isRunning) return;

    _isRunning = true;
    _sessionStartTime = DateTime.now();
    _totalSeconds = _selectedDuration * 60;
    _remainingTime = _totalSeconds;
    _completedCycles = 0;
    _currentPhase = BreathingPhase.ready;
    
    // Start background music
    await _startBackgroundMusic();
    
    notifyListeners();

    // Start countdown timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        _remainingTime--;
        notifyListeners();
      } else {
        _completeSession(completed: true);
      }
    });

    // Start breathing cycle
    await _startBreathingCycle();
  }

  /// Start breathing cycle phases
  Future<void> _startBreathingCycle() async {
    await _executePhase(BreathingPhase.ready, 3);

    while (_isRunning && _remainingTime > 0) {
      await _executePhase(BreathingPhase.inhale, _technique.inhaleSeconds);
      if (!_isRunning) break;

      if (_technique.holdSeconds > 0) {
        await _executePhase(BreathingPhase.hold, _technique.holdSeconds);
        if (!_isRunning) break;
      }

      await _executePhase(BreathingPhase.exhale, _technique.exhaleSeconds);
      if (!_isRunning) break;

      _completedCycles++;
      notifyListeners();
    }
  }

  /// Execute a single breathing phase, counting down second by second so
  /// the session ring can show a live per-phase countdown.
  Future<void> _executePhase(BreathingPhase phase, int seconds) async {
    if (!_isRunning) return;

    _currentPhase = phase;
    _phaseTotalSeconds = seconds;
    _phaseSecondsRemaining = seconds;
    notifyListeners();

    // Trigger feedback
    await _triggerFeedback(phase);

    final completer = Completer<void>();
    _phaseTimer?.cancel();
    _phaseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isRunning) {
        timer.cancel();
        if (!completer.isCompleted) completer.complete();
        return;
      }
      _phaseSecondsRemaining--;
      notifyListeners();
      if (_phaseSecondsRemaining <= 0) {
        timer.cancel();
        if (!completer.isCompleted) completer.complete();
      }
    });
    await completer.future;
  }

  /// Trigger haptic and audio feedback
  Future<void> _triggerFeedback(BreathingPhase phase) async {
    // Vibration feedback
    if (localStorage.isVibrationEnabled()) {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        switch (phase) {
          case BreathingPhase.inhale:
            Vibration.vibrate(duration: 100);
            break;
          case BreathingPhase.hold:
            Vibration.vibrate(duration: 50);
            break;
          case BreathingPhase.exhale:
            Vibration.vibrate(duration: 100);
            break;
          default:
            break;
        }
      }
    }

    // Audio feedback (optional - requires audio files)
    if (localStorage.isSoundEnabled()) {
      // Uncomment when audio files are added
      // try {
      //   switch (phase) {
      //     case BreathingPhase.inhale:
      //       await _audioPlayer.play(AssetSource('sounds/inhale.mp3'));
      //       break;
      //     case BreathingPhase.exhale:
      //       await _audioPlayer.play(AssetSource('sounds/exhale.mp3'));
      //       break;
      //     default:
      //       break;
      //   }
      // } catch (e) {
      //   debugPrint('Audio playback error: $e');
      // }
    }
  }

  /// Start background music
  Future<void> _startBackgroundMusic() async {
    if (localStorage.isSoundEnabled()) {
      try {
        await _bgMusicPlayer.setReleaseMode(ReleaseMode.loop);
        await _bgMusicPlayer.setVolume(0.3); // Set to 30% volume
        await _bgMusicPlayer.play(AssetSource('sounds/bg.mp3'));
      } catch (e) {
        debugPrint('Background music playback error: $e');
      }
    }
  }

  /// Stop background music
  Future<void> _stopBackgroundMusic() async {
    try {
      await _bgMusicPlayer.stop();
    } catch (e) {
      debugPrint('Background music stop error: $e');
    }
  }

  /// Stop the current session
  Future<void> stopSession() async {
    await _completeSession(completed: false);
  }

  /// Complete the session and save to storage
  Future<void> _completeSession({required bool completed}) async {
    _timer?.cancel();
    _phaseTimer?.cancel();
    
    // Stop background music
    await _stopBackgroundMusic();
    
    if (_sessionStartTime != null) {
      final session = BreathingSession(
        startTime: _sessionStartTime!,
        endTime: DateTime.now(),
        durationMinutes: _selectedDuration,
        completedCycles: _completedCycles,
        completed: completed,
        moodBefore: _moodBefore,
        techniqueId: _technique.id,
      );

      await localStorage.saveSession(session);
    }

    _isRunning = false;
    _currentPhase = completed ? BreathingPhase.complete : BreathingPhase.ready;
    _sessionStartTime = null;
    
    notifyListeners();
  }

  /// Reset to initial state
  void reset() {
    _timer?.cancel();
    _phaseTimer?.cancel();
    _stopBackgroundMusic();
    _isRunning = false;
    _currentPhase = BreathingPhase.ready;
    _remainingTime = 0;
    _totalSeconds = 0;
    _completedCycles = 0;
    _sessionStartTime = null;
    _moodBefore = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _phaseTimer?.cancel();
    _audioPlayer.dispose();
    _bgMusicPlayer.dispose();
    super.dispose();
  }
}
