import 'package:flutter/material.dart';

/// AppThemeExtension provides custom theme properties for Rally app components.
///
/// Includes semantic colors and text styles for success, warning, and special text.
@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  /// Creates an [AppThemeExtension] with custom semantic colors and text styles.
  const AppThemeExtension({
    required this.successColor,
    required this.warningColor,
    required this.specialTextStyle,
  });

  /// Color used for success states (e.g., confirmations).
  final Color successColor;

  /// Color used for warning states (e.g., cautions).
  final Color warningColor;

  /// Special text style for custom UI elements.
  final TextStyle specialTextStyle;

  /// Returns a copy of this theme extension with the given fields replaced by new values.
  @override
  ThemeExtension<AppThemeExtension> copyWith({
    Color? successColor,
    Color? warningColor,
    TextStyle? specialTextStyle,
  }) {
    return AppThemeExtension(
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
      specialTextStyle: specialTextStyle ?? this.specialTextStyle,
    );
  }

  /// Linearly interpolate between two [AppThemeExtension]s.
  @override
  ThemeExtension<AppThemeExtension> lerp(
    ThemeExtension<AppThemeExtension>? other,
    double t,
  ) {
    if (other is! AppThemeExtension) {
      return this;
    }
    return AppThemeExtension(
      successColor: Color.lerp(successColor, other.successColor, t)!,
      warningColor: Color.lerp(warningColor, other.warningColor, t)!,
      specialTextStyle:
          TextStyle.lerp(specialTextStyle, other.specialTextStyle, t)!,
    );
  }
}
