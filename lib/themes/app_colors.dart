import 'package:flutter/material.dart';

abstract class AppColors {
  // Light theme colors
  static const Color lightPrimary = Color(0xFF6200EE); // Purple
  static const Color lightPrimaryVariant = Color(0xFF3700B3); // Dark purple
  static const Color lightSecondary = Color(0xFF03DAC6); // Teal

  // Dark theme colors
  static const Color darkPrimary = Color(0xFFBB86FC); // Light purple
  static const Color darkPrimaryVariant = Color(0xFF3700B3); // Dark purple
  static const Color darkSecondary = Color(0xFF03DAC6); // Same teal

  // Common colors (used in both themes)
  static const Color error = Color(0xFFB00020); // Red
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color warning = Color(0xFFFFC107); // Amber
}
