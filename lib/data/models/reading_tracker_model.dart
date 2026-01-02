enum ReadingType {
  quran,
  tafsir,
  hadith,
}

class ReadingSession {
  final String id;
  final ReadingType type;
  final String title;
  final int? surahNumber;
  final String? surahName;
  final int? fromAyah;
  final int? toAyah;
  final int? juzNumber;
  final int? pageNumber;
  final int? pagesRead;
  final String? notes;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationMinutes;
  final bool isCompleted;

  ReadingSession({
    required this.id,
    required this.type,
    required this.title,
    this.surahNumber,
    this.surahName,
    this.fromAyah,
    this.toAyah,
    this.juzNumber,
    this.pageNumber,
    this.pagesRead,
    this.notes,
    required this.startTime,
    this.endTime,
    this.durationMinutes = 0,
    this.isCompleted = false,
  });

  ReadingSession copyWith({
    String? id,
    ReadingType? type,
    String? title,
    int? surahNumber,
    String? surahName,
    int? fromAyah,
    int? toAyah,
    int? juzNumber,
    int? pageNumber,
    int? pagesRead,
    String? notes,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
    bool? isCompleted,
  }) {
    return ReadingSession(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      surahNumber: surahNumber ?? this.surahNumber,
      surahName: surahName ?? this.surahName,
      fromAyah: fromAyah ?? this.fromAyah,
      toAyah: toAyah ?? this.toAyah,
      juzNumber: juzNumber ?? this.juzNumber,
      pageNumber: pageNumber ?? this.pageNumber,
      pagesRead: pagesRead ?? this.pagesRead,
      notes: notes ?? this.notes,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'title': title,
      'surahNumber': surahNumber,
      'surahName': surahName,
      'fromAyah': fromAyah,
      'toAyah': toAyah,
      'juzNumber': juzNumber,
      'pageNumber': pageNumber,
      'pagesRead': pagesRead,
      'notes': notes,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'durationMinutes': durationMinutes,
      'isCompleted': isCompleted,
    };
  }

  factory ReadingSession.fromJson(Map<String, dynamic> json) {
    return ReadingSession(
      id: json['id'] as String,
      type: ReadingType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      title: json['title'] as String,
      surahNumber: json['surahNumber'] as int?,
      surahName: json['surahName'] as String?,
      fromAyah: json['fromAyah'] as int?,
      toAyah: json['toAyah'] as int?,
      juzNumber: json['juzNumber'] as int?,
      pageNumber: json['pageNumber'] as int?,
      pagesRead: json['pagesRead'] as int?,
      notes: json['notes'] as String?,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      durationMinutes: json['durationMinutes'] as int? ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}

class DailyReadingGoal {
  final int quranMinutes;
  final int tafsirMinutes;
  final int hadithMinutes;

  DailyReadingGoal({
    this.quranMinutes = 15,
    this.tafsirMinutes = 10,
    this.hadithMinutes = 10,
  });

  Map<String, dynamic> toJson() {
    return {
      'quranMinutes': quranMinutes,
      'tafsirMinutes': tafsirMinutes,
      'hadithMinutes': hadithMinutes,
    };
  }

  factory DailyReadingGoal.fromJson(Map<String, dynamic> json) {
    return DailyReadingGoal(
      quranMinutes: json['quranMinutes'] as int? ?? 15,
      tafsirMinutes: json['tafsirMinutes'] as int? ?? 10,
      hadithMinutes: json['hadithMinutes'] as int? ?? 10,
    );
  }

  int get totalMinutes => quranMinutes + tafsirMinutes + hadithMinutes;
}

class ReadingTrackerModel {
  final String date;
  final List<ReadingSession> sessions;
  final DailyReadingGoal goal;

  ReadingTrackerModel({
    required this.date,
    required this.sessions,
    required this.goal,
  });

  ReadingTrackerModel copyWith({
    String? date,
    List<ReadingSession>? sessions,
    DailyReadingGoal? goal,
  }) {
    return ReadingTrackerModel(
      date: date ?? this.date,
      sessions: sessions ?? this.sessions,
      goal: goal ?? this.goal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'sessions': sessions.map((s) => s.toJson()).toList(),
      'goal': goal.toJson(),
    };
  }

  factory ReadingTrackerModel.fromJson(Map<String, dynamic> json) {
    return ReadingTrackerModel(
      date: json['date'] as String,
      sessions: (json['sessions'] as List<dynamic>?)
              ?.map((s) => ReadingSession.fromJson(Map<String, dynamic>.from(s as Map)))
              .toList() ??
          [],
      goal: json['goal'] != null
          ? DailyReadingGoal.fromJson(Map<String, dynamic>.from(json['goal'] as Map))
          : DailyReadingGoal(),
    );
  }

  factory ReadingTrackerModel.empty() {
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    return ReadingTrackerModel(
      date: dateStr,
      sessions: [],
      goal: DailyReadingGoal(),
    );
  }

  // Getters for statistics
  int get totalSessions => sessions.length;
  int get completedSessions => sessions.where((s) => s.isCompleted).length;

  int getTotalMinutesByType(ReadingType type) {
    return sessions
        .where((s) => s.type == type)
        .fold(0, (sum, s) => sum + s.durationMinutes);
  }

  int get quranMinutes => getTotalMinutesByType(ReadingType.quran);
  int get tafsirMinutes => getTotalMinutesByType(ReadingType.tafsir);
  int get hadithMinutes => getTotalMinutesByType(ReadingType.hadith);
  int get totalMinutes => quranMinutes + tafsirMinutes + hadithMinutes;

  double get quranProgress => goal.quranMinutes > 0
      ? (quranMinutes / goal.quranMinutes).clamp(0.0, 1.0)
      : 0.0;
  double get tafsirProgress => goal.tafsirMinutes > 0
      ? (tafsirMinutes / goal.tafsirMinutes).clamp(0.0, 1.0)
      : 0.0;
  double get hadithProgress => goal.hadithMinutes > 0
      ? (hadithMinutes / goal.hadithMinutes).clamp(0.0, 1.0)
      : 0.0;
  double get overallProgress => goal.totalMinutes > 0
      ? (totalMinutes / goal.totalMinutes).clamp(0.0, 1.0)
      : 0.0;

  bool get isQuranGoalMet => quranMinutes >= goal.quranMinutes;
  bool get isTafsirGoalMet => tafsirMinutes >= goal.tafsirMinutes;
  bool get isHadithGoalMet => hadithMinutes >= goal.hadithMinutes;
  bool get isAllGoalsMet => isQuranGoalMet && isTafsirGoalMet && isHadithGoalMet;
}
