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
    Color.fromARGB(255, 37, 36, 31); // muted gray (professional)

static const Color borderLightMode =
    Color(0xFFE6E3DA); // soft neutral divider tone (if needed)

static const Color iconBgLightMode =
    Color(0xFFF3EAD1); // subtle gold-ivory tint (premium, not yellow)

  // Primary Colors
  static const Color primary = Color.fromARGB(255, 228, 176, 7); // Golden color
  static const Color primaryLight = Color(0xFFE5C158); // Lighter golden

  // Text Colors (Dark Theme)
  static const Color textPrimary = Colors.white; // Main text color
  static const Color textSecondary = Color(0xFFE0E0E0); // Secondary text
  static const Color textTertiary = Color(0xFFB0B0B0); // Tertiary text
  static const Color textGolden = Color(0xFFD4AF37); // Golden text
  static const Color onPrimaryText = Colors.white; // Text on primary color (badges, icons)
  static const Color onPrimaryDark = Color(0xFF000000); // Black text on primary (dark theme)
  static const Color onSecondaryDark = Color(0xFF000000); // Black text on secondary (dark theme)
  static const Color onSurface = Color(0xFFFFFFFF); // White text on surface
  static const Color onSurfaceVariant = Color(0xFFB0B0B0); // Grey text on surface variant
  static const Color textSecondaryDarkMode = Color.fromARGB(255, 163, 160, 149); // muted gray (professional)

  // Text Colors (Light Theme)
  static const Color onPrimaryTextLight = Colors.white; // Text on primary color (light theme)

  // Grey Shades
  static const Color grey400 = Color(0xFFB0B0B0);
  static const Color grey500 = Color(0xFF888888);
  static const Color grey600 = Color(0xFF666666);
  static const Color grey800 = Color(0xFF2A2A2A);

  // Divider Colors
  static const Color dividerDark = Color(0xFF3A3A3A); // Divider in dark theme
  static const Color dividerLight = Color(0xFFE0E0E0); // Divider in light theme

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

  // === Light Theme Gradients ===
  // AppBar gradient (3 shades) - slightly elevated from background
  static const lightAppBarGradient1 = Color.fromARGB(255, 233, 230, 217);
  static const lightAppBarGradient2 = Color.fromARGB(255, 236, 233, 215);
  static const lightAppBarGradient3 = Color.fromARGB(255, 255, 254, 246);
  static const lightAppBarBorder = Color.fromARGB(101, 206, 161, 15); // subtle golden 3D border
  
  // Background gradient (2 shades)
  static const lightBackgroundGradient1 = Color(0xFFEAE9E4);
static const lightBackgroundGradient2 = Color(0xFFF2F1EC);
  
  // Card gradient (3 shades)
  static const lightCardGradient1 = Color(0xFFFCFAF3);
static const lightCardGradient2 = Color(0xFFF8F6EF);
static const lightCardGradient3 = Color(0xFFF2EFE6);
  
  // Inner card gradient (2 shades)
  static const lightInnerCardGradient1 = Color(0xFFFDFBF6);
static const lightInnerCardGradient2 = Color(0xFFFAF7F0);

  // === Dark Theme Gradients ===
  // AppBar gradient (3 shades) - slightly elevated from background
  static const darkAppBarGradient1 = Color(0xFF0A0A0C);
  static const darkAppBarGradient2 = Color(0xFF101012);
  static const darkAppBarGradient3 = Color(0xFF161616);
  static const darkAppBarBorder = Color(0x1AD4AF37); // subtle golden 3D border
  
  // Background gradient (2 shades)
  static const darkBackgroundGradient1 = Color(0xFF0D0D0F);
  static const darkBackgroundGradient2 = Color(0xFF1A1A1A);
  
  // Card gradient (3 shades)
  static const darkCardGradient1 = Color(0xFF2C2C2E);
  static const darkCardGradient2 = Color(0xFF242424);
  static const darkCardGradient3 = Color(0xFF1C1C1E);
  
  // Inner card gradient (2 shades)
  static const darkInnerCardGradient1 = Color(0xFF303032);
  static const darkInnerCardGradient2 = Color(0xFF252527);

  // === Premium Card Style Colors ===
  // Light theme premium card
  static const lightPremiumCard1 = Color(0xFFF7F6F1); // surface
  static const lightPremiumCard2 = Color(0xFFEFEEE9); // surfaceContainerLow
  static const lightPremiumBorder = Color(0xFFCEA10F); // primary with 18% opacity applied
  static const lightPremiumOverlay1 = Color(0x081F2937); // onSurface with 3% opacity
  static const lightPremiumNoise = Color(0x051F2937); // onSurface with 2% opacity
  
  // Dark theme premium card  
  static const darkPremiumCard1 = Color(0xFF1A1A1A); // surface (darkBackground)
  static const darkPremiumCard2 = Color(0xFF141414); // surfaceContainerLow
  static const darkPremiumBorder = Color(0xFFD4AF37); // primaryGold with 10% opacity applied
  static const darkPremiumOverlay1 = Color(0x0FFFFFFF); // onSurface with 6% opacity
  static const darkPremiumNoise = Color(0x0AFFFFFF); // onSurface with 4% opacity

  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color darkSurface = Color(0xFF2A2A2A);
  static const Color darkCard = Color(0xFF242424);

  static Color? get white => null;
}


