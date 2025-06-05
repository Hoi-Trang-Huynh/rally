import 'package:flutter/material.dart';

@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  const AppThemeExtension({
    required this.successColor,
    required this.warningColor,
    required this.specialTextStyle,
  });
  final Color successColor;
  final Color warningColor;
  final TextStyle specialTextStyle;

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
