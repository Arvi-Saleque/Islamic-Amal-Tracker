import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme_storage.dart';

/// Provider for managing app theme selection
/// Supports: 'light', 'dark', and future themes like 'green'
final appThemeModeProvider =
    StateNotifierProvider<AppThemeModeController, String>(
  (ref) => AppThemeModeController()..load(),
);

class AppThemeModeController extends StateNotifier<String> {
  AppThemeModeController() : super('dark');

  /// Load the saved theme from storage
  void load() {
    final theme = ThemeStorage.getSelectedTheme();
    state = theme; // 'dark', 'light', or future themes
  }

  /// Set a specific theme by name
  Future<void> setTheme(String themeName) async {
    state = themeName;
    await ThemeStorage.setSelectedTheme(themeName);
  }

  /// Toggle between light and dark themes
  Future<void> toggle() async {
    await setTheme(state == 'light' ? 'dark' : 'light');
  }

  /// Check if current theme is light
  bool get isLight => state == 'light';

  /// Check if current theme is dark
  bool get isDark => state == 'dark';
}
