import 'prayer_record.dart';

class DailyStats {
  final String id;
  final DateTime date;
  
  // Prayer stats
  final int prayersCompleted;
  final int totalPrayers;
  final int totalRakatCompleted;
  
  // Dhikr stats
  final int totalDhikrCount;
  final int dhikrSessionsCompleted;
  
  // Amal stats
  final int amalItemsCompleted;
  final int totalAmalItems;
  final Map<String, int> categoryCompletionCount;
  
  // Reading stats
  final int pagesRead;
  final Duration readingDuration;
  
  // Overall
  final double overallScore;
  final int streakDays;
  
  // Cloud sync fields
  final int modelVersion;
  final DateTime createdAt;
  DateTime updatedAt;
  SyncStatus syncStatus;
  DateTime? lastSyncedAt;
  
  DailyStats({
    required this.id,
    required this.date,
    this.prayersCompleted = 0,
    this.totalPrayers = 5,
    this.totalRakatCompleted = 0,
    this.totalDhikrCount = 0,
    this.dhikrSessionsCompleted = 0,
    this.amalItemsCompleted = 0,
    this.totalAmalItems = 0,
    Map<String, int>? categoryCompletionCount,
    this.pagesRead = 0,
    Duration? readingDuration,
    this.overallScore = 0.0,
    this.streakDays = 0,
    required this.modelVersion,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = SyncStatus.pending,
    this.lastSyncedAt,
  })  : categoryCompletionCount = categoryCompletionCount ?? {},
        readingDuration = readingDuration ?? Duration.zero;
  
  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'prayersCompleted': prayersCompleted,
        'totalPrayers': totalPrayers,
        'totalRakatCompleted': totalRakatCompleted,
        'totalDhikrCount': totalDhikrCount,
        'dhikrSessionsCompleted': dhikrSessionsCompleted,
        'amalItemsCompleted': amalItemsCompleted,
        'totalAmalItems': totalAmalItems,
        'categoryCompletionCount': categoryCompletionCount,
        'pagesRead': pagesRead,
        'readingDuration': readingDuration.inSeconds,
        'overallScore': overallScore,
        'streakDays': streakDays,
        'modelVersion': modelVersion,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'syncStatus': syncStatus.name,
        'lastSyncedAt': lastSyncedAt?.toIso8601String(),
      };
  
  factory DailyStats.fromJson(Map<String, dynamic> json) => DailyStats(
        id: json['id'],
        date: DateTime.parse(json['date']),
        prayersCompleted: json['prayersCompleted'] ?? 0,
        totalPrayers: json['totalPrayers'] ?? 5,
        totalRakatCompleted: json['totalRakatCompleted'] ?? 0,
        totalDhikrCount: json['totalDhikrCount'] ?? 0,
        dhikrSessionsCompleted: json['dhikrSessionsCompleted'] ?? 0,
        amalItemsCompleted: json['amalItemsCompleted'] ?? 0,
        totalAmalItems: json['totalAmalItems'] ?? 0,
        categoryCompletionCount: Map<String, int>.from(json['categoryCompletionCount'] ?? {}),
        pagesRead: json['pagesRead'] ?? 0,
        readingDuration: Duration(seconds: json['readingDuration'] ?? 0),
        overallScore: json['overallScore'] ?? 0.0,
        streakDays: json['streakDays'] ?? 0,
        modelVersion: json['modelVersion'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        syncStatus: SyncStatus.values.firstWhere((e) => e.name == json['syncStatus']),
        lastSyncedAt: json['lastSyncedAt'] != null ? DateTime.parse(json['lastSyncedAt']) : null,
      );
  
  DailyStats copyWith({
    int? prayersCompleted,
    int? totalRakatCompleted,
    int? totalDhikrCount,
    int? dhikrSessionsCompleted,
    int? amalItemsCompleted,
    int? totalAmalItems,
    Map<String, int>? categoryCompletionCount,
    int? pagesRead,
    Duration? readingDuration,
    double? overallScore,
    int? streakDays,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
  }) {
    return DailyStats(
      id: id,
      date: date,
      prayersCompleted: prayersCompleted ?? this.prayersCompleted,
      totalPrayers: totalPrayers,
      totalRakatCompleted: totalRakatCompleted ?? this.totalRakatCompleted,
      totalDhikrCount: totalDhikrCount ?? this.totalDhikrCount,
      dhikrSessionsCompleted: dhikrSessionsCompleted ?? this.dhikrSessionsCompleted,
      amalItemsCompleted: amalItemsCompleted ?? this.amalItemsCompleted,
      totalAmalItems: totalAmalItems ?? this.totalAmalItems,
      categoryCompletionCount: categoryCompletionCount ?? this.categoryCompletionCount,
      pagesRead: pagesRead ?? this.pagesRead,
      readingDuration: readingDuration ?? this.readingDuration,
      overallScore: overallScore ?? this.overallScore,
      streakDays: streakDays ?? this.streakDays,
      modelVersion: modelVersion,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      syncStatus: syncStatus ?? SyncStatus.pending,
      lastSyncedAt: lastSyncedAt,
    );
  }
  
  double get prayerProgress => totalPrayers > 0 ? (prayersCompleted / totalPrayers) : 0.0;
  double get amalProgress => totalAmalItems > 0 ? (amalItemsCompleted / totalAmalItems) : 0.0;
}

class MonthlyStats {
  final int month;
  final int year;
  final List<DailyStats> dailyRecords;
  final Map<String, int> categoryTotals;
  final List<Achievement> achievements;
  
  MonthlyStats({
    required this.month,
    required this.year,
    required this.dailyRecords,
    required this.categoryTotals,
    required this.achievements,
  });
  
  Map<String, dynamic> toJson() => {
        'month': month,
        'year': year,
        'dailyRecords': dailyRecords.map((d) => d.toJson()).toList(),
        'categoryTotals': categoryTotals,
        'achievements': achievements.map((a) => a.toJson()).toList(),
      };
  
  factory MonthlyStats.fromJson(Map<String, dynamic> json) => MonthlyStats(
        month: json['month'],
        year: json['year'],
        dailyRecords: (json['dailyRecords'] as List).map((d) => DailyStats.fromJson(d)).toList(),
        categoryTotals: Map<String, int>.from(json['categoryTotals']),
        achievements: (json['achievements'] as List).map((a) => Achievement.fromJson(a)).toList(),
      );
  
  int get totalPrayersCompleted => dailyRecords.fold(0, (sum, d) => sum + d.prayersCompleted);
  int get totalDhikr => dailyRecords.fold(0, (sum, d) => sum + d.totalDhikrCount);
  double get averageScore => dailyRecords.isNotEmpty
      ? dailyRecords.fold(0.0, (sum, d) => sum + d.overallScore) / dailyRecords.length
      : 0.0;
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final DateTime unlockedAt;
  
  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.unlockedAt,
  });
  
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'iconName': iconName,
        'unlockedAt': unlockedAt.toIso8601String(),
      };
  
  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        iconName: json['iconName'],
        unlockedAt: DateTime.parse(json['unlockedAt']),
      );
}


