import 'package:flutter/material.dart';

abstract class AppColors {
  // Light theme colors
  static const lightPrimary = Color(0xFF6200EE); // Purple
  static const lightPrimaryVariant = Color(0xFF3700B3); // Dark purple
  static const lightSecondary = Color(0xFF03DAC6); // Teal

  // Dark theme colors
  static const darkPrimary = Color(0xFFBB86FC); // Light purple
  static const darkPrimaryVariant = Color(0xFF3700B3); // Dark purple
  static const darkSecondary = Color(0xFF03DAC6); // Same teal

  // Common colors (used in both themes)
  static const error = Color(0xFFB00020); // Red
  static const success = Color(0xFF4CAF50); // Green
  static const warning = Color(0xFFFFC107); // Amber
}
