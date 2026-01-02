import 'prayer_record.dart';

class ReadingProgress {
  final String id;
  final String bookName;
  final ReadingType readingType;
  final String? bookNameAr;
  
  // Progress tracking
  final int totalPages;
  int currentPage;
  
  final int? totalPortions; // For Quran (30 Juz)
  int? currentPortion;
  
  final List<ReadingSession> sessions;
  
  final DateTime startDate;
  DateTime? completedDate;
  bool isCompleted;
  
  // Cloud sync fields
  final int modelVersion;
  final DateTime createdAt;
  DateTime updatedAt;
  SyncStatus syncStatus;
  DateTime? lastSyncedAt;
  
  ReadingProgress({
    required this.id,
    required this.bookName,
    required this.readingType,
    this.bookNameAr,
    required this.totalPages,
    this.currentPage = 0,
    this.totalPortions,
    this.currentPortion,
    List<ReadingSession>? sessions,
    required this.startDate,
    this.completedDate,
    this.isCompleted = false,
    required this.modelVersion,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = SyncStatus.pending,
    this.lastSyncedAt,
  }) : sessions = sessions ?? [];
  
  Map<String, dynamic> toJson() => {
        'id': id,
        'bookName': bookName,
        'readingType': readingType.name,
        'bookNameAr': bookNameAr,
        'totalPages': totalPages,
        'currentPage': currentPage,
        'totalPortions': totalPortions,
        'currentPortion': currentPortion,
        'sessions': sessions.map((s) => s.toJson()).toList(),
        'startDate': startDate.toIso8601String(),
        'completedDate': completedDate?.toIso8601String(),
        'isCompleted': isCompleted,
        'modelVersion': modelVersion,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'syncStatus': syncStatus.name,
        'lastSyncedAt': lastSyncedAt?.toIso8601String(),
      };
  
  factory ReadingProgress.fromJson(Map<String, dynamic> json) => ReadingProgress(
        id: json['id'],
        bookName: json['bookName'],
        readingType: ReadingType.values.firstWhere((e) => e.name == json['readingType']),
        bookNameAr: json['bookNameAr'],
        totalPages: json['totalPages'],
        currentPage: json['currentPage'] ?? 0,
        totalPortions: json['totalPortions'],
        currentPortion: json['currentPortion'],
        sessions: (json['sessions'] as List?)?.map((s) => ReadingSession.fromJson(s)).toList() ?? [],
        startDate: DateTime.parse(json['startDate']),
        completedDate: json['completedDate'] != null ? DateTime.parse(json['completedDate']) : null,
        isCompleted: json['isCompleted'] ?? false,
        modelVersion: json['modelVersion'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        syncStatus: SyncStatus.values.firstWhere((e) => e.name == json['syncStatus']),
        lastSyncedAt: json['lastSyncedAt'] != null ? DateTime.parse(json['lastSyncedAt']) : null,
      );
  
  ReadingProgress copyWith({
    int? currentPage,
    int? currentPortion,
    List<ReadingSession>? sessions,
    DateTime? completedDate,
    bool? isCompleted,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
  }) {
    return ReadingProgress(
      id: id,
      bookName: bookName,
      readingType: readingType,
      bookNameAr: bookNameAr,
      totalPages: totalPages,
      currentPage: currentPage ?? this.currentPage,
      totalPortions: totalPortions,
      currentPortion: currentPortion ?? this.currentPortion,
      sessions: sessions ?? this.sessions,
      startDate: startDate,
      completedDate: completedDate ?? this.completedDate,
      isCompleted: isCompleted ?? this.isCompleted,
      modelVersion: modelVersion,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      syncStatus: syncStatus ?? SyncStatus.pending,
      lastSyncedAt: lastSyncedAt,
    );
  }
  
  double get progress => totalPages > 0 ? (currentPage / totalPages).clamp(0.0, 1.0) : 0.0;
}

class ReadingSession {
  final DateTime date;
  final int pagesRead;
  final Duration duration;
  final String? notes;
  
  ReadingSession({
    required this.date,
    required this.pagesRead,
    required this.duration,
    this.notes,
  });
  
  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'pagesRead': pagesRead,
        'duration': duration.inSeconds,
        'notes': notes,
      };
  
  factory ReadingSession.fromJson(Map<String, dynamic> json) => ReadingSession(
        date: DateTime.parse(json['date']),
        pagesRead: json['pagesRead'],
        duration: Duration(seconds: json['duration']),
        notes: json['notes'],
      );
}

