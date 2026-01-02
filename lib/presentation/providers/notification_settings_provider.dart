import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../data/models/notification_settings_model.dart';
import '../../services/notification_service.dart';
import 'prayer_times_provider.dart';

class NotificationSettingsState {
  final NotificationSettingsModel settings;
  final bool hasPermission;
  final bool isLoading;

  NotificationSettingsState({
    required this.settings,
    this.hasPermission = false,
    this.isLoading = false,
  });

  NotificationSettingsState copyWith({
    NotificationSettingsModel? settings,
    bool? hasPermission,
    bool? isLoading,
  }) {
    return NotificationSettingsState(
      settings: settings ?? this.settings,
      hasPermission: hasPermission ?? this.hasPermission,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class NotificationSettingsNotifier extends StateNotifier<NotificationSettingsState> {
  Box? _box;
  final NotificationService _notificationService = NotificationService();
  final Ref _ref;

  NotificationSettingsNotifier(this._ref)
      : super(NotificationSettingsState(
          settings: NotificationSettingsModel(),
        )) {
    _initBox();
  }

  Future<void> _initBox() async {
    _box = await Hive.openBox('notification_settings');
    _initialize();
  }

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);
    
    // Initialize notification service
    await _notificationService.initialize();
    
    // Load saved settings
    final data = _box?.get('settings');
    if (data != null) {
      final settings = NotificationSettingsModel.fromJson(
        Map<String, dynamic>.from(data),
      );
      state = state.copyWith(settings: settings);
    }
    
    // Check permission status
    final hasPermission = await _notificationService.requestPermissions();
    state = state.copyWith(hasPermission: hasPermission, isLoading: false);
    
    // Schedule notifications if enabled
    if (hasPermission) {
      await _scheduleAllNotifications();
    }
  }

  Future<void> requestPermission() async {
    final hasPermission = await _notificationService.requestPermissions();
    state = state.copyWith(hasPermission: hasPermission);
    
    if (hasPermission) {
      await _scheduleAllNotifications();
    }
  }

  Future<void> _scheduleAllNotifications() async {
    final settings = state.settings;
    
    // Schedule prayer reminders
    if (settings.prayerNotificationsEnabled) {
      await _schedulePrayerNotifications();
    }
    
    // Schedule morning dhikr
    if (settings.morningDhikrEnabled) {
      await _notificationService.scheduleMorningDhikrReminder(
        hour: settings.morningDhikrHour,
        minute: settings.morningDhikrMinute,
      );
    }
    
    // Schedule evening dhikr
    if (settings.eveningDhikrEnabled) {
      await _notificationService.scheduleEveningDhikrReminder(
        hour: settings.eveningDhikrHour,
        minute: settings.eveningDhikrMinute,
      );
    }
    
    // Schedule daily amal reminder
    if (settings.dailyAmalReminderEnabled) {
      await _notificationService.scheduleDailyAmalReminder(
        hour: settings.dailyAmalReminderHour,
        minute: settings.dailyAmalReminderMinute,
      );
    }
  }

  Future<void> _schedulePrayerNotifications() async {
    final prayerTimesState = _ref.read(prayerTimesProvider);
    final settings = state.settings;
    
    if (prayerTimesState.prayerTimes.isEmpty) return;
    
    // Cancel existing prayer notifications
    await _notificationService.cancelAllPrayerNotifications();
    
    final prayerTimes = <String, DateTime>{};
    
    if (settings.fajrEnabled && prayerTimesState.prayerTimes['fajr'] != null) {
      prayerTimes['fajr'] = prayerTimesState.prayerTimes['fajr']!;
    }
    if (settings.dhuhrEnabled && prayerTimesState.prayerTimes['dhuhr'] != null) {
      prayerTimes['dhuhr'] = prayerTimesState.prayerTimes['dhuhr']!;
    }
    if (settings.asrEnabled && prayerTimesState.prayerTimes['asr'] != null) {
      prayerTimes['asr'] = prayerTimesState.prayerTimes['asr']!;
    }
    if (settings.maghribEnabled && prayerTimesState.prayerTimes['maghrib'] != null) {
      prayerTimes['maghrib'] = prayerTimesState.prayerTimes['maghrib']!;
    }
    if (settings.ishaEnabled && prayerTimesState.prayerTimes['isha'] != null) {
      prayerTimes['isha'] = prayerTimesState.prayerTimes['isha']!;
    }
    
    await _notificationService.scheduleAllPrayerReminders(
      prayerTimes: prayerTimes,
      minutesBefore: settings.prayerReminderMinutesBefore,
    );
  }

  Future<void> updateSettings(NotificationSettingsModel newSettings) async {
    state = state.copyWith(settings: newSettings);
    await _saveSettings();
    
    // Reschedule notifications
    await _notificationService.cancelAllNotifications();
    if (state.hasPermission) {
      await _scheduleAllNotifications();
    }
  }

  // Individual setting updates
  Future<void> togglePrayerNotifications(bool enabled) async {
    await updateSettings(
      state.settings.copyWith(prayerNotificationsEnabled: enabled),
    );
  }

  Future<void> setPrayerReminderMinutes(int minutes) async {
    await updateSettings(
      state.settings.copyWith(prayerReminderMinutesBefore: minutes),
    );
  }

  Future<void> toggleFajr(bool enabled) async {
    await updateSettings(state.settings.copyWith(fajrEnabled: enabled));
  }

  Future<void> toggleDhuhr(bool enabled) async {
    await updateSettings(state.settings.copyWith(dhuhrEnabled: enabled));
  }

  Future<void> toggleAsr(bool enabled) async {
    await updateSettings(state.settings.copyWith(asrEnabled: enabled));
  }

  Future<void> toggleMaghrib(bool enabled) async {
    await updateSettings(state.settings.copyWith(maghribEnabled: enabled));
  }

  Future<void> toggleIsha(bool enabled) async {
    await updateSettings(state.settings.copyWith(ishaEnabled: enabled));
  }

  Future<void> toggleMorningDhikr(bool enabled) async {
    await updateSettings(state.settings.copyWith(morningDhikrEnabled: enabled));
  }

  Future<void> setMorningDhikrTime(int hour, int minute) async {
    await updateSettings(
      state.settings.copyWith(
        morningDhikrHour: hour,
        morningDhikrMinute: minute,
      ),
    );
  }

  Future<void> toggleEveningDhikr(bool enabled) async {
    await updateSettings(state.settings.copyWith(eveningDhikrEnabled: enabled));
  }

  Future<void> setEveningDhikrTime(int hour, int minute) async {
    await updateSettings(
      state.settings.copyWith(
        eveningDhikrHour: hour,
        eveningDhikrMinute: minute,
      ),
    );
  }

  Future<void> toggleDailyAmalReminder(bool enabled) async {
    await updateSettings(
      state.settings.copyWith(dailyAmalReminderEnabled: enabled),
    );
  }

  Future<void> setDailyAmalReminderTime(int hour, int minute) async {
    await updateSettings(
      state.settings.copyWith(
        dailyAmalReminderHour: hour,
        dailyAmalReminderMinute: minute,
      ),
    );
  }

  Future<void> _saveSettings() async {
    _box?.put('settings', state.settings.toJson());
  }

  // Test notification
  Future<void> sendTestNotification() async {
    await _notificationService.showInstantNotification(
      title: 'টেস্ট নোটিফিকেশন ✅',
      body: 'নোটিফিকেশন সঠিকভাবে কাজ করছে!',
    );
  }

  // Refresh prayer notifications (call after prayer times update)
  Future<void> refreshPrayerNotifications() async {
    if (state.hasPermission && state.settings.prayerNotificationsEnabled) {
      await _schedulePrayerNotifications();
    }
  }
}

final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettingsState>(
  (ref) => NotificationSettingsNotifier(ref),
);
