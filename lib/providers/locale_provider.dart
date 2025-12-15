import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rally/constants/shared_pref_keys.dart';
import 'package:rally/i18n/generated/translations.g.dart';
import 'package:rally/services/shared_prefs_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// State class for the [LocaleNotifier].
class LocaleState {
  /// The current locale.
  final AppLocale locale;

  /// Creates a new [LocaleState].
  const LocaleState({required this.locale});
}

/// Provider for the [LocaleNotifier].
final NotifierProvider<LocaleNotifier, LocaleState> localeProvider =
    NotifierProvider<LocaleNotifier, LocaleState>(LocaleNotifier.new);

/// Notifier for managing the app's locale.
class LocaleNotifier extends Notifier<LocaleState> {
  @override
  LocaleState build() {
    return _loadLocale();
  }

  LocaleState _loadLocale() {
    final SharedPreferences prefs = ref.watch(sharedPrefsServiceProvider);
    final String? code = prefs.getString(SharedPrefKeys.languageCode);

    // Fallback to English if invalid
    final AppLocale matched = AppLocale.values.firstWhere(
      (AppLocale loc) => loc.languageCode == code,
      orElse: () => AppLocale.en,
    );

    // Sync slang's LocaleSettings with our saved locale
    LocaleSettings.setLocaleSync(matched);

    return LocaleState(locale: matched);
  }

  /// Sets the app's locale to [locale].
  Future<void> setLocale(AppLocale locale) async {
    final SharedPreferences prefs = ref.read(sharedPrefsServiceProvider);
    await prefs.setString(SharedPrefKeys.languageCode, locale.languageCode);
    await LocaleSettings.setLocale(locale);
    state = LocaleState(locale: locale);
  }

  /// Returns the current locale.
  AppLocale get currentLocale => state.locale;

  /// Returns the current Flutter locale.
  Locale get currentFlutterLocale => state.locale.flutterLocale;

  /// Returns all supported locales.
  static List<AppLocale> get supportedLocales => AppLocale.values;
}
