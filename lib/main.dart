import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rally/l10n/generated/app_localizations.dart';
import 'package:rally/providers/theme_provider.dart';
import 'package:rally/providers/locale_provider.dart';
import 'package:rally/themes/app_theme.dart';
import 'package:rally/screens/loading/app_loading.dart';
import 'package:rally/screens/playground/theme_test.dart';
import 'package:rally/firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';

/// Entry point for the Rally app.
///
/// Initializes Flutter bindings, disables Google Fonts runtime fetching,
/// loads environment variables, initializes Firebase, and runs the app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  try {
    await dotenv.load();
  } catch (e) {
    debugPrint('Warning: .env file not found or failed to load: $e');
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: RallyApp()));
}

/// The root widget for the Rally app.
///
/// Handles theme and locale state, shows a loading screen while providers initialize,
/// and sets up the main MaterialApp with theming and localization.
class RallyApp extends ConsumerWidget {
  /// Creates a new instance of the RallyApp widget.
  ///
  /// The [key] parameter is used to control how one widget replaces another widget in the tree.
  const RallyApp({super.key});

  /// Builds the Rally app UI, applying theme, locale, and loading state.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeState themeState = ref.watch(themeProvider);
    final ThemeNotifier themeNotifier = ref.read(themeProvider.notifier);

    final LocaleState localeState = ref.watch(localeProvider);
    final LocaleNotifier localeNotifier = ref.read(localeProvider.notifier);

    final bool isLoading =
        themeState.isLoading ||
        localeState
            .isLoading; // Add more loading flag from other providers in the future

    // Return the app startup screen while loading all providers
    if (isLoading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AppLoadingScreen(),
      );
    }

    return MaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeNotifier.currentThemeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      locale: localeNotifier.currentLocale,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const ThemeTestScreen(title: 'Rally'),
    );
  }
}
