import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends ValueNotifier<Locale?> {
  LocaleController(this._preferences) : super(_readLocale(_preferences));

  static const _preferenceKey = 'locale';
  final SharedPreferences _preferences;

  static Locale? _readLocale(SharedPreferences preferences) {
    final languageCode = preferences.getString(_preferenceKey);
    return languageCode == null ? null : Locale(languageCode);
  }

  Future<void> setLocale(Locale locale) async {
    if (value == locale) return;
    value = locale;
    await _preferences.setString(_preferenceKey, locale.languageCode);
  }
}
