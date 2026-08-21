import 'package:flutter/foundation.dart';

@immutable
class CurrencyInfo {
  const CurrencyInfo({
    required this.code,
    required this.name,
    required this.symbol,
    required this.decimalDigits,
  });

  factory CurrencyInfo.fromJson(Map<String, Object?> json) {
    return CurrencyInfo(
      code: json['code']! as String,
      name: json['name']! as String,
      symbol: json['symbol']! as String,
      decimalDigits: json['decimal_digits']! as int,
    );
  }

  final String code;
  final String name;
  final String symbol;
  final int decimalDigits;
}
