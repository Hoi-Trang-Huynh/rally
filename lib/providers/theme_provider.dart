import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rally/constants/shared_pref_keys.dart';
import 'package:rally/services/shared_prefs_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { light, dark, system }

class ThemeState {
  final AppThemeMode mode;

  const ThemeState({required this.mode});
}

final NotifierProvider<ThemeNotifier, ThemeState> themeProvider =
    NotifierProvider<ThemeNotifier, ThemeState>(ThemeNotifier.new);

class ThemeNotifier extends Notifier<ThemeState> {
  @override
  ThemeState build() {
    return _loadTheme();
  }

  ThemeState _loadTheme() {
    final SharedPreferences prefs = ref.watch(sharedPrefsServiceProvider);
    final int? index = prefs.getInt(SharedPrefKeys.themeMode);
    final AppThemeMode mode =
        (index != null && index >= 0 && index < AppThemeMode.values.length)
            ? AppThemeMode.values[index]
            : AppThemeMode.system;
    return ThemeState(mode: mode);
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    final SharedPreferences prefs = ref.read(sharedPrefsServiceProvider);
    await prefs.setInt(SharedPrefKeys.themeMode, mode.index);
    state = ThemeState(mode: mode);
  }

  ThemeMode get currentThemeMode {
    switch (state.mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}
