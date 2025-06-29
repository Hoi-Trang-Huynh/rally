import 'package:flutter/material.dart';
import 'package:rally/l10n/generated/app_localizations.dart';

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
