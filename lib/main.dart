import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rally/constants/shared_pref_keys.dart';
import 'package:rally/firebase_options.dart';
import 'package:rally/i18n/generated/translations.g.dart';
import 'package:rally/providers/locale_provider.dart';
import 'package:rally/providers/theme_provider.dart';
import 'package:rally/router/app_router.dart';
import 'package:rally/services/shared_prefs_service.dart';
import 'package:rally/themes/app_colors.dart';
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

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    debugPrint('Failed to initialize Firebase: $e');
    // If running on an unsupported platform (e.g. Windows without config),
    // the app might crash later when accessing Firebase services.
  }

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

    // Get the router
    final GoRouter router = ref.watch(goRouterProvider);

    // Determine system UI colors based on current theme
    final bool isDark =
        themeNotifier.currentThemeMode == ThemeMode.dark ||
        (themeNotifier.currentThemeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    final SystemUiOverlayStyle systemUiStyle = SystemUiOverlayStyle(
      // Status bar
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,

      // Navigation bar (Android bottom bar)
      systemNavigationBarColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemUiStyle,
      child: MaterialApp.router(
        title: 'Rally',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeNotifier.currentThemeMode,
        locale: localeNotifier.currentFlutterLocale,
        supportedLocales: AppLocaleUtils.supportedLocales,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        routerConfig: router,
      ),
    );
  }
}
