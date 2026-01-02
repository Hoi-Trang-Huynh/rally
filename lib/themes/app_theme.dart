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
      primary: const Color(0xff904a48),
      surfaceTint: const Color(0xff904a48),
      onPrimary: const Color(0xffffffff),
      primaryContainer: const Color(0xffffdad7),
      onPrimaryContainer: const Color(0xff733332),
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
      surface: const Color(0xfffff8f7),
      onSurface: const Color(0xff231919),
      onSurfaceVariant: const Color(0xff534342),
      outline: const Color(0xff857372),
      outlineVariant: const Color(0xffd8c1c0),
      shadow: const Color(0xff000000),
      scrim: const Color(0xff000000),
      inverseSurface: const Color(0xff382e2d),
      inversePrimary: const Color(0xffffb3af),
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
      surfaceDim: const Color(0xffe8d6d5),
      surfaceBright: const Color(0xfffff8f7),
      surfaceContainerLowest: const Color(0xffffffff),
      surfaceContainerLow: const Color(0xfffff0ef),
      surfaceContainer: const Color(0xfffceae8),
      surfaceContainerHigh: const Color(0xfff6e4e3),
      surfaceContainerHighest: const Color(0xfff0dedd),
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
      textTheme: AppTextStyles.m3TextTheme
          .copyWith(
            // Mobile optimizations
            headlineMedium: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            bodyMedium: const TextStyle(fontSize: 16), // Readable body text
          )
          .apply(
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
      primary: const Color(0xffffb3af),
      surfaceTint: const Color(0xffffb3af),
      onPrimary: const Color(0xff571d1d),
      primaryContainer: const Color(0xff733332),
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
      surface: const Color(0xff1a1111),
      onSurface: const Color(0xfff0dedd),
      onSurfaceVariant: const Color(0xffd8c1c0),
      outline: const Color(0xffa08c8b),
      outlineVariant: const Color(0xff534342),
      shadow: const Color(0xff000000),
      scrim: const Color(0xff000000),
      inverseSurface: const Color(0xfff0dedd),
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
      surfaceDim: const Color(0xff1a1111),
      surfaceBright: const Color(0xff423736),
      surfaceContainerLowest: const Color(0xff140c0c),
      surfaceContainerLow: const Color(0xff231919),
      surfaceContainer: const Color(0xff271d1d),
      surfaceContainerHigh: const Color(0xff322827),
      surfaceContainerHighest: const Color(0xff3d3231),
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
      textTheme: AppTextStyles.m3TextTheme
          .copyWith(
            // Mobile optimizations
            headlineMedium: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            bodyMedium: const TextStyle(fontSize: 16),
          )
          .apply(
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
