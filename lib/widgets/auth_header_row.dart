import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rally/i18n/generated/translations.g.dart';
import 'package:rally/providers/locale_provider.dart';
import 'package:rally/providers/theme_provider.dart';

/// A reusable header row widget for auth screens.
///
/// Contains a language picker on the left and a theme toggle on the right.
class AuthHeaderRow extends ConsumerWidget {
  /// Creates a new [AuthHeaderRow].
  const AuthHeaderRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Locale state
    final LocaleState localeState = ref.watch(localeProvider);
    final LocaleNotifier localeNotifier = ref.read(localeProvider.notifier);
    final List<AppLocale> supportedLocales = LocaleNotifier.supportedLocales;

    // Theme state
    final ThemeState themeState = ref.watch(themeProvider);
    final ThemeNotifier themeNotifier = ref.read(themeProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // Language picker (top-left) - static icon + dropdown with short codes
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.language, size: 20),
              const SizedBox(width: 4),
              DropdownButtonHideUnderline(
                child: DropdownButton<AppLocale>(
                  value: localeState.locale,
                  onChanged: (AppLocale? selected) {
                    if (selected != null) {
                      localeNotifier.setLocale(selected);
                    }
                  },
                  items:
                      supportedLocales.map((AppLocale locale) {
                        return DropdownMenuItem<AppLocale>(
                          value: locale,
                          child: Text(locale.languageCode.toUpperCase()),
                        );
                      }).toList(),
                ),
              ),
            ],
          ),
          // Theme toggle (top-right)
          IconButton(
            icon: Icon(themeState.mode == AppThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              final AppThemeMode next =
                  themeState.mode == AppThemeMode.light ? AppThemeMode.dark : AppThemeMode.light;
              themeNotifier.setThemeMode(next);
            },
          ),
        ],
      ),
    );
  }
}
