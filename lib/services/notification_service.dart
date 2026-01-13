import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'dart:ui' show Color;
import 'dart:io' show Platform;
import 'dart:async';

// ================================
// Top-level callback functions (MUST be top-level for alarm manager)
// ================================

/// Show notification callback - fired by AlarmManager
@pragma('vm:entry-point')
Future<void> alarmCallback() async {
  print('🔔 Alarm callback fired!');
  
  // Initialize notifications
  final FlutterLocalNotificationsPlugin notifications = FlutterLocalNotificationsPlugin();
  
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const settings = InitializationSettings(android: androidSettings);
  await notifications.initialize(settings);
  
  // Show notification
  const android = AndroidNotificationDetails(
    'alarm_reminders',
    'Alarm Reminders',
    channelDescription: 'Reliable alarm-based reminders',
    importance: Importance.max,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
    color: Color(0xFFD4AF37),
    enableVibration: true,
    playSound: true,
    fullScreenIntent: true,
  );

  await notifications.show(
    999,
    '⏰ রিমাইন্ডার',
    'আপনার সময় হয়ে গেছে!',
    const NotificationDetails(android: android),
  );
  
  print('✅ Notification shown from alarm callback');
}

/// Prayer alarm callback - handles prayer notifications
/// Note: We use a generic message since AlarmManager doesn't pass parameters
@pragma('vm:entry-point')
Future<void> prayerAlarmCallback() async {
  print('🕌 Prayer alarm callback fired!');
  
  final FlutterLocalNotificationsPlugin notifications = FlutterLocalNotificationsPlugin();
  
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const settings = InitializationSettings(android: androidSettings);
  await notifications.initialize(settings);
  
  const android = AndroidNotificationDetails(
    'prayer_reminders',
    'নামাজের রিমাইন্ডার',
    channelDescription: 'ওয়াক্ত শেষ হওয়ার আগে রিমাইন্ডার',
    importance: Importance.max,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
    color: Color(0xFFD4AF37),
    enableVibration: true,
    playSound: true,
    fullScreenIntent: true,
  );

  await notifications.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000, // Unique ID
    '🕌 নামাজের সময়!',
    'ওয়াক্ত শেষ হয়ে যাচ্ছে! এখনো নামাজ না পড়ে থাকলে দ্রুত আদায় করুন।',
    const NotificationDetails(android: android),
  );
  
  print('✅ Prayer notification shown');
}

/// Dhikr alarm callback - handles morning/evening dhikr
@pragma('vm:entry-point')
Future<void> dhikrAlarmCallback() async {
  print('📿 Dhikr alarm callback fired!');
  
  final FlutterLocalNotificationsPlugin notifications = FlutterLocalNotificationsPlugin();
  
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const settings = InitializationSettings(android: androidSettings);
  await notifications.initialize(settings);
  
  // Check time to determine morning or evening
  final hour = DateTime.now().hour;
  final isMorning = hour < 12;
  final title = isMorning ? 'সকালের যিকির 🌅' : 'সন্ধ্যার যিকির 🌆';
  final body = isMorning 
      ? 'সকালের যিকির পড়ার সময় হয়েছে। আল্লাহর যিকির করুন।'
      : 'সন্ধ্যার যিকির পড়ার সময় হয়েছে। আল্লাহর যিকির করুন।';
  
  const android = AndroidNotificationDetails(
    'dhikr_reminders',
    'যিকির রিমাইন্ডার',
    channelDescription: 'দৈনিক যিকির রিমাইন্ডার',
    importance: Importance.max,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
    color: Color(0xFFD4AF37),
    enableVibration: true,
    playSound: true,
    fullScreenIntent: true,
  );

  await notifications.show(
    isMorning ? 10 : 11,
    title,
    body,
    const NotificationDetails(android: android),
  );
  
  print('✅ Dhikr notification shown');
}

/// Amal alarm callback - handles daily amal reminder
@pragma('vm:entry-point')
Future<void> amalAlarmCallback() async {
  print('✨ Amal alarm callback fired!');
  
  final FlutterLocalNotificationsPlugin notifications = FlutterLocalNotificationsPlugin();
  
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const settings = InitializationSettings(android: androidSettings);
  await notifications.initialize(settings);
  
  const android = AndroidNotificationDetails(
    'amal_reminders',
    'দৈনিক আমল রিমাইন্ডার',
    channelDescription: 'প্রতিদিনের আমল রিমাইন্ডার',
    importance: Importance.max,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
    color: Color(0xFFD4AF37),
    enableVibration: true,
    playSound: true,
    fullScreenIntent: true,
  );

  await notifications.show(
    20, // dailyAmalReminderId
    'দৈনিক আমল রিমাইন্ডার ✨',
    'আজকের আমলগুলো সম্পন্ন করুন। প্রতিদিনের ছোট ছোট আমল বড় সওয়াব এনে দেয়।',
    const NotificationDetails(android: android),
  );
  
  print('✅ Amal notification shown');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  
  // Timer map for timer-based notifications (works better on Chinese phones)
  final Map<int, Timer> _activeTimers = {};

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
    
    // Web doesn't support local notifications the same way
    if (kIsWeb) {
      _isInitialized = true;
      print('⚠️ Notifications not supported on web');
      return;
    }

    // Initialize timezone
    tz_data.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    print('🌍 Device timezone: $timeZoneName');
    tz.setLocalLocation(tz.getLocation(timeZoneName));
    print('🌍 TZ local location set to: ${tz.local.name}');

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
    if (kIsWeb) return true; // No permission needed on web
    
    try {
      // 1. Notification permission
      final notifStatus = await Permission.notification.request();
      print('🔔 Notification permission: ${notifStatus.isGranted}');
      
      if (notifStatus.isGranted) {
        // 2. Exact alarm permission for Android 12+
        final alarmStatus = await Permission.scheduleExactAlarm.request();
        print('⏰ Exact alarm permission: ${alarmStatus.isGranted}');
        
        // 3. Battery optimization - VERY IMPORTANT for Chinese phones!
        if (Platform.isAndroid) {
          final batteryStatus = await Permission.ignoreBatteryOptimizations.request();
          print('🔋 Battery optimization ignored: ${batteryStatus.isGranted}');
        }
        
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error requesting permissions: $e');
      return false;
    }
  }

  // Request battery optimization disable separately
  Future<bool> requestIgnoreBatteryOptimization() async {
    if (kIsWeb || !Platform.isAndroid) return true;
    
    try {
      final status = await Permission.ignoreBatteryOptimizations.status;
      if (!status.isGranted) {
        final result = await Permission.ignoreBatteryOptimizations.request();
        return result.isGranted;
      }
      return true;
    } catch (e) {
      print('❌ Error requesting battery optimization: $e');
      return false;
    }
  }

  // Check if all required permissions are granted
  Future<Map<String, bool>> checkAllPermissions() async {
    if (kIsWeb) {
      return {
        'notification': true,
        'exactAlarm': true,
        'batteryOptimization': true,
      };
    }
    
    final notificationStatus = await Permission.notification.status;
    final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
    final batteryStatus = Platform.isAndroid 
        ? await Permission.ignoreBatteryOptimizations.status
        : PermissionStatus.granted;
    
    return {
      'notification': notificationStatus.isGranted,
      'exactAlarm': exactAlarmStatus.isGranted,
      'batteryOptimization': batteryStatus.isGranted,
    };
  }

  // Request exact alarm permission specifically
  Future<bool> requestExactAlarmPermission() async {
    if (kIsWeb) return true;
    
    final status = await Permission.scheduleExactAlarm.request();
    return status.isGranted;
  }

  // Check if notifications can be scheduled (all permissions granted)
  Future<bool> canScheduleNotifications() async {
    final permissions = await checkAllPermissions();
    return permissions['notification'] == true && permissions['exactAlarm'] == true;
  }

  // Open app notification settings
  Future<void> openNotificationSettings() async {
    await openAppSettings();
  }

  // Schedule prayer reminder (before waqt ends)
  Future<void> schedulePrayerReminder({
    required int id,
    required String prayerName,
    required DateTime waqtEndTime,
    required int minutesBefore,
  }) async {
    if (kIsWeb) return; // Skip on web
    
    try {
      final scheduledTime = waqtEndTime.subtract(Duration(minutes: minutesBefore));
      final now = DateTime.now();
      
      print('🕌 Scheduling prayer reminder: $prayerName');
      print('   Waqt ends: $waqtEndTime');
      print('   Minutes before: $minutesBefore');
      print('   Scheduled time: $scheduledTime');
      print('   Current time: $now');
      
      // Don't schedule if time has passed
      if (scheduledTime.isBefore(now)) {
        print('   ⏭️ Skipped - time already passed');
        return;
      }

      // Use AlarmManager on Android for reliability
      if (Platform.isAndroid) {
        await AndroidAlarmManager.oneShotAt(
          scheduledTime,
          id,
          prayerAlarmCallback,
          exact: true,
          wakeup: true,
          rescheduleOnReboot: true,
        );
        print('   ✅ Prayer alarm scheduled with AlarmManager!');
      } else {
        // iOS fallback - use zonedSchedule
        final String timeZoneName = await FlutterTimezone.getLocalTimezone();
        final location = tz.getLocation(timeZoneName);
        final tzScheduledTime = tz.TZDateTime.from(scheduledTime, location);
        
        await _notifications.zonedSchedule(
          id,
          '$prayerName এর ওয়াক্ত শেষ হয়ে যাচ্ছে! 🕌',
          '$prayerName এর ওয়াক্ত শেষ হতে আর $minutesBefore মিনিট বাকি',
          tzScheduledTime,
          NotificationDetails(
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
        print('   ✅ Prayer reminder scheduled for iOS!');
      }
    } catch (e) {
      print('   ❌ Error scheduling prayer reminder: $e');
    }
  }

  // Schedule all prayer reminders for the day (before waqt ends)
  Future<void> scheduleAllPrayerReminders({
    required Map<String, DateTime> prayerTimes,
    required Map<String, DateTime> waqtEndTimes,
    required int minutesBefore,
  }) async {
    if (kIsWeb) return; // Skip on web
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
      final waqtEnd = waqtEndTimes[entry.key];
      if (id != null && name != null && waqtEnd != null) {
        await schedulePrayerReminder(
          id: id,
          prayerName: name,
          waqtEndTime: waqtEnd,
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
    if (kIsWeb) return; // Skip on web
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
    if (kIsWeb) return; // Skip on web
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
    if (kIsWeb) return; // Skip on web
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

    print('📅 Scheduling daily reminder: $title');
    print('   Scheduled for: $scheduledDate');
    print('   ID: $id');

    // Use AlarmManager on Android for reliability
    if (Platform.isAndroid) {
      // Determine which callback to use based on channel ID
      final callback = channelId == dhikrChannelId 
          ? dhikrAlarmCallback 
          : amalAlarmCallback;
      
      await AndroidAlarmManager.oneShotAt(
        scheduledDate,
        id,
        callback,
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
      );
      print('   ✅ Alarm scheduled with AlarmManager!');
    } else {
      // iOS fallback - use zonedSchedule
      final tzScheduledTime = tz.TZDateTime.from(scheduledDate, tz.local);
      
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tzScheduledTime,
        NotificationDetails(
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
      print('   ✅ Reminder scheduled for iOS!');
    }
  }

  // Cancel specific notification
  Future<void> cancelNotification(int id) async {
    if (kIsWeb) return; // Skip on web
    
    // Cancel local notification
    await _notifications.cancel(id);
    
    // Also cancel alarm if Android
    if (Platform.isAndroid) {
      try {
        await AndroidAlarmManager.cancel(id);
        print('✅ Cancelled alarm $id');
      } catch (e) {
        print('⚠️ Could not cancel alarm $id: $e');
      }
    }
  }

  // Cancel all prayer notifications
  Future<void> cancelAllPrayerNotifications() async {
    if (kIsWeb) return; // Skip on web
    await _notifications.cancel(fajrNotificationId);
    await _notifications.cancel(dhuhrNotificationId);
    await _notifications.cancel(asrNotificationId);
    await _notifications.cancel(maghribNotificationId);
    await _notifications.cancel(ishaNotificationId);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    if (kIsWeb) return; // Skip on web
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

  // Schedule custom reminder using AndroidAlarmManager (more reliable)
  Future<void> scheduleCustomReminderWithAlarm({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required int dayOfWeek, // 0=Sunday, 1=Monday, ..., 6=Saturday
  }) async {
    if (kIsWeb || !Platform.isAndroid) {
      // Fallback to local notifications for iOS/Web
      return scheduleCustomReminder(
        id: id,
        title: title,
        body: body,
        hour: hour,
        minute: minute,
        dayOfWeek: dayOfWeek,
      );
    }
    
    try {
      // Calculate the next occurrence
      final now = DateTime.now();
      var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
      
      // Convert dayOfWeek (0=Sun, 6=Sat) to Dart weekday (1=Mon, 7=Sun)
      final targetDartWeekday = dayOfWeek == 0 ? 7 : dayOfWeek;
      
      // If time has passed today, start from tomorrow
      if (scheduledDate.isBefore(now) || scheduledDate.isAtSameMomentAs(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
      
      // Find next occurrence of target weekday
      while (scheduledDate.weekday != targetDartWeekday) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      print('🚨 Scheduling ALARM-based reminder: $title');
      print('   Time: $hour:$minute on day $dayOfWeek');
      print('   Next occurrence: $scheduledDate');
      print('   Alarm ID: $id');

      // Schedule using AndroidAlarmManager for reliability
      await AndroidAlarmManager.oneShotAt(
        scheduledDate,
        id,
        alarmCallback,
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
      );
      
      print('✅ Alarm scheduled successfully!');
    } catch (e) {
      print('❌ Error scheduling alarm: $e');
      // Fallback to regular notification
      await scheduleCustomReminder(
        id: id,
        title: title,
        body: body,
        hour: hour,
        minute: minute,
        dayOfWeek: dayOfWeek,
      );
    }
  }

  // Schedule custom reminder (existing method - now uses alarm manager)
  Future<void> scheduleCustomReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required int dayOfWeek, // 0=Sunday, 1=Monday, ..., 6=Saturday (same as UI)
  }) async {
    if (kIsWeb) return; // Skip on web
    
    try {
      // Ensure timezone is initialized
      if (!_isInitialized) {
        await initialize();
      }
      
      // Always ensure timezone is set correctly (may reset after hot reload)
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      final location = tz.getLocation(timeZoneName);
      
      final now = tz.TZDateTime.now(location);
      
      // Convert dayOfWeek (0=Sun, 6=Sat) to Dart weekday (1=Mon, 7=Sun)
      final targetDartWeekday = dayOfWeek == 0 ? 7 : dayOfWeek;
      
      // Start from today with the specified time in local timezone
      var scheduledDate = tz.TZDateTime(location, now.year, now.month, now.day, hour, minute);
      
      // If this time today has passed, start checking from tomorrow
      if (scheduledDate.isBefore(now) || scheduledDate.isAtSameMomentAs(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
      
      // Find the next occurrence of target day
      while (scheduledDate.weekday != targetDartWeekday) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      print('📅 Scheduling custom reminder: $title');
      print('   Timezone: ${location.name}');
      print('   Now (local): ${now.toString()} (${now.timeZoneName})');
      print('   Target day: $dayOfWeek (Dart weekday: $targetDartWeekday, today is: ${now.weekday})');
      print('   Scheduled for (local): ${scheduledDate.toString()} (${scheduledDate.timeZoneName})');
      print('   Notification ID: $id');

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            amalChannelId,
            'কাস্টম রিমাইন্ডার',
            channelDescription: 'কাস্টম রিমাইন্ডার নোটিফিকেশন',
            importance: Importance.max,
            priority: Priority.max,
            icon: '@mipmap/ic_launcher',
            color: const Color(0xFFD4AF37),
            enableVibration: true,
            playSound: true,
            fullScreenIntent: true,
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
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
      print('✅ Custom reminder scheduled successfully!');
    } catch (e) {
      print('❌ Error scheduling custom reminder: $e');
    }
  }
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            color: const Color(0xFFD4AF37),
            enableVibration: true,
            playSound: true,
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
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
      print('✅ Custom reminder scheduled successfully!');
    } catch (e) {
      print('❌ Error scheduling custom reminder: $e');
    }
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (kIsWeb) return []; // Return empty on web
    return await _notifications.pendingNotificationRequests();
  }

  // Test notification - fires immediately
  Future<void> showTestNotification({
    required String title,
    required String body,
  }) async {
    if (kIsWeb) return;
    
    await _notifications.show(
      99999, // Test ID
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          amalChannelId,
          'টেস্ট নোটিফিকেশন',
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFFD4AF37),
          playSound: true,
          enableVibration: true,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
    print('✅ Test notification sent!');
  }

  // Schedule test notification for X seconds later
  Future<void> scheduleTestNotification({
    required int seconds,
    required String title,
    required String body,
  }) async {
    if (kIsWeb) return;
    
    final scheduledTime = tz.TZDateTime.now(tz.local).add(Duration(seconds: seconds));
    
    print('⏰ Scheduling test notification for: $scheduledTime');
    
    await _notifications.zonedSchedule(
      99998, // Test ID
      title,
      body,
      scheduledTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          amalChannelId,
          'টেস্ট নোটিফিকেশন',
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFFD4AF37),
          fullScreenIntent: true,
          playSound: true,
          enableVibration: true,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
    print('✅ Test notification scheduled for $seconds seconds later');
  }

  // 🆕 Timer-based notification - Works better on Chinese phones (OnePlus/Xiaomi/Samsung)!
  Future<void> scheduleTimerNotification({
    required int seconds,
    String? title,
    String? body,
  }) async {
    if (kIsWeb) return;
    
    print('🕐 Timer started for $seconds seconds...');
    
    // Cancel existing timer with same ID if any
    _activeTimers[99997]?.cancel();
    
    _activeTimers[99997] = Timer(Duration(seconds: seconds), () async {
      await _notifications.show(
        99997,
        title ?? '⏰ Timer Test',
        body ?? 'This notification was scheduled $seconds seconds ago using Timer!',
        NotificationDetails(
          android: AndroidNotificationDetails(
            amalChannelId,
            'Timer Notification',
            importance: Importance.max,
            priority: Priority.max,
            icon: '@mipmap/ic_launcher',
            color: const Color(0xFFD4AF37),
            fullScreenIntent: true,
            playSound: true,
            enableVibration: true,
          ),
        ),
      );
      print('✅ Timer notification shown!');
      _activeTimers.remove(99997);
    });
    
    print('✅ Timer scheduled successfully!');
  }

  // 🆕 AlarmManager test - Works even when app is killed!
  Future<void> scheduleAlarmManagerTest({int seconds = 10}) async {
    if (kIsWeb || !Platform.isAndroid) {
      print('AlarmManager only works on Android');
      return;
    }
    
    print('🔔 AlarmManager test starting...');
    
    try {
      final alarmTime = DateTime.now().add(Duration(seconds: seconds));
      
      await AndroidAlarmManager.oneShot(
        Duration(seconds: seconds),
        8888, // Unique ID
        alarmCallback,
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
      );
      
      print('✅ AlarmManager scheduled for $alarmTime');
    } catch (e) {
      print('❌ AlarmManager error: $e');
    }
  }
}
