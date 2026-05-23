import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../../data/models/daily_amal_model.dart';
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

class DailyAmalState {
  final DailyAmalModel todayData;
  final bool isLoading;

  DailyAmalState({required this.todayData, this.isLoading = false});

  DailyAmalState copyWith({DailyAmalModel? todayData, bool? isLoading}) {
    return DailyAmalState(
      todayData: todayData ?? this.todayData,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class DailyAmalNotifier extends StateNotifier<DailyAmalState> {
  static const String _boxName = 'daily_amal';
  Box? _box;

  DailyAmalNotifier()
    : super(DailyAmalState(todayData: DailyAmalModel.empty(_getTodayDate()))) {
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
      print('Error initializing daily amal: $e');
    }
  }

  Future<void> loadTodayData() async {
    if (_box == null) return;

    final today = _getTodayDate();
    final data = _box!.get(today);

    if (data != null) {
      try {
        final model = DailyAmalModel.fromJson(_deepConvert(data));

        // Check if today's data has any custom items
        final hasCustomItems = model.items.any(
          (item) => item.id.startsWith('custom_'),
        );

        if (!hasCustomItems) {
          // No custom items in today's data, try to get from previous days
          final customItemsFromPreviousDays =
              await _getCustomItemsFromPreviousDays();

          if (customItemsFromPreviousDays.isNotEmpty) {
            final allItems = List<DailyAmalItem>.from(model.items);

            for (final customItem in customItemsFromPreviousDays) {
              // Check if this custom item already exists (by title to avoid duplicates)
              final alreadyExists = allItems.any(
                (item) =>
                    item.title == customItem.title &&
                    item.id.startsWith('custom_'),
              );

              if (!alreadyExists) {
                // Add with new id but same title, reset completion status
                allItems.add(
                  DailyAmalItem(
                    id: 'custom_${DateTime.now().millisecondsSinceEpoch}_${customItemsFromPreviousDays.indexOf(customItem)}',
                    title: customItem.title,
                    category: customItem.category,
                    isCompleted: false,
                    completedAt: null,
                  ),
                );
              }
            }

            state = state.copyWith(todayData: model.copyWith(items: allItems));
            await _saveTodayData();
            return;
          }
        }

        state = state.copyWith(todayData: model);
      } catch (e) {
        print('Error loading daily amal data: $e');
        state = state.copyWith(todayData: DailyAmalModel.empty(today));
        await _saveTodayData();
      }
    } else {
      // Create new data for today - but first check for custom items from previous days
      final customItemsFromPreviousDays =
          await _getCustomItemsFromPreviousDays();

      // Start with empty template for today
      final newModel = DailyAmalModel.empty(today);

      // Add custom items from previous days (with isCompleted = false)
      if (customItemsFromPreviousDays.isNotEmpty) {
        final allItems = List<DailyAmalItem>.from(newModel.items);

        for (final customItem in customItemsFromPreviousDays) {
          // Check if this custom item already exists (by title to avoid duplicates)
          final alreadyExists = allItems.any(
            (item) =>
                item.title == customItem.title && item.id.startsWith('custom_'),
          );

          if (!alreadyExists) {
            // Add with new id but same title, reset completion status
            allItems.add(
              DailyAmalItem(
                id: 'custom_${DateTime.now().millisecondsSinceEpoch}_${customItemsFromPreviousDays.indexOf(customItem)}',
                title: customItem.title,
                category: customItem.category,
                isCompleted: false,
                completedAt: null,
              ),
            );
          }
        }

        state = state.copyWith(todayData: newModel.copyWith(items: allItems));
      } else {
        state = state.copyWith(todayData: newModel);
      }

      await _saveTodayData();
    }
  }

  /// Get custom items from the most recent previous day that has data
  Future<List<DailyAmalItem>> _getCustomItemsFromPreviousDays() async {
    if (_box == null) return [];

    final customItems = <DailyAmalItem>[];

    // Check last 7 days for custom items
    for (int i = 1; i <= 7; i++) {
      final previousDate = DateTime.now().subtract(Duration(days: i));
      final previousDateStr = DateFormat('yyyy-MM-dd').format(previousDate);
      final previousData = _box!.get(previousDateStr);

      if (previousData != null) {
        try {
          final previousModel = DailyAmalModel.fromJson(
            _deepConvert(previousData),
          );

          // Find custom items (id starts with 'custom_')
          for (final item in previousModel.items) {
            if (item.id.startsWith('custom_')) {
              // Check if we already have this item (by title)
              final alreadyAdded = customItems.any(
                (ci) => ci.title == item.title,
              );
              if (!alreadyAdded) {
                customItems.add(item);
              }
            }
          }

          // If we found data, we have the custom items we need
          if (customItems.isNotEmpty) {
            break;
          }
        } catch (e) {
          print('Error loading previous day data: $e');
        }
      }
    }

    return customItems;
  }

  Future<void> _saveTodayData() async {
    if (_box == null) return;

    try {
      final json = state.todayData.toJson();
      _box!.put(state.todayData.date, json);

      // Sync to cloud
      firestoreSyncService.syncDailyAmal(state.todayData.date, json);
    } catch (e) {
      print('Error saving daily amal data: $e');
    }
  }

  Future<void> toggleItem(String itemId) async {
    final items = List<DailyAmalItem>.from(state.todayData.items);
    final index = items.indexWhere((item) => item.id == itemId);

    if (index != -1) {
      final item = items[index];
      items[index] = item.copyWith(
        isCompleted: !item.isCompleted,
        completedAt: !item.isCompleted ? DateTime.now() : null,
      );

      state = state.copyWith(todayData: state.todayData.copyWith(items: items));

      await _saveTodayData();
    }
  }

  Future<void> addCustomItem(String title, String category) async {
    final items = List<DailyAmalItem>.from(state.todayData.items);
    final newItem = DailyAmalItem(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      category: category,
    );

    items.add(newItem);

    state = state.copyWith(todayData: state.todayData.copyWith(items: items));

    await _saveTodayData();
  }

  Future<void> deleteItem(String itemId) async {
    final items = List<DailyAmalItem>.from(state.todayData.items);
    items.removeWhere((item) => item.id == itemId);

    state = state.copyWith(todayData: state.todayData.copyWith(items: items));

    await _saveTodayData();
  }

  int get completedCount => state.todayData.completedCount;
  int get totalCount => state.todayData.totalCount;

  List<DailyAmalItem> getItemsByCategory(String category) {
    return state.todayData.items
        .where((item) => item.category == category)
        .toList();
  }
}

final dailyAmalProvider =
    StateNotifierProvider<DailyAmalNotifier, DailyAmalState>((ref) {
      return DailyAmalNotifier();
    });
