import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rally/constants/shared_pref_keys.dart';
import 'package:rally/l10n/generated/app_localizations.dart';
import 'package:rally/services/shared_prefs_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// State class for the [LocaleNotifier].
class LocaleState {
  /// The current locale.
  final Locale locale;

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

    // Fallback to first supported locale if invalid
    final Locale matched = AppLocalizations.supportedLocales.firstWhere(
      (Locale loc) => loc.languageCode == code,
      orElse: () => const Locale('en'),
    );

    return LocaleState(locale: matched);
  }

  /// Sets the app's locale to [localeCode].
  Future<void> setLocale(Locale localeCode) async {
    final SharedPreferences prefs = ref.read(sharedPrefsServiceProvider);
    await prefs.setString(SharedPrefKeys.languageCode, localeCode.languageCode);
    state = LocaleState(locale: localeCode);
  }

  /// Returns the current locale.
  Locale get currentLocale => state.locale;
}
