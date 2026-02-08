/// Keys used for storing data in SharedPreferences.
abstract class SharedPrefKeys {
  /// Key for storing the user's selected theme mode.
  static const String themeMode = 'theme_mode';

  /// Key for storing the user's selected language code.
  static const String languageCode = 'language_code';

  /// Key for storing whether the user has seen the onboarding screen.
  static const String onboardingSeen = 'onboarding_seen';

  /// Key for storing the draft Rally creation data as JSON.
  static const String rallyDraft = 'rally_draft_json';
  // Add more keys as needed
}
