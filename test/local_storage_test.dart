import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mindful_breathing/data/models/breathing_session.dart';
import 'package:mindful_breathing/data/storage/local_storage.dart';

void main() {
  late Directory tempDir;
  late LocalStorage storage;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('mindful_breathing_test_');
    storage = LocalStorage();
    await storage.initForTesting(tempDir.path);
  });

  tearDown(() async {
    await storage.close();
    await Hive.deleteFromDisk();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  BreathingSession sessionOn(DateTime day, {bool completed = true, int minutes = 5}) {
    final start = DateTime(day.year, day.month, day.day, 9);
    return BreathingSession(
      startTime: start,
      endTime: start.add(Duration(minutes: minutes)),
      durationMinutes: minutes,
      completedCycles: 4,
      completed: completed,
    );
  }

  group('sessions', () {
    test('saveSession persists and getAllSessions reads it back', () async {
      final today = DateTime.now();
      await storage.saveSession(sessionOn(today));

      expect(storage.getAllSessions(), hasLength(1));
      expect(storage.getTotalSessionsCount(), 1);
    });

    test('getSessionsDescending orders newest first and respects limit', () async {
      final today = DateTime.now();
      await storage.saveSession(sessionOn(today.subtract(const Duration(days: 2))));
      await storage.saveSession(sessionOn(today));
      await storage.saveSession(sessionOn(today.subtract(const Duration(days: 1))));

      final sessions = storage.getSessionsDescending();
      expect(sessions, hasLength(3));
      expect(sessions.first.startTime.day, today.day);
      expect(sessions.last.startTime.day, today.subtract(const Duration(days: 2)).day);

      expect(storage.getSessionsDescending(limit: 2), hasLength(2));
    });

    test('updateLastSession attaches mood to the most recently saved session', () async {
      await storage.saveSession(sessionOn(DateTime.now()));
      await storage.updateLastSession((s) => s.copyWith(moodAfter: 'Calm'));

      expect(storage.getSessionsDescending().first.moodAfter, 'Calm');
    });

    test('clearSessions empties the history', () async {
      await storage.saveSession(sessionOn(DateTime.now()));
      await storage.clearSessions();

      expect(storage.getAllSessions(), isEmpty);
    });
  });

  group('getCurrentStreak', () {
    test('is zero with no sessions', () {
      expect(storage.getCurrentStreak(), 0);
    });

    test('counts consecutive completed days ending today', () async {
      final today = DateTime.now();
      await storage.saveSession(sessionOn(today));
      await storage.saveSession(sessionOn(today.subtract(const Duration(days: 1))));
      await storage.saveSession(sessionOn(today.subtract(const Duration(days: 2))));

      expect(storage.getCurrentStreak(), 3);
    });

    test('still counts if the most recent session was yesterday', () async {
      final today = DateTime.now();
      await storage.saveSession(sessionOn(today.subtract(const Duration(days: 1))));

      expect(storage.getCurrentStreak(), 1);
    });

    test('breaks on a gap before yesterday', () async {
      final today = DateTime.now();
      await storage.saveSession(sessionOn(today.subtract(const Duration(days: 3))));

      expect(storage.getCurrentStreak(), 0);
    });

    test('ignores incomplete sessions', () async {
      final today = DateTime.now();
      await storage.saveSession(sessionOn(today, completed: false));

      expect(storage.getCurrentStreak(), 0);
    });
  });

  group('getTotalDuration', () {
    test('sums only completed sessions', () async {
      final today = DateTime.now();
      await storage.saveSession(sessionOn(today, minutes: 5));
      await storage.saveSession(sessionOn(today, minutes: 10, completed: false));

      expect(storage.getTotalDuration(), const Duration(minutes: 5));
    });
  });

  group('getDailyMinutes', () {
    test('buckets completed session minutes by calendar day', () async {
      final today = DateTime.now();
      final startOfToday = DateTime(today.year, today.month, today.day);
      await storage.saveSession(sessionOn(today, minutes: 12));
      await storage.saveSession(sessionOn(today.subtract(const Duration(days: 1)), minutes: 8));

      final daily = storage.getDailyMinutes(7);
      expect(daily[startOfToday], 12);
      expect(daily[startOfToday.subtract(const Duration(days: 1))], 8);
      expect(daily, hasLength(7));
    });

    test('sessions outside the requested window are dropped', () async {
      final today = DateTime.now();
      await storage.saveSession(sessionOn(today.subtract(const Duration(days: 10)), minutes: 20));

      final daily = storage.getDailyMinutes(7);
      expect(daily.values.every((m) => m == 0), isTrue);
    });
  });

  group('settings', () {
    test('sound and vibration default to enabled', () {
      expect(storage.isSoundEnabled(), isTrue);
      expect(storage.isVibrationEnabled(), isTrue);
    });

    test('sound and vibration toggles persist', () async {
      await storage.setSoundEnabled(false);
      await storage.setVibrationEnabled(false);

      expect(storage.isSoundEnabled(), isFalse);
      expect(storage.isVibrationEnabled(), isFalse);
    });

    test('theme mode defaults to dark and persists changes', () async {
      expect(storage.getThemeMode(), isTrue);

      await storage.saveThemeMode(false);
      expect(storage.getThemeMode(), isFalse);
    });

    test('selected technique defaults to 4-7-8 and persists', () async {
      expect(storage.getSelectedTechniqueId(), '4-7-8');

      await storage.setSelectedTechniqueId('box-4x4');
      expect(storage.getSelectedTechniqueId(), 'box-4x4');
    });

    test('selected ambience defaults to forest and persists', () async {
      expect(storage.getSelectedAmbienceId(), 'forest');

      await storage.setSelectedAmbienceId('rain');
      expect(storage.getSelectedAmbienceId(), 'rain');
    });

    test('onboarding flag defaults to false and persists', () async {
      expect(storage.hasSeenOnboarding(), isFalse);

      await storage.setOnboardingSeen();
      expect(storage.hasSeenOnboarding(), isTrue);
    });

    test('stealth mode defaults to false and persists changes', () async {
      expect(storage.isStealthModeEnabled(), isFalse);

      await storage.setStealthModeEnabled(true);
      expect(storage.isStealthModeEnabled(), isTrue);

      await storage.setStealthModeEnabled(false);
      expect(storage.isStealthModeEnabled(), isFalse);
    });

    test('daily reminder defaults to false and persists changes', () async {
      expect(storage.isReminderEnabled(), isFalse);
      expect(storage.getReminderHour(), 20);
      expect(storage.getReminderMinute(), 0);

      await storage.setReminderEnabled(true);
      await storage.setReminderTime(7, 30);

      expect(storage.isReminderEnabled(), isTrue);
      expect(storage.getReminderHour(), 7);
      expect(storage.getReminderMinute(), 30);

      await storage.setReminderEnabled(false);
      expect(storage.isReminderEnabled(), isFalse);
    });
  });
}
