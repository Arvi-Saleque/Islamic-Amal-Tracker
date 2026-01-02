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

class DailyAmalState {
  final DailyAmalModel todayData;
  final bool isLoading;

  DailyAmalState({
    required this.todayData,
    this.isLoading = false,
  });

  DailyAmalState copyWith({
    DailyAmalModel? todayData,
    bool? isLoading,
  }) {
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
      : super(DailyAmalState(
          todayData: DailyAmalModel.empty(_getTodayDate()),
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
      print('Error initializing daily amal: $e');
    }
  }

  Future<void> loadTodayData() async {
    if (_box == null) return;

    final today = _getTodayDate();
    final data = _box!.get(today);

    if (data != null) {
      try {
        final model = DailyAmalModel.fromJson(
          _deepConvert(data),
        );
        state = state.copyWith(todayData: model);
      } catch (e) {
        print('Error loading daily amal data: $e');
        state = state.copyWith(
          todayData: DailyAmalModel.empty(today),
        );
        await _saveTodayData();
      }
    } else {
      // Create new data for today
      state = state.copyWith(
        todayData: DailyAmalModel.empty(today),
      );
      await _saveTodayData();
    }
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

      state = state.copyWith(
        todayData: state.todayData.copyWith(items: items),
      );

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

    state = state.copyWith(
      todayData: state.todayData.copyWith(items: items),
    );

    await _saveTodayData();
  }

  Future<void> deleteItem(String itemId) async {
    final items = List<DailyAmalItem>.from(state.todayData.items);
    items.removeWhere((item) => item.id == itemId);

    state = state.copyWith(
      todayData: state.todayData.copyWith(items: items),
    );

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
