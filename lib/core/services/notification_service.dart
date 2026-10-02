import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// 100% On-device, offline daily reminder notification service.
///
/// Schedules local notifications using the device's internal clock and OS
/// alarm manager. Never sends push tokens, never connects to external servers.
class NotificationService {
  static const int dailyReminderId = 1001;
  static const String channelId = 'mindful_daily_reminders';
  static const String channelName = 'Daily Practice Reminders';
  static const String channelDescription = 'Gentle daily reminders to pause and practice mindful breathing.';

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Initialize local notifications and timezones
  Future<void> init() async {
    if (_initialized) return;

    try {
      tz_data.initializeTimeZones();

      const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      await _plugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification tapped: ${response.payload}');
        },
      );

      _initialized = true;
    } catch (e) {
      debugPrint('NotificationService init error (safe to ignore in test/desktop): $e');
    }
  }

  /// Request notification permissions on Android 13+ and iOS/macOS
  Future<bool> requestPermissions() async {
    try {
      final androidImplementation =
          _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        final granted = await androidImplementation.requestNotificationsPermission();
        return granted ?? false;
      }

      final iosImplementation =
          _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      if (iosImplementation != null) {
        final granted = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }

      final macImplementation =
          _plugin.resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>();
      if (macImplementation != null) {
        final granted = await macImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }

      return true;
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
      return false;
    }
  }

  /// Schedule a recurring daily reminder at [hour] and [minute] (24-hour clock).
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    try {
      if (!_initialized) await init();

      final scheduledDate = _nextInstanceOfTime(hour, minute);

      const androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/launcher_icon',
      );

      const darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
        macOS: darwinDetails,
      );

      await _plugin.zonedSchedule(
        id: dailyReminderId,
        title: 'Time to breathe',
        body: 'Take a 3-minute pause to reset your nervous system and find your calm.',
        scheduledDate: scheduledDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      debugPrint('Daily reminder successfully scheduled for $hour:${minute.toString().padLeft(2, '0')} (Next: $scheduledDate)');
    } catch (e) {
      debugPrint('Error scheduling daily reminder: $e');
    }
  }

  /// Cancel the scheduled daily practice reminder
  Future<void> cancelDailyReminder() async {
    try {
      await _plugin.cancel(id: dailyReminderId);
      debugPrint('Daily practice reminder cancelled');
    } catch (e) {
      debugPrint('Error cancelling daily reminder: $e');
    }
  }

  /// Helper to calculate the next TZDateTime occurrence of [hour]:[minute].
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
