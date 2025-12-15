import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rally/i18n/generated/translations.g.dart';
import 'package:rally/providers/locale_provider.dart';
import 'package:rally/utils/locale_utils.dart';

/// A playground screen for testing locale switching.
class LocaleTestScreen extends ConsumerWidget {
  /// The title of the screen.
  final String title;

  /// Creates a new [LocaleTestScreen] with the given [title].
  const LocaleTestScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LocaleState localeState = ref.watch(localeProvider);
    final LocaleNotifier localeNotifier = ref.read(localeProvider.notifier);

    final List<AppLocale> supported = LocaleNotifier.supportedLocales;
    final AppLocale current = localeState.locale;

    return Scaffold(
      appBar: AppBar(title: Text(t.common.hello)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Current Locale: ${current.languageCode}'),
            const SizedBox(height: 16),
            DropdownButton<AppLocale>(
              value: current,
              onChanged: (AppLocale? selected) {
                if (selected != null) {
                  localeNotifier.setLocale(selected);
                }
              },
              items:
                  supported.map((AppLocale locale) {
                    return DropdownMenuItem<AppLocale>(
                      value: locale,
                      child: Text(getLocalizedLanguageName(context, locale)),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
