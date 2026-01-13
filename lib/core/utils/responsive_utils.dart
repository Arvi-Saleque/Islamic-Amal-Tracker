import 'package:flutter/material.dart';

/// Responsive utility class for adaptive sizing across different devices
class ResponsiveUtils {
  /// Get adaptive font size based on screen width
  static double getAdaptiveFontSize(BuildContext context, double baseFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Small phones (width < 360)
    if (screenWidth < 360) {
      return baseFontSize * 0.85;
    }
    // Normal phones (360 <= width < 400)
    else if (screenWidth < 400) {
      return baseFontSize * 0.95;
    }
    // Large phones and small tablets (400 <= width < 600)
    else if (screenWidth < 600) {
      return baseFontSize;
    }
    // Tablets (width >= 600)
    else {
      return baseFontSize * 1.1;
    }
  }

  /// Get adaptive padding based on screen width
  static double getAdaptivePadding(BuildContext context, double basePadding) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < 360) {
      return basePadding * 0.8;
    } else if (screenWidth < 400) {
      return basePadding * 0.9;
    } else if (screenWidth < 600) {
      return basePadding;
    } else {
      return basePadding * 1.2;
    }
  }

  /// Get adaptive icon size based on screen width
  static double getAdaptiveIconSize(BuildContext context, double baseIconSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < 360) {
      return baseIconSize * 0.85;
    } else if (screenWidth < 400) {
      return baseIconSize * 0.9;
    } else if (screenWidth < 600) {
      return baseIconSize;
    } else {
      return baseIconSize * 1.15;
    }
  }

  /// Check if device is a small screen
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 360;
  }

  /// Check if device is a tablet
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600;
  }

  /// Get adaptive horizontal margin
  static double getHorizontalMargin(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < 360) {
      return 12;
    } else if (screenWidth < 400) {
      return 16;
    } else if (screenWidth < 600) {
      return 20;
    } else {
      return 24;
    }
  }
}

/// Extension on BuildContext for easy access to responsive utilities
extension ResponsiveExtension on BuildContext {
  /// Get adaptive font size
  double adaptiveFontSize(double baseSize) => 
      ResponsiveUtils.getAdaptiveFontSize(this, baseSize);
  
  /// Get adaptive padding
  double adaptivePadding(double baseSize) => 
      ResponsiveUtils.getAdaptivePadding(this, baseSize);
  
  /// Get adaptive icon size
  double adaptiveIconSize(double baseSize) => 
      ResponsiveUtils.getAdaptiveIconSize(this, baseSize);
  
  /// Check if small screen
  bool get isSmallScreen => ResponsiveUtils.isSmallScreen(this);
  
  /// Check if tablet
  bool get isTablet => ResponsiveUtils.isTablet(this);
  
  /// Get horizontal margin
  double get horizontalMargin => ResponsiveUtils.getHorizontalMargin(this);
  
  /// Get screen width
  double get screenWidth => MediaQuery.of(this).size.width;
  
  /// Get screen height  
  double get screenHeight => MediaQuery.of(this).size.height;
}

/// Responsive text widget that auto-scales and handles overflow
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int maxLines;
  final TextOverflow overflow;
  final TextAlign? textAlign;

  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.maxLines = 2,
    this.overflow = TextOverflow.ellipsis,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? const TextStyle();
    final adaptedFontSize = baseStyle.fontSize != null
        ? context.adaptiveFontSize(baseStyle.fontSize!)
        : null;

    return Text(
      text,
      style: baseStyle.copyWith(fontSize: adaptedFontSize),
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}
