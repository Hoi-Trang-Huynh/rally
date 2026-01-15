import 'package:flutter/material.dart';

/// Responsive utility class for scaling UI elements based on screen size.
///
/// This class provides methods to scale sizes proportionally to the device screen,
/// ensuring consistent UI across different phone sizes and tablets.
///
/// **Guidelines:**
/// - Use `w()` for horizontal dimensions (padding, margins, widths, border radius)
/// - Use `h()` for vertical dimensions (heights, vertical spacing)
/// - Use `wp()`/`hp()` for percentage-based layouts
/// - For text, use `Theme.of(context).textTheme` - Flutter handles text scaling automatically
///
/// Example:
/// ```dart
/// final double padding = Responsive.w(context, 24);
/// final double height = Responsive.h(context, 16);
/// ```
class Responsive {
  // Design reference dimensions (iPhone 13 mini / SE size)
  static const double _designWidth = 375.0;
  static const double _designHeight = 812.0;

  // Cached screen dimensions for current context
  static double _screenWidth = 0;
  static double _screenHeight = 0;

  /// Initialize or update cached screen dimensions from context.
  static void _init(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    _screenWidth = size.width;
    _screenHeight = size.height;
  }

  /// Scale based on screen width.
  ///
  /// Use for horizontal dimensions: padding, margins, widths, border radius.
  /// Example: `Responsive.w(context, 24)` returns 24 scaled to screen width.
  static double w(BuildContext context, double size) {
    _init(context);
    return size * (_screenWidth / _designWidth);
  }

  /// Scale based on screen height.
  ///
  /// Use for vertical dimensions: heights, vertical spacing.
  /// Example: `Responsive.h(context, 16)` returns 16 scaled to screen height.
  static double h(BuildContext context, double size) {
    _init(context);
    return size * (_screenHeight / _designHeight);
  }

  /// Get percentage of screen width.
  ///
  /// Example: `Responsive.wp(context, 50)` returns 50% of screen width.
  static double wp(BuildContext context, double percentage) {
    _init(context);
    return (_screenWidth * percentage) / 100;
  }

  /// Get percentage of screen height.
  ///
  /// Example: `Responsive.hp(context, 50)` returns 50% of screen height.
  static double hp(BuildContext context, double percentage) {
    _init(context);
    return (_screenHeight * percentage) / 100;
  }

  /// Check if the current device is a tablet (width >= 600dp).
  static bool isTablet(BuildContext context) {
    _init(context);
    return _screenWidth >= 600;
  }

  /// Check if the current device is a phone (width < 600dp).
  static bool isPhone(BuildContext context) {
    _init(context);
    return _screenWidth < 600;
  }

  /// Check if the current device is a small phone (width < 360dp).
  static bool isSmallPhone(BuildContext context) {
    _init(context);
    return _screenWidth < 360;
  }

  /// Get the current screen width.
  static double screenWidth(BuildContext context) {
    _init(context);
    return _screenWidth;
  }

  /// Get the current screen height.
  static double screenHeight(BuildContext context) {
    _init(context);
    return _screenHeight;
  }
}
