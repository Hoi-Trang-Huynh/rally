import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rally/firebase_options.dart';
import 'package:rally/l10n/generated/app_localizations.dart';
import 'package:rally/models/app_user.dart';
import 'package:rally/providers/auth_provider.dart';
import 'package:rally/providers/locale_provider.dart';
import 'package:rally/providers/theme_provider.dart';
import 'package:rally/screens/auth/login_screen.dart';
import 'package:rally/screens/loading/app_loading.dart';
import 'package:rally/screens/playground/auth_test.dart';
// import 'package:rally/screens/playground/theme_test.dart';
import 'package:rally/services/shared_prefs_service.dart';
import 'package:rally/themes/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: <Override>[sharedPrefsServiceProvider.overrideWithValue(sharedPrefs)],
      child: const RallyApp(),
    ),
  );
}

/// The root widget for the Rally app.
///
/// Handles theme and locale state, shows a loading screen while providers initialize,
/// and sets up the main MaterialApp with theming and localization.
class RallyApp extends ConsumerWidget {
  /// Creates a new instance of the RallyApp widget.ub1txeasdsiuytrewq  gfgfdsaBVVFGFC VVDVV   ///
  /// The [key] parameter is used to control how one widget replaces another widget in the tree.
  const RallyApp({super.key});

  /// Builds the Rally app UI, applying theme, locale, and loading state.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeNotifier themeNotifier = ref.read(themeProvider.notifier);
    final LocaleNotifier localeNotifier = ref.read(localeProvider.notifier);

    // Watch the state to rebuild when it changes
    ref.watch(themeProvider);
    ref.watch(localeProvider);

    final AsyncValue<AppUser?> authState = ref.watch(appUserProvider);

    return MaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeNotifier.currentThemeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      locale: localeNotifier.currentLocale,
      supportedLocales: AppLocalizations.supportedLocales,
      home: authState.when(
        data: (AppUser? user) {
          // Not logged in - show login screen
          if (user == null) {
            return const LoginScreen();
          }
          // Fully authenticated - show home
          return const AuthTestScreen();
        },
        loading: () => const AppLoadingScreen(),
        error:
            (Object error, StackTrace stack) =>
                Scaffold(body: Center(child: Text('Error: $error'))),
      ),
    );
  }
}
