enum SyncStatus {
  synced,
  pending,
  failed,
}

enum CategoryType {
  dhikr,
  miswak,
  azkar,
  surah,
  dua,
  custom,
}

enum PrayerType {
  fajr,
  dhuhr,
  asr,
  maghrib,
  isha,
}

enum ReadingType {
  quran,
  tafsir,
  hadith,
  other,
}

class PrayerRecord {
  final String id;
  final DateTime date;
  final PrayerType prayerType;
  
  // Prayer completion status
  bool isCompleted;
  DateTime? completedAt;
  
  // Rakat tracking
  final Map<String, int> rakatTarget; // e.g., {'sunnah': 2, 'fard': 2}
  final Map<String, int> rakatCompleted;
  
  // Time adjustment
  DateTime? scheduledTime;
  int adjustmentMinutes; // Manual +/- adjustment
  
  // Cloud sync fields
  final int modelVersion;
  final DateTime createdAt;
  DateTime updatedAt;
  SyncStatus syncStatus;
  DateTime? lastSyncedAt;
  
  PrayerRecord({
    required this.id,
    required this.date,
    required this.prayerType,
    this.isCompleted = false,
    this.completedAt,
    required this.rakatTarget,
    Map<String, int>? rakatCompleted,
    this.scheduledTime,
    this.adjustmentMinutes = 0,
    required this.modelVersion,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = SyncStatus.pending,
    this.lastSyncedAt,
  }) : rakatCompleted = rakatCompleted ?? {};
  
  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'prayerType': prayerType.name,
        'isCompleted': isCompleted,
        'completedAt': completedAt?.toIso8601String(),
        'rakatTarget': rakatTarget,
        'rakatCompleted': rakatCompleted,
        'scheduledTime': scheduledTime?.toIso8601String(),
        'adjustmentMinutes': adjustmentMinutes,
        'modelVersion': modelVersion,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'syncStatus': syncStatus.name,
        'lastSyncedAt': lastSyncedAt?.toIso8601String(),
      };
  
  factory PrayerRecord.fromJson(Map<String, dynamic> json) => PrayerRecord(
        id: json['id'],
        date: DateTime.parse(json['date']),
        prayerType: PrayerType.values.firstWhere((e) => e.name == json['prayerType']),
        isCompleted: json['isCompleted'] ?? false,
        completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
        rakatTarget: Map<String, int>.from(json['rakatTarget']),
        rakatCompleted: Map<String, int>.from(json['rakatCompleted'] ?? {}),
        scheduledTime: json['scheduledTime'] != null ? DateTime.parse(json['scheduledTime']) : null,
        adjustmentMinutes: json['adjustmentMinutes'] ?? 0,
        modelVersion: json['modelVersion'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        syncStatus: SyncStatus.values.firstWhere((e) => e.name == json['syncStatus']),
        lastSyncedAt: json['lastSyncedAt'] != null ? DateTime.parse(json['lastSyncedAt']) : null,
      );
  
  PrayerRecord copyWith({
    bool? isCompleted,
    DateTime? completedAt,
    Map<String, int>? rakatCompleted,
    DateTime? scheduledTime,
    int? adjustmentMinutes,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
  }) {
    return PrayerRecord(
      id: id,
      date: date,
      prayerType: prayerType,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      rakatTarget: rakatTarget,
      rakatCompleted: rakatCompleted ?? this.rakatCompleted,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      adjustmentMinutes: adjustmentMinutes ?? this.adjustmentMinutes,
      modelVersion: modelVersion,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      syncStatus: syncStatus ?? SyncStatus.pending,
      lastSyncedAt: lastSyncedAt,
    );
  }
  
  int get totalRakatTarget => rakatTarget.values.fold(0, (sum, val) => sum + val);
  int get totalRakatCompleted => rakatCompleted.values.fold(0, (sum, val) => sum + val);
}

