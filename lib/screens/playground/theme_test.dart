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
    final themeNotifier = ref.read(themeProvider.notifier);
    final currentTheme = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.hello,
          style: AppTextStyles.headlineLarge(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              final next =
                  currentTheme == AppThemeMode.light
                      ? AppThemeMode.dark
                      : AppThemeMode.light;
              themeNotifier.setThemeMode(next);
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Current Theme: $currentTheme',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
