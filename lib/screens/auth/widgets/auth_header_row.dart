import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rally/providers/theme_provider.dart';
import 'package:rally/screens/auth/widgets/language_selector.dart';
import 'package:rally/screens/onboarding/onboarding_screen.dart';

/// A reusable header row widget for auth screens.
///
/// Contains a language picker on the left and a theme toggle on the right.
class AuthHeaderRow extends ConsumerWidget {
  /// Creates a new [AuthHeaderRow].
  const AuthHeaderRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Locale state - now handled by LanguageSelector
    // Theme state
    final ThemeState themeState = ref.watch(themeProvider);
    final ThemeNotifier themeNotifier = ref.read(themeProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // Language selector (top-left) - new pill design
          const LanguageSelector(),
          // Theme toggle (top-right)
          // Theme toggle (top-right)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.info_outline, color: Theme.of(context).colorScheme.onSurface),
                tooltip: 'App Intro',
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(builder: (_) => const OnboardingScreen()),
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  themeState.mode == AppThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
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
        ],
      ),
    );
  }
}
