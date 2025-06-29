import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rally/constants/shared_pref_keys.dart';
import 'package:rally/l10n/generated/app_localizations.dart';

class LocaleState {
  final Locale locale;
  final bool isLoading;

  LocaleState({required this.locale, required this.isLoading});
}

final StateNotifierProvider<LocaleNotifier, LocaleState> localeProvider =
    StateNotifierProvider<LocaleNotifier, LocaleState>((Ref ref) {
      return LocaleNotifier(ref);
    });

class LocaleNotifier extends StateNotifier<LocaleState> {
  final Ref ref;

  LocaleNotifier(this.ref)
    : super(LocaleState(locale: const Locale('en'), isLoading: true)) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? code = prefs.getString(SharedPrefKeys.languageCode);

    // Fallback to first supported locale if invalid
    final Locale matched = AppLocalizations.supportedLocales.firstWhere(
      (Locale loc) => loc.languageCode == code,
      orElse: () => const Locale('en'),
    );

    state = LocaleState(locale: matched, isLoading: false);
  }

  Future<void> setLocale(Locale localeCode) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(SharedPrefKeys.languageCode, localeCode.languageCode);
    state = LocaleState(locale: localeCode, isLoading: false);
  }

  Locale get currentLocale => state.locale;
}
