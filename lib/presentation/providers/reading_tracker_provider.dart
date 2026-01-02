import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../data/models/reading_tracker_model.dart';

/// Recursively converts dynamic Maps to Map<String, dynamic>
Map<String, dynamic> _deepConvert(Map data) {
  return data.map((key, value) {
    if (value is Map) {
      return MapEntry(key.toString(), _deepConvert(value));
    } else if (value is List) {
      return MapEntry(key.toString(), value.map((e) {
        if (e is Map) {
          return _deepConvert(e);
        }
        return e;
      }).toList());
    }
    return MapEntry(key.toString(), value);
  });
}

class ReadingTrackerState {
  final ReadingTrackerModel todayData;
  final bool isLoading;

  ReadingTrackerState({
    required this.todayData,
    this.isLoading = false,
  });

  ReadingTrackerState copyWith({
    ReadingTrackerModel? todayData,
    bool? isLoading,
  }) {
    return ReadingTrackerState(
      todayData: todayData ?? this.todayData,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ReadingTrackerNotifier extends StateNotifier<ReadingTrackerState> {
  Box? _box;

  ReadingTrackerNotifier()
      : super(ReadingTrackerState(todayData: ReadingTrackerModel.empty())) {
    _init();
  }

  Future<void> _init() async {
    _box = await Hive.openBox('reading_tracker');
    loadTodayData();
  }

  String get _todayKey {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  void loadTodayData() {
    if (_box == null) return;
    final data = _box!.get(_todayKey);
    if (data != null) {
      state = state.copyWith(
        todayData: ReadingTrackerModel.fromJson(_deepConvert(data)),
      );
    } else {
      final newData = ReadingTrackerModel.empty();
      state = state.copyWith(todayData: newData);
      _saveToHive();
    }
  }

  void addSession({
    required ReadingType type,
    required String title,
    int? surahNumber,
    String? surahName,
    int? fromAyah,
    int? toAyah,
    int? juzNumber,
    int? pageNumber,
    int? pagesRead,
    String? notes,
    required int durationMinutes,
  }) {
    final sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
    final newSession = ReadingSession(
      id: sessionId,
      type: type,
      title: title,
      surahNumber: surahNumber,
      surahName: surahName,
      fromAyah: fromAyah,
      toAyah: toAyah,
      juzNumber: juzNumber,
      pageNumber: pageNumber,
      pagesRead: pagesRead,
      notes: notes,
      startTime: DateTime.now(),
      endTime: DateTime.now(),
      durationMinutes: durationMinutes,
      isCompleted: true,
    );

    final updatedSessions = [...state.todayData.sessions, newSession];
    state = state.copyWith(
      todayData: state.todayData.copyWith(sessions: updatedSessions),
    );
    _saveToHive();
  }

  void updateSession(String sessionId, {
    String? title,
    int? surahNumber,
    String? surahName,
    int? fromAyah,
    int? toAyah,
    int? juzNumber,
    int? pageNumber,
    int? pagesRead,
    String? notes,
    int? durationMinutes,
  }) {
    final updatedSessions = state.todayData.sessions.map((session) {
      if (session.id == sessionId) {
        return session.copyWith(
          title: title ?? session.title,
          surahNumber: surahNumber ?? session.surahNumber,
          surahName: surahName ?? session.surahName,
          fromAyah: fromAyah ?? session.fromAyah,
          toAyah: toAyah ?? session.toAyah,
          juzNumber: juzNumber ?? session.juzNumber,
          pageNumber: pageNumber ?? session.pageNumber,
          pagesRead: pagesRead ?? session.pagesRead,
          notes: notes ?? session.notes,
          durationMinutes: durationMinutes ?? session.durationMinutes,
        );
      }
      return session;
    }).toList();

    state = state.copyWith(
      todayData: state.todayData.copyWith(sessions: updatedSessions),
    );
    _saveToHive();
  }

  void deleteSession(String sessionId) {
    final updatedSessions = state.todayData.sessions
        .where((session) => session.id != sessionId)
        .toList();

    state = state.copyWith(
      todayData: state.todayData.copyWith(sessions: updatedSessions),
    );
    _saveToHive();
  }

  void updateGoal({
    int? quranMinutes,
    int? tafsirMinutes,
    int? hadithMinutes,
  }) {
    final newGoal = DailyReadingGoal(
      quranMinutes: quranMinutes ?? state.todayData.goal.quranMinutes,
      tafsirMinutes: tafsirMinutes ?? state.todayData.goal.tafsirMinutes,
      hadithMinutes: hadithMinutes ?? state.todayData.goal.hadithMinutes,
    );

    state = state.copyWith(
      todayData: state.todayData.copyWith(goal: newGoal),
    );
    _saveToHive();
  }

  void _saveToHive() {
    _box?.put(_todayKey, state.todayData.toJson());
  }

  List<ReadingSession> getSessionsByType(ReadingType type) {
    return state.todayData.sessions
        .where((session) => session.type == type)
        .toList();
  }

  ReadingSession? getSessionById(String sessionId) {
    try {
      return state.todayData.sessions.firstWhere(
        (session) => session.id == sessionId,
      );
    } catch (e) {
      return null;
    }
  }
}

final readingTrackerProvider =
    StateNotifierProvider<ReadingTrackerNotifier, ReadingTrackerState>((ref) {
  return ReadingTrackerNotifier();
});
