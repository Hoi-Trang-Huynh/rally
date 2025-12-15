import 'package:flutter/material.dart';

/// AppTextStyles provides text style definitions for the Rally app using Material 3.
class AppTextStyles {
  /// Returns the Material 3 TextTheme based on the user's specifications.
  static TextTheme get m3TextTheme {
    return const TextTheme(
      // Display
      displayLarge: TextStyle(fontSize: 57, height: 64 / 57, letterSpacing: -0.25),
      displayMedium: TextStyle(fontSize: 45, height: 52 / 45, letterSpacing: 0),
      displaySmall: TextStyle(fontSize: 36, height: 44 / 36, letterSpacing: 0),

      // Headline
      headlineLarge: TextStyle(fontSize: 32, height: 40 / 32, letterSpacing: 0),
      headlineMedium: TextStyle(fontSize: 28, height: 36 / 28, letterSpacing: 0),
      headlineSmall: TextStyle(fontSize: 24, height: 32 / 24, letterSpacing: 0),

      // Title
      titleLarge: TextStyle(fontSize: 22, height: 28 / 22, letterSpacing: 0),
      titleMedium: TextStyle(fontSize: 12, letterSpacing: 0),
      titleSmall: TextStyle(fontSize: 12, letterSpacing: 0),

      // Body
      bodyLarge: TextStyle(fontSize: 16, height: 24 / 16, letterSpacing: 0.5),
      bodyMedium: TextStyle(fontSize: 14, height: 20 / 14, letterSpacing: 0.25),
      bodySmall: TextStyle(fontSize: 12, height: 16 / 12, letterSpacing: 0.4),

      // Label
      labelLarge: TextStyle(fontSize: 12, letterSpacing: 0),
      labelMedium: TextStyle(fontSize: 12, letterSpacing: 0),
      labelSmall: TextStyle(fontSize: 12, letterSpacing: 0),
    );
  }
}
