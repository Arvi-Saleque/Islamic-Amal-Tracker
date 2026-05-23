import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../data/models/statistics_model.dart';
import '../../data/models/daily_amal_model.dart';
import '../../data/models/dhikr_counter_model.dart';
import '../../data/models/reading_tracker_model.dart';
import '../../data/models/prayer_tracking_model.dart';
import '../../data/services/firestore_sync_service.dart';
import 'prayer_tracking_provider.dart';
import 'daily_amal_provider.dart';
import 'dhikr_counter_provider.dart';
import 'reading_tracker_provider.dart';

/// Recursively converts dynamic Maps to Map<String, dynamic>
Map<String, dynamic> _deepConvert(Map data) {
  return data.map((key, value) {
    if (value is Map) {
      return MapEntry(key.toString(), _deepConvert(value));
    } else if (value is List) {
      return MapEntry(
        key.toString(),
        value.map((e) {
          if (e is Map) {
            return _deepConvert(e);
          }
          return e;
        }).toList(),
      );
    }
    return MapEntry(key.toString(), value);
  });
}

class StatisticsState {
  final StatisticsModel data;
  final WeeklyStatistics weeklyStats;
  final bool isLoading;

  StatisticsState({
    required this.data,
    required this.weeklyStats,
    this.isLoading = false,
  });

  StatisticsState copyWith({
    StatisticsModel? data,
    WeeklyStatistics? weeklyStats,
    bool? isLoading,
  }) {
    return StatisticsState(
      data: data ?? this.data,
      weeklyStats: weeklyStats ?? this.weeklyStats,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class StatisticsNotifier extends StateNotifier<StatisticsState> {
  Box? _box;
  final Ref _ref;

  StatisticsNotifier(this._ref)
    : super(
        StatisticsState(
          data: StatisticsModel.empty(),
          weeklyStats: WeeklyStatistics(days: []),
        ),
      ) {
    _init();
  }

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    _box = await Hive.openBox('statistics');
    await _waitForOtherBoxes();
    loadData();
  }

  // Wait for other data boxes to be ready
  Future<void> _waitForOtherBoxes() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      // Ignore
    }
  }

  String get _todayKey {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  void loadData() {
    if (_box == null) return;
    state = state.copyWith(isLoading: true);
    final data = _box!.get('statistics_data');
    if (data != null) {
      final statsModel = StatisticsModel.fromJson(_deepConvert(data));
      state = state.copyWith(
        data: statsModel,
        weeklyStats: statsModel.getWeeklyStats(),
        isLoading: false,
      );
    }
    // Rebuild from all boxes to ensure data is up-to-date
    rebuildFromBoxes();
  }

  /// Force refresh weekly stats from current data
  void refreshWeeklyStats() {
    state = state.copyWith(weeklyStats: state.data.getWeeklyStats());
  }

  /// Rebuild statistics from all individual data boxes
  Future<void> rebuildFromBoxes() async {
    try {
      state = state.copyWith(isLoading: true);

      final prayerBox = await Hive.openBox('prayer_tracking');
      final amalBox = await Hive.openBox('daily_amal');
      final dhikrBox = await Hive.openBox('dhikr_counter');
      final readingBox = await Hive.openBox('reading_tracker');

      final updatedDailyStats = Map<String, DailyStatistics>.from(
        state.data.dailyStats,
      );

      // Get all unique dates from all boxes
      final allDates = <String>{};
      for (var key in prayerBox.keys) {
        if (key is String && key.contains('-')) allDates.add(key);
      }
      for (var key in amalBox.keys) {
        if (key is String && key.contains('-')) allDates.add(key);
      }
      for (var key in dhikrBox.keys) {
        if (key is String && key.contains('-')) allDates.add(key);
      }
      for (var key in readingBox.keys) {
        if (key is String && key.contains('-')) allDates.add(key);
      }

      // Rebuild stats for each date
      for (final dateKey in allDates) {
        int prayersCompleted = 0;
        int amalCompleted = 0;
        int totalAmal = 18;
        int dhikrCount = 0;
        int dhikrTarget = 600;
        int readingMinutes = 0;
        int readingTarget = 35;

        // Prayer data
        final prayerData = prayerBox.get(dateKey);
        if (prayerData != null) {
          final prayerDone = prayerData['prayerDone'] as Map?;
          if (prayerDone != null) {
            for (var done in prayerDone.values) {
              if (done == true) {
                prayersCompleted++;
              }
            }
          }
        }

        // Amal data
        final amalData = amalBox.get(dateKey);
        if (amalData != null) {
          final items = amalData['items'] as List?;
          if (items != null && items.isNotEmpty) {
            totalAmal = items.length;
            for (var item in items) {
              if (item is Map && item['isCompleted'] == true) {
                amalCompleted++;
              }
            }
          }
        }

        // Dhikr data
        final dhikrData = dhikrBox.get(dateKey);
        if (dhikrData != null) {
          final items = dhikrData['items'] as List?;
          if (items != null && items.isNotEmpty) {
            dhikrTarget = 0;
            for (var item in items) {
              if (item is Map) {
                dhikrCount +=
                    (item['currentCount'] as int? ??
                    item['count'] as int? ??
                    0);
                dhikrTarget +=
                    (item['targetCount'] as int? ??
                    item['target'] as int? ??
                    100);
              }
            }
            if (dhikrTarget == 0) dhikrTarget = 1;
          }
        }

        // Reading data
        final readingData = readingBox.get(dateKey);
        if (readingData != null) {
          final sessions = readingData['sessions'] as List?;
          if (sessions != null) {
            for (var session in sessions) {
              if (session is Map) {
                readingMinutes +=
                    (session['durationMinutes'] as int? ??
                    session['duration'] as int? ??
                    0);
              }
            }
          }
          // Get reading target from goal
          final goalData = readingData['goal'] as Map?;
          if (goalData != null) {
            readingTarget = goalData['totalMinutes'] as int? ?? 35;
          }
        }

        updatedDailyStats[dateKey] = DailyStatistics(
          date: dateKey,
          prayersCompleted: prayersCompleted,
          totalPrayers: 5,
          amalCompleted: amalCompleted,
          totalAmal: totalAmal,
          dhikrCount: dhikrCount,
          dhikrTarget: dhikrTarget,
          readingMinutes: readingMinutes,
          readingTarget: readingTarget,
        );
      }

      // Calculate streaks
      int currentStreak = _calculateCurrentStreak(updatedDailyStats);
      int bestStreak = state.data.bestStreak;
      if (currentStreak > bestStreak) {
        bestStreak = currentStreak;
      }

      final updatedModel = StatisticsModel(
        dailyStats: updatedDailyStats,
        currentStreak: currentStreak,
        bestStreak: bestStreak,
        lastActiveDate: DateTime.now(),
      );

      state = state.copyWith(
        data: updatedModel,
        weeklyStats: updatedModel.getWeeklyStats(),
        isLoading: false,
      );

      _saveToHive();
    } catch (e) {
      print('Error rebuilding stats from boxes: $e');
      state = state.copyWith(isLoading: false);
      // Fallback to updating today's stats only
      updateTodayStats();
    }
  }

  void updateTodayStats() {
    // Get current data from all providers
    final prayerState = _ref.read(prayerTrackingProvider);
    final amalState = _ref.read(dailyAmalProvider);
    final dhikrState = _ref.read(dhikrCounterProvider);
    final readingState = _ref.read(readingTrackerProvider);

    final todayStats = DailyStatistics(
      date: _todayKey,
      prayersCompleted: prayerState.todayData.completedPrayersCount,
      totalPrayers: 5,
      amalCompleted: amalState.todayData.completedCount,
      totalAmal: amalState.todayData.totalCount,
      dhikrCount: dhikrState.todayData.totalCount,
      dhikrTarget: dhikrState.todayData.totalTarget,
      readingMinutes: readingState.todayData.totalMinutes,
      readingTarget: readingState.todayData.goal.totalMinutes,
    );

    // Update daily stats map
    final updatedDailyStats = Map<String, DailyStatistics>.from(
      state.data.dailyStats,
    );
    updatedDailyStats[_todayKey] = todayStats;

    // Calculate streaks
    int currentStreak = _calculateCurrentStreak(updatedDailyStats);
    int bestStreak = state.data.bestStreak;
    if (currentStreak > bestStreak) {
      bestStreak = currentStreak;
    }

    final updatedModel = StatisticsModel(
      dailyStats: updatedDailyStats,
      currentStreak: currentStreak,
      bestStreak: bestStreak,
      lastActiveDate: DateTime.now(),
    );

    state = state.copyWith(
      data: updatedModel,
      weeklyStats: updatedModel.getWeeklyStats(),
    );

    _saveToHive();
  }

  int _calculateCurrentStreak(Map<String, DailyStatistics> dailyStats) {
    int streak = 0;
    final now = DateTime.now();

    for (int i = 0; i < 365; i++) {
      final date = now.subtract(Duration(days: i));
      final dateStr = _formatDate(date);
      final dayStats = dailyStats[dateStr];

      if (dayStats != null && dayStats.overallScore >= 60) {
        streak++;
      } else if (i > 0) {
        // Allow today to be incomplete
        break;
      }
    }

    return streak;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _saveToHive() {
    final json = state.data.toJson();
    _box?.put('statistics_data', json);
    // Sync to cloud
    firestoreSyncService.syncStatistics(json);
  }

  List<DailyStatistics> getMonthlyStats() {
    return state.data.getMonthlyStats();
  }

  DailyStatistics? getStatsForDate(String date) {
    return state.data.dailyStats[date];
  }

  // Get detailed data for a specific date
  Future<DayDetailedData> getDetailedDataForDate(String dateKey) async {
    final amalBox = await Hive.openBox('daily_amal');
    final dhikrBox = await Hive.openBox('dhikr_counter');
    final readingBox = await Hive.openBox('reading_tracker');
    final prayerBox = await Hive.openBox('prayer_tracking');

    // Get Amal data
    final amalData = amalBox.get(dateKey);
    DailyAmalModel? amalModel;
    if (amalData != null) {
      amalModel = DailyAmalModel.fromJson(Map<String, dynamic>.from(amalData));
    }

    // Get Dhikr data
    final dhikrData = dhikrBox.get(dateKey);
    DhikrCounterModel? dhikrModel;
    if (dhikrData != null) {
      dhikrModel = DhikrCounterModel.fromJson(
        Map<String, dynamic>.from(dhikrData),
      );
    }

    // Get Reading data
    final readingData = readingBox.get(dateKey);
    ReadingTrackerModel? readingModel;
    if (readingData != null) {
      readingModel = ReadingTrackerModel.fromJson(
        Map<String, dynamic>.from(readingData),
      );
    }

    // Get Prayer data
    final prayerData = prayerBox.get(dateKey);
    PrayerTrackingModel? prayerModel;
    if (prayerData != null) {
      prayerModel = PrayerTrackingModel.fromJson(
        Map<String, dynamic>.from(prayerData),
      );
    }

    return DayDetailedData(
      amalModel: amalModel,
      dhikrModel: dhikrModel,
      readingModel: readingModel,
      prayerModel: prayerModel,
    );
  }
}

class DayDetailedData {
  final DailyAmalModel? amalModel;
  final DhikrCounterModel? dhikrModel;
  final ReadingTrackerModel? readingModel;
  final PrayerTrackingModel? prayerModel;

  DayDetailedData({
    this.amalModel,
    this.dhikrModel,
    this.readingModel,
    this.prayerModel,
  });
}

final statisticsProvider =
    StateNotifierProvider<StatisticsNotifier, StatisticsState>((ref) {
      return StatisticsNotifier(ref);
    });
