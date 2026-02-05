import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme_storage.dart';

final appThemeModeProvider =
    StateNotifierProvider<AppThemeModeController, ThemeMode>(
  (ref) => AppThemeModeController()..load(),
);

class AppThemeModeController extends StateNotifier<ThemeMode> {
  AppThemeModeController() : super(ThemeMode.dark);

  void load() {
    final isLight = ThemeStorage.getSettingsIsLight();
    state = isLight ? ThemeMode.light : ThemeMode.dark;
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    await ThemeStorage.setSettingsIsLight(mode == ThemeMode.light);
  }

  Future<void> toggle() async {
    await setMode(state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
  }
}
