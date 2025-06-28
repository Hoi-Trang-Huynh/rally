import 'package:flutter/material.dart';
import 'package:rally/l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rally/providers/theme_provider.dart';
import 'package:rally/themes/app_theme.dart';
import 'package:rally/screens/playground/theme_test.dart';

void main() {
  runApp(const ProviderScope(child: RallyApp()));
}

class RallyApp extends ConsumerWidget {
  const RallyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appThemeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return MaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeNotifier.MaterialThemeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const ThemeTestScreen(title: 'Rally Demo'),
    );
  }
}
