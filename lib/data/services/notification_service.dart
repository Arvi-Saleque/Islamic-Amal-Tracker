import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../core/constants/app_constants.dart';
import '../models/prayer_record.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  
  static bool _initialized = false;
  
  // Initialize notification service
  static Future<void> initialize() async {
    if (_initialized) return;
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    _initialized = true;
  }
  
  static void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    // TODO: Navigate to specific screen based on payload
  }
  
  // Schedule prayer notification
  static Future<void> schedulePrayerNotification({
    required PrayerType prayerType,
    required DateTime prayerTime,
    required int minutesBefore,
  }) async {
    await initialize();
    
    final notificationTime = prayerTime.subtract(Duration(minutes: minutesBefore));
    final now = DateTime.now();
    
    // Don't schedule if time has passed
    if (notificationTime.isBefore(now)) return;
    
    final prayerName = _getPrayerNameBangla(prayerType);
    final notificationId = _getPrayerNotificationId(prayerType);
    
    final androidDetails = AndroidNotificationDetails(
      'prayer_notifications',
      'নামাজের নোটিফিকেশন',
      channelDescription: 'নামাজের সময়ের জন্য নোটিফিকেশন',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    final tzDateTime = tz.TZDateTime.from(notificationTime, tz.local);
    
    await _notifications.zonedSchedule(
      notificationId,
      '$prayerName নামাজের সময়',
      '$minutesBefore মিনিট পরে $prayerName নামাজের সময় হবে',
      tzDateTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'prayer_${prayerType.name}',
    );
  }
  
  // Schedule all daily prayer notifications
  static Future<void> scheduleAllPrayerNotifications({
    required Map<PrayerType, DateTime> prayerTimes,
    required int minutesBefore,
  }) async {
    // Cancel existing prayer notifications
    await cancelAllPrayerNotifications();
    
    // Schedule new ones
    for (final entry in prayerTimes.entries) {
      await schedulePrayerNotification(
        prayerType: entry.key,
        prayerTime: entry.value,
        minutesBefore: minutesBefore,
      );
    }
  }
  
  // Schedule custom reminder
  static Future<void> scheduleCustomReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    RepeatInterval? repeatInterval,
  }) async {
    await initialize();
    
    final androidDetails = AndroidNotificationDetails(
      'custom_reminders',
      'কাস্টম রিমাইন্ডার',
      channelDescription: 'ব্যবহারকারীর নির্ধারিত রিমাইন্ডার',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    final tzDateTime = tz.TZDateTime.from(scheduledTime, tz.local);
    
    if (repeatInterval != null) {
      await _notifications.periodicallyShow(
        id,
        title,
        body,
        repeatInterval,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'custom_$id',
      );
    } else {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tzDateTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'custom_$id',
      );
    }
  }
  
  // Cancel all prayer notifications
  static Future<void> cancelAllPrayerNotifications() async {
    await _notifications.cancel(AppConstants.fajrNotificationId);
    await _notifications.cancel(AppConstants.dhuhrNotificationId);
    await _notifications.cancel(AppConstants.asrNotificationId);
    await _notifications.cancel(AppConstants.maghribNotificationId);
    await _notifications.cancel(AppConstants.ishaNotificationId);
  }
  
  // Cancel specific notification
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }
  
  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
  
  // Helper methods
  static int _getPrayerNotificationId(PrayerType type) {
    switch (type) {
      case PrayerType.fajr:
        return AppConstants.fajrNotificationId;
      case PrayerType.dhuhr:
        return AppConstants.dhuhrNotificationId;
      case PrayerType.asr:
        return AppConstants.asrNotificationId;
      case PrayerType.maghrib:
        return AppConstants.maghribNotificationId;
      case PrayerType.isha:
        return AppConstants.ishaNotificationId;
    }
  }
  
  static String _getPrayerNameBangla(PrayerType type) {
    switch (type) {
      case PrayerType.fajr:
        return 'ফজর';
      case PrayerType.dhuhr:
        return 'যোহর';
      case PrayerType.asr:
        return 'আসর';
      case PrayerType.maghrib:
        return 'মাগরিব';
      case PrayerType.isha:
        return 'এশা';
    }
  }
}
