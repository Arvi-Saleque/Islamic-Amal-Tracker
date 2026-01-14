import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyReminderService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _reminderEnabledKey = 'daily_reminder_enabled';
  static const String _reminderHourKey = 'daily_reminder_hour';
  static const String _reminderMinuteKey = 'daily_reminder_minute';
  static const int _dailyReminderId = 1001;

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      // Default to UTC if timezone detection fails
      tz.setLocalLocation(tz.UTC);
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );
    
    // Create notification channel
    await _createNotificationChannel();
  }

  static Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'daily_reminder_channel',
      'দৈনিক আমল রিমাইন্ডার',
      description: 'দৈনিক আমল রিমাইন্ডার নোটিফিকেশন',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static void _onNotificationResponse(NotificationResponse response) {
    // Handle notification tap - can navigate to specific screen
    print('Notification tapped: ${response.payload}');
  }

  /// Show an immediate test notification
  static Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'daily_reminder_channel',
      'দৈনিক আমল রিমাইন্ডার',
      channelDescription: 'দৈনিক আমল রিমাইন্ডার নোটিফিকেশন',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const notificationDetails = NotificationDetails(android: androidDetails);
    
    await _notifications.show(
      0,
      '🕌 আমল রিমাইন্ডার',
      'আজকের আমলগুলো করতে ভুলবেন না!',
      notificationDetails,
    );
  }

  /// Schedule daily notification at specified time
  static Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    // Cancel any existing reminder first
    await cancelDailyReminder();

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'daily_reminder_channel',
      'দৈনিক আমল রিমাইন্ডার',
      channelDescription: 'দৈনিক আমল রিমাইন্ডার নোটিফিকেশন',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(
        'আজকের আমলগুলো সম্পন্ন করুন। আল্লাহ আমাদের সবাইকে আমল করার তৌফিক দান করুন।',
        contentTitle: '🕌 দৈনিক আমল রিমাইন্ডার',
      ),
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.zonedSchedule(
      _dailyReminderId,
      '🕌 দৈনিক আমল রিমাইন্ডার',
      'আজকের আমলগুলো সম্পন্ন করুন!',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
    );

    // Save settings
    await _saveReminderSettings(true, hour, minute);
    
    print('Daily reminder scheduled for $hour:$minute');
  }

  /// Cancel the daily reminder
  static Future<void> cancelDailyReminder() async {
    await _notifications.cancel(_dailyReminderId);
    await _saveReminderSettings(false, 0, 0);
    print('Daily reminder cancelled');
  }

  /// Save reminder settings to SharedPreferences
  static Future<void> _saveReminderSettings(bool enabled, int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reminderEnabledKey, enabled);
    await prefs.setInt(_reminderHourKey, hour);
    await prefs.setInt(_reminderMinuteKey, minute);
  }

  /// Get saved reminder settings
  static Future<Map<String, dynamic>> getReminderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'enabled': prefs.getBool(_reminderEnabledKey) ?? false,
      'hour': prefs.getInt(_reminderHourKey) ?? 8,
      'minute': prefs.getInt(_reminderMinuteKey) ?? 0,
    };
  }

  /// Reschedule reminder if it was enabled (call on app start)
  static Future<void> rescheduleReminderIfNeeded() async {
    final settings = await getReminderSettings();
    if (settings['enabled'] == true) {
      await scheduleDailyReminder(
        hour: settings['hour'],
        minute: settings['minute'],
      );
    }
  }

  /// Check if notifications are permitted
  static Future<bool> areNotificationsEnabled() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      return await androidPlugin.areNotificationsEnabled() ?? false;
    }
    return false;
  }

  /// Request notification permission (Android 13+)
  static Future<bool> requestNotificationPermission() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      return await androidPlugin.requestNotificationsPermission() ?? false;
    }
    return false;
  }
}
