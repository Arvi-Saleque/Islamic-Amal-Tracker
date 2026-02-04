import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/custom_reminder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:geolocator/geolocator.dart';
import 'prayer_times_api_service.dart';

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

  static const String _kDefaultPrayerLastScheduledDay =
      'default_prayer_last_scheduled_day';
  static const String _kDefaultDhikrLastScheduledDay =
      'default_dhikr_last_scheduled_day';

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
  static const int _defaultDailyAmalId = 9001;
  static const int _defaultPrayerBaseId =
      9200; // unique block for default prayers
  static const int _defaultMorningDhikrId = 9301;
  static const int _defaultEveningDhikrId = 9302;

  static const int _defaultScheduleDaysAhead = 30;
  static const String _kDefaultWindowScheduledOn =
      'default_window_scheduled_on';

  // Large safe ID ranges for default rolling schedules
  static const int _defaultPrayerIdBase = 200000;
  static const int _defaultDhikrIdBase = 210000;

  static const String _kDefaultWindowStartDay = 'default_window_start_day';
  static const String _kDefaultWindowDaysAhead = 'default_window_days_ahead';


  static int _getDefaultPrayerNotificationId(PrayerName prayer) {
    return _defaultPrayerBaseId + prayer.index; // stable + unique
  }

  static String _displayPrayerName(PrayerName prayer) {
    switch (prayer) {
      case PrayerName.fajr:
        return 'Fajr';
      case PrayerName.dhuhr:
        return 'Dhuhr';
      case PrayerName.asr:
        return 'Asr';
      case PrayerName.maghrib:
        return 'Maghrib';
      case PrayerName.isha:
        return 'Isha';
    }
  }

  static String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static String _dayKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static int _defaultPrayerIdForDayIndex(int dayIndex, int prayerIndex) {
    // reserve 10 IDs per day
    return _defaultPrayerIdBase + dayIndex * 10 + prayerIndex;
  }

  static int _defaultDhikrIdForDayIndex(int dayIndex, bool morning) {
    // reserve 10 IDs per day
    return _defaultDhikrIdBase + dayIndex * 10 + (morning ? 1 : 2);
  }

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

  static Future<void> scheduleDefaultDailyAmalReminder() async {
    // Don’t touch personal daily reminder ID (1001)
    await _notifications.cancel(_defaultDailyAmalId);

    final now = tz.TZDateTime.now(tz.local);

    // Default: 10:00 PM
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      20,
      30,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'default_daily_amal_channel',
      'Default Daily Amal',
      channelDescription: 'Always active default daily amal reminder',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.zonedSchedule(
      _defaultDailyAmalId,
      '🕌 আমল রিমাইন্ডার',
      'আজকের আমলগুলো করতে ভুলবেন না!',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents:
          DateTimeComponents.time, // repeats daily at 10 PM
    );
  }

  static Future<void> cancelDefaultDailyAmalReminder() async {
    await _notifications.cancel(_defaultDailyAmalId);
  }

  static Future<void> scheduleDefaultPrayerReminders({
    required Map<String, DateTime> prayerTimes,
  }) async {
    // Offsets in minutes (your rules)
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();

    final last = prefs.getString(_kDefaultPrayerLastScheduledDay);
    if (last == today) {
      return; // already scheduled today
    }

    const offsets = {
      'fajr': 30,
      'dhuhr': 60,
      'asr': 15,
      'maghrib': 10,
      'isha': 60,
    };

    for (final prayer in PrayerName.values) {
      final key = prayer
          .name; // assumes PrayerName names are fajr/dhuhr/asr/maghrib/isha
      final base = prayerTimes[key];
      final off = offsets[key];

      if (base == null || off == null) continue;

      final when = base.add(Duration(minutes: off));

      // Cancel previous default schedule for this prayer to avoid duplicates
      await _notifications.cancel(_getDefaultPrayerNotificationId(prayer));

      final scheduledDate = tz.TZDateTime.from(when, tz.local);
      final now = tz.TZDateTime.now(tz.local);

      // If today's time already passed, schedule for next day (same clock time)
      final target = scheduledDate.isBefore(now)
          ? scheduledDate.add(const Duration(days: 1))
          : scheduledDate;

      const androidDetails = AndroidNotificationDetails(
        'default_prayer_channel',
        'Default Prayer Reminders',
        channelDescription:
            'Always active default prayer reminders based on prayer times',
        importance: Importance.high,
        priority: Priority.high,
      );

      const details = NotificationDetails(android: androidDetails);

      await _notifications.zonedSchedule(
        _getDefaultPrayerNotificationId(prayer),
        '🕌 ${_displayPrayerName(prayer)} নামাজ',
        'নামাজ আদায় করে নিন। অজুর সময় মিসওয়াক করতে ভুলবেন না।',
        target,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        // IMPORTANT: don’t use DateTimeComponents.time here because prayer times shift daily.
      );
    }
    await prefs.setString(_kDefaultPrayerLastScheduledDay, today);
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
      'প্রতিদিনের নির্ধারিত আমলসমূহ সম্পন্ন না করলে সম্পন্ন করে নিন।',
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
      '$prayerName এর সালাতের সময় হয়ে গেছে। সালাত আদায় করে নিন।\nঅজুর সময় মিসওয়াক করতে ভুলবেন না।',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    // Save settings
    final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('${_prayerReminderPrefix}${prayer.name}_enabled', true);
await prefs.setInt('${_prayerReminderPrefix}${prayer.name}_hour', hour);
    await prefs.setInt('${_prayerReminderPrefix}${prayer.name}_minute', minute);

    print('${prayer.name} reminder scheduled for $hour:$minute');
  }

  static Future<void> cancelAllPrayerReminders() async {
    for (final prayer in PrayerName.values) {
      await cancelPrayerReminder(prayer);
    }
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

  static Future<void> scheduleDefaultDhikrReminders({
    required DateTime fajrTime,
    required DateTime maghribTime,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();

    final last = prefs.getString(_kDefaultDhikrLastScheduledDay);
    if (last == today) return;

    // Morning dhikr = fajr + 60
    final morning = fajrTime.add(const Duration(minutes: 60));
    await _notifications.cancel(_defaultMorningDhikrId);
    await _notifications.zonedSchedule(
      _defaultMorningDhikrId,
      '🌅 Morning Dhikr',
      'সময় হয়েছে — সকালের যিকির পড়ুন।',
      tz.TZDateTime.from(morning, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'default_dhikr_channel',
          'Default Dhikr Reminders',
          channelDescription: 'Always active default dhikr reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    // Evening dhikr = maghrib + 30
    final evening = maghribTime.add(const Duration(minutes: 30));
    await _notifications.cancel(_defaultEveningDhikrId);
    await _notifications.zonedSchedule(
      _defaultEveningDhikrId,
      '🌙 Evening Dhikr',
      'সময় হয়েছে — সন্ধ্যার যিকির পড়ুন।',
      tz.TZDateTime.from(evening, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'default_dhikr_channel',
          'Default Dhikr Reminders',
          channelDescription: 'Always active default dhikr reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    await prefs.setString(_kDefaultDhikrLastScheduledDay, today);
  }

  static Future<void> scheduleDefaultRollingWindowFromApi({
    int daysAhead = _defaultScheduleDaysAhead,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();

    // Don’t rebuild the same 30-day window repeatedly on the same day
    final startKey = prefs.getString(_kDefaultWindowStartDay);
    final days = prefs.getInt(_kDefaultWindowDaysAhead) ?? daysAhead;

    DateTime? startDate;
    if (startKey != null) {
      final parts = startKey.split('-');
      if (parts.length == 3) {
        startDate = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      }
    }

    if (startDate != null) {
      final todayDate = DateTime.now();
      final todayMidnight = DateTime(todayDate.year, todayDate.month, todayDate.day);

      final endDate = startDate.add(Duration(days: days));
      final remaining = endDate.difference(todayMidnight).inDays;

      // ✅ If still have at least 7 days scheduled, do nothing
      if (remaining >= 7) {
        return;
      }
    }


    double lat = 23.8103;
    double lon = 90.4125;

    final perm = await Geolocator.checkPermission();
    final canUseLocation =
        perm == LocationPermission.always || perm == LocationPermission.whileInUse;

    if (canUseLocation) {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );
      lat = pos.latitude;
      lon = pos.longitude;
    }
// DO NOT request permission here



    // Clear previously scheduled IDs for our window (only within our ID ranges)
    for (int i = 0; i < daysAhead; i++) {
      // 5 prayers (we use PrayerName.values order: fajr,dhuhr,asr,maghrib,isha)
      for (int p = 0; p < 5; p++) {
        await _notifications.cancel(_defaultPrayerIdForDayIndex(i, p));
      }
      await _notifications.cancel(_defaultDhikrIdForDayIndex(i, true));
      await _notifications.cancel(_defaultDhikrIdForDayIndex(i, false));
    }

    final nowDate = DateTime.now();
    final todayMidnight =
        DateTime(nowDate.year, nowDate.month, nowDate.day);

    // Offsets (your default rules)
    const offsets = <String, int>{
      'fajr': 30,
      'dhuhr': 60,
      'asr': 15,
      'maghrib': 10,
      'isha': 60,
    };

    for (int i = 0; i < daysAhead; i++) {
      final date = todayMidnight.add(Duration(days: i));

      final pt = await PrayerTimesApiService.fetchPrayerTimesForDate(
        date: date,
        latitude: lat,
        longitude: lon,
        method: 1,
      );

      // ===== Default prayers =====
      final keys = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];

      for (int p = 0; p < keys.length; p++) {
        final key = keys[p];
        final base = pt[key]!;
        final when = base.add(Duration(minutes: offsets[key]!));

        final target = tz.TZDateTime.from(when, tz.local);
        if (target.isBefore(tz.TZDateTime.now(tz.local))) continue;

        await _notifications.zonedSchedule(
          _defaultPrayerIdForDayIndex(i, p),
          '🕌 ${key.toUpperCase()}',
          'Default reminder (${offsets[key]} min after waqt)',
          target,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'default_prayer_channel',
              'Default Prayer Reminders',
              channelDescription:
                  'Always active default prayer reminders (rolling window)',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }

      // ===== Default dhikr =====
      final morning = tz.TZDateTime.from(
          pt['fajr']!.add(const Duration(minutes: 60)), tz.local);
      if (morning.isAfter(tz.TZDateTime.now(tz.local))) {
        await _notifications.zonedSchedule(
          _defaultDhikrIdForDayIndex(i, true),
          '🌅 Morning Dhikr',
          'Default reminder (Fajr + 60 min)',
          morning,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'default_dhikr_channel',
              'Default Dhikr Reminders',
              channelDescription:
                  'Always active default dhikr reminders (rolling window)',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }

      final evening = tz.TZDateTime.from(
          pt['maghrib']!.add(const Duration(minutes: 30)), tz.local);
      if (evening.isAfter(tz.TZDateTime.now(tz.local))) {
        await _notifications.zonedSchedule(
          _defaultDhikrIdForDayIndex(i, false),
          '🌙 Evening Dhikr',
          'Default reminder (Maghrib + 30 min)',
          evening,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'default_dhikr_channel',
              'Default Dhikr Reminders',
              channelDescription:
                  'Always active default dhikr reminders (rolling window)',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }
    }

    await prefs.setString(_kDefaultWindowScheduledOn, today);

    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);

    await prefs.setString(_kDefaultWindowStartDay, _dayKey(start));
    await prefs.setInt(_kDefaultWindowDaysAhead, daysAhead);

  }
}
