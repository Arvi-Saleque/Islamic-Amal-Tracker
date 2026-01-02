import 'prayer_record.dart';

class AppSettings {
  final String id;
  
  // General settings
  bool isFirstTime;
  String language;
  String theme; // 'light', 'dark', 'system'
  
  // Notification settings
  bool notificationsEnabled;
  bool prayerNotificationsEnabled;
  int prayerNotificationMinutesBefore;
  
  // Prayer settings
  double latitude;
  double longitude;
  String? locationName;
  Map<String, int> prayerTimeAdjustments; // Manual +/- minutes per prayer
  
  // Widget settings
  bool widgetEnabled;
  
  // Cloud sync settings
  bool cloudSyncEnabled;
  String? lastSyncTimestamp;
  
  // Cloud sync fields
  final int modelVersion;
  final DateTime createdAt;
  DateTime updatedAt;
  SyncStatus syncStatus;
  DateTime? lastSyncedAt;
  
  AppSettings({
    required this.id,
    this.isFirstTime = true,
    this.language = 'bn',
    this.theme = 'system',
    this.notificationsEnabled = true,
    this.prayerNotificationsEnabled = true,
    this.prayerNotificationMinutesBefore = 15,
    this.latitude = 23.8103, // Default Dhaka
    this.longitude = 90.4125,
    this.locationName,
    Map<String, int>? prayerTimeAdjustments,
    this.widgetEnabled = true,
    this.cloudSyncEnabled = false,
    this.lastSyncTimestamp,
    required this.modelVersion,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = SyncStatus.pending,
    this.lastSyncedAt,
  }) : prayerTimeAdjustments = prayerTimeAdjustments ?? {
          'fajr': 0,
          'dhuhr': 0,
          'asr': 0,
          'maghrib': 0,
          'isha': 0,
        };
  
  Map<String, dynamic> toJson() => {
        'id': id,
        'isFirstTime': isFirstTime,
        'language': language,
        'theme': theme,
        'notificationsEnabled': notificationsEnabled,
        'prayerNotificationsEnabled': prayerNotificationsEnabled,
        'prayerNotificationMinutesBefore': prayerNotificationMinutesBefore,
        'latitude': latitude,
        'longitude': longitude,
        'locationName': locationName,
        'prayerTimeAdjustments': prayerTimeAdjustments,
        'widgetEnabled': widgetEnabled,
        'cloudSyncEnabled': cloudSyncEnabled,
        'lastSyncTimestamp': lastSyncTimestamp,
        'modelVersion': modelVersion,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'syncStatus': syncStatus.name,
        'lastSyncedAt': lastSyncedAt?.toIso8601String(),
      };
  
  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        id: json['id'],
        isFirstTime: json['isFirstTime'] ?? true,
        language: json['language'] ?? 'bn',
        theme: json['theme'] ?? 'system',
        notificationsEnabled: json['notificationsEnabled'] ?? true,
        prayerNotificationsEnabled: json['prayerNotificationsEnabled'] ?? true,
        prayerNotificationMinutesBefore: json['prayerNotificationMinutesBefore'] ?? 15,
        latitude: json['latitude'] ?? 23.8103,
        longitude: json['longitude'] ?? 90.4125,
        locationName: json['locationName'],
        prayerTimeAdjustments: json['prayerTimeAdjustments'] != null
            ? Map<String, int>.from(json['prayerTimeAdjustments'])
            : null,
        widgetEnabled: json['widgetEnabled'] ?? true,
        cloudSyncEnabled: json['cloudSyncEnabled'] ?? false,
        lastSyncTimestamp: json['lastSyncTimestamp'],
        modelVersion: json['modelVersion'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        syncStatus: SyncStatus.values.firstWhere((e) => e.name == json['syncStatus']),
        lastSyncedAt: json['lastSyncedAt'] != null ? DateTime.parse(json['lastSyncedAt']) : null,
      );
  
  AppSettings copyWith({
    bool? isFirstTime,
    String? language,
    String? theme,
    bool? notificationsEnabled,
    bool? prayerNotificationsEnabled,
    int? prayerNotificationMinutesBefore,
    double? latitude,
    double? longitude,
    String? locationName,
    Map<String, int>? prayerTimeAdjustments,
    bool? widgetEnabled,
    bool? cloudSyncEnabled,
    String? lastSyncTimestamp,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
  }) {
    return AppSettings(
      id: id,
      isFirstTime: isFirstTime ?? this.isFirstTime,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      prayerNotificationsEnabled: prayerNotificationsEnabled ?? this.prayerNotificationsEnabled,
      prayerNotificationMinutesBefore: prayerNotificationMinutesBefore ?? this.prayerNotificationMinutesBefore,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      prayerTimeAdjustments: prayerTimeAdjustments ?? this.prayerTimeAdjustments,
      widgetEnabled: widgetEnabled ?? this.widgetEnabled,
      cloudSyncEnabled: cloudSyncEnabled ?? this.cloudSyncEnabled,
      lastSyncTimestamp: lastSyncTimestamp ?? this.lastSyncTimestamp,
      modelVersion: modelVersion,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      syncStatus: syncStatus ?? SyncStatus.pending,
      lastSyncedAt: lastSyncedAt,
    );
  }
}


