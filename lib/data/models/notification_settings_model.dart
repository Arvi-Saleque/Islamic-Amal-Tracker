class NotificationSettingsModel {
  // Prayer notification settings
  final bool prayerNotificationsEnabled;
  final int prayerReminderMinutesBefore;
  final bool fajrEnabled;
  final bool dhuhrEnabled;
  final bool asrEnabled;
  final bool maghribEnabled;
  final bool ishaEnabled;

  // Dhikr notification settings
  final bool morningDhikrEnabled;
  final int morningDhikrHour;
  final int morningDhikrMinute;
  final bool eveningDhikrEnabled;
  final int eveningDhikrHour;
  final int eveningDhikrMinute;

  // Daily amal reminder
  final bool dailyAmalReminderEnabled;
  final int dailyAmalReminderHour;
  final int dailyAmalReminderMinute;

  NotificationSettingsModel({
    this.prayerNotificationsEnabled = true,
    this.prayerReminderMinutesBefore = 10,
    this.fajrEnabled = true,
    this.dhuhrEnabled = true,
    this.asrEnabled = true,
    this.maghribEnabled = true,
    this.ishaEnabled = true,
    this.morningDhikrEnabled = true,
    this.morningDhikrHour = 6,
    this.morningDhikrMinute = 0,
    this.eveningDhikrEnabled = true,
    this.eveningDhikrHour = 17,
    this.eveningDhikrMinute = 30,
    this.dailyAmalReminderEnabled = true,
    this.dailyAmalReminderHour = 21,
    this.dailyAmalReminderMinute = 0,
  });

  NotificationSettingsModel copyWith({
    bool? prayerNotificationsEnabled,
    int? prayerReminderMinutesBefore,
    bool? fajrEnabled,
    bool? dhuhrEnabled,
    bool? asrEnabled,
    bool? maghribEnabled,
    bool? ishaEnabled,
    bool? morningDhikrEnabled,
    int? morningDhikrHour,
    int? morningDhikrMinute,
    bool? eveningDhikrEnabled,
    int? eveningDhikrHour,
    int? eveningDhikrMinute,
    bool? dailyAmalReminderEnabled,
    int? dailyAmalReminderHour,
    int? dailyAmalReminderMinute,
  }) {
    return NotificationSettingsModel(
      prayerNotificationsEnabled:
          prayerNotificationsEnabled ?? this.prayerNotificationsEnabled,
      prayerReminderMinutesBefore:
          prayerReminderMinutesBefore ?? this.prayerReminderMinutesBefore,
      fajrEnabled: fajrEnabled ?? this.fajrEnabled,
      dhuhrEnabled: dhuhrEnabled ?? this.dhuhrEnabled,
      asrEnabled: asrEnabled ?? this.asrEnabled,
      maghribEnabled: maghribEnabled ?? this.maghribEnabled,
      ishaEnabled: ishaEnabled ?? this.ishaEnabled,
      morningDhikrEnabled: morningDhikrEnabled ?? this.morningDhikrEnabled,
      morningDhikrHour: morningDhikrHour ?? this.morningDhikrHour,
      morningDhikrMinute: morningDhikrMinute ?? this.morningDhikrMinute,
      eveningDhikrEnabled: eveningDhikrEnabled ?? this.eveningDhikrEnabled,
      eveningDhikrHour: eveningDhikrHour ?? this.eveningDhikrHour,
      eveningDhikrMinute: eveningDhikrMinute ?? this.eveningDhikrMinute,
      dailyAmalReminderEnabled:
          dailyAmalReminderEnabled ?? this.dailyAmalReminderEnabled,
      dailyAmalReminderHour:
          dailyAmalReminderHour ?? this.dailyAmalReminderHour,
      dailyAmalReminderMinute:
          dailyAmalReminderMinute ?? this.dailyAmalReminderMinute,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prayerNotificationsEnabled': prayerNotificationsEnabled,
      'prayerReminderMinutesBefore': prayerReminderMinutesBefore,
      'fajrEnabled': fajrEnabled,
      'dhuhrEnabled': dhuhrEnabled,
      'asrEnabled': asrEnabled,
      'maghribEnabled': maghribEnabled,
      'ishaEnabled': ishaEnabled,
      'morningDhikrEnabled': morningDhikrEnabled,
      'morningDhikrHour': morningDhikrHour,
      'morningDhikrMinute': morningDhikrMinute,
      'eveningDhikrEnabled': eveningDhikrEnabled,
      'eveningDhikrHour': eveningDhikrHour,
      'eveningDhikrMinute': eveningDhikrMinute,
      'dailyAmalReminderEnabled': dailyAmalReminderEnabled,
      'dailyAmalReminderHour': dailyAmalReminderHour,
      'dailyAmalReminderMinute': dailyAmalReminderMinute,
    };
  }

  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsModel(
      prayerNotificationsEnabled:
          json['prayerNotificationsEnabled'] as bool? ?? true,
      prayerReminderMinutesBefore:
          json['prayerReminderMinutesBefore'] as int? ?? 10,
      fajrEnabled: json['fajrEnabled'] as bool? ?? true,
      dhuhrEnabled: json['dhuhrEnabled'] as bool? ?? true,
      asrEnabled: json['asrEnabled'] as bool? ?? true,
      maghribEnabled: json['maghribEnabled'] as bool? ?? true,
      ishaEnabled: json['ishaEnabled'] as bool? ?? true,
      morningDhikrEnabled: json['morningDhikrEnabled'] as bool? ?? true,
      morningDhikrHour: json['morningDhikrHour'] as int? ?? 6,
      morningDhikrMinute: json['morningDhikrMinute'] as int? ?? 0,
      eveningDhikrEnabled: json['eveningDhikrEnabled'] as bool? ?? true,
      eveningDhikrHour: json['eveningDhikrHour'] as int? ?? 17,
      eveningDhikrMinute: json['eveningDhikrMinute'] as int? ?? 30,
      dailyAmalReminderEnabled:
          json['dailyAmalReminderEnabled'] as bool? ?? true,
      dailyAmalReminderHour: json['dailyAmalReminderHour'] as int? ?? 21,
      dailyAmalReminderMinute: json['dailyAmalReminderMinute'] as int? ?? 0,
    );
  }

  // Helper to format time
  String formatTime(int hour, int minute) {
    final h = hour > 12 ? hour - 12 : hour == 0 ? 12 : hour;
    final m = minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  String get morningDhikrTime => formatTime(morningDhikrHour, morningDhikrMinute);
  String get eveningDhikrTime => formatTime(eveningDhikrHour, eveningDhikrMinute);
  String get dailyAmalReminderTime =>
      formatTime(dailyAmalReminderHour, dailyAmalReminderMinute);
}
