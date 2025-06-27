// providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { light, dark, system }

class ThemeState {
  final AppThemeMode mode;
  final bool isLoading;

  ThemeState({required this.mode, required this.isLoading});
}

const _themePrefKey = 'app_theme_mode';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier(ref);
});

class ThemeNotifier extends StateNotifier<ThemeState> {
  final Ref ref;

  ThemeNotifier(this.ref)
    : super(ThemeState(mode: AppThemeMode.system, isLoading: true)) {
    _loadTheme(); // Load on init
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_themePrefKey);
    final mode =
        (index != null && index >= 0 && index < AppThemeMode.values.length)
            ? AppThemeMode.values[index]
            : AppThemeMode.system;
    state = ThemeState(mode: mode, isLoading: false);
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themePrefKey, mode.index);
    state = ThemeState(mode: mode, isLoading: false);
  }

  ThemeMode get MaterialThemeMode {
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
