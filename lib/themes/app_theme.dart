// themes/app_theme.dart
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_theme_extension.dart';

/// AppTheme provides the Rally app's theme configuration using Material 3.
///
/// Uses [ColorScheme.fromSeed] to generate a harmonious color scheme based on the primary color.
/// When designers finalize the moodboard, update the seed and overrides as needed.
abstract class AppTheme {
  /// The light theme for the Rally app, following Material 3 guidelines.
  ///
  /// Uses [ColorScheme.fromSeed] with [AppColors.primary500] as the seed color.
  /// Overrides surface and error colors for consistency with the design palette.
  static ThemeData get light {
    final ThemeData base = ThemeData.light(useMaterial3: true);
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.seedColor,
      brightness: Brightness.light,
      primary: const Color(0xffC04444),
      surfaceTint: const Color(0xffC04444),
      onPrimary: const Color(0xffffffff),
      primaryContainer: const Color(0xffffdad7),
      onPrimaryContainer: const Color(0xff8B2D2D),
      secondary: const Color(0xff775654),
      onSecondary: const Color(0xffffffff),
      secondaryContainer: const Color(0xffffdad7),
      onSecondaryContainer: const Color(0xff5d3f3d),
      tertiary: const Color(0xff854b70),
      onTertiary: const Color(0xffffffff),
      tertiaryContainer: const Color(0xffffd8ec),
      onTertiaryContainer: const Color(0xff6a3457),
      error: const Color(0xffba1a1a),
      onError: const Color(0xffffffff),
      errorContainer: const Color(0xffffdad6),
      onErrorContainer: const Color(0xff93000a),
      surface: const Color(0xfffafafa), // Clean white
      onSurface: const Color(0xff1a1a1a),
      onSurfaceVariant: const Color(0xff6b6b6b),
      outline: const Color(0xff858585),
      outlineVariant: const Color(0xffe5e5e5),
      shadow: const Color(0xff000000),
      scrim: const Color(0xff000000),
      inverseSurface: const Color(0xff262626),
      inversePrimary: const Color(0xffffb3af),
      primaryFixed: const Color(0xffffdad7),
      onPrimaryFixed: const Color(0xff3b080a),
      primaryFixedDim: const Color(0xffffb3af),
      onPrimaryFixedVariant: const Color(0xff733332),
      secondaryFixed: const Color(0xfff5f5f5),
      onSecondaryFixed: const Color(0xff1a1a1a),
      secondaryFixedDim: const Color(0xffe5e5e5),
      onSecondaryFixedVariant: const Color(0xff525252),
      tertiaryFixed: const Color(0xffffd8ec),
      onTertiaryFixed: const Color(0xff37072a),
      tertiaryFixedDim: const Color(0xfff9b1db),
      onTertiaryFixedVariant: const Color(0xff6a3457),
      surfaceDim: const Color(0xffe5e5e5),
      surfaceBright: const Color(0xffffffff),
      surfaceContainerLowest: const Color(0xffffffff),
      surfaceContainerLow: const Color(0xfff2f2f2), // Slightly darker than surface
      surfaceContainer: const Color(0xffebebeb), // Distinct gray for navbar
      surfaceContainerHigh: const Color(0xffe6e6e6), // Darker for emphasis
      surfaceContainerHighest: const Color(0xffdfdfdf), // Darkest container
    );

    // Common Button Style for consistency
    final FilledButtonThemeData filledButtonTheme = FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(56), // Mobile friendly height
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );

    return base.copyWith(
      colorScheme: colorScheme,
      textTheme: AppTextStyles.m3TextTheme.apply(
        fontFamily: 'Inclusive Sans',
        displayColor: colorScheme.onSurface,
        bodyColor: colorScheme.onSurface,
      ),
      filledButtonTheme: filledButtonTheme,
      extensions: <ThemeExtension<dynamic>>[
        const AppThemeExtension(
          successColor: AppColors.success500,
          warningColor: AppColors.warning500,
          specialTextStyle: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  /// The dark theme for the Rally app, following Material 3 guidelines.
  ///
  /// Uses [ColorScheme.fromSeed] with [AppColors.primary500] as the seed color.
  /// Overrides surface and error colors for consistency with the design palette.
  static ThemeData get dark {
    final ThemeData base = ThemeData.dark(useMaterial3: true);
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.seedColor,
      brightness: Brightness.dark,
      primary: const Color(0xffC04444),
      surfaceTint: const Color(0xffC04444),
      onPrimary: const Color(0xffffffff),
      primaryContainer: const Color(0xff8B2D2D),
      onPrimaryContainer: const Color(0xffffdad7),
      secondary: const Color(0xffe7bdba),
      onSecondary: const Color(0xff442928),
      secondaryContainer: const Color(0xff5d3f3d),
      onSecondaryContainer: const Color(0xffffdad7),
      tertiary: const Color(0xfff9b1db),
      onTertiary: const Color(0xff501e40),
      tertiaryContainer: const Color(0xff6a3457),
      onTertiaryContainer: const Color(0xffffd8ec),
      error: const Color(0xffffb4ab),
      onError: const Color(0xff690005),
      errorContainer: const Color(0xff93000a),
      onErrorContainer: const Color(0xffffdad6),
      surface: const Color(0xff121212), // Instagram dark gray
      onSurface: const Color(0xfffafafa),
      onSurfaceVariant: const Color(0xffa1a1aa),
      outline: const Color(0xff3f3f46),
      outlineVariant: const Color(0xff27272a),
      shadow: const Color(0xff000000),
      scrim: const Color(0xff000000),
      inverseSurface: const Color(0xfffafafa),
      inversePrimary: const Color(0xff904a48),
      primaryFixed: const Color(0xffffdad7),
      onPrimaryFixed: const Color(0xff3b080a),
      primaryFixedDim: const Color(0xffffb3af),
      onPrimaryFixedVariant: const Color(0xff733332),
      secondaryFixed: const Color(0xffffdad7),
      onSecondaryFixed: const Color(0xff2c1514),
      secondaryFixedDim: const Color(0xffe7bdba),
      onSecondaryFixedVariant: const Color(0xff5d3f3d),
      tertiaryFixed: const Color(0xffffd8ec),
      onTertiaryFixed: const Color(0xff37072a),
      tertiaryFixedDim: const Color(0xfff9b1db),
      onTertiaryFixedVariant: const Color(0xff6a3457),
      surfaceDim: const Color(0xff0a0a0a),
      surfaceBright: const Color(0xff2a2a2a),
      surfaceContainerLowest: const Color(0xff0a0a0a),
      surfaceContainerLow: const Color(0xff1a1a1a),
      surfaceContainer: const Color(0xff212121), // Nav bar - soft dark gray
      surfaceContainerHigh: const Color(0xff2b2b2b),
      surfaceContainerHighest: const Color(0xff363636),
    );

    // Common Button Style (Dark)
    final FilledButtonThemeData filledButtonTheme = FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );

    return base.copyWith(
      colorScheme: colorScheme,
      textTheme: AppTextStyles.m3TextTheme.apply(
        fontFamily: 'Inclusive Sans',
        displayColor: colorScheme.onSurface,
        bodyColor: colorScheme.onSurface,
      ),
      filledButtonTheme: filledButtonTheme,
      extensions: <ThemeExtension<dynamic>>[
        const AppThemeExtension(
          successColor: AppColors.success500,
          warningColor: AppColors.warning500,
          specialTextStyle: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
