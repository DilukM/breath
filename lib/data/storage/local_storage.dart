import 'package:hive_flutter/hive_flutter.dart';
import '../models/breathing_session.dart';
import '../../core/utils/constants.dart';

/// Hive implementation for local storage
class LocalStorage {
  late Box<BreathingSession> _sessionBox;
  late Box _settingsBox;

  /// Initialize Hive and open boxes
  Future<void> init() async {
    await Hive.initFlutter();
    await _openBoxes();
  }

  /// Test-only entry point: initializes Hive against a plain filesystem
  /// path instead of [Hive.initFlutter], which requires platform channels
  /// (path_provider) unavailable under `flutter test`.
  Future<void> initForTesting(String path) async {
    Hive.init(path);
    await _openBoxes();
  }

  Future<void> _openBoxes() async {
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(BreathingSessionAdapter());
    }

    // Open boxes
    _sessionBox = await Hive.openBox<BreathingSession>(
      AppConstants.sessionHistoryBox,
    );
    _settingsBox = await Hive.openBox(AppConstants.settingsBox);
  }

  /// Save a breathing session
  Future<void> saveSession(BreathingSession session) async {
    await _sessionBox.add(session);
  }

  /// Get all sessions
  List<BreathingSession> getAllSessions() {
    return _sessionBox.values.toList();
  }

  /// Get recent sessions (last n sessions)
  List<BreathingSession> getRecentSessions(int count) {
    final sessions = _sessionBox.values.toList();
    sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
    return sessions.take(count).toList();
  }

  /// Clear all sessions
  Future<void> clearSessions() async {
    await _sessionBox.clear();
  }

  /// Get setting value
  T? getSetting<T>(String key, {T? defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue) as T?;
  }

  /// Save setting value
  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  /// Check if vibration is enabled
  bool isVibrationEnabled() {
    return getSetting<bool>(
      AppConstants.vibrationEnabledKey,
      defaultValue: true,
    ) ?? true;
  }

  /// Check if sound is enabled
  bool isSoundEnabled() {
    return getSetting<bool>(
      AppConstants.soundEnabledKey,
      defaultValue: true,
    ) ?? true;
  }

  /// Set vibration enabled
  Future<void> setVibrationEnabled(bool enabled) async {
    await saveSetting(AppConstants.vibrationEnabledKey, enabled);
  }

  /// Set sound enabled
  Future<void> setSoundEnabled(bool enabled) async {
    await saveSetting(AppConstants.soundEnabledKey, enabled);
  }

  /// Check if stealth (pocket / haptic-only) mode is enabled by default
  bool isStealthModeEnabled() {
    return getSetting<bool>(
      AppConstants.stealthModeKey,
      defaultValue: false,
    ) ?? false;
  }

  /// Set stealth (pocket / haptic-only) mode
  Future<void> setStealthModeEnabled(bool enabled) async {
    await saveSetting(AppConstants.stealthModeKey, enabled);
  }

  /// Check if daily reminder notification is enabled
  bool isReminderEnabled() {
    return getSetting<bool>(
      AppConstants.reminderEnabledKey,
      defaultValue: false,
    ) ?? false;
  }

  /// Set daily reminder notification enabled
  Future<void> setReminderEnabled(bool enabled) async {
    await saveSetting(AppConstants.reminderEnabledKey, enabled);
  }

  /// Get scheduled daily reminder hour (0-23, default: 20 for 8 PM)
  int getReminderHour() {
    return getSetting<int>(
      AppConstants.reminderHourKey,
      defaultValue: 20,
    ) ?? 20;
  }

  /// Get scheduled daily reminder minute (0-59, default: 0)
  int getReminderMinute() {
    return getSetting<int>(
      AppConstants.reminderMinuteKey,
      defaultValue: 0,
    ) ?? 0;
  }

  /// Save scheduled daily reminder time
  Future<void> setReminderTime(int hour, int minute) async {
    await saveSetting(AppConstants.reminderHourKey, hour);
    await saveSetting(AppConstants.reminderMinuteKey, minute);
  }

  /// Get theme mode (dark mode enabled)
  bool getThemeMode() {
    return getSetting<bool>(
      'isDarkMode',
      defaultValue: true,
    ) ?? true;
  }

  /// Save theme mode
  Future<void> saveThemeMode(bool isDark) async {
    await saveSetting('isDarkMode', isDark);
  }

  /// Update the most recently saved session (used to attach the
  /// post-session mood once the user picks it on the completion screen).
  Future<void> updateLastSession(BreathingSession Function(BreathingSession) update) async {
    if (_sessionBox.isEmpty) return;
    final key = _sessionBox.keys.last;
    final current = _sessionBox.get(key);
    if (current == null) return;
    await _sessionBox.put(key, update(current));
  }

  /// Current consecutive-day streak of completed sessions, counting back
  /// from today (a streak still counts if the last session was yesterday).
  int getCurrentStreak() {
    final days = _sessionBox.values
        .where((s) => s.completed)
        .map((s) => DateTime(s.startTime.year, s.startTime.month, s.startTime.day))
        .toSet();
    if (days.isEmpty) return 0;

    var cursor = DateTime.now();
    cursor = DateTime(cursor.year, cursor.month, cursor.day);
    if (!days.contains(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
      if (!days.contains(cursor)) return 0;
    }

    var streak = 0;
    while (days.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// Total number of sessions ever recorded (completed or not).
  int getTotalSessionsCount() => _sessionBox.length;

  /// Total time spent across all completed sessions.
  Duration getTotalDuration() {
    final totalSeconds = _sessionBox.values
        .where((s) => s.completed)
        .fold<int>(0, (sum, s) => sum + s.actualDuration.inSeconds);
    return Duration(seconds: totalSeconds);
  }

  /// Minutes practiced per calendar day for the last [days] days
  /// (inclusive of today), keyed by midnight of that day.
  Map<DateTime, int> getDailyMinutes(int days) {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: days - 1));
    final result = <DateTime, int>{
      for (var i = 0; i < days; i++) start.add(Duration(days: i)): 0,
    };
    for (final session in _sessionBox.values) {
      if (!session.completed) continue;
      final day = DateTime(
        session.startTime.year,
        session.startTime.month,
        session.startTime.day,
      );
      if (result.containsKey(day)) {
        result[day] = result[day]! + (session.actualDuration.inSeconds / 60).round();
      }
    }
    return result;
  }

  /// Most recent sessions, newest first.
  List<BreathingSession> getSessionsDescending({int? limit}) {
    final sessions = _sessionBox.values.toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
    return limit != null ? sessions.take(limit).toList() : sessions;
  }

  /// Selected breathing technique id (see [kBreathingTechniques]).
  String getSelectedTechniqueId() {
    return getSetting<String>('selected_technique', defaultValue: '4-7-8') ?? '4-7-8';
  }

  Future<void> setSelectedTechniqueId(String id) async {
    await saveSetting('selected_technique', id);
  }

  /// Selected ambience track id (see [kAmbienceTracks]).
  String getSelectedAmbienceId() {
    return getSetting<String>('selected_ambience', defaultValue: 'forest') ?? 'forest';
  }

  Future<void> setSelectedAmbienceId(String id) async {
    await saveSetting('selected_ambience', id);
  }

  /// Whether the user has completed the onboarding screen before.
  bool hasSeenOnboarding() {
    return getSetting<bool>('onboarding_seen', defaultValue: false) ?? false;
  }

  Future<void> setOnboardingSeen() async {
    await saveSetting('onboarding_seen', true);
  }

  /// Close all boxes
  Future<void> close() async {
    await _sessionBox.close();
    await _settingsBox.close();
  }
}
