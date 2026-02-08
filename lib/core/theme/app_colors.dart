import 'package:flutter/material.dart';

/// Global color theme for the app
class AppColors {
  // Dark Theme Colors
  static const Color backgroundDark = Color(0xFF0A0A0A); // Main dark background
  static const Color backgroundLight =
      Color(0xFF1A1A1A); // Light grey for cards/boxes

  // Light Theme Colors (Premium Soft Ivory — NO PURE WHITE)
static const Color backgroundLightMode =
    Color(0xFFF2F1EC); // calm ivory-greige background (less yellow)

static const Color surfaceLightMode =
    Color(0xFFF7F6F1); // cards: soft neutral ivory (clean, not white)

static const Color cardLightMode =
    Color(0xFFFBFAF5); // inner items: brighter ivory (still not pure white)

static const Color textLightMode =
    Color(0xFF1F2937); // professional dark gray (cleaner than brown)

static const Color textSecondaryLightMode =
    Color(0xFF6B7280); // muted gray (professional)

static const Color borderLightMode =
    Color(0xFFE6E3DA); // soft neutral divider tone (if needed)

static const Color iconBgLightMode =
    Color(0xFFF3EAD1); // subtle gold-ivory tint (premium, not yellow)

  // Primary Colors
  static const Color primary = Color.fromARGB(255, 206, 161, 15); // Golden color
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

  // gradient colors for light 
  static const lightgradient1 = Color.fromARGB(255, 231, 229, 219);
  static const lightgradient2 = Color.fromARGB(255, 229, 228, 221);
  static const lightgradient3 = Color.fromARGB(255, 241, 240, 236);

  // gradient colors for dark 
  static const darkgradient1 = Color.fromARGB(26, 26, 26, 1);
  static const darkgradient2 = Color.fromARGB(26, 34, 34, 2);
  static const darkgradient3 = Color.fromARGB(26, 40, 40, 4);


  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color darkSurface = Color(0xFF2A2A2A);
  static const Color darkCard = Color(0xFF242424);
}


