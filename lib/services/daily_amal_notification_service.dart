import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

class DailyAmalNotificationService {
  static final DailyAmalNotificationService _instance = DailyAmalNotificationService._internal();
  factory DailyAmalNotificationService() => _instance;
  DailyAmalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _reminderEnabledKey = 'daily_amal_reminder_enabled';
  static const String _reminderTimeKey = 'daily_amal_reminder_time';
  static const int _notificationId = 999;

  // Initialize notification service
  Future<void> initialize() async {
    // Initialize timezone database
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Dhaka'));

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combined initialization settings
    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize plugin
    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('Notification tapped: ${response.payload}');
        // Handle notification tap here - could navigate to daily amal screen
      },
    );

    // Create notification channel for Android
    await _createNotificationChannel();
  }

  // Create Android notification channel
  Future<void> _createNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      'daily_amal_reminder',
      'দৈনিক আমল রিমাইন্ডার',
      description: 'প্রতিদিনের আমল সম্পন্ন করার জন্য রিমাইন্ডার',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  // Schedule daily reminder at specific time
  Future<void> scheduleDailyReminder(int hour, int minute) async {
    // Save settings
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reminderEnabledKey, true);
    await prefs.setString(_reminderTimeKey, '$hour:$minute');

    // Cancel any existing notification
    await _notifications.cancel(_notificationId);

    // Schedule new notification
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
    
    // If the time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'daily_amal_reminder',
      'দৈনিক আমল রিমাইন্ডার',
      channelDescription: 'প্রতিদিনের আমল সম্পন্ন করার জন্য রিমাইন্ডার',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    // Convert DateTime to TZDateTime
    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    // Schedule daily notification
    await _notifications.zonedSchedule(
      _notificationId,
      'আমল সম্পন্ন করার সময়',
      'আজকের আমল সম্পন্ন করুন এবং আল্লাহর নৈকট্য লাভ করুন',
      tzScheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily at same time
    );

    print('✅ Daily reminder scheduled for: ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}');
  }

  // Cancel daily reminder
  Future<void> cancelDailyReminder() async {
    // Save settings
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reminderEnabledKey, false);
    
    // Cancel notification
    await _notifications.cancel(_notificationId);
    print('❌ Daily reminder cancelled');
  }

  // Check if reminder is enabled
  Future<bool> isReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_reminderEnabledKey) ?? false;
  }

  // Get saved reminder time
  Future<String?> getReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_reminderTimeKey);
  }

  // Send test notification immediately
  Future<void> sendTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'daily_amal_reminder',
      'দৈনিক আমল রিমাইন্ডার',
      channelDescription: 'প্রতিদিনের আমল সম্পন্ন করার জন্য রিমাইন্ডার',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(
      0,
      'টেস্ট নোটিফিকেশন',
      'আপনার নোটিফিকেশন সিস্টেম সঠিকভাবে কাজ করছে!',
      notificationDetails,
    );
  }
}
