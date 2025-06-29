import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rally/l10n/generated/app_localizations.dart';
import 'package:rally/providers/theme_provider.dart';
import 'package:rally/themes/app_text_styles.dart';

class ThemeTestScreen extends ConsumerWidget {
  const ThemeTestScreen({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeState themeState = ref.watch(themeProvider);
    final ThemeNotifier themeNotifier = ref.read(themeProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.hello,
          style: AppTextStyles.headlineLarge(context),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              final AppThemeMode next =
                  themeState.mode == AppThemeMode.light
                      ? AppThemeMode.dark
                      : AppThemeMode.light;
              themeNotifier.setThemeMode(next);
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Current Theme: ${themeState.mode}',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
