import 'package:flutter/material.dart';

/// AppColors provides the design system color palette for the Rally app.
///
/// Colors are grouped by usage: Neutral, Primary, Success, Warning, Destructive.
/// Each color is named by its group and shade (e.g., neutral50, primary500).
///
/// See design documentation for intended usage and hex values.
abstract class AppColors {
  /// Seed color for generating the color scheme.
  static const Color seedColor = Color(0xFFC04444);

  /// Success colors: Used for success states, confirmations, etc.
  /// 50 - #F0FDF4
  static const Color success50 = Color(0xFFF0FDF4);

  /// 100 - #DCFCE7
  static const Color success100 = Color(0xFFDCFCE7);

  /// 200 - #BBF7D0
  static const Color success200 = Color(0xFFBBF7D0);

  /// 300 - #86EFAC
  static const Color success300 = Color(0xFF86EFAC);

  /// 400 - #4ADE80
  static const Color success400 = Color(0xFF4ADE80);

  /// 500 - #22C55E (success main)
  static const Color success500 = Color(0xFF22C55E);

  /// 600 - #16A34A
  static const Color success600 = Color(0xFF16A34A);

  /// 700 - #15803D
  static const Color success700 = Color(0xFF15803D);

  /// 800 - #166534
  static const Color success800 = Color(0xFF166534);

  /// 900 - #14532D
  static const Color success900 = Color(0xFF14532D);

  /// Warning colors: Used for warning states, cautions, etc.
  /// 50 - #FFF8E1
  static const Color warning50 = Color(0xFFFFF8E1);

  /// 100 - #FEF3C7
  static const Color warning100 = Color(0xFFFEF3C7);

  /// 200 - #FDE68A
  static const Color warning200 = Color(0xFFFDE68A);

  /// 300 - #FCD34D
  static const Color warning300 = Color(0xFFFCD34D);

  /// 400 - #FBBF24
  static const Color warning400 = Color(0xFFFBBF24);

  /// 500 - #F59E0B (warning main)
  static const Color warning500 = Color(0xFFF59E0B);

  /// 600 - #D97706
  static const Color warning600 = Color(0xFFD97706);

  /// 700 - #B45309
  static const Color warning700 = Color(0xFFB45309);

  /// 800 - #92400E
  static const Color warning800 = Color(0xFF92400E);

  /// 900 - #78350F
  static const Color warning900 = Color(0xFF78350F);
}
