import 'package:flutter/material.dart';

/// Global color theme for the app
/// Change these values to update colors throughout the entire app
class AppColors {
  // Dark Theme Colors
  static const Color backgroundDark = Color(0xFF0A0A0A); // Main dark background
  static const Color backgroundLight =
      Color(0xFF1A1A1A); // Light grey for cards/boxes

  // Light Theme Colors
  // Light Theme Colors (Creamy Premium — NO WHITE)
  static const Color backgroundLightMode = Color(
      0xFFF1E7D3); // main background: warm almond cream (darker than surface)

  static const Color surfaceLightMode =
      Color(0xFFF7EEDC); // cards: soft butter cream (clearly not white)
  static const Color cardLightMode =
      Color(0xFFFBF3E3); // inner items: lighter cream, still not white

  static const Color textLightMode =
      Color(0xFF2A2116); // warm dark brown (excellent contrast)

  static const Color textSecondaryLightMode =
      Color(0xFF6E6254); // muted warm brown-gray

// Keep for compatibility but DON'T use as actual border in UI
  static const Color borderLightMode =
      Color(0xFFE3D6C1); // creamy divider tone (not a visible border)

  static const Color iconBgLightMode =
      Color(0xFFFFEBC2); // gold-cream bubble background (not white)

  // Primary Colors
  static const Color primary = Color(0xFFD4AF37); // Golden color
  static const Color primaryLight = Color(0xFFE5C158); // Lighter golden

  // Text Colors (Dark Theme)
  static const Color textPrimary = Colors.white; // Main text color
  static const Color textSecondary = Color(0xFFE0E0E0); // Secondary text
  static const Color textTertiary = Color(0xFFB0B0B0); // Tertiary text
  static const Color textGolden = Color(0xFFD4AF37); // Golden text

  // Grey Shades
  static const Color grey400 = Color(0xFFB0B0B0);
  static const Color grey500 = Color(0xFF888888);
  static const Color grey600 = Color(0xFF666666);
  static const Color grey800 = Color(0xFF2A2A2A);

  // Accent Colors
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color warning = Color(0xFFFF9800); // Orange
  static const Color error = Color(0xFFE57373); // Light red
  static const Color danger = Colors.red; // Red

  // Shadow Colors (Dark Theme)
  static Color shadowDark = Colors.black.withOpacity(0.3);
  static Color shadowGolden = const Color(0xFFD4AF37).withOpacity(0.08);

  // Shadow Colors (Light Theme)
  static Color shadowLightMode = Colors.black.withOpacity(0.1);
  static Color shadowGoldenLight = const Color(0xFFD4AF37).withOpacity(0.05);

  // Opacity Variations
  static Color primaryOpacity15 = const Color(0xFFD4AF37).withOpacity(0.15);
  static Color primaryOpacity20 = const Color(0xFFD4AF37).withOpacity(0.2);
  static Color primaryOpacity06 = const Color(0xFFD4AF37).withOpacity(0.06);
  static Color primaryOpacity10 = const Color(0xFFD4AF37).withOpacity(0.1);
  static Color primaryOpacity05 = const Color(0xFFD4AF37).withOpacity(0.05);

  // Transparent
  static const Color transparent = Colors.transparent;
}
