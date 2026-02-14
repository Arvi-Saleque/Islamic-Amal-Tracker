import 'package:amal_tracker/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Custom theme extension for gradient colors
class GradientColors extends ThemeExtension<GradientColors> {
  // AppBar gradient (3 shades)
  final List<Color> appBarGradient;
  
  // AppBar bottom border for 3D effect
  final Color appBarBorder;
  
  // Main background gradient (2 shades)
  final List<Color> backgroundGradient;
  
  // Card background gradient (3 shades)
  final List<Color> cardGradient;
  
  // Inner card gradient (2 shades)
  final List<Color> innerCardGradient;
  
  // Text on primary color (badges, icons on primary background)
  final Color onPrimaryText;
  
  // Bullet text color (for usage rules, lists, etc.)
  final Color bulletTextColor;

  const GradientColors({
    required this.appBarGradient,
    required this.appBarBorder,
    required this.backgroundGradient,
    required this.cardGradient,
    required this.innerCardGradient,
    required this.onPrimaryText,
    required this.bulletTextColor,
  });

  @override
  GradientColors copyWith({
    List<Color>? appBarGradient,
    Color? appBarBorder,
    List<Color>? backgroundGradient,
    List<Color>? cardGradient,
    List<Color>? innerCardGradient,
    Color? onPrimaryText,
    Color? bulletTextColor,
  }) {
    return GradientColors(
      appBarGradient: appBarGradient ?? this.appBarGradient,
      appBarBorder: appBarBorder ?? this.appBarBorder,
      backgroundGradient: backgroundGradient ?? this.backgroundGradient,
      cardGradient: cardGradient ?? this.cardGradient,
      innerCardGradient: innerCardGradient ?? this.innerCardGradient,
      onPrimaryText: onPrimaryText ?? this.onPrimaryText,
      bulletTextColor: bulletTextColor ?? this.bulletTextColor,
    );
  }

  @override
  GradientColors lerp(ThemeExtension<GradientColors>? other, double t) {
    if (other is! GradientColors) return this;
    return GradientColors(
      appBarGradient: appBarGradient.asMap().entries.map((e) => 
        Color.lerp(e.value, other.appBarGradient[e.key], t)!).toList(),
      appBarBorder: Color.lerp(appBarBorder, other.appBarBorder, t)!,
      backgroundGradient: backgroundGradient.asMap().entries.map((e) => 
        Color.lerp(e.value, other.backgroundGradient[e.key], t)!).toList(),
      cardGradient: cardGradient.asMap().entries.map((e) => 
        Color.lerp(e.value, other.cardGradient[e.key], t)!).toList(),
      innerCardGradient: innerCardGradient.asMap().entries.map((e) => 
        Color.lerp(e.value, other.innerCardGradient[e.key], t)!).toList(),
      onPrimaryText: Color.lerp(onPrimaryText, other.onPrimaryText, t)!,
      bulletTextColor: Color.lerp(bulletTextColor, other.bulletTextColor, t)!,
    );
  }

  // Light theme gradients
  static const light = GradientColors(
    appBarGradient: [
      AppColors.lightAppBarGradient1,
      AppColors.lightAppBarGradient2,
      AppColors.lightAppBarGradient3,
    ],
    appBarBorder: AppColors.lightAppBarBorder,
    backgroundGradient: [
      AppColors.lightBackgroundGradient1,
      AppColors.lightBackgroundGradient2,
    ],
    cardGradient: [
      AppColors.lightCardGradient1,
      AppColors.lightCardGradient2,
      AppColors.lightCardGradient3,
    ],
    innerCardGradient: [
      AppColors.lightInnerCardGradient1,
      AppColors.lightInnerCardGradient2,
    ],
    onPrimaryText: AppColors.onPrimaryTextLight,
    bulletTextColor: AppColors.textSecondaryLightMode,
  );

  // Dark theme gradients
  static const dark = GradientColors(
    appBarGradient: [
      AppColors.darkAppBarGradient1,
      AppColors.darkAppBarGradient2,
      AppColors.darkAppBarGradient3,
    ],
    appBarBorder: AppColors.darkAppBarBorder,
    backgroundGradient: [
      AppColors.darkBackgroundGradient1,
      AppColors.darkBackgroundGradient2,
    ],
    cardGradient: [
      AppColors.darkCardGradient1,
      AppColors.darkCardGradient2,
      AppColors.darkCardGradient3,
    ],
    innerCardGradient: [
      AppColors.darkInnerCardGradient1,
      AppColors.darkInnerCardGradient2,
    ],
    onPrimaryText: AppColors.onPrimaryText,
    bulletTextColor: AppColors.textSecondaryDarkMode,
  );
}

/// Premium card styling extension for home-style cards
/// 
/// Usage:
/// ```dart
/// final cardStyle = Theme.of(context).extension<PremiumCardStyle>()!;
/// 
/// Container(
///   decoration: BoxDecoration(
///     gradient: LinearGradient(
///       begin: Alignment.topLeft,
///       end: Alignment.bottomRight,
///       colors: cardStyle.cardGradient,
///     ),
///     border: Border.all(
///       color: cardStyle.borderColor,
///       width: cardStyle.borderWidth,
///     ),
///     borderRadius: BorderRadius.circular(18),
///     boxShadow: [
///       BoxShadow(
///         color: cardStyle.shadowDark,
///         blurRadius: cardStyle.shadowDarkBlur,
///         offset: cardStyle.shadowDarkOffset,
///         spreadRadius: cardStyle.shadowDarkSpread,
///       ),
///       BoxShadow(
///         color: cardStyle.shadowGlow,
///         blurRadius: cardStyle.shadowGlowBlur,
///         offset: cardStyle.shadowGlowOffset,
///         spreadRadius: cardStyle.shadowGlowSpread,
///       ),
///     ],
///   ),
///   child: YourContent(),
/// )
/// ```
class PremiumCardStyle extends ThemeExtension<PremiumCardStyle> {
  // Main card gradient (diagonal: topLeft → bottomRight)
  final List<Color> cardGradient;
  
  // Border color
  final Color borderColor;
  
  // Shadow colors
  final Color shadowDark;
  final Color shadowGlow;
  
  // Top overlay gradient
  final List<Color> topOverlayGradient;
  
  // Noise texture color
  final Color noiseColor;
  
  // Shadow properties
  final double shadowDarkBlur;
  final double shadowDarkOpacity;
  final Offset shadowDarkOffset;
  final double shadowDarkSpread;
  
  final double shadowGlowBlur;
  final double shadowGlowOpacity;
  final Offset shadowGlowOffset;
  final double shadowGlowSpread;
  
  // Border width
  final double borderWidth;

  const PremiumCardStyle({
    required this.cardGradient,
    required this.borderColor,
    required this.shadowDark,
    required this.shadowGlow,
    required this.topOverlayGradient,
    required this.noiseColor,
    this.shadowDarkBlur = 10,
    this.shadowDarkOpacity = 0.45,
    this.shadowDarkOffset = const Offset(0, 5),
    this.shadowDarkSpread = -10,
    this.shadowGlowBlur = 16,
    this.shadowGlowOpacity = 0.06,
    this.shadowGlowOffset = const Offset(0, 6),
    this.shadowGlowSpread = -10,
    this.borderWidth = 1,
  });

  @override
  PremiumCardStyle copyWith({
    List<Color>? cardGradient,
    Color? borderColor,
    Color? shadowDark,
    Color? shadowGlow,
    List<Color>? topOverlayGradient,
    Color? noiseColor,
    double? shadowDarkBlur,
    double? shadowDarkOpacity,
    Offset? shadowDarkOffset,
    double? shadowDarkSpread,
    double? shadowGlowBlur,
    double? shadowGlowOpacity,
    Offset? shadowGlowOffset,
    double? shadowGlowSpread,
    double? borderWidth,
  }) {
    return PremiumCardStyle(
      cardGradient: cardGradient ?? this.cardGradient,
      borderColor: borderColor ?? this.borderColor,
      shadowDark: shadowDark ?? this.shadowDark,
      shadowGlow: shadowGlow ?? this.shadowGlow,
      topOverlayGradient: topOverlayGradient ?? this.topOverlayGradient,
      noiseColor: noiseColor ?? this.noiseColor,
      shadowDarkBlur: shadowDarkBlur ?? this.shadowDarkBlur,
      shadowDarkOpacity: shadowDarkOpacity ?? this.shadowDarkOpacity,
      shadowDarkOffset: shadowDarkOffset ?? this.shadowDarkOffset,
      shadowDarkSpread: shadowDarkSpread ?? this.shadowDarkSpread,
      shadowGlowBlur: shadowGlowBlur ?? this.shadowGlowBlur,
      shadowGlowOpacity: shadowGlowOpacity ?? this.shadowGlowOpacity,
      shadowGlowOffset: shadowGlowOffset ?? this.shadowGlowOffset,
      shadowGlowSpread: shadowGlowSpread ?? this.shadowGlowSpread,
      borderWidth: borderWidth ?? this.borderWidth,
    );
  }

  @override
  PremiumCardStyle lerp(ThemeExtension<PremiumCardStyle>? other, double t) {
    if (other is! PremiumCardStyle) return this;
    return PremiumCardStyle(
      cardGradient: cardGradient.asMap().entries.map((e) => 
        Color.lerp(e.value, other.cardGradient[e.key], t)!).toList(),
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      shadowDark: Color.lerp(shadowDark, other.shadowDark, t)!,
      shadowGlow: Color.lerp(shadowGlow, other.shadowGlow, t)!,
      topOverlayGradient: topOverlayGradient.asMap().entries.map((e) => 
        Color.lerp(e.value, other.topOverlayGradient[e.key], t)!).toList(),
      noiseColor: Color.lerp(noiseColor, other.noiseColor, t)!,
      shadowDarkBlur: lerpDouble(shadowDarkBlur, other.shadowDarkBlur, t),
      shadowDarkOpacity: lerpDouble(shadowDarkOpacity, other.shadowDarkOpacity, t),
      shadowGlowBlur: lerpDouble(shadowGlowBlur, other.shadowGlowBlur, t),
      shadowGlowOpacity: lerpDouble(shadowGlowOpacity, other.shadowGlowOpacity, t),
      borderWidth: lerpDouble(borderWidth, other.borderWidth, t),
    );
  }
  
  double lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }

  // Light theme premium card style
  static const light = PremiumCardStyle(
    cardGradient: [
      AppColors.lightPremiumCard1,
      AppColors.lightPremiumCard2,
    ],
    borderColor: Color(0x2ECEA10F), // primary.withOpacity(0.18)
    shadowDark: Color(0x1A000000), // black.withOpacity(0.10)
    shadowGlow: Color(0x14CEA10F), // primary.withOpacity(0.08)
    topOverlayGradient: [
      AppColors.lightPremiumOverlay1,
      Colors.transparent,
    ],
    noiseColor: AppColors.lightPremiumNoise,
    shadowDarkBlur: 18,
    shadowDarkOpacity: 0.10,
  );

  // Dark theme premium card style
  static const dark = PremiumCardStyle(
    cardGradient: [
      AppColors.darkPremiumCard1,
      AppColors.darkPremiumCard2,
    ],
    borderColor: Color(0x1AD4AF37), // primaryGold.withOpacity(0.10)
    shadowDark: Color(0x73000000), // black.withOpacity(0.45)
    shadowGlow: Color(0x0FD4AF37), // primaryGold.withOpacity(0.06)
    topOverlayGradient: [
      AppColors.darkPremiumOverlay1,
      Colors.transparent,
    ],
    noiseColor: AppColors.darkPremiumNoise,
    shadowDarkBlur: 18,
    shadowDarkOpacity: 0.45,
  );
}

/// Builds a premium card with golden border, 3D shadows, and glow effect
/// Matches the home page card styling exactly
/// 
/// Usage:
/// ```dart
/// buildPremiumCard(
///   context: context,
///   child: YourContent(),
///   radius: 18,
///   padding: EdgeInsets.all(16),
/// )
/// ```
Widget buildPremiumCard({
  required BuildContext context,
  required Widget child,
  double radius = 18,
  BorderRadius? borderRadius,
  EdgeInsets padding = const EdgeInsets.all(16),
  EdgeInsets margin = EdgeInsets.zero,
  Alignment gradientBegin = Alignment.topLeft,
  Alignment gradientEnd = Alignment.bottomRight,
}) {
  final theme = Theme.of(context);
  final cardStyle = theme.extension<PremiumCardStyle>()!;
  final br = borderRadius ?? BorderRadius.circular(radius);

  return Container(
    margin: margin,
    decoration: BoxDecoration(
      borderRadius: br,
      boxShadow: [
        BoxShadow(
          color: cardStyle.shadowDark,
          blurRadius: cardStyle.shadowDarkBlur,
          offset: cardStyle.shadowDarkOffset,
          spreadRadius: cardStyle.shadowDarkSpread,
        ),
        BoxShadow(
          color: cardStyle.shadowGlow,
          blurRadius: cardStyle.shadowGlowBlur,
          offset: cardStyle.shadowGlowOffset,
          spreadRadius: cardStyle.shadowGlowSpread,
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: br,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: gradientBegin,
            end: gradientEnd,
            colors: cardStyle.cardGradient,
          ),
          border: Border.all(
            color: cardStyle.borderColor,
            width: cardStyle.borderWidth,
          ),
          borderRadius: br,
        ),
        child: Stack(
          children: [
            // Top overlay gradient for depth
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: cardStyle.topOverlayGradient,
                    ),
                    borderRadius: br,
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: padding,
              child: child,
            ),
          ],
        ),
      ),
    ),
  );
}

/// Builds a premium card with InkWell for tap interactions
/// Includes golden border, 3D shadows, glow effect, and ripple effect
/// 
/// Usage:
/// ```dart
/// buildPremiumInkCard(
///   context: context,
///   onTap: () {},
///   child: YourContent(),
/// )
/// ```
Widget buildPremiumInkCard({
  required BuildContext context,
  required VoidCallback onTap,
  required Widget child,
  double radius = 18,
  BorderRadius? borderRadius,
  EdgeInsets padding = const EdgeInsets.all(16),
  EdgeInsets margin = EdgeInsets.zero,
  Alignment gradientBegin = Alignment.topLeft,
  Alignment gradientEnd = Alignment.bottomRight,
  Color? backgroundColor,
}) {
  final theme = Theme.of(context);
  final cardStyle = theme.extension<PremiumCardStyle>()!;
  final br = borderRadius ?? BorderRadius.circular(radius);

  return Container(
    margin: margin,
    decoration: BoxDecoration(
      borderRadius: br,
      boxShadow: [
        BoxShadow(
          color: cardStyle.shadowDark,
          blurRadius: cardStyle.shadowDarkBlur,
          offset: cardStyle.shadowDarkOffset,
          spreadRadius: cardStyle.shadowDarkSpread,
        ),
        BoxShadow(
          color: cardStyle.shadowGlow,
          blurRadius: cardStyle.shadowGlowBlur,
          offset: cardStyle.shadowGlowOffset,
          spreadRadius: cardStyle.shadowGlowSpread,
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: br,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: br,
          child: Ink(
            decoration: BoxDecoration(
              color: backgroundColor,
              gradient: backgroundColor == null
                  ? LinearGradient(
                      begin: gradientBegin,
                      end: gradientEnd,
                      colors: cardStyle.cardGradient,
                    )
                  : null,
              border: Border.all(
                color: cardStyle.borderColor,
                width: cardStyle.borderWidth,
              ),
            ),
            child: Stack(
              children: [
                // Top overlay gradient for depth
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: cardStyle.topOverlayGradient,
                        ),
                      ),
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: padding,
                  child: child,
                ),
              ],
            ),    
          ),
        ),
      ),
    ),
  );
}

class AppTheme {
  /// Get theme by name - supports easy extension to new themes
  /// Currently supports: 'light', 'dark'
  /// Future: 'green', 'blue', etc.
  static ThemeData getTheme(String themeName) {
    switch (themeName) {
      case 'light':
        return lightTheme;
      case 'dark':
        return darkTheme;
      // Easy to add new themes:
      // case 'green':
      //   return greenTheme;
      default:
        return darkTheme; // fallback
    }
  }

  // Colors
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryGold,
      secondary: AppColors.primaryGold,
      surface: AppColors.darkBackground,
      surfaceContainerHighest: AppColors.darkCard,
      onPrimary: AppColors.onPrimaryDark,
      onSecondary: AppColors.onSecondaryDark,
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      foregroundColor: AppColors.primaryGold,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.primaryGold,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: AppColors.primaryGold),
    ),
    cardTheme: CardThemeData(   
      color: AppColors.darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    fontFamily: 'MehdiEkushey',
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryGold,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryGold,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryGold,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: AppColors.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: AppColors.textTertiary,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: AppColors.grey500,
      ),
    ),
    iconTheme: const IconThemeData(
      color: AppColors.primaryGold,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.dividerDark,
      thickness: 1,
    ),
    extensions: const <ThemeExtension<dynamic>>[
      GradientColors.dark,
      PremiumCardStyle.dark,
    ],
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
      onPrimary: AppColors.onPrimaryTextLight,
      onSecondary: AppColors.onPrimaryTextLight,
      onSurface: AppColors.textLightMode,
      error: AppColors.error,
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
    fontFamily: 'MehdiEkushey',
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
    extensions: const <ThemeExtension<dynamic>>[
      GradientColors.light,
      PremiumCardStyle.light,
    ],
  );
}

