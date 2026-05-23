import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../../data/models/prayer_tracking_model.dart';
import '../../data/services/firestore_sync_service.dart';

// Prayer tracking state
class PrayerTrackingState {
  final PrayerTrackingModel todayData;
  final bool isLoading;

  PrayerTrackingState({required this.todayData, this.isLoading = false});

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
    : super(
        PrayerTrackingState(
          todayData: PrayerTrackingModel.empty(_getTodayDate()),
        ),
      ) {
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
        var model = PrayerTrackingModel.fromJson(
          Map<String, dynamic>.from(data),
        );

        // Migrate old data: Fix Zuhr prayer from 2 to 4 rakat farz
        model = _migrateOldData(model);

        state = state.copyWith(todayData: model);
        await _saveTodayData(); // Save migrated data
      } catch (e) {
        print('Error loading prayer data: $e');
        state = state.copyWith(todayData: PrayerTrackingModel.empty(today));
        await _saveTodayData();
      }
    } else {
      // Create new data for today
      state = state.copyWith(todayData: PrayerTrackingModel.empty(today));
      await _saveTodayData();
    }
  }

  // Migrate old data format to new format with 2 fard options
  PrayerTrackingModel _migrateOldData(PrayerTrackingModel model) {
    final oldRakatsDone = model.rakatsDone;
    final newRakatsDone = <String, Map<String, bool>>{};
    final prayerDone = Map<String, bool>.from(model.prayerDone);
    bool needsMigration = false;

    // Define new format for each prayer
    final newFormats = {
      'ফজর': {
        '২ রাকাত ফরয (জামাতে/আউয়াল ওয়াক্তে)': false,
        '২ রাকাত ফরয (দেরী করে)': false,
        '২ রাকাত সুন্নাত': false,
      },
      'যোহর': {
        '৪ রাকাত সুন্নাত (আগে)': false,
        '৪ রাকাত ফরয (জামাতে/আউয়াল ওয়াক্তে)': false,
        '৪ রাকাত ফরয (দেরী করে)': false,
        '২ রাকাত সুন্নাত (পরে)': false,
      },
      'আসর': {
        '৪ রাকাত ফরয (জামাতে/আউয়াল ওয়াক্তে)': false,
        '৪ রাকাত ফরয (দেরী করে)': false,
      },
      'মাগরিব': {
        '৩ রাকাত ফরয (জামাতে/আউয়াল ওয়াক্তে)': false,
        '৩ রাকাত ফরয (দেরী করে)': false,
        '২ রাকাত সুন্নাত': false,
      },
      'এশা': {
        '৪ রাকাত ফরয (জামাতে/আউয়াল ওয়াক্তে)': false,
        '৪ রাকাত ফরয (দেরী করে)': false,
        '২ রাকাত সুন্নাত': false,
        '৩ রাকাত বেতের': false,
      },
    };

    // Check each prayer and migrate
    for (final prayer in ['ফজর', 'যোহর', 'আসর', 'মাগরিব', 'এশা']) {
      final newRakats = Map<String, bool>.from(newFormats[prayer]!);
      final validKeys = newFormats[prayer]!.keys.toSet();

      if (oldRakatsDone.containsKey(prayer)) {
        final oldRakats = oldRakatsDone[prayer]!;

        // Check if keys match exactly
        final oldKeys = oldRakats.keys.toSet();
        if (oldKeys.length != validKeys.length ||
            !oldKeys.containsAll(validKeys)) {
          needsMigration = true;

          // Transfer old values to new format
          for (final oldKey in oldRakats.keys) {
            if (oldRakats[oldKey] == true) {
              // Map old fard to first fard option (জামাতে/আউয়াল ওয়াক্তে)
              if (oldKey.contains('ফরয') &&
                  !oldKey.contains('(জামাতে') &&
                  !oldKey.contains('(দেরী')) {
                for (final newKey in newRakats.keys) {
                  if (newKey.contains('ফরয (জামাতে')) {
                    newRakats[newKey] = true;
                    break;
                  }
                }
              }
              // If already new format fard, keep it
              if (newRakats.containsKey(oldKey)) {
                newRakats[oldKey] = true;
              }
              // Map sunnah values
              if (oldKey.contains('সুন্নাত')) {
                for (final newKey in newRakats.keys) {
                  if (newKey.contains('সুন্নাত') &&
                      ((oldKey.contains('(আগে)') && newKey.contains('(আগে)')) ||
                          (oldKey.contains('(পরে)') &&
                              newKey.contains('(পরে)')) ||
                          (!oldKey.contains('(') && !newKey.contains('(')))) {
                    newRakats[newKey] = true;
                  }
                }
              }
            }
          }

          // Update prayerDone based on any fard being done
          final anyFardDone = newRakats.entries.any(
            (e) => e.key.contains('ফরয') && e.value,
          );
          prayerDone[prayer] = anyFardDone;
        } else {
          // Keys match, keep old values
          for (final key in validKeys) {
            newRakats[key] = oldRakats[key] ?? false;
          }
        }
      } else {
        needsMigration = true;
      }

      newRakatsDone[prayer] = newRakats;
    }

    if (needsMigration) {
      return model.copyWith(rakatsDone: newRakatsDone, prayerDone: prayerDone);
    }

    return model.copyWith(rakatsDone: newRakatsDone);
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

    // Update rakats - when toggling on, check first fard option only
    // When toggling off, uncheck all
    final newRakatsDone = Map<String, Map<String, bool>>.from(
      state.todayData.rakatsDone,
    );
    if (newRakatsDone.containsKey(prayer)) {
      final rakats = Map<String, bool>.from(newRakatsDone[prayer]!);
      if (newValue) {
        // Find first fard option and check it
        bool firstFardChecked = false;
        for (var rakat in rakats.keys) {
          if (rakat.contains('ফরয') && !firstFardChecked) {
            rakats[rakat] = true;
            firstFardChecked = true;
          } else if (rakat.contains('ফরয')) {
            rakats[rakat] = false; // Uncheck other fard options
          }
          // Don't change sunnah/witr status when toggling prayer
        }
      } else {
        // Uncheck all when toggling off
        for (var rakat in rakats.keys) {
          rakats[rakat] = false;
        }
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
    final newRakatsDone = Map<String, Map<String, bool>>.from(
      state.todayData.rakatsDone,
    );

    if (newRakatsDone.containsKey(prayer)) {
      final rakats = Map<String, bool>.from(newRakatsDone[prayer]!);

      // If selecting a fard option, uncheck the other fard option (they are mutually exclusive)
      final isFardOption = rakat.contains('ফরয');
      if (isFardOption && !(rakats[rakat] ?? false)) {
        // Uncheck other fard options when checking this one
        for (final key in rakats.keys.toList()) {
          if (key.contains('ফরয') && key != rakat) {
            rakats[key] = false;
          }
        }
      }

      rakats[rakat] = !(rakats[rakat] ?? false);
      newRakatsDone[prayer] = rakats;

      // Check if any fard is done - prayer is complete if any fard option is checked
      final anyFardDone = rakats.entries.any(
        (e) => e.key.contains('ফরয') && e.value,
      );
      final newPrayerDone = Map<String, bool>.from(state.todayData.prayerDone);
      newPrayerDone[prayer] = anyFardDone;

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
    'যোহর': false,
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
