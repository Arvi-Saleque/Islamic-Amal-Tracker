import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../data/models/dhikr_counter_model.dart';
import '../../data/services/firestore_sync_service.dart';

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

class DhikrCounterState {
  final DhikrCounterModel todayData;
  final bool isLoading;

  DhikrCounterState({required this.todayData, this.isLoading = false});

  DhikrCounterState copyWith({DhikrCounterModel? todayData, bool? isLoading}) {
    return DhikrCounterState(
      todayData: todayData ?? this.todayData,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class DhikrCounterNotifier extends StateNotifier<DhikrCounterState> {
  Box? _box;

  DhikrCounterNotifier()
    : super(DhikrCounterState(todayData: DhikrCounterModel.empty())) {
    _init();
  }

  Future<void> _init() async {
    _box = await Hive.openBox('dhikr_counter');
    loadTodayData();
  }

  String get _todayKey {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void loadTodayData() {
    if (_box == null) return;

    final data = _box!.get(_todayKey);
    if (data != null) {
      final loadedData = DhikrCounterModel.fromJson(_deepConvert(data));

      // Check if today's data has any custom dhikrs
      final hasCustomDhikrs = loadedData.items.any(
        (item) => item.isCustom == true,
      );

      if (!hasCustomDhikrs) {
        // No custom dhikrs in today's data, try to get from previous days
        final customDhikrsFromPreviousDays = _getCustomDhikrsFromPreviousDays();

        if (customDhikrsFromPreviousDays.isNotEmpty) {
          final allItems = List<DhikrItem>.from(loadedData.items);

          int customIndex = 0;
          for (final customDhikr in customDhikrsFromPreviousDays) {
            // Check if this custom dhikr already exists (by title to avoid duplicates)
            final alreadyExists = allItems.any(
              (item) =>
                  item.title == customDhikr.title && item.isCustom == true,
            );

            if (!alreadyExists) {
              // Add with new id but same title and target, reset count to 0
              allItems.add(
                DhikrItem(
                  id: 'custom_${DateTime.now().millisecondsSinceEpoch}_$customIndex',
                  title: customDhikr.title,
                  arabic: customDhikr.arabic,
                  targetCount: customDhikr.targetCount,
                  currentCount: 0,
                  isCustom: true,
                  lastUpdated: null,
                ),
              );
              customIndex++;
            }
          }

          state = state.copyWith(
            todayData: loadedData.copyWith(items: allItems),
          );
          _saveToHive();
          return;
        }
      }

      state = state.copyWith(todayData: loadedData);
    } else {
      // Create new data for today - but first check for custom dhikrs from previous days
      final customDhikrsFromPreviousDays = _getCustomDhikrsFromPreviousDays();

      // Start with empty template for today
      final newData = DhikrCounterModel.empty();

      // Add custom dhikrs from previous days (with currentCount = 0)
      if (customDhikrsFromPreviousDays.isNotEmpty) {
        final allItems = List<DhikrItem>.from(newData.items);

        int customIndex = 0;
        for (final customDhikr in customDhikrsFromPreviousDays) {
          // Check if this custom dhikr already exists (by title to avoid duplicates)
          final alreadyExists = allItems.any(
            (item) => item.title == customDhikr.title && item.isCustom == true,
          );

          if (!alreadyExists) {
            // Add with new id but same title and target, reset count to 0
            allItems.add(
              DhikrItem(
                id: 'custom_${DateTime.now().millisecondsSinceEpoch}_$customIndex',
                title: customDhikr.title,
                arabic: customDhikr.arabic,
                targetCount: customDhikr.targetCount,
                currentCount: 0,
                isCustom: true,
                lastUpdated: null,
              ),
            );
            customIndex++;
          }
        }

        state = state.copyWith(todayData: newData.copyWith(items: allItems));
      } else {
        state = state.copyWith(todayData: newData);
      }

      _saveToHive();
    }
  }

  /// Get custom dhikrs from all previous days (last 7 days)
  List<DhikrItem> _getCustomDhikrsFromPreviousDays() {
    if (_box == null) return [];

    final customDhikrs = <DhikrItem>[];

    // Check last 7 days for custom dhikrs
    for (int i = 1; i <= 7; i++) {
      final previousDate = DateTime.now().subtract(Duration(days: i));
      final previousDateStr = _getDateKey(previousDate);
      final previousData = _box!.get(previousDateStr);

      if (previousData != null) {
        try {
          final previousModel = DhikrCounterModel.fromJson(
            _deepConvert(previousData),
          );

          // Find custom dhikrs (isCustom == true)
          for (final item in previousModel.items) {
            if (item.isCustom == true) {
              // Check if we already have this dhikr (by title)
              final alreadyAdded = customDhikrs.any(
                (cd) => cd.title == item.title,
              );
              if (!alreadyAdded) {
                customDhikrs.add(item);
              }
            }
          }

          // Found data with custom items, we can stop searching
          if (customDhikrs.isNotEmpty) {
            break;
          }
        } catch (e) {
          // Error loading previous day dhikr data
        }
      }
    }

    return customDhikrs;
  }

  void incrementDhikr(String dhikrId) {
    final updatedItems = state.todayData.items.map((item) {
      if (item.id == dhikrId && item.currentCount < item.targetCount) {
        return item.copyWith(
          currentCount: item.currentCount + 1,
          lastUpdated: DateTime.now(),
        );
      }
      return item;
    }).toList();

    state = state.copyWith(
      todayData: state.todayData.copyWith(items: updatedItems),
    );
    _saveToHive();
  }

  void decrementDhikr(String dhikrId) {
    final updatedItems = state.todayData.items.map((item) {
      if (item.id == dhikrId && item.currentCount > 0) {
        return item.copyWith(
          currentCount: item.currentCount - 1,
          lastUpdated: DateTime.now(),
        );
      }
      return item;
    }).toList();

    state = state.copyWith(
      todayData: state.todayData.copyWith(items: updatedItems),
    );
    _saveToHive();
  }

  void resetDhikr(String dhikrId) {
    final updatedItems = state.todayData.items.map((item) {
      if (item.id == dhikrId) {
        return item.copyWith(currentCount: 0, lastUpdated: DateTime.now());
      }
      return item;
    }).toList();

    state = state.copyWith(
      todayData: state.todayData.copyWith(items: updatedItems),
    );
    _saveToHive();
  }

  void resetAllDhikr() {
    final updatedItems = state.todayData.items.map((item) {
      return item.copyWith(currentCount: 0, lastUpdated: DateTime.now());
    }).toList();

    state = state.copyWith(
      todayData: state.todayData.copyWith(items: updatedItems),
    );
    _saveToHive();
  }

  void addCustomDhikr(String title, String? arabic, int targetCount) {
    final customId = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    final newDhikr = DhikrItem(
      id: customId,
      title: title,
      arabic: arabic,
      targetCount: targetCount,
      isCustom: true,
    );

    final updatedItems = [...state.todayData.items, newDhikr];
    state = state.copyWith(
      todayData: state.todayData.copyWith(items: updatedItems),
    );
    _saveToHive();
  }

  void deleteDhikr(String dhikrId) {
    final updatedItems = state.todayData.items
        .where((item) => item.id != dhikrId)
        .toList();

    state = state.copyWith(
      todayData: state.todayData.copyWith(items: updatedItems),
    );
    _saveToHive();
  }

  void updateTarget(String dhikrId, int newTarget) {
    final updatedItems = state.todayData.items.map((item) {
      if (item.id == dhikrId) {
        return item.copyWith(targetCount: newTarget);
      }
      return item;
    }).toList();

    state = state.copyWith(
      todayData: state.todayData.copyWith(items: updatedItems),
    );
    _saveToHive();
  }

  void _saveToHive() {
    final json = state.todayData.toJson();
    _box?.put(_todayKey, json);

    // Sync to cloud
    firestoreSyncService.syncDhikrCounter(_todayKey, json);
  }

  DhikrItem? getDhikrById(String dhikrId) {
    try {
      return state.todayData.items.firstWhere((item) => item.id == dhikrId);
    } catch (e) {
      return null;
    }
  }
}

final dhikrCounterProvider =
    StateNotifierProvider<DhikrCounterNotifier, DhikrCounterState>((ref) {
      return DhikrCounterNotifier();
    });
