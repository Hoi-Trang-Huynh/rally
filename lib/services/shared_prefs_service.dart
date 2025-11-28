import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider that holds the instance of [SharedPreferences].
///
/// This provider must be overridden in the [ProviderScope] at the root of the app.
/// It is intended to be initialized before `runApp` is called.
final Provider<SharedPreferences> sharedPrefsServiceProvider = Provider<SharedPreferences>((
  Ref ref,
) {
  throw UnimplementedError('sharedPrefsServiceProvider must be overridden in main.dart');
});
