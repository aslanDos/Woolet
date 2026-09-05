import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:woolet/core/constants/app_enums.dart';

abstract final class AppDateUtils {
  static const _kazakhShortWeekdays = [
    'дүй',
    'сей',
    'сәр',
    'бей',
    'жұм',
    'сен',
    'жек',
  ];

  static String weekdayName(DateTime value, Locale locale) {
    if (locale.languageCode == 'kk') {
      return _kazakhShortWeekdays[value.weekday - 1];
    }
    return DateFormat.EEEE(locale.toLanguageTag()).format(value);
  }

  static DateTime shiftBudgetPeriod(
    DateTime value,
    BudgetPeriod period,
    int offset,
  ) {
    return switch (period) {
      BudgetPeriod.daily => value.add(Duration(days: offset)),
      BudgetPeriod.weekly => value.add(Duration(days: offset * 7)),
      BudgetPeriod.monthly => DateTime(value.year, value.month + offset, 1),
      BudgetPeriod.yearly => DateTime(value.year + offset, value.month, 1),
    };
  }

  static String formatNumeric(DateTime value, {DateTime? relativeTo}) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final reference = relativeTo ?? DateTime.now();
    return value.year == reference.year
        ? '$day.$month'
        : '$day.$month.${value.year}';
  }

  static String formatRange(
    DateTime start,
    DateTime endExclusive, {
    DateTime? relativeTo,
  }) {
    final end = endExclusive.subtract(const Duration(days: 1));
    final startLabel = formatNumeric(start, relativeTo: relativeTo);
    if (_isSameDay(start, end)) return startLabel;
    return '$startLabel — ${formatNumeric(end, relativeTo: relativeTo)}';
  }

  static bool _isSameDay(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}
