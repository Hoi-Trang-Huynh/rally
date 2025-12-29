import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rally/constants/shared_pref_keys.dart';
import 'package:rally/firebase_options.dart';
import 'package:rally/i18n/generated/translations.g.dart';
import 'package:rally/models/app_user.dart';
import 'package:rally/providers/auth_provider.dart';
import 'package:rally/providers/locale_provider.dart';
import 'package:rally/providers/theme_provider.dart';
import 'package:rally/screens/auth/auth_screen.dart';
import 'package:rally/screens/auth/profile_completion_screen.dart';
import 'package:rally/screens/home/main_shell.dart';
import 'package:rally/screens/loading/app_loading.dart';
import 'package:rally/screens/onboarding/onboarding_screen.dart';
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

  // Initialize locale (await deferred loading)
  final String? languageCode = sharedPrefs.getString(SharedPrefKeys.languageCode);
  final AppLocale locale = AppLocale.values.firstWhere(
    (AppLocale loc) => loc.languageCode == languageCode,
    orElse: () => AppLocale.en,
  );
  await LocaleSettings.setLocale(locale);

  runApp(
    ProviderScope(
      overrides: <Override>[sharedPrefsServiceProvider.overrideWithValue(sharedPrefs)],
      child: TranslationProvider(child: const RallyApp()),
    ),
  );
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
    final ThemeNotifier themeNotifier = ref.read(themeProvider.notifier);
    final LocaleNotifier localeNotifier = ref.read(localeProvider.notifier);

    // Watch the state to rebuild when it changes
    ref.watch(themeProvider);
    ref.watch(localeProvider);

    final AsyncValue<AppUser?> authState = ref.watch(appUserProvider);

    return MaterialApp(
      title: 'Rally',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeNotifier.currentThemeMode,
      locale: localeNotifier.currentFlutterLocale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: authState.when(
        data: (AppUser? user) {
          if (user == null) {
            final SharedPreferences prefs = ref.watch(sharedPrefsServiceProvider);
            final bool onboardingSeen = prefs.getBool(SharedPrefKeys.onboardingSeen) ?? false;

            if (!onboardingSeen) {
              return const OnboardingScreen();
            }
            // Default to Signup for new users, consistent with "Get Started" flow
            return const AuthScreen(initialIsLogin: false);
          }

          // Check if email is verified before showing home
          if (!user.isEmailVerified) {
            // User is logged in but email not verified - stay on signup for verification
            return const AuthScreen(initialIsLogin: false);
          }

          // Check if profile needs completion (Google sign-in users)
          if (user.needsProfileCompletion) {
            return const ProfileCompletionScreen();
          }

          // Fully authenticated and verified - show home
          return const MainShell();
        },
        loading: () => const AppLoadingScreen(),
        error:
            (Object error, StackTrace stack) =>
                Scaffold(body: Center(child: Text('Error: $error'))),
      ),
    );
  }
}
