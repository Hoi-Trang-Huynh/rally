import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rally/l10n/generated/app_localizations.dart';
import 'package:rally/providers/locale_provider.dart';
import 'package:rally/utils/locale_utils.dart';

class LocaleTestScreen extends ConsumerWidget {
  final String title;

  const LocaleTestScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LocaleState localeState = ref.watch(localeProvider);
    final LocaleNotifier localeNotifier = ref.read(localeProvider.notifier);

    final List<Locale> supported = AppLocalizations.supportedLocales;
    final Locale current = localeState.locale;

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.hello)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Current Locale: ${current.languageCode}'),
            const SizedBox(height: 16),
            DropdownButton<Locale>(
              value: current,
              onChanged: (Locale? selected) {
                if (selected != null) {
                  localeNotifier.setLocale(selected);
                }
              },
              items:
                  supported.map((Locale locale) {
                    return DropdownMenuItem<Locale>(
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
