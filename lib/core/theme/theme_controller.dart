import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController(this._preferences) : super(_readThemeMode(_preferences));

  static const _preferenceKey = 'theme_mode';

  final SharedPreferences _preferences;

  Future<void> setThemeMode(ThemeMode mode) async {
    if (value == mode) return;
    value = mode;
    await _preferences.setString(_preferenceKey, mode.name);
  }

  static ThemeMode _readThemeMode(SharedPreferences preferences) {
    final savedValue = preferences.getString(_preferenceKey);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == savedValue,
      orElse: () => ThemeMode.system,
    );
  }
}
