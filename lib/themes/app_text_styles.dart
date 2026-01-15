import 'package:flutter/material.dart';

/// AppTextStyles provides text style definitions for the Rally app using Material 3.
///
/// This is the **single source of truth** for text styles. Use these via:
/// ```dart
/// Theme.of(context).textTheme.bodyMedium
/// ```
///
/// Flutter's built-in text scaling handles responsive sizing automatically
/// based on device settings and screen size.
class AppTextStyles {
  /// Returns the Material 3 TextTheme.
  ///
  /// Used in [AppTheme] for the default theme configuration.
  /// These follow M3 type scale specifications.
  static TextTheme get m3TextTheme {
    return const TextTheme(
      // Display - Large promotional text
      displayLarge: TextStyle(fontSize: 57, height: 64 / 57, letterSpacing: -0.25),
      displayMedium: TextStyle(fontSize: 45, height: 52 / 45, letterSpacing: 0),
      displaySmall: TextStyle(fontSize: 36, height: 44 / 36, letterSpacing: 0),

      // Headline - High emphasis text
      headlineLarge: TextStyle(fontSize: 32, height: 40 / 32, letterSpacing: 0),
      headlineMedium: TextStyle(fontSize: 28, height: 36 / 28, letterSpacing: 0),
      headlineSmall: TextStyle(fontSize: 24, height: 32 / 24, letterSpacing: 0),

      // Title - Medium emphasis text
      titleLarge: TextStyle(fontSize: 22, height: 28 / 22, letterSpacing: 0),
      titleMedium: TextStyle(fontSize: 16, height: 24 / 16, letterSpacing: 0.15),
      titleSmall: TextStyle(fontSize: 14, height: 20 / 14, letterSpacing: 0.1),

      // Body - Paragraph text
      bodyLarge: TextStyle(fontSize: 16, height: 24 / 16, letterSpacing: 0.5),
      bodyMedium: TextStyle(fontSize: 14, height: 20 / 14, letterSpacing: 0.25),
      bodySmall: TextStyle(fontSize: 12, height: 16 / 12, letterSpacing: 0.4),

      // Label - Button/caption text
      labelLarge: TextStyle(fontSize: 14, height: 20 / 14, letterSpacing: 0.1),
      labelMedium: TextStyle(fontSize: 12, height: 16 / 12, letterSpacing: 0.5),
      labelSmall: TextStyle(fontSize: 11, height: 16 / 11, letterSpacing: 0.5),
    );
  }
}
