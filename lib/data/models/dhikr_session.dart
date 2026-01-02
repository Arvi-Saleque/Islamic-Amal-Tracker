import 'prayer_record.dart';

class DhikrSession {
  final String id;
  final String dhikrId; // Reference to category
  final String dhikrName;
  final String? dhikrNameAr;
  
  final int targetCount;
  int currentCount;
  
  final DateTime date;
  final DateTime startTime;
  DateTime? completedAt;
  bool isCompleted;
  
  final List<DateTime> timestamps; // For analytics
  
  // Cloud sync fields
  final int modelVersion;
  final DateTime createdAt;
  DateTime updatedAt;
  SyncStatus syncStatus;
  DateTime? lastSyncedAt;
  
  DhikrSession({
    required this.id,
    required this.dhikrId,
    required this.dhikrName,
    this.dhikrNameAr,
    required this.targetCount,
    this.currentCount = 0,
    required this.date,
    required this.startTime,
    this.completedAt,
    this.isCompleted = false,
    List<DateTime>? timestamps,
    required this.modelVersion,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = SyncStatus.pending,
    this.lastSyncedAt,
  }) : timestamps = timestamps ?? [];
  
  Map<String, dynamic> toJson() => {
        'id': id,
        'dhikrId': dhikrId,
        'dhikrName': dhikrName,
        'dhikrNameAr': dhikrNameAr,
        'targetCount': targetCount,
        'currentCount': currentCount,
        'date': date.toIso8601String(),
        'startTime': startTime.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'isCompleted': isCompleted,
        'timestamps': timestamps.map((t) => t.toIso8601String()).toList(),
        'modelVersion': modelVersion,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'syncStatus': syncStatus.name,
        'lastSyncedAt': lastSyncedAt?.toIso8601String(),
      };
  
  factory DhikrSession.fromJson(Map<String, dynamic> json) => DhikrSession(
        id: json['id'],
        dhikrId: json['dhikrId'],
        dhikrName: json['dhikrName'],
        dhikrNameAr: json['dhikrNameAr'],
        targetCount: json['targetCount'],
        currentCount: json['currentCount'] ?? 0,
        date: DateTime.parse(json['date']),
        startTime: DateTime.parse(json['startTime']),
        completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
        isCompleted: json['isCompleted'] ?? false,
        timestamps: (json['timestamps'] as List?)?.map((t) => DateTime.parse(t)).toList() ?? [],
        modelVersion: json['modelVersion'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        syncStatus: SyncStatus.values.firstWhere((e) => e.name == json['syncStatus']),
        lastSyncedAt: json['lastSyncedAt'] != null ? DateTime.parse(json['lastSyncedAt']) : null,
      );
  
  DhikrSession copyWith({
    int? currentCount,
    DateTime? completedAt,
    bool? isCompleted,
    List<DateTime>? timestamps,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
  }) {
    return DhikrSession(
      id: id,
      dhikrId: dhikrId,
      dhikrName: dhikrName,
      dhikrNameAr: dhikrNameAr,
      targetCount: targetCount,
      currentCount: currentCount ?? this.currentCount,
      date: date,
      startTime: startTime,
      completedAt: completedAt ?? this.completedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      timestamps: timestamps ?? this.timestamps,
      modelVersion: modelVersion,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      syncStatus: syncStatus ?? SyncStatus.pending,
      lastSyncedAt: lastSyncedAt,
    );
  }
  
  double get progress => targetCount > 0 ? (currentCount / targetCount).clamp(0.0, 1.0) : 0.0;
}

class DhikrHistory {
  final String dhikrId;
  final DateTime date;
  final int totalCount;
  final List<DhikrSession> sessions;
  
  DhikrHistory({
    required this.dhikrId,
    required this.date,
    required this.totalCount,
    required this.sessions,
  });
  
  Map<String, dynamic> toJson() => {
        'dhikrId': dhikrId,
        'date': date.toIso8601String(),
        'totalCount': totalCount,
        'sessions': sessions.map((s) => s.toJson()).toList(),
      };
  
  factory DhikrHistory.fromJson(Map<String, dynamic> json) => DhikrHistory(
        dhikrId: json['dhikrId'],
        date: DateTime.parse(json['date']),
        totalCount: json['totalCount'],
        sessions: (json['sessions'] as List).map((s) => DhikrSession.fromJson(s)).toList(),
      );
}


