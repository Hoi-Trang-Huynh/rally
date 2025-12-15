import 'package:flutter/material.dart';
import 'package:rally/i18n/generated/translations.g.dart';

/// Returns the localized name of the language for the given [locale].
///
/// This function maps the language code to a localized string defined in
/// the slang translations. If the language code is not recognized, it returns
/// the language code itself.
String getLocalizedLanguageName(BuildContext context, AppLocale locale) {
  switch (locale) {
    case AppLocale.en:
      return t.common.language.english;
    case AppLocale.vi:
      return t.common.language.vietnamese;
  }
}
