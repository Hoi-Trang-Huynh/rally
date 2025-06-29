import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rally/constants/shared_pref_keys.dart';

enum AppThemeMode { light, dark, system }

class ThemeState {
  final AppThemeMode mode;
  final bool isLoading;

  ThemeState({required this.mode, required this.isLoading});
}

final StateNotifierProvider<ThemeNotifier, ThemeState> themeProvider =
    StateNotifierProvider<ThemeNotifier, ThemeState>((Ref ref) {
      return ThemeNotifier(ref);
    });

class ThemeNotifier extends StateNotifier<ThemeState> {
  final Ref ref;

  ThemeNotifier(this.ref)
    : super(ThemeState(mode: AppThemeMode.system, isLoading: true)) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? index = prefs.getInt(SharedPrefKeys.themeMode);
    final AppThemeMode mode =
        (index != null && index >= 0 && index < AppThemeMode.values.length)
            ? AppThemeMode.values[index]
            : AppThemeMode.system;
    state = ThemeState(mode: mode, isLoading: false);
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(SharedPrefKeys.themeMode, mode.index);
    state = ThemeState(mode: mode, isLoading: false);
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
