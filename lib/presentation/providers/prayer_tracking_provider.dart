import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../../data/models/prayer_tracking_model.dart';
import '../../data/services/firestore_sync_service.dart';

// Prayer tracking state
class PrayerTrackingState {
  final PrayerTrackingModel todayData;
  final bool isLoading;

  PrayerTrackingState({
    required this.todayData,
    this.isLoading = false,
  });

  PrayerTrackingState copyWith({
    PrayerTrackingModel? todayData,
    bool? isLoading,
  }) {
    return PrayerTrackingState(
      todayData: todayData ?? this.todayData,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Prayer tracking notifier
class PrayerTrackingNotifier extends StateNotifier<PrayerTrackingState> {
  static const String _boxName = 'prayer_tracking';
  Box? _box;

  PrayerTrackingNotifier()
      : super(PrayerTrackingState(
          todayData: PrayerTrackingModel.empty(_getTodayDate()),
        )) {
    _init();
  }

  static String _getTodayDate() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  Future<void> _init() async {
    try {
      _box = await Hive.openBox(_boxName);
      await loadTodayData();
    } catch (e) {
      print('Error initializing prayer tracking: $e');
    }
  }

  // Load today's data from Hive
  Future<void> loadTodayData() async {
    if (_box == null) return;

    final today = _getTodayDate();
    final data = _box!.get(today);

    if (data != null) {
      try {
        final model = PrayerTrackingModel.fromJson(
          Map<String, dynamic>.from(data),
        );
        state = state.copyWith(todayData: model);
      } catch (e) {
        print('Error loading prayer data: $e');
        state = state.copyWith(
          todayData: PrayerTrackingModel.empty(today),
        );
        await _saveTodayData();
      }
    } else {
      // Create new data for today
      state = state.copyWith(
        todayData: PrayerTrackingModel.empty(today),
      );
      await _saveTodayData();
    }
  }

  // Save today's data to Hive
  Future<void> _saveTodayData() async {
    if (_box == null) return;

    try {
      final json = state.todayData.toJson();
      _box!.put(state.todayData.date, json);
      
      // Sync to cloud
      firestoreSyncService.syncPrayerTracking(state.todayData.date, json);
    } catch (e) {
      print('Error saving prayer data: $e');
    }
  }

  // Toggle entire prayer
  Future<void> togglePrayer(String prayer) async {
    final currentValue = state.todayData.prayerDone[prayer] ?? false;
    final newValue = !currentValue;

    // Update prayer done
    final newPrayerDone = Map<String, bool>.from(state.todayData.prayerDone);
    newPrayerDone[prayer] = newValue;

    // Update all rakats
    final newRakatsDone =
        Map<String, Map<String, bool>>.from(state.todayData.rakatsDone);
    if (newRakatsDone.containsKey(prayer)) {
      final rakats = Map<String, bool>.from(newRakatsDone[prayer]!);
      for (var rakat in rakats.keys) {
        rakats[rakat] = newValue;
      }
      newRakatsDone[prayer] = rakats;
    }

    state = state.copyWith(
      todayData: state.todayData.copyWith(
        prayerDone: newPrayerDone,
        rakatsDone: newRakatsDone,
      ),
    );

    await _saveTodayData();
  }

  // Toggle individual rakat
  Future<void> toggleRakat(String prayer, String rakat) async {
    final newRakatsDone =
        Map<String, Map<String, bool>>.from(state.todayData.rakatsDone);

    if (newRakatsDone.containsKey(prayer)) {
      final rakats = Map<String, bool>.from(newRakatsDone[prayer]!);
      rakats[rakat] = !(rakats[rakat] ?? false);
      newRakatsDone[prayer] = rakats;

      // Check if all rakats are done
      final allDone = rakats.values.every((done) => done);
      final newPrayerDone = Map<String, bool>.from(state.todayData.prayerDone);
      newPrayerDone[prayer] = allDone;

      state = state.copyWith(
        todayData: state.todayData.copyWith(
          prayerDone: newPrayerDone,
          rakatsDone: newRakatsDone,
        ),
      );

      await _saveTodayData();
    }
  }

  // Get completed prayers count
  int get completedPrayersCount {
    return state.todayData.completedPrayersCount;
  }

  // Check if prayer is expanded
  final Map<String, bool> _expandedStates = {
    'ফজর': false,
    'যুহর': false,
    'আসর': false,
    'মাগরিব': false,
    'এশা': false,
  };

  bool isExpanded(String prayer) => _expandedStates[prayer] ?? false;

  void toggleExpanded(String prayer) {
    _expandedStates[prayer] = !(_expandedStates[prayer] ?? false);
  }
}

// Provider
final prayerTrackingProvider =
    StateNotifierProvider<PrayerTrackingNotifier, PrayerTrackingState>((ref) {
  return PrayerTrackingNotifier();
});
