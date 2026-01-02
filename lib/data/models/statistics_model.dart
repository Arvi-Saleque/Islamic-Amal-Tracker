class DailyStatistics {
  final String date;
  final int prayersCompleted;
  final int totalPrayers;
  final int amalCompleted;
  final int totalAmal;
  final int dhikrCount;
  final int dhikrTarget;
  final int readingMinutes;
  final int readingTarget;

  DailyStatistics({
    required this.date,
    this.prayersCompleted = 0,
    this.totalPrayers = 5,
    this.amalCompleted = 0,
    this.totalAmal = 18,
    this.dhikrCount = 0,
    this.dhikrTarget = 700,
    this.readingMinutes = 0,
    this.readingTarget = 35,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'prayersCompleted': prayersCompleted,
      'totalPrayers': totalPrayers,
      'amalCompleted': amalCompleted,
      'totalAmal': totalAmal,
      'dhikrCount': dhikrCount,
      'dhikrTarget': dhikrTarget,
      'readingMinutes': readingMinutes,
      'readingTarget': readingTarget,
    };
  }

  factory DailyStatistics.fromJson(Map<String, dynamic> json) {
    return DailyStatistics(
      date: json['date'] as String,
      prayersCompleted: json['prayersCompleted'] as int? ?? 0,
      totalPrayers: json['totalPrayers'] as int? ?? 5,
      amalCompleted: json['amalCompleted'] as int? ?? 0,
      totalAmal: json['totalAmal'] as int? ?? 18,
      dhikrCount: json['dhikrCount'] as int? ?? 0,
      dhikrTarget: json['dhikrTarget'] as int? ?? 700,
      readingMinutes: json['readingMinutes'] as int? ?? 0,
      readingTarget: json['readingTarget'] as int? ?? 35,
    );
  }

  double get prayerProgress => totalPrayers > 0 ? prayersCompleted / totalPrayers : 0.0;
  double get amalProgress => totalAmal > 0 ? amalCompleted / totalAmal : 0.0;
  double get dhikrProgress => dhikrTarget > 0 ? (dhikrCount / dhikrTarget).clamp(0.0, 1.0) : 0.0;
  double get readingProgress => readingTarget > 0 ? (readingMinutes / readingTarget).clamp(0.0, 1.0) : 0.0;
  
  double get overallProgress {
    return (prayerProgress + amalProgress + dhikrProgress + readingProgress) / 4;
  }

  int get overallScore {
    return (overallProgress * 100).toInt();
  }
}

class WeeklyStatistics {
  final List<DailyStatistics> days;
  final int currentStreak;
  final int bestStreak;

  WeeklyStatistics({
    required this.days,
    this.currentStreak = 0,
    this.bestStreak = 0,
  });

  int get totalPrayersCompleted => days.fold(0, (sum, d) => sum + d.prayersCompleted);
  int get totalAmalCompleted => days.fold(0, (sum, d) => sum + d.amalCompleted);
  int get totalDhikrCount => days.fold(0, (sum, d) => sum + d.dhikrCount);
  int get totalReadingMinutes => days.fold(0, (sum, d) => sum + d.readingMinutes);

  double get averagePrayerProgress {
    if (days.isEmpty) return 0.0;
    return days.map((d) => d.prayerProgress).reduce((a, b) => a + b) / days.length;
  }

  double get averageAmalProgress {
    if (days.isEmpty) return 0.0;
    return days.map((d) => d.amalProgress).reduce((a, b) => a + b) / days.length;
  }

  double get averageDhikrProgress {
    if (days.isEmpty) return 0.0;
    return days.map((d) => d.dhikrProgress).reduce((a, b) => a + b) / days.length;
  }

  double get averageReadingProgress {
    if (days.isEmpty) return 0.0;
    return days.map((d) => d.readingProgress).reduce((a, b) => a + b) / days.length;
  }

  double get averageOverallProgress {
    if (days.isEmpty) return 0.0;
    return days.map((d) => d.overallProgress).reduce((a, b) => a + b) / days.length;
  }

  int get perfectDays => days.where((d) => d.overallScore >= 100).length;
}

class StatisticsModel {
  final Map<String, DailyStatistics> dailyStats;
  final int currentStreak;
  final int bestStreak;
  final DateTime? lastActiveDate;

  StatisticsModel({
    required this.dailyStats,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.lastActiveDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'dailyStats': dailyStats.map((key, value) => MapEntry(key, value.toJson())),
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'lastActiveDate': lastActiveDate?.toIso8601String(),
    };
  }

  factory StatisticsModel.fromJson(Map<String, dynamic> json) {
    final dailyStatsRaw = json['dailyStats'] as Map? ?? {};
    final dailyStatsJson = Map<String, dynamic>.from(dailyStatsRaw);
    final dailyStats = dailyStatsJson.map(
      (key, value) => MapEntry(
        key,
        DailyStatistics.fromJson(Map<String, dynamic>.from(value as Map)),
      ),
    );

    return StatisticsModel(
      dailyStats: dailyStats,
      currentStreak: json['currentStreak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
      lastActiveDate: json['lastActiveDate'] != null
          ? DateTime.parse(json['lastActiveDate'] as String)
          : null,
    );
  }

  factory StatisticsModel.empty() {
    return StatisticsModel(
      dailyStats: {},
      currentStreak: 0,
      bestStreak: 0,
    );
  }

  WeeklyStatistics getWeeklyStats() {
    final now = DateTime.now();
    final weekDays = <DailyStatistics>[];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = _formatDate(date);
      weekDays.add(dailyStats[dateStr] ?? DailyStatistics(date: dateStr));
    }

    return WeeklyStatistics(
      days: weekDays,
      currentStreak: currentStreak,
      bestStreak: bestStreak,
    );
  }

  List<DailyStatistics> getMonthlyStats() {
    final now = DateTime.now();
    final monthDays = <DailyStatistics>[];

    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = _formatDate(date);
      monthDays.add(dailyStats[dateStr] ?? DailyStatistics(date: dateStr));
    }

    return monthDays;
  }

  List<DailyStatistics> getMonthlyStatsForMonth(int year, int month) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final monthDays = <DailyStatistics>[];

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final dateStr = _formatDate(date);
      monthDays.add(dailyStats[dateStr] ?? DailyStatistics(date: dateStr));
    }

    return monthDays;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
