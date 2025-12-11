import 'package:flutter/material.dart';
import 'package:rally/l10n/generated/app_localizations.dart';

/// Returns the localized name of the language for the given [locale].
///
/// This function maps the language code to a localized string defined in
/// [AppLocalizations]. If the language code is not recognized, it returns
/// the language code itself.
String getLocalizedLanguageName(BuildContext context, Locale locale) {
  final AppLocalizations localizations = AppLocalizations.of(context)!;

  switch (locale.languageCode) {
    case 'en':
      return localizations.languageEnglish;
    case 'vi':
      return localizations.languageVietnamese;
    case 'ko':
      return localizations.languageKorean;
    default:
      return locale.languageCode;
  }
}
