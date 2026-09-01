import 'package:equatable/equatable.dart';

class AnalyticsPoint extends Equatable {
  const AnalyticsPoint({required this.date, required this.amountMinor});

  final DateTime date;
  final int amountMinor;

  @override
  List<Object?> get props => [date, amountMinor];
}

class AnalyticsCategoryTotal extends Equatable {
  const AnalyticsCategoryTotal({
    required this.categoryUuid,
    required this.amountMinor,
  });

  final String? categoryUuid;
  final int amountMinor;

  @override
  List<Object?> get props => [categoryUuid, amountMinor];
}

class AnalyticsEntity extends Equatable {
  const AnalyticsEntity({
    required this.incomeMinor,
    required this.expenseMinor,
    required this.biggestDayMinor,
    required this.dailyAverageMinor,
    required this.incomeTrend,
    required this.spendingTrend,
    required this.incomeCategoryTotals,
    required this.categoryTotals,
  });

  const AnalyticsEntity.empty()
    : incomeMinor = 0,
      expenseMinor = 0,
      biggestDayMinor = 0,
      dailyAverageMinor = 0,
      incomeTrend = const [],
      spendingTrend = const [],
      incomeCategoryTotals = const [],
      categoryTotals = const [];

  final int incomeMinor;
  final int expenseMinor;
  final int biggestDayMinor;
  final int dailyAverageMinor;
  final List<AnalyticsPoint> incomeTrend;
  final List<AnalyticsPoint> spendingTrend;
  final List<AnalyticsCategoryTotal> incomeCategoryTotals;
  final List<AnalyticsCategoryTotal> categoryTotals;

  int get netCashFlowMinor => incomeMinor - expenseMinor;

  @override
  List<Object?> get props => [
    incomeMinor,
    expenseMinor,
    biggestDayMinor,
    dailyAverageMinor,
    incomeTrend,
    spendingTrend,
    incomeCategoryTotals,
    categoryTotals,
  ];
}

class AnalyticsQuery extends Equatable {
  const AnalyticsQuery({this.start, this.endExclusive, this.accountUuid});

  final DateTime? start;
  final DateTime? endExclusive;
  final String? accountUuid;

  @override
  List<Object?> get props => [start, endExclusive, accountUuid];
}
