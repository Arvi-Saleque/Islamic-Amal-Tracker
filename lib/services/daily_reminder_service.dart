import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/custom_reminder.dart';

class DailyReminderService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Keys for SharedPreferences
  static const String _reminderEnabledKey = 'daily_reminder_enabled';
  static const String _reminderHourKey = 'daily_reminder_hour';
  static const String _reminderMinuteKey = 'daily_reminder_minute';

  // Dhikr keys
  static const String _morningDhikrEnabledKey = 'morning_dhikr_enabled';
  static const String _morningDhikrHourKey = 'morning_dhikr_hour';
  static const String _morningDhikrMinuteKey = 'morning_dhikr_minute';
  static const String _eveningDhikrEnabledKey = 'evening_dhikr_enabled';
  static const String _eveningDhikrHourKey = 'evening_dhikr_hour';
  static const String _eveningDhikrMinuteKey = 'evening_dhikr_minute';

  // Prayer reminder keys
  static const String _prayerReminderPrefix = 'prayer_reminder_';

  // Custom reminders key
  static const String _customRemindersKey = 'custom_reminders';

  // Notification IDs
  static const int _dailyReminderId = 1001;
  static const int _morningDhikrId = 1002;
  static const int _eveningDhikrId = 1003;
  static const int _fajrReminderId = 2001;
  static const int _dhuhrReminderId = 2002;
  static const int _asrReminderId = 2003;
  static const int _maghribReminderId = 2004;
  static const int _ishaReminderId = 2005;
  static const int _customReminderBaseId = 3000;

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      // Default to UTC if timezone detection fails
      tz.setLocalLocation(tz.UTC);
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Create notification channel
    await _createNotificationChannel();
  }

  static Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel dailyChannel = AndroidNotificationChannel(
      'daily_reminder_channel',
      'দৈনিক আমল রিমাইন্ডার',
      description: 'দৈনিক আমল রিমাইন্ডার নোটিফিকেশন',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    const AndroidNotificationChannel dhikrChannel = AndroidNotificationChannel(
      'dhikr_reminder_channel',
      'যিকির রিমাইন্ডার',
      description: 'সকাল-সন্ধ্যা যিকির রিমাইন্ডার',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    const AndroidNotificationChannel prayerChannel = AndroidNotificationChannel(
      'prayer_reminder_channel',
      'নামাজের রিমাইন্ডার',
      description: 'নামাজের সময় রিমাইন্ডার',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    const AndroidNotificationChannel customChannel = AndroidNotificationChannel(
      'custom_reminder_channel',
      'কাস্টম রিমাইন্ডার',
      description: 'কাস্টম রিমাইন্ডার নোটিফিকেশন',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(dailyChannel);
    await androidPlugin?.createNotificationChannel(dhikrChannel);
    await androidPlugin?.createNotificationChannel(prayerChannel);
    await androidPlugin?.createNotificationChannel(customChannel);
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
        'প্রতিদিনের নির্ধারিত আমলসমূহ সম্পন্ন না করলে সম্পন্ন করুন।',
        contentTitle: '📋 দৈনিক আমল রিমাইন্ডার',
      ),
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.zonedSchedule(
      _dailyReminderId,
      '📋 দৈনিক আমল রিমাইন্ডার',
      'প্রতিদিনের নির্ধারিত আমলসমূহ সম্পন্ন না করলে সম্পন্ন করুন।',
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
  static Future<void> _saveReminderSettings(
      bool enabled, int hour, int minute) async {
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
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      return await androidPlugin.areNotificationsEnabled() ?? false;
    }
    return false;
  }

  /// Request notification permission (Android 13+)
  static Future<bool> requestNotificationPermission() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      return await androidPlugin.requestNotificationsPermission() ?? false;
    }
    return false;
  }

  // ============ DHIKR REMINDERS ============

  /// Schedule morning dhikr reminder
  static Future<void> scheduleMorningDhikrReminder({
    required int hour,
    required int minute,
  }) async {
    await cancelMorningDhikrReminder();

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

    const androidDetails = AndroidNotificationDetails(
      'dhikr_reminder_channel',
      'যিকির রিমাইন্ডার',
      channelDescription: 'সকাল-সন্ধ্যা যিকির রিমাইন্ডার',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(
        'সকালের যিকিরের সময় হয়েছে। প্রতিদিনের আমল থেকে সকালের আযকার সম্পন্ন করুন।',
        contentTitle: '☀️ সকালের যিকির',
      ),
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.zonedSchedule(
      _morningDhikrId,
      '☀️ সকালের যিকির',
      'সকালের যিকিরের সময় হয়েছে। প্রতিদিনের আমল থেকে সকালের আযকার সম্পন্ন করুন।',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_morningDhikrEnabledKey, true);
    await prefs.setInt(_morningDhikrHourKey, hour);
    await prefs.setInt(_morningDhikrMinuteKey, minute);

    print('Morning dhikr reminder scheduled for $hour:$minute');
  }

  /// Cancel morning dhikr reminder
  static Future<void> cancelMorningDhikrReminder() async {
    await _notifications.cancel(_morningDhikrId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_morningDhikrEnabledKey, false);
    print('Morning dhikr reminder cancelled');
  }

  /// Schedule evening dhikr reminder
  static Future<void> scheduleEveningDhikrReminder({
    required int hour,
    required int minute,
  }) async {
    await cancelEveningDhikrReminder();

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

    const androidDetails = AndroidNotificationDetails(
      'dhikr_reminder_channel',
      'যিকির রিমাইন্ডার',
      channelDescription: 'সকাল-সন্ধ্যা যিকির রিমাইন্ডার',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(
        'সন্ধ্যার যিকিরের সময় হয়েছে। প্রতিদিনের আমল থেকে সন্ধ্যার আযকার সম্পন্ন করুন।',
        contentTitle: '🌆 সন্ধ্যার যিকির',
      ),
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.zonedSchedule(
      _eveningDhikrId,
      '🌆 সন্ধ্যার যিকির',
      'সন্ধ্যার যিকিরের সময় হয়েছে। প্রতিদিনের আমল থেকে সন্ধ্যার আযকার সম্পন্ন করুন।',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_eveningDhikrEnabledKey, true);
    await prefs.setInt(_eveningDhikrHourKey, hour);
    await prefs.setInt(_eveningDhikrMinuteKey, minute);

    print('Evening dhikr reminder scheduled for $hour:$minute');
  }

  /// Cancel evening dhikr reminder
  static Future<void> cancelEveningDhikrReminder() async {
    await _notifications.cancel(_eveningDhikrId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_eveningDhikrEnabledKey, false);
    print('Evening dhikr reminder cancelled');
  }

  /// Get dhikr reminder settings
  static Future<Map<String, dynamic>> getDhikrReminderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'morningEnabled': prefs.getBool(_morningDhikrEnabledKey) ?? false,
      'morningHour': prefs.getInt(_morningDhikrHourKey) ?? 6,
      'morningMinute': prefs.getInt(_morningDhikrMinuteKey) ?? 0,
      'eveningEnabled': prefs.getBool(_eveningDhikrEnabledKey) ?? false,
      'eveningHour': prefs.getInt(_eveningDhikrHourKey) ?? 18,
      'eveningMinute': prefs.getInt(_eveningDhikrMinuteKey) ?? 0,
    };
  }

  // ============ PRAYER REMINDERS ============

  static int _getPrayerNotificationId(PrayerName prayer) {
    switch (prayer) {
      case PrayerName.fajr:
        return _fajrReminderId;
      case PrayerName.dhuhr:
        return _dhuhrReminderId;
      case PrayerName.asr:
        return _asrReminderId;
      case PrayerName.maghrib:
        return _maghribReminderId;
      case PrayerName.isha:
        return _ishaReminderId;
    }
  }

  static String _getPrayerEmoji(PrayerName prayer) {
    switch (prayer) {
      case PrayerName.fajr:
        return '🌅';
      case PrayerName.dhuhr:
        return '☀️';
      case PrayerName.asr:
        return '🌤️';
      case PrayerName.maghrib:
        return '🌆';
      case PrayerName.isha:
        return '🌙';
    }
  }

  /// Schedule prayer reminder
  static Future<void> schedulePrayerReminder({
    required PrayerName prayer,
    required DateTime prayerTime,
    required int minutesBefore,
  }) async {
    await cancelPrayerReminder(prayer);

    final reminderTime = prayerTime.subtract(Duration(minutes: minutesBefore));
    final now = DateTime.now();

    // If time has passed, schedule for tomorrow
    var scheduledDateTime = reminderTime;
    if (scheduledDateTime.isBefore(now)) {
      scheduledDateTime = scheduledDateTime.add(const Duration(days: 1));
    }

    final scheduledDate = tz.TZDateTime.from(scheduledDateTime, tz.local);

    final prayerName = CustomReminder.getPrayerBengaliName(prayer);
    final emoji = _getPrayerEmoji(prayer);

    final androidDetails = AndroidNotificationDetails(
      'prayer_reminder_channel',
      'নামাজের রিমাইন্ডার',
      channelDescription: 'নামাজের সময় রিমাইন্ডার',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(
        '$prayerName এর সময় হতে $minutesBefore মিনিট বাকি আছে। নামাজের প্রস্তুতি নিন।',
        contentTitle: '$emoji $prayerName এর সময়',
      ),
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.zonedSchedule(
      _getPrayerNotificationId(prayer),
      '$emoji $prayerName এর সময়',
      '$prayerName এর সময় হতে $minutesBefore মিনিট বাকি',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    // Save settings
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${_prayerReminderPrefix}${prayer.name}_enabled', true);
    await prefs.setInt(
        '${_prayerReminderPrefix}${prayer.name}_minutesBefore', minutesBefore);

    print('${prayer.name} reminder scheduled for $scheduledDateTime');
  }

  /// Schedule prayer reminder at specific time (always enabled)
  static Future<void> schedulePrayerReminderAtTime({
    required PrayerName prayer,
    required int hour,
    required int minute,
  }) async {
    await cancelPrayerReminder(prayer);

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final prayerName = CustomReminder.getPrayerBengaliName(prayer);
    final emoji = _getPrayerEmoji(prayer);

    final androidDetails = AndroidNotificationDetails(
      'prayer_reminder_channel',
      'নামাজের রিমাইন্ডার',
      channelDescription: 'নামাজের সময় রিমাইন্ডার',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(
        '$prayerName এর সালাতের সময় হয়ে গেছে। সালাত আদায় করে নিন।\nঅজুর সময় মিসওয়াক করতে ভুলবেন না।',
        contentTitle: '$emoji $prayerName এর সালাত',
      ),
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.zonedSchedule(
      _getPrayerNotificationId(prayer),
      '$emoji $prayerName এর সালাত',
      '$prayerName এর সালাতের সময় হয়ে গেছে। সালাত আদায় করে নিন।',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    // Save settings
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${_prayerReminderPrefix}${prayer.name}_hour', hour);
    await prefs.setInt('${_prayerReminderPrefix}${prayer.name}_minute', minute);

    print('${prayer.name} reminder scheduled for $hour:$minute');
  }

  /// Cancel prayer reminder
  static Future<void> cancelPrayerReminder(PrayerName prayer) async {
    await _notifications.cancel(_getPrayerNotificationId(prayer));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
        '${_prayerReminderPrefix}${prayer.name}_enabled', false);
    print('${prayer.name} reminder cancelled');
  }

  /// Get prayer reminder settings
  static Future<Map<String, dynamic>> getPrayerReminderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settings = <String, dynamic>{};

    for (final prayer in PrayerName.values) {
      settings['${prayer.name}_enabled'] =
          prefs.getBool('${_prayerReminderPrefix}${prayer.name}_enabled') ??
              false;
      settings['${prayer.name}_minutesBefore'] = prefs
              .getInt('${_prayerReminderPrefix}${prayer.name}_minutesBefore') ??
          10;
      settings['${prayer.name}_hour'] =
          prefs.getInt('${_prayerReminderPrefix}${prayer.name}_hour');
      settings['${prayer.name}_minute'] =
          prefs.getInt('${_prayerReminderPrefix}${prayer.name}_minute');
    }

    return settings;
  }

  // ============ CUSTOM REMINDERS ============

  /// Get all custom reminders
  static Future<List<CustomReminder>> getCustomReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_customRemindersKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((j) => CustomReminder.fromJson(j)).toList();
    } catch (e) {
      print('Error loading custom reminders: $e');
      return [];
    }
  }

  /// Save custom reminders
  static Future<void> _saveCustomReminders(
      List<CustomReminder> reminders) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(reminders.map((r) => r.toJson()).toList());
    await prefs.setString(_customRemindersKey, jsonString);
  }

  /// Add a custom reminder
  static Future<void> addCustomReminder(CustomReminder reminder) async {
    final reminders = await getCustomReminders();
    reminders.add(reminder);
    await _saveCustomReminders(reminders);

    if (reminder.isEnabled) {
      await _scheduleCustomReminderNotification(reminder);
    }
  }

  /// Update a custom reminder
  static Future<void> updateCustomReminder(CustomReminder reminder) async {
    final reminders = await getCustomReminders();
    final index = reminders.indexWhere((r) => r.id == reminder.id);

    if (index != -1) {
      reminders[index] = reminder;
      await _saveCustomReminders(reminders);

      // Cancel existing and reschedule if enabled
      await _cancelCustomReminderNotification(reminder.id);
      if (reminder.isEnabled) {
        await _scheduleCustomReminderNotification(reminder);
      }
    }
  }

  /// Delete a custom reminder
  static Future<void> deleteCustomReminder(String id) async {
    final reminders = await getCustomReminders();
    reminders.removeWhere((r) => r.id == id);
    await _saveCustomReminders(reminders);
    await _cancelCustomReminderNotification(id);
  }

  /// Schedule notification for a custom reminder
  static Future<void> _scheduleCustomReminderNotification(
      CustomReminder reminder) async {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime? scheduledDate;

    if (reminder.type == ReminderType.fixedTime &&
        reminder.fixedHour != null &&
        reminder.fixedMinute != null) {
      scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        reminder.fixedHour!,
        reminder.fixedMinute!,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
    }

    if (scheduledDate == null) return;

    final notificationId =
        _customReminderBaseId + int.parse(reminder.id) % 1000;

    const androidDetails = AndroidNotificationDetails(
      'custom_reminder_channel',
      'কাস্টম রিমাইন্ডার',
      channelDescription: 'কাস্টম রিমাইন্ডার নোটিফিকেশন',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    final notificationDetails =
        const NotificationDetails(android: androidDetails);

    await _notifications.zonedSchedule(
      notificationId,
      '🔔 ${reminder.title}',
      reminder.description ?? 'আপনার কাস্টম রিমাইন্ডার',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    print('Custom reminder "${reminder.title}" scheduled');
  }

  /// Cancel notification for a custom reminder
  static Future<void> _cancelCustomReminderNotification(String id) async {
    final notificationId = _customReminderBaseId + int.parse(id) % 1000;
    await _notifications.cancel(notificationId);
  }

  /// Reschedule all enabled reminders (call on app start)
  static Future<void> rescheduleAllReminders() async {
    // Reschedule daily reminder
    final dailySettings = await getReminderSettings();
    if (dailySettings['enabled'] == true) {
      await scheduleDailyReminder(
        hour: dailySettings['hour'],
        minute: dailySettings['minute'],
      );
    }

    // Reschedule dhikr reminders
    final dhikrSettings = await getDhikrReminderSettings();
    if (dhikrSettings['morningEnabled'] == true) {
      await scheduleMorningDhikrReminder(
        hour: dhikrSettings['morningHour'],
        minute: dhikrSettings['morningMinute'],
      );
    }
    if (dhikrSettings['eveningEnabled'] == true) {
      await scheduleEveningDhikrReminder(
        hour: dhikrSettings['eveningHour'],
        minute: dhikrSettings['eveningMinute'],
      );
    }

    // Reschedule custom reminders
    final customReminders = await getCustomReminders();
    for (final reminder in customReminders.where((r) => r.isEnabled)) {
      await _scheduleCustomReminderNotification(reminder);
    }
  }
}
