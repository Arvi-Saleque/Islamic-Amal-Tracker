import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../data/models/notification_settings_model.dart';
import '../../services/notification_service.dart';

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
    try {
      _box = await Hive.openBox('notification_settings');
      await _initialize();
    } catch (e) {
      print('Error initializing notification settings: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Initialize local notification service
      await _notificationService.initialize();
      
      // Load saved settings from local storage
      final data = _box?.get('settings');
      if (data != null) {
        final settings = NotificationSettingsModel.fromJson(
          Map<String, dynamic>.from(data),
        );
        state = state.copyWith(settings: settings);
      }
      
      // Just CHECK permission status, don't request (to avoid blocking UI)
      final permissions = await _notificationService.checkAllPermissions();
      final hasPermission = permissions['notification'] == true;
      state = state.copyWith(hasPermission: hasPermission, isLoading: false);
      
      // Schedule local notifications based on saved settings
      if (hasPermission) {
        await _scheduleAllNotifications();
      }
    } catch (e) {
      print('Error in _initialize: $e');
      state = state.copyWith(isLoading: false);
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
    
    // Schedule dhikr reminders
    if (settings.morningDhikrEnabled) {
      await _notificationService.scheduleMorningDhikrReminder(
        hour: settings.morningDhikrHour,
        minute: settings.morningDhikrMinute,
      );
    } else {
      await _notificationService.cancelNotification(NotificationService.morningDhikrId);
    }
    
    if (settings.eveningDhikrEnabled) {
      await _notificationService.scheduleEveningDhikrReminder(
        hour: settings.eveningDhikrHour,
        minute: settings.eveningDhikrMinute,
      );
    } else {
      await _notificationService.cancelNotification(NotificationService.eveningDhikrId);
    }
    
    // Schedule daily amal reminder
    if (settings.dailyAmalReminderEnabled) {
      await _notificationService.scheduleDailyAmalReminder(
        hour: settings.dailyAmalReminderHour,
        minute: settings.dailyAmalReminderMinute,
      );
    } else {
      await _notificationService.cancelNotification(NotificationService.dailyAmalReminderId);
    }
  }

  Future<void> updateSettings(NotificationSettingsModel newSettings) async {
    state = state.copyWith(settings: newSettings);
    await _saveSettings();
    
    // Reschedule local notifications
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

  // Refresh reminder settings (call after prayer times update)
  Future<void> refreshReminderSettings() async {
    if (state.hasPermission) {
      await _scheduleAllNotifications();
    }
  }
}

final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettingsState>(
  (ref) => NotificationSettingsNotifier(ref),
);
