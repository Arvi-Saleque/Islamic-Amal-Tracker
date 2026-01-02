import 'package:hive/hive.dart';
import 'prayer_record.dart';

class AmalItem {
  final String id;
  final String categoryId;
  final String title;
  final String? titleAr;
  final String? description;
  
  bool isCompleted;
  DateTime? completedAt;
  
  // For counter-type items
  final bool hasCounter;
  final int? targetValue;
  int? currentValue;
  
  AmalItem({
    required this.id,
    required this.categoryId,
    required this.title,
    this.titleAr,
    this.description,
    this.isCompleted = false,
    this.completedAt,
    this.hasCounter = false,
    this.targetValue,
    this.currentValue,
  });
  
  Map<String, dynamic> toJson() => {
        'id': id,
        'categoryId': categoryId,
        'title': title,
        'titleAr': titleAr,
        'description': description,
        'isCompleted': isCompleted,
        'completedAt': completedAt?.toIso8601String(),
        'hasCounter': hasCounter,
        'targetValue': targetValue,
        'currentValue': currentValue,
      };
  
  factory AmalItem.fromJson(Map<String, dynamic> json) => AmalItem(
        id: json['id'],
        categoryId: json['categoryId'],
        title: json['title'],
        titleAr: json['titleAr'],
        description: json['description'],
        isCompleted: json['isCompleted'] ?? false,
        completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
        hasCounter: json['hasCounter'] ?? false,
        targetValue: json['targetValue'],
        currentValue: json['currentValue'],
      );
  
  AmalItem copyWith({
    bool? isCompleted,
    DateTime? completedAt,
    int? currentValue,
  }) {
    return AmalItem(
      id: id,
      categoryId: categoryId,
      title: title,
      titleAr: titleAr,
      description: description,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      hasCounter: hasCounter,
      targetValue: targetValue,
      currentValue: currentValue ?? this.currentValue,
    );
  }
}

class AmalCategory {
  final String id;
  final String name;
  final String? nameAr;
  final String? description;
  final CategoryType categoryType;
  
  List<AmalItem> items;
  final int? targetCount;
  
  final bool isCustom;
  bool isActive;
  
  final String? iconName;
  final int? sortOrder;
  
  // Cloud sync fields
  final int modelVersion;
  final DateTime createdAt;
  DateTime updatedAt;
  SyncStatus syncStatus;
  DateTime? lastSyncedAt;
  
  AmalCategory({
    required this.id,
    required this.name,
    this.nameAr,
    this.description,
    required this.categoryType,
    List<AmalItem>? items,
    this.targetCount,
    this.isCustom = false,
    this.isActive = true,
    this.iconName,
    this.sortOrder,
    required this.modelVersion,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = SyncStatus.pending,
    this.lastSyncedAt,
  }) : items = items ?? [];
  
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'nameAr': nameAr,
        'description': description,
        'categoryType': categoryType.name,
        'items': items.map((item) => item.toJson()).toList(),
        'targetCount': targetCount,
        'isCustom': isCustom,
        'isActive': isActive,
        'iconName': iconName,
        'sortOrder': sortOrder,
        'modelVersion': modelVersion,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'syncStatus': syncStatus.name,
        'lastSyncedAt': lastSyncedAt?.toIso8601String(),
      };
  
  factory AmalCategory.fromJson(Map<String, dynamic> json) => AmalCategory(
        id: json['id'],
        name: json['name'],
        nameAr: json['nameAr'],
        description: json['description'],
        categoryType: CategoryType.values.firstWhere((e) => e.name == json['categoryType']),
        items: (json['items'] as List?)?.map((item) => AmalItem.fromJson(item)).toList() ?? [],
        targetCount: json['targetCount'],
        isCustom: json['isCustom'] ?? false,
        isActive: json['isActive'] ?? true,
        iconName: json['iconName'],
        sortOrder: json['sortOrder'],
        modelVersion: json['modelVersion'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        syncStatus: SyncStatus.values.firstWhere((e) => e.name == json['syncStatus']),
        lastSyncedAt: json['lastSyncedAt'] != null ? DateTime.parse(json['lastSyncedAt']) : null,
      );
  
  AmalCategory copyWith({
    String? name,
    List<AmalItem>? items,
    bool? isActive,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
  }) {
    return AmalCategory(
      id: id,
      name: name ?? this.name,
      nameAr: nameAr,
      description: description,
      categoryType: categoryType,
      items: items ?? this.items,
      targetCount: targetCount,
      isCustom: isCustom,
      isActive: isActive ?? this.isActive,
      iconName: iconName,
      sortOrder: sortOrder,
      modelVersion: modelVersion,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      syncStatus: syncStatus ?? SyncStatus.pending,
      lastSyncedAt: lastSyncedAt,
    );
  }
  
  int get completedCount => items.where((item) => item.isCompleted).length;
  double get progress => items.isNotEmpty ? (completedCount / items.length).clamp(0.0, 1.0) : 0.0;
}

class DailyAmalRecord {
  final DateTime date;
  final List<String> completedItemIds;
  final Map<String, int> categoryCompletionCount;
  final double overallProgress;
  
  DailyAmalRecord({
    required this.date,
    required this.completedItemIds,
    required this.categoryCompletionCount,
    required this.overallProgress,
  });
  
  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'completedItemIds': completedItemIds,
        'categoryCompletionCount': categoryCompletionCount,
        'overallProgress': overallProgress,
      };
  
  factory DailyAmalRecord.fromJson(Map<String, dynamic> json) => DailyAmalRecord(
        date: DateTime.parse(json['date']),
        completedItemIds: List<String>.from(json['completedItemIds']),
        categoryCompletionCount: Map<String, int>.from(json['categoryCompletionCount']),
        overallProgress: json['overallProgress'],
      );
}

