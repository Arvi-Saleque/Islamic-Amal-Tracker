import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../models/prayer_record.dart';
import '../models/dhikr_session.dart';
import '../models/amal_category.dart';
import '../models/reading_progress.dart';
import '../models/daily_stats.dart';
import '../models/app_settings.dart';

class HiveService {
  static late Box prayersBox;
  static late Box dhikrBox;
  static late Box categoriesBox;
  static late Box readingBox;
  static late Box statsBox;
  static late Box settingsBox;
  static late Box customRemindersBox;
  static late Box sinTrackerBox;
  
  static Future<void> init() async {
    // Open all boxes using Hive 2.x API
    prayersBox = await Hive.openBox(AppConstants.prayerBoxName);
    
    dhikrBox = await Hive.openBox(AppConstants.dhikrBoxName);
    
    categoriesBox = await Hive.openBox(AppConstants.categoriesBoxName);
    
    readingBox = await Hive.openBox(AppConstants.readingBoxName);
    
    statsBox = await Hive.openBox(AppConstants.statsBoxName);
    
    settingsBox = await Hive.openBox(AppConstants.settingsBoxName);
    
    customRemindersBox = await Hive.openBox('custom_reminders');
    
    sinTrackerBox = await Hive.openBox('sin_tracker');
    
    // Initialize default data if first time
    await _initializeDefaultData();
  }
  
  static Future<void> _initializeDefaultData() async {
    // Check if app is opened for first time
    final settingsData = settingsBox.get('app_settings');
    if (settingsData == null) {
      // Initialize default settings
      final defaultSettings = AppSettings(
        id: 'app_settings',
        isFirstTime: true,
        notificationsEnabled: true,
        prayerNotificationsEnabled: true,
        theme: 'system',
        language: 'bn',
        modelVersion: AppConstants.currentModelVersion,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      settingsBox.put('app_settings', defaultSettings.toJson());
      
      // Initialize default dhikr
      for (final dhikr in AppConstants.defaultDhikrList) {
        final dhikrCategory = AmalCategory(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: dhikr['name_bn'],
          categoryType: CategoryType.dhikr,
          targetCount: dhikr['target'],
          isCustom: false,
          isActive: true,
          modelVersion: AppConstants.currentModelVersion,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        categoriesBox.put(dhikrCategory.id, dhikrCategory.toJson());
      }
      
      // Initialize default daily amal categories
      await _initializeDefaultAmalCategories();
    }
  }
  
  static Future<void> _initializeDefaultAmalCategories() async {
    // Miswak category
    final miswakCategory = AmalCategory(
      id: 'miswak_category',
      name: 'মিসওয়াক',
      categoryType: CategoryType.miswak,
      items: AppConstants.miswakTimes
          .map((time) => AmalItem(
                id: 'miswak_${time.hashCode}',
                title: time,
                isCompleted: false,
                categoryId: 'miswak_category',
              ))
          .toList(),
      targetCount: AppConstants.miswakTimes.length,
      isCustom: false,
      isActive: true,
      modelVersion: AppConstants.currentModelVersion,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    categoriesBox.put(miswakCategory.id, miswakCategory.toJson());
    
    // Post-prayer azkar category
    final azkarCategory = AmalCategory(
      id: 'azkar_category',
      name: 'নামাজের পরের আজকার',
      categoryType: CategoryType.azkar,
      items: AppConstants.postPrayerAzkar
          .map((azkar) => AmalItem(
                id: 'azkar_${azkar.hashCode}',
                title: azkar,
                isCompleted: false,
                categoryId: 'azkar_category',
              ))
          .toList(),
      targetCount: AppConstants.postPrayerAzkar.length,
      isCustom: false,
      isActive: true,
      modelVersion: AppConstants.currentModelVersion,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    categoriesBox.put(azkarCategory.id, azkarCategory.toJson());
    
    // Surahs category
    final surahCategory = AmalCategory(
      id: 'surah_category',
      name: 'দৈনিক সূরা',
      categoryType: CategoryType.surah,
      items: AppConstants.defaultSurahs
          .map((surah) => AmalItem(
                id: 'surah_${surah['name_bn'].hashCode}',
                title: surah['name_bn']!,
                titleAr: surah['name_ar'],
                isCompleted: false,
                categoryId: 'surah_category',
              ))
          .toList(),
      targetCount: AppConstants.defaultSurahs.length,
      isCustom: false,
      isActive: true,
      modelVersion: AppConstants.currentModelVersion,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    categoriesBox.put(surahCategory.id, surahCategory.toJson());
    
    // Daily duas category
    final duaCategory = AmalCategory(
      id: 'dua_category',
      name: 'দৈনিক দোয়া',
      categoryType: CategoryType.dua,
      items: AppConstants.defaultDailyDuas
          .map((dua) => AmalItem(
                id: 'dua_${dua.hashCode}',
                title: dua,
                isCompleted: false,
                categoryId: 'dua_category',
              ))
          .toList(),
      targetCount: AppConstants.defaultDailyDuas.length,
      isCustom: false,
      isActive: true,
      modelVersion: AppConstants.currentModelVersion,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    categoriesBox.put(duaCategory.id, duaCategory.toJson());
  }
  
  static Future<void> close() async {
    prayersBox.close();
    dhikrBox.close();
    categoriesBox.close();
    readingBox.close();
    statsBox.close();
    settingsBox.close();
    customRemindersBox.close();
  }
}
