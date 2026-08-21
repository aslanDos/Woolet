import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:woolet/core/models/currency_info.dart';

class CurrencyController extends ValueNotifier<CurrencyInfo> {
  CurrencyController._({
    required SharedPreferences preferences,
    required this.currencies,
    required CurrencyInfo initialCurrency,
  }) : _preferences = preferences,
       super(initialCurrency);

  static const _assetPath = 'assets/data/currencies.json';
  static const _preferenceKey = 'currency_code';
  static const _defaultCode = 'KZT';

  final SharedPreferences _preferences;
  final List<CurrencyInfo> currencies;

  static Future<CurrencyController> create(
    SharedPreferences preferences,
  ) async {
    final jsonString = await rootBundle.loadString(_assetPath);
    final json = jsonDecode(jsonString) as Map<String, Object?>;
    final values = (json['currencies']! as List<Object?>)
        .cast<Map<String, Object?>>()
        .map(CurrencyInfo.fromJson)
        .toList(growable: false);
    final savedCode = preferences.getString(_preferenceKey) ?? _defaultCode;
    final initialCurrency = _findByCode(values, savedCode);

    return CurrencyController._(
      preferences: preferences,
      currencies: List.unmodifiable(values),
      initialCurrency: initialCurrency,
    );
  }

  Future<void> setCurrency(CurrencyInfo currency) async {
    if (value.code == currency.code) return;
    value = currency;
    await _preferences.setString(_preferenceKey, currency.code);
  }

  CurrencyInfo? findByCode(String code) {
    for (final currency in currencies) {
      if (currency.code == code) return currency;
    }
    return null;
  }

  String symbolForCode(String code) => findByCode(code)?.symbol ?? code;

  static CurrencyInfo _findByCode(List<CurrencyInfo> currencies, String code) {
    for (final currency in currencies) {
      if (currency.code == code) return currency;
    }
    return currencies.first;
  }
}
