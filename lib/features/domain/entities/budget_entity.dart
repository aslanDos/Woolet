import 'package:equatable/equatable.dart';
import 'package:woolet/core/constants/app_enums.dart';

class BudgetPeriodRange extends Equatable {
  const BudgetPeriodRange(this.start, this.end);

  final DateTime start;
  final DateTime end;

  @override
  List<Object?> get props => [start, end];
}

class BudgetEntity extends Equatable {
  static const int maxNameLength = 48;

  const BudgetEntity({
    required this.uuid,
    required this.name,
    required this.amountMinor,
    required this.categoryUuids,
    required this.period,
    required this.startDay,
    required this.iconCode,
    required this.colorValue,
    required this.createdAt,
    this.accountUuid,
  });

  final String uuid;
  final String name;
  final int amountMinor;
  final List<String> categoryUuids;
  final BudgetPeriod period;
  final int startDay;
  final String iconCode;
  final int colorValue;
  final String? accountUuid;
  final DateTime createdAt;

  bool get isValid =>
      uuid.isNotEmpty &&
      name.trim().isNotEmpty &&
      name.trim().length <= maxNameLength &&
      amountMinor > 0 &&
      categoryUuids.isNotEmpty &&
      startDay >= 1 &&
      startDay <= 31;

  BudgetPeriodRange rangeAt(DateTime value) {
    final now = DateTime(value.year, value.month, value.day);
    return switch (period) {
      BudgetPeriod.daily => BudgetPeriodRange(
        now,
        now.add(const Duration(days: 1)),
      ),
      BudgetPeriod.weekly => _weeklyRange(now),
      BudgetPeriod.monthly => _monthlyRange(now),
      BudgetPeriod.yearly => BudgetPeriodRange(
        DateTime(now.year),
        DateTime(now.year + 1),
      ),
    };
  }

  BudgetPeriodRange _weeklyRange(DateTime now) {
    final start = now.subtract(Duration(days: now.weekday - DateTime.monday));
    return BudgetPeriodRange(start, start.add(const Duration(days: 7)));
  }

  BudgetPeriodRange _monthlyRange(DateTime now) {
    DateTime startFor(int year, int month) {
      final lastDay = DateTime(year, month + 1, 0).day;
      return DateTime(year, month, startDay.clamp(1, lastDay));
    }

    var start = startFor(now.year, now.month);
    if (now.isBefore(start)) start = startFor(now.year, now.month - 1);
    final end = startFor(start.year, start.month + 1);
    return BudgetPeriodRange(start, end);
  }

  @override
  List<Object?> get props => [
    uuid,
    name,
    amountMinor,
    categoryUuids,
    period,
    startDay,
    iconCode,
    colorValue,
    accountUuid,
    createdAt,
  ];
}
