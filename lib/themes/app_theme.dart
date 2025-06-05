// themes/app_theme.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_theme_extension.dart';

abstract class AppTheme {
  static ThemeData get light {
    final base = ThemeData.light();
    return base.copyWith(
      colorScheme: const ColorScheme.light(
        primary: AppColors.lightPrimary,
        secondary: AppColors.lightSecondary,
        surface: AppColors.lightPrimaryVariant,
        error: AppColors.error,
      ),
      extensions: <ThemeExtension<dynamic>>[
        const AppThemeExtension(
          successColor: AppColors.success,
          warningColor: AppColors.warning,
          specialTextStyle: TextStyle(
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  static ThemeData get dark {
    final base = ThemeData.dark();
    return base.copyWith(
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkPrimary,
        secondary: AppColors.darkSecondary,
        surface: AppColors.darkPrimaryVariant,
        error: AppColors.error,
      ),
      extensions: <ThemeExtension<dynamic>>[
        const AppThemeExtension(
          successColor: AppColors.success,
          warningColor: AppColors.warning,
          specialTextStyle: TextStyle(
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
