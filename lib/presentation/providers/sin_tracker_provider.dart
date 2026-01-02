import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../data/models/sin_tracker_model.dart';
import '../../data/services/firestore_sync_service.dart';

class SinTrackerState {
  final DailySinRecord todayRecord;
  final List<SinType> sinTypes; // ডিফল্ট + কাস্টম
  final bool isLoading;

  SinTrackerState({
    required this.todayRecord,
    required this.sinTypes,
    this.isLoading = false,
  });

  SinTrackerState copyWith({
    DailySinRecord? todayRecord,
    List<SinType>? sinTypes,
    bool? isLoading,
  }) {
    return SinTrackerState(
      todayRecord: todayRecord ?? this.todayRecord,
      sinTypes: sinTypes ?? this.sinTypes,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SinTrackerNotifier extends StateNotifier<SinTrackerState> {
  static const String _boxName = 'sin_tracker';
  static const String _sinTypesKey = 'sin_types';
  
  SinTrackerNotifier() : super(SinTrackerState(
    todayRecord: DailySinRecord(
      date: _getTodayDate(),
      records: [],
    ),
    sinTypes: getDefaultSinTypes(),
    isLoading: true,
  )) {
    _loadData();
  }

  static String _getTodayDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _loadData() async {
    try {
      final box = await Hive.openBox(_boxName);
      final today = _getTodayDate();
      
      // Load sin types (default + custom)
      final sinTypesData = box.get(_sinTypesKey);
      List<SinType> sinTypes = getDefaultSinTypes();
      
      if (sinTypesData != null) {
        final List<dynamic> typesList = List<dynamic>.from(sinTypesData);
        final customTypes = typesList.map((s) {
          final map = _deepConvert(Map<String, dynamic>.from(s));
          return SinType.fromJson(map);
        }).where((t) => !t.isDefault).toList();
        
        sinTypes = [...getDefaultSinTypes(), ...customTypes];
      }
      
      // Load today's record
      final todayData = box.get(today);
      DailySinRecord todayRecord;
      
      if (todayData != null) {
        final map = _deepConvert(Map<String, dynamic>.from(todayData));
        todayRecord = DailySinRecord.fromJson(map);
      } else {
        // Initialize with empty records for all sin types
        todayRecord = DailySinRecord(
          date: today, 
          records: sinTypes.map((t) => SinRecord(sinTypeId: t.id)).toList(),
        );
      }
      
      // Ensure all sin types have a record
      final existingIds = todayRecord.records.map((r) => r.sinTypeId).toSet();
      final missingRecords = sinTypes
          .where((t) => !existingIds.contains(t.id))
          .map((t) => SinRecord(sinTypeId: t.id))
          .toList();
      
      if (missingRecords.isNotEmpty) {
        todayRecord = todayRecord.copyWith(
          records: [...todayRecord.records, ...missingRecords],
        );
      }
      
      state = SinTrackerState(
        todayRecord: todayRecord,
        sinTypes: sinTypes,
        isLoading: false,
      );
    } catch (e) {
      print('Error loading sin tracker data: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Map<String, dynamic> _deepConvert(Map<dynamic, dynamic> map) {
    return map.map((key, value) {
      if (value is Map) {
        return MapEntry(key.toString(), _deepConvert(value));
      } else if (value is List) {
        return MapEntry(key.toString(), value.map((item) {
          if (item is Map) {
            return _deepConvert(item);
          }
          return item;
        }).toList());
      }
      return MapEntry(key.toString(), value);
    });
  }

  Future<void> _saveData() async {
    try {
      final box = await Hive.openBox(_boxName);
      final todayJson = state.todayRecord.toJson();
      await box.put(state.todayRecord.date, todayJson);
      
      // Save custom sin types only
      final customTypes = state.sinTypes.where((t) => !t.isDefault).toList();
      final allTypes = [...getDefaultSinTypes(), ...customTypes];
      final typesJson = allTypes.map((t) => t.toJson()).toList();
      await box.put(_sinTypesKey, typesJson);
      
      // Sync to cloud
      firestoreSyncService.syncSinTracker(state.todayRecord.date, todayJson);
      firestoreSyncService.syncSinTypes(typesJson.cast<Map<String, dynamic>>());
    } catch (e) {
      print('Error saving sin tracker data: $e');
    }
  }

  /// গুনাহ হয়েছে/হয়নি টগল করা
  void toggleSin(String sinTypeId) {
    final updatedRecords = state.todayRecord.records.map((record) {
      if (record.sinTypeId == sinTypeId) {
        // যদি গুনাহ ছিল, তাহলে সব ক্লিয়ার করি
        if (record.hasSinned) {
          return SinRecord(sinTypeId: sinTypeId);
        } else {
          // গুনাহ মার্ক করি
          return record.copyWith(hasSinned: true);
        }
      }
      return record;
    }).toList();
    
    state = state.copyWith(
      todayRecord: state.todayRecord.copyWith(records: updatedRecords),
    );
    _saveData();
  }

  /// কাফফারা দেওয়া
  void giveKaffara(String sinTypeId, String kaffaraType) {
    final updatedRecords = state.todayRecord.records.map((record) {
      if (record.sinTypeId == sinTypeId && record.hasSinned) {
        return record.copyWith(
          kaffaraDone: true,
          kaffaraType: kaffaraType,
        );
      }
      return record;
    }).toList();
    
    state = state.copyWith(
      todayRecord: state.todayRecord.copyWith(records: updatedRecords),
    );
    _saveData();
  }

  /// কাফফারা বাতিল করা
  void undoKaffara(String sinTypeId) {
    final updatedRecords = state.todayRecord.records.map((record) {
      if (record.sinTypeId == sinTypeId) {
        return SinRecord(
          sinTypeId: sinTypeId,
          hasSinned: record.hasSinned,
          kaffaraDone: false,
          kaffaraType: null,
        );
      }
      return record;
    }).toList();
    
    state = state.copyWith(
      todayRecord: state.todayRecord.copyWith(records: updatedRecords),
    );
    _saveData();
  }

  /// কাস্টম গুনাহের ধরন যোগ করা
  void addCustomSinType(String name) {
    final newType = SinType(
      id: 'custom_sin_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      isDefault: false,
      icon: 'warning',
    );
    
    // Add new record for this type
    final newRecord = SinRecord(sinTypeId: newType.id);
    
    state = state.copyWith(
      sinTypes: [...state.sinTypes, newType],
      todayRecord: state.todayRecord.copyWith(
        records: [...state.todayRecord.records, newRecord],
      ),
    );
    _saveData();
  }

  /// কাস্টম গুনাহের ধরন মুছে ফেলা
  void removeCustomSinType(String sinTypeId) {
    final updatedTypes = state.sinTypes.where((t) => t.id != sinTypeId).toList();
    final updatedRecords = state.todayRecord.records
        .where((r) => r.sinTypeId != sinTypeId)
        .toList();
    
    state = state.copyWith(
      sinTypes: updatedTypes,
      todayRecord: state.todayRecord.copyWith(records: updatedRecords),
    );
    _saveData();
  }

  /// আজকের সব ডেটা রিসেট
  void resetToday() {
    state = state.copyWith(
      todayRecord: DailySinRecord(
        date: _getTodayDate(),
        records: state.sinTypes.map((t) => SinRecord(sinTypeId: t.id)).toList(),
      ),
    );
    _saveData();
  }

  /// নির্দিষ্ট তারিখের ডেটা লোড করা
  Future<DailySinRecord?> getRecordForDate(String dateKey) async {
    try {
      final box = await Hive.openBox(_boxName);
      final data = box.get(dateKey);
      
      if (data != null) {
        final map = _deepConvert(Map<String, dynamic>.from(data));
        return DailySinRecord.fromJson(map);
      }
      return null;
    } catch (e) {
      print('Error loading sin record for date $dateKey: $e');
      return null;
    }
  }

  /// সাপ্তাহিক গুনাহ কাউন্ট
  Future<int> getWeeklySinCount() async {
    try {
      final box = await Hive.openBox(_boxName);
      int totalSins = 0;
      
      final now = DateTime.now();
      for (int i = 0; i < 7; i++) {
        final date = now.subtract(Duration(days: i));
        final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        final data = box.get(dateKey);
        
        if (data != null) {
          final map = _deepConvert(Map<String, dynamic>.from(data));
          final record = DailySinRecord.fromJson(map);
          totalSins += record.totalSinCount;
        }
      }
      
      return totalSins;
    } catch (e) {
      print('Error getting weekly sin count: $e');
      return 0;
    }
  }

  /// মাসিক গুনাহ কাউন্ট
  Future<int> getMonthlySinCount(int year, int month) async {
    try {
      final box = await Hive.openBox(_boxName);
      int totalSins = 0;
      
      final daysInMonth = DateTime(year, month + 1, 0).day;
      for (int day = 1; day <= daysInMonth; day++) {
        final dateKey = '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
        final data = box.get(dateKey);
        
        if (data != null) {
          final map = _deepConvert(Map<String, dynamic>.from(data));
          final record = DailySinRecord.fromJson(map);
          totalSins += record.totalSinCount;
        }
      }
      
      return totalSins;
    } catch (e) {
      print('Error getting monthly sin count: $e');
      return 0;
    }
  }
}

final sinTrackerProvider = StateNotifierProvider<SinTrackerNotifier, SinTrackerState>((ref) {
  return SinTrackerNotifier();
});
