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

class DhikrCounterState {
  final DhikrCounterModel todayData;
  final bool isLoading;

  DhikrCounterState({
    required this.todayData,
    this.isLoading = false,
  });

  DhikrCounterState copyWith({
    DhikrCounterModel? todayData,
    bool? isLoading,
  }) {
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

  void loadTodayData() {
    if (_box == null) return;
    final data = _box!.get(_todayKey);
    if (data != null) {
      state = state.copyWith(
        todayData: DhikrCounterModel.fromJson(_deepConvert(data)),
      );
    } else {
      // Create new data for today
      final newData = DhikrCounterModel.empty();
      state = state.copyWith(todayData: newData);
      _saveToHive();
    }
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
        return item.copyWith(
          currentCount: 0,
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

  void resetAllDhikr() {
    final updatedItems = state.todayData.items.map((item) {
      return item.copyWith(
        currentCount: 0,
        lastUpdated: DateTime.now(),
      );
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
