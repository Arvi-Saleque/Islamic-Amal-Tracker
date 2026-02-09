
enum ReminderType {
  beforePrayer,  // নামাজের আগে
  afterPrayer,   // নামাজের পরে
  fixedTime,     // নির্দিষ্ট সময়ে
}

enum PrayerName {
  fajr,     // ফজর
  dhuhr,    // যোহর
  asr,      // আসর
  maghrib,  // মাগরিব
  isha,     // এশা
}

class CustomReminder {
  final String id;
  final String title;
  final String? description;
  final ReminderType type;
  final PrayerName? prayer;  // null if type is fixedTime
  final int minutesOffset;   // minutes before/after prayer (positive = after, negative = before)
  final int? fixedHour;      // for fixedTime type
  final int? fixedMinute;    // for fixedTime type
  final bool isEnabled;
  final List<int> repeatDays; // 1-7 (Monday-Sunday), empty = daily
  final DateTime createdAt;

  CustomReminder({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    this.prayer,
    this.minutesOffset = 0,
    this.fixedHour,
    this.fixedMinute,
    this.isEnabled = true,
    this.repeatDays = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Generate unique ID
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  CustomReminder copyWith({
    String? id,
    String? title,
    String? description,
    ReminderType? type,
    PrayerName? prayer,
    int? minutesOffset,
    int? fixedHour,
    int? fixedMinute,
    bool? isEnabled,
    List<int>? repeatDays,
    DateTime? createdAt,
  }) {
    return CustomReminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      prayer: prayer ?? this.prayer,
      minutesOffset: minutesOffset ?? this.minutesOffset,
      fixedHour: fixedHour ?? this.fixedHour,
      fixedMinute: fixedMinute ?? this.fixedMinute,
      isEnabled: isEnabled ?? this.isEnabled,
      repeatDays: repeatDays ?? this.repeatDays,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.index,
      'prayer': prayer?.index,
      'minutesOffset': minutesOffset,
      'fixedHour': fixedHour,
      'fixedMinute': fixedMinute,
      'isEnabled': isEnabled,
      'repeatDays': repeatDays,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CustomReminder.fromJson(Map<String, dynamic> json) {
    return CustomReminder(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      type: ReminderType.values[json['type'] as int],
      prayer: json['prayer'] != null ? PrayerName.values[json['prayer'] as int] : null,
      minutesOffset: json['minutesOffset'] as int? ?? 0,
      fixedHour: json['fixedHour'] as int?,
      fixedMinute: json['fixedMinute'] as int?,
      isEnabled: json['isEnabled'] as bool? ?? true,
      repeatDays: (json['repeatDays'] as List<dynamic>?)?.cast<int>() ?? [],
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  // Get Bengali name for prayer
  static String getPrayerBengaliName(PrayerName prayer) {
    switch (prayer) {
      case PrayerName.fajr:
        return 'ফজর';
      case PrayerName.dhuhr:
        return 'যোহর';
      case PrayerName.asr:
        return 'আসর';
      case PrayerName.maghrib:
        return 'মাগরিব';
      case PrayerName.isha:
        return 'এশা';
    }
  }

  // Get Bengali name for reminder type
  static String getTypeBengaliName(ReminderType type) {
    switch (type) {
      case ReminderType.beforePrayer:
        return 'নামাজের আগে';
      case ReminderType.afterPrayer:
        return 'নামাজের পরে';
      case ReminderType.fixedTime:
        return 'নির্দিষ্ট সময়ে';
    }
  }

  // Get display string for the reminder time
  String getTimeDisplayString() {
    if (type == ReminderType.fixedTime && fixedHour != null && fixedMinute != null) {
      final hour = fixedHour! > 12 ? fixedHour! - 12 : (fixedHour == 0 ? 12 : fixedHour!);
      final period = fixedHour! >= 12 ? 'PM' : 'AM';
      return '$hour:${fixedMinute!.toString().padLeft(2, '0')} $period';
    } else if (prayer != null) {
      final prayerName = getPrayerBengaliName(prayer!);
      if (minutesOffset == 0) {
        return '$prayerName এর সময়';
      } else if (minutesOffset > 0) {
        return '$prayerName এর $minutesOffset মিনিট পরে';
      } else {
        return '$prayerName এর ${minutesOffset.abs()} মিনিট আগে';
      }
    }
    return '';
  }

  @override
  String toString() {
    return 'CustomReminder(id: $id, title: $title, type: $type, prayer: $prayer)';
  }
}
