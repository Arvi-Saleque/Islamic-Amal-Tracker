import '../../data/local/hive_service.dart';

class ThemeStorage {
  // Only for Settings page preview toggle (for now)
  static const String _settingsLightKey = 'settings_light_mode';

  static bool getSettingsIsLight() {
    // default: false (dark)
    return HiveService.settingsBox.get(_settingsLightKey, defaultValue: false) as bool;
  }

  static Future<void> setSettingsIsLight(bool value) async {
    await HiveService.settingsBox.put(_settingsLightKey, value);
  }
}
