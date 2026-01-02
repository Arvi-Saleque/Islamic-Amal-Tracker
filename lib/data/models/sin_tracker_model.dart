import 'package:hive/hive.dart';

part 'sin_tracker_model.g.dart';

/// একটি গুনাহের রেকর্ড - হয়েছে কিনা এবং কাফফারা দিয়েছে কিনা
@HiveType(typeId: 10)
class SinRecord {
  @HiveField(0)
  final String sinTypeId;
  
  @HiveField(1)
  final bool hasSinned; // গুনাহ হয়েছে কিনা
  
  @HiveField(2)
  final bool kaffaraDone; // কাফফারা দিয়েছে কিনা
  
  @HiveField(3)
  final String? kaffaraType; // 'prayer', 'charity', 'istighfar'

  SinRecord({
    required this.sinTypeId,
    this.hasSinned = false,
    this.kaffaraDone = false,
    this.kaffaraType,
  });

  SinRecord copyWith({
    String? sinTypeId,
    bool? hasSinned,
    bool? kaffaraDone,
    String? kaffaraType,
  }) {
    return SinRecord(
      sinTypeId: sinTypeId ?? this.sinTypeId,
      hasSinned: hasSinned ?? this.hasSinned,
      kaffaraDone: kaffaraDone ?? this.kaffaraDone,
      kaffaraType: kaffaraType ?? this.kaffaraType,
    );
  }

  Map<String, dynamic> toJson() => {
    'sinTypeId': sinTypeId,
    'hasSinned': hasSinned,
    'kaffaraDone': kaffaraDone,
    'kaffaraType': kaffaraType,
  };

  factory SinRecord.fromJson(Map<String, dynamic> json) => SinRecord(
    sinTypeId: json['sinTypeId'] as String,
    hasSinned: json['hasSinned'] as bool? ?? false,
    kaffaraDone: json['kaffaraDone'] as bool? ?? false,
    kaffaraType: json['kaffaraType'] as String?,
  );
}

/// গুনাহের ধরন - ডিফল্ট বা কাস্টম
@HiveType(typeId: 11)
class SinType {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final bool isDefault;
  
  @HiveField(3)
  final String icon;

  SinType({
    required this.id,
    required this.name,
    this.isDefault = false,
    this.icon = 'warning',
  });

  SinType copyWith({
    String? id,
    String? name,
    bool? isDefault,
    String? icon,
  }) {
    return SinType(
      id: id ?? this.id,
      name: name ?? this.name,
      isDefault: isDefault ?? this.isDefault,
      icon: icon ?? this.icon,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'isDefault': isDefault,
    'icon': icon,
  };

  factory SinType.fromJson(Map<String, dynamic> json) => SinType(
    id: json['id'] as String,
    name: json['name'] as String,
    isDefault: json['isDefault'] as bool? ?? false,
    icon: json['icon'] as String? ?? 'warning',
  );
}

/// দৈনিক গুনাহের রেকর্ড
@HiveType(typeId: 12)
class DailySinRecord {
  @HiveField(0)
  final String date;
  
  @HiveField(1)
  final List<SinRecord> records;

  DailySinRecord({
    required this.date,
    required this.records,
  });

  DailySinRecord copyWith({
    String? date,
    List<SinRecord>? records,
  }) {
    return DailySinRecord(
      date: date ?? this.date,
      records: records ?? this.records,
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date,
    'records': records.map((r) => r.toJson()).toList(),
  };

  factory DailySinRecord.fromJson(Map<String, dynamic> json) => DailySinRecord(
    date: json['date'] as String,
    records: (json['records'] as List<dynamic>?)
        ?.map((r) => SinRecord.fromJson(Map<String, dynamic>.from(r)))
        .toList() ?? [],
  );

  // মোট গুনাহ সংখ্যা (যেগুলো হয়েছে)
  int get totalSinCount => records.where((r) => r.hasSinned).length;
  
  // বাকি কাফফারা (গুনাহ হয়েছে কিন্তু কাফফারা হয়নি)
  int get pendingKaffaraCount => records.where((r) => r.hasSinned && !r.kaffaraDone).length;
  
  // সম্পন্ন কাফফারা
  int get completedKaffaraCount => records.where((r) => r.hasSinned && r.kaffaraDone).length;
  
  // নির্দিষ্ট ধরনের গুনাহের রেকর্ড
  SinRecord? getRecordForType(String sinTypeId) {
    try {
      return records.firstWhere((r) => r.sinTypeId == sinTypeId);
    } catch (e) {
      return null;
    }
  }
}

// ডিফল্ট গুনাহের ধরন
List<SinType> getDefaultSinTypes() {
  return [
    SinType(id: 'sin_lie', name: 'মিথ্যা বলা', isDefault: true, icon: 'voice'),
    SinType(id: 'sin_backbiting', name: 'গিবত করা', isDefault: true, icon: 'chat'),
    SinType(id: 'sin_eye', name: 'চোখের গুনাহ', isDefault: true, icon: 'eye'),
    SinType(id: 'sin_ear', name: 'কানের গুনাহ', isDefault: true, icon: 'ear'),
  ];
}

// কাফফারার ধরন
class KaffaraType {
  static const String istighfar = 'istighfar';
  static const String quran = 'quran';
  static const String charity = 'charity';
  static const String prayer = 'prayer';
  
  static String getName(String type) {
    switch (type) {
      case istighfar:
        return 'এস্তেগফার/যিকির';
      case quran:
        return 'কোরআন তেলাওয়াত';
      case charity:
        return 'দান-সদকা';
      case prayer:
        return 'নফল নামাজ';
      default:
        return 'অন্যান্য';
    }
  }
  
  static String getIcon(String type) {
    switch (type) {
      case istighfar:
        return 'star';
      case quran:
        return 'book';
      case charity:
        return 'volunteer';
      case prayer:
        return 'mosque';
      default:
        return 'check';
    }
  }
}
