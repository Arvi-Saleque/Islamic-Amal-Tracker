import '../../data/local/hive_service.dart';

class ThemeStorage {
  static const String _themeKey = 'selected_theme';

  /// Get the currently selected theme name
  /// Returns 'dark', 'light', or future themes like 'green'
  static String getSelectedTheme() {
    return HiveService.settingsBox.get(_themeKey, defaultValue: 'dark') as String;
  }

  /// Set the selected theme name
  static Future<void> setSelectedTheme(String themeName) async {
    await HiveService.settingsBox.put(_themeKey, themeName);
  }

  // Deprecated - kept for backward compatibility
  static bool getSettingsIsLight() {
    final theme = getSelectedTheme();
    return theme == 'light';
  }

  static Future<void> setSettingsIsLight(bool value) async {
    await setSelectedTheme(value ? 'light' : 'dark');
  }
}
