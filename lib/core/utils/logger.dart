import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

abstract final class Log {
  static void d(Object? message, {String label = 'log'}) {
    _console(message, level: 'debug', label: label);
  }

  static void i(Object? message, {String label = 'log'}) {
    _console(message, level: 'info', label: label);
  }

  static void e(Object? message, {String label = 'log'}) {
    _console(message, level: 'error', label: label);
  }

  static void _console(
    Object? message, {
    required String level,
    required String label,
  }) {
    if (!kDebugMode) return;

    final normalizedLabel = label.trim().toLowerCase().replaceAll(' ', '_');

    developer.log(message.toString(), name: '${level}_$normalizedLabel');
  }
}
