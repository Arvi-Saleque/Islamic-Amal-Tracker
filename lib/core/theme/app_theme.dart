import 'package:amal_tracker/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color darkSurface = Color(0xFF2A2A2A);
  static const Color darkCard = Color(0xFF242424);

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primaryGold,
      secondary: primaryGold,
      surface: darkBackground,
      surfaceContainerHighest: darkCard,
      onPrimary: Color(0xFF000000),
      onSecondary: Color(0xFF000000),
      onSurface: Color(0xFFFFFFFF),
      onSurfaceVariant: Color(0xFFB0B0B0),
    ),
    scaffoldBackgroundColor: darkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackground,
      foregroundColor: primaryGold,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: primaryGold,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: primaryGold),
    ),
    cardTheme: CardThemeData(
      color: darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: primaryGold,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: primaryGold,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: primaryGold,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.white,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Color(0xFFB0B0B0),
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: Color(0xFF808080),
      ),
    ),
    iconTheme: const IconThemeData(
      color: primaryGold,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF3A3A3A),
      thickness: 1,
    ),
  );

  // Add this inside AppTheme class (below darkTheme)

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.primary,
      surface: AppColors.surfaceLightMode,
      surfaceContainerHighest: AppColors.cardLightMode, // Light gray for containers
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textLightMode,
    ),
    scaffoldBackgroundColor: AppColors.backgroundLightMode,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundLightMode,
      foregroundColor: AppColors.primary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.primary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: IconThemeData(color: AppColors.textLightMode),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surfaceLightMode,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.borderLightMode),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.borderLightMode,
      thickness: 1,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textLightMode,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textLightMode,
      ),
      bodyMedium: TextStyle(
        fontSize: 13,
        color: AppColors.textSecondaryLightMode,
      ),
    ),
  );
}
