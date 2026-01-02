import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:ui' show Color;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // Notification Channel IDs
  static const String prayerChannelId = 'prayer_reminders';
  static const String amalChannelId = 'amal_reminders';
  static const String dhikrChannelId = 'dhikr_reminders';

  // Notification IDs
  static const int fajrNotificationId = 1;
  static const int dhuhrNotificationId = 2;
  static const int asrNotificationId = 3;
  static const int maghribNotificationId = 4;
  static const int ishaNotificationId = 5;
  static const int morningDhikrId = 10;
  static const int eveningDhikrId = 11;
  static const int dailyAmalReminderId = 20;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz_data.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    // Android settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings
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

    // Create notification channels
    await _createNotificationChannels();

    _isInitialized = true;
  }

  Future<void> _createNotificationChannels() async {
    final androidPlugin =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      // Prayer channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          prayerChannelId,
          'নামাজের রিমাইন্ডার',
          description: 'নামাজের সময়ের আগে রিমাইন্ডার',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );

      // Amal channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          amalChannelId,
          'দৈনিক আমল রিমাইন্ডার',
          description: 'দৈনিক আমল সম্পন্ন করার রিমাইন্ডার',
          importance: Importance.defaultImportance,
          playSound: true,
        ),
      );

      // Dhikr channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          dhikrChannelId,
          'যিকির রিমাইন্ডার',
          description: 'সকাল-সন্ধ্যার যিকিরের রিমাইন্ডার',
          importance: Importance.high,
          playSound: true,
        ),
      );
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    // Can navigate to specific screen based on payload
  }

  Future<bool> requestPermissions() async {
    final status = await Permission.notification.request();
    if (status.isGranted) {
      // Also request exact alarm permission for Android 12+
      await Permission.scheduleExactAlarm.request();
      return true;
    }
    return false;
  }

  // Schedule prayer reminder
  Future<void> schedulePrayerReminder({
    required int id,
    required String prayerName,
    required DateTime prayerTime,
    required int minutesBefore,
  }) async {
    final scheduledTime = prayerTime.subtract(Duration(minutes: minutesBefore));
    
    // Don't schedule if time has passed
    if (scheduledTime.isBefore(DateTime.now())) return;

    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

    await _notifications.zonedSchedule(
      id,
      'নামাজের সময় হয়ে আসছে 🕌',
      '$prayerName এর সময় $minutesBefore মিনিট পরে',
      tzScheduledTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          prayerChannelId,
          'নামাজের রিমাইন্ডার',
          channelDescription: 'নামাজের সময়ের আগে রিমাইন্ডার',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFFD4AF37),
          styleInformation: BigTextStyleInformation(
            '$prayerName এর সময় আর মাত্র $minutesBefore মিনিট বাকি। নামাজের জন্য প্রস্তুত হোন।',
          ),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'prayer_$prayerName',
    );
  }

  // Schedule all prayer reminders for the day
  Future<void> scheduleAllPrayerReminders({
    required Map<String, DateTime> prayerTimes,
    required int minutesBefore,
  }) async {
    final prayerIds = {
      'fajr': fajrNotificationId,
      'dhuhr': dhuhrNotificationId,
      'asr': asrNotificationId,
      'maghrib': maghribNotificationId,
      'isha': ishaNotificationId,
    };

    final prayerNames = {
      'fajr': 'ফজর',
      'dhuhr': 'যোহর',
      'asr': 'আসর',
      'maghrib': 'মাগরিব',
      'isha': 'এশা',
    };

    for (final entry in prayerTimes.entries) {
      final id = prayerIds[entry.key];
      final name = prayerNames[entry.key];
      if (id != null && name != null) {
        await schedulePrayerReminder(
          id: id,
          prayerName: name,
          prayerTime: entry.value,
          minutesBefore: minutesBefore,
        );
      }
    }
  }

  // Schedule morning dhikr reminder
  Future<void> scheduleMorningDhikrReminder({
    required int hour,
    required int minute,
  }) async {
    await _scheduleDailyReminder(
      id: morningDhikrId,
      title: 'সকালের যিকির 🌅',
      body: 'সকালের যিকির পড়ার সময় হয়েছে। আল্লাহর যিকির করুন।',
      hour: hour,
      minute: minute,
      channelId: dhikrChannelId,
      payload: 'dhikr_morning',
    );
  }

  // Schedule evening dhikr reminder
  Future<void> scheduleEveningDhikrReminder({
    required int hour,
    required int minute,
  }) async {
    await _scheduleDailyReminder(
      id: eveningDhikrId,
      title: 'সন্ধ্যার যিকির 🌆',
      body: 'সন্ধ্যার যিকির পড়ার সময় হয়েছে। আল্লাহর যিকির করুন।',
      hour: hour,
      minute: minute,
      channelId: dhikrChannelId,
      payload: 'dhikr_evening',
    );
  }

  // Schedule daily amal reminder
  Future<void> scheduleDailyAmalReminder({
    required int hour,
    required int minute,
  }) async {
    await _scheduleDailyReminder(
      id: dailyAmalReminderId,
      title: 'দৈনিক আমল রিমাইন্ডার ✨',
      body: 'আজকের আমলগুলো সম্পন্ন করুন। প্রতিদিনের ছোট ছোট আমল বড় সওয়াব এনে দেয়।',
      hour: hour,
      minute: minute,
      channelId: amalChannelId,
      payload: 'amal_daily',
    );
  }

  Future<void> _scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required String channelId,
    required String payload,
  }) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
    
    // If time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final tzScheduledTime = tz.TZDateTime.from(scheduledDate, tz.local);

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tzScheduledTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId == dhikrChannelId ? 'যিকির রিমাইন্ডার' : 'দৈনিক আমল রিমাইন্ডার',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFFD4AF37),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
      payload: payload,
    );
  }

  // Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Cancel all prayer notifications
  Future<void> cancelAllPrayerNotifications() async {
    await _notifications.cancel(fajrNotificationId);
    await _notifications.cancel(dhuhrNotificationId);
    await _notifications.cancel(asrNotificationId);
    await _notifications.cancel(maghribNotificationId);
    await _notifications.cancel(ishaNotificationId);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Show instant notification (for testing)
  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    await _notifications.show(
      0,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          amalChannelId,
          'টেস্ট নোটিফিকেশন',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFFD4AF37),
        ),
      ),
    );
  }

  // Schedule custom reminder
  Future<void> scheduleCustomReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required int dayOfWeek, // 0=Sunday, 1=Monday, ..., 6=Saturday
  }) async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

      // If the time has already passed today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      // Adjust to the correct day of week
      while (scheduledDate.weekday % 7 != dayOfWeek) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            amalChannelId,
            'কাস্টম রিমাইন্ডার',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            color: const Color(0xFFD4AF37),
            enableVibration: true,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    } catch (e) {
      print('Error scheduling custom reminder: $e');
    }
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
