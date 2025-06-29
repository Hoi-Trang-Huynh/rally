import 'package:flutter/material.dart';

class AppTextStyles {
  static TextStyle headlineLarge(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    return TextStyle(
      fontSize: _getHeadlineSize(locale.languageCode),
      fontWeight: FontWeight.bold,
      height: 1.2,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle bodyText(BuildContext context) {
    return TextStyle(
      fontSize: 16,
      height: 1.5,
      color: Theme.of(context).textTheme.bodyMedium?.color,
    );
  }

  static double _getHeadlineSize(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 28.0;
      case 'vn':
        return 32.0;
      default:
        return 24.0;
    }
  }
}
