import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../core/utils/constants.dart';
import '../../data/models/ambience_track.dart';
import '../../data/models/breathing_session.dart';
import '../../data/models/breathing_technique.dart';
import '../../data/storage/local_storage.dart';

/// State management for breathing sessions using Provider
class BreathingProvider extends ChangeNotifier {
  final LocalStorage localStorage;

  // Session state
  bool _isRunning = false;
  bool _isStealthMode = false;
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
  late AmbienceTrack _ambienceTrack;

  // Timer
  Timer? _timer;
  Timer? _phaseTimer;

  // Audio players
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _bgMusicPlayer = AudioPlayer();

  // Getters
  bool get isRunning => _isRunning;
  bool get isStealthMode => _isStealthMode;
  int get selectedDuration => _selectedDuration;
  BreathingPhase get currentPhase => _currentPhase;
  int get remainingTime => _remainingTime;
  int get totalSeconds => _totalSeconds;
  int get completedCycles => _completedCycles;
  double get progress => _totalSeconds > 0 ? (_totalSeconds - _remainingTime) / _totalSeconds : 0.0;
  BreathingTechnique get technique => _technique;
  AmbienceTrack get ambienceTrack => _ambienceTrack;
  String? get moodBefore => _moodBefore;
  int get phaseSecondsRemaining => _phaseSecondsRemaining;
  double get phaseProgress =>
      _phaseTotalSeconds > 0 ? _phaseSecondsRemaining / _phaseTotalSeconds : 0.0;

  BreathingProvider({required this.localStorage}) {
    _isStealthMode = localStorage.isStealthModeEnabled();
    _technique = techniqueById(localStorage.getSelectedTechniqueId());
    _ambienceTrack = ambienceById(localStorage.getSelectedAmbienceId());

    // audioplayers doesn't always throw from play() when a source fails to
    // decode on the native side — on Android/iOS that can surface later via
    // these streams instead. Without this, a bad file just plays silence
    // with nothing in the logs.
    _bgMusicPlayer.onLog.listen((msg) => debugPrint('Ambience player log: $msg'));
    _bgMusicPlayer.onPlayerStateChanged.listen(
      (state) => debugPrint('Ambience player state: $state'),
    );

    _configureMixableAudio();
  }

  /// By default each [AudioPlayer] requests exclusive Android audio focus
  /// (AUDIOFOCUS_GAIN) when it starts — so the short inhale/exhale cue was
  /// silently stopping the looping ambience track every time it played, even
  /// though both come from this same app. Requesting no focus on either
  /// player lets them mix instead of fighting each other.
  ///
  /// iOS is left on its own default [AudioContextIOS] (category `playback`,
  /// no extra options) — multiple players within the same app already mix
  /// fine there without needing `mixWithOthers`, and that option combined
  /// with an explicit category tripped an assertion in
  /// audioplayers_platform_interface on some versions.
  void _configureMixableAudio() {
    final context = AudioContext(
      android: const AudioContextAndroid(
        audioFocus: AndroidAudioFocus.none,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.media,
      ),
    );
    unawaited(_bgMusicPlayer.setAudioContext(context));
    unawaited(_audioPlayer.setAudioContext(context));
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

  /// Set the ambience track played during a session
  Future<void> setAmbience(String id) async {
    _ambienceTrack = ambienceById(id);
    await localStorage.setSelectedAmbienceId(id);
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

  /// Explicitly set or toggle Stealth Mode (pocket / tactile-only breathing)
  void setStealthMode(bool enabled) {
    if (_isStealthMode == enabled) return;
    _isStealthMode = enabled;
    if (_isStealthMode) {
      unawaited(_stopBackgroundMusic());
    } else if (_isRunning && localStorage.isSoundEnabled()) {
      unawaited(_startBackgroundMusic());
    }
    notifyListeners();
  }

  /// Toggle Stealth Mode
  void toggleStealthMode([bool? force]) {
    setStealthMode(force ?? !_isStealthMode);
  }

  /// Start a breathing session
  Future<void> startSession() async {
    if (_isRunning) return;

    // Check if stealth mode should default to true from settings
    if (localStorage.isStealthModeEnabled()) {
      _isStealthMode = true;
    }

    _isRunning = true;
    _sessionStartTime = DateTime.now();
    _totalSeconds = _selectedDuration * 60;
    _remainingTime = _totalSeconds;
    _completedCycles = 0;
    _currentPhase = BreathingPhase.ready;

    // Start the ambience track if not in stealth mode
    unawaited(_startBackgroundMusic());

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
    // Vibration feedback (always on in stealth mode, or if vibration is enabled)
    final vibrationAllowed = _isStealthMode || localStorage.isVibrationEnabled();
    if (vibrationAllowed) {
      try {
        final hasVibrator = await Vibration.hasVibrator();
        final hasCustom = await Vibration.hasCustomVibrationsSupport();
        if (hasVibrator == true) {
          switch (phase) {
            case BreathingPhase.ready:
              if (hasCustom) {
                await Vibration.vibrate(pattern: [0, 80, 60, 80]);
              } else {
                await Vibration.vibrate(duration: 80);
              }
              HapticFeedback.lightImpact().catchError((_) {});
              break;
            case BreathingPhase.inhale:
              // Rising dual-pulse to signal expansion
              if (hasCustom) {
                await Vibration.vibrate(pattern: [0, 140, 80, 70]);
              } else {
                await Vibration.vibrate(duration: 120);
              }
              HapticFeedback.mediumImpact().catchError((_) {});
              break;
            case BreathingPhase.hold:
              // Crisp singular tap signaling stillness
              await Vibration.vibrate(duration: 40);
              HapticFeedback.selectionClick().catchError((_) {});
              break;
            case BreathingPhase.exhale:
              // Grounding descending wave to signal release
              if (hasCustom) {
                await Vibration.vibrate(pattern: [0, 180, 90, 100]);
              } else {
                await Vibration.vibrate(duration: 160);
              }
              HapticFeedback.heavyImpact().catchError((_) {});
              break;
            case BreathingPhase.complete:
              if (hasCustom) {
                await Vibration.vibrate(pattern: [0, 100, 80, 100, 80, 150]);
              } else {
                await Vibration.vibrate(duration: 200);
              }
              HapticFeedback.heavyImpact().catchError((_) {});
              break;
          }
        } else {
          // Native system haptics fallback
          switch (phase) {
            case BreathingPhase.inhale:
              HapticFeedback.mediumImpact().catchError((_) {});
              break;
            case BreathingPhase.hold:
              HapticFeedback.selectionClick().catchError((_) {});
              break;
            case BreathingPhase.exhale:
            case BreathingPhase.complete:
              HapticFeedback.heavyImpact().catchError((_) {});
              break;
            default:
              HapticFeedback.lightImpact().catchError((_) {});
          }
        }
      } catch (e) {
        debugPrint('Vibration feedback error: $e');
      }
    }

    // Audio cue for the phase change (suppressed in stealth mode)
    if (!_isStealthMode && localStorage.isSoundEnabled()) {
      try {
        switch (phase) {
          case BreathingPhase.inhale:
            await _audioPlayer.play(AssetSource('sounds/inhale.mp3'), volume: 0.6);
            break;
          case BreathingPhase.exhale:
            await _audioPlayer.play(AssetSource('sounds/exhale.mp3'), volume: 0.6);
            break;
          default:
            break;
        }
      } catch (e) {
        debugPrint('Audio playback error: $e');
      }
    }
  }

  /// Start playing the selected ambience track
  Future<void> _startBackgroundMusic() async {
    if (!_isStealthMode && localStorage.isSoundEnabled()) {
      try {
        await _bgMusicPlayer.setReleaseMode(ReleaseMode.loop);
        await _bgMusicPlayer.setVolume(0.3); // Set to 30% volume
        
        if (_ambienceTrack.url != null) {
          await _bgMusicPlayer.play(UrlSource(_ambienceTrack.url!));
        } else if (_ambienceTrack.assetPath != null) {
          await _bgMusicPlayer.play(AssetSource(_ambienceTrack.assetPath!));
        }
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
    _isStealthMode = localStorage.isStealthModeEnabled();
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
