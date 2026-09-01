import 'dart:math' as math;

import 'package:dartz/dartz.dart';
import 'package:woolet/core/constants/app_enums.dart';
import 'package:woolet/core/errors/failures.dart';
import 'package:woolet/core/utils/logger.dart';
import 'package:woolet/features/data/datasources/transaction_local_data_source.dart';
import 'package:woolet/features/domain/entities/analytics_entity.dart';
import 'package:woolet/features/domain/repositories/analytics_repository.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  const AnalyticsRepositoryImpl({required this.localDataSource});

  final TransactionLocalDataSource localDataSource;

  @override
  Future<Either<Failure, AnalyticsEntity>> getAnalytics(
    AnalyticsQuery query,
  ) async {
    try {
      final transactions = (await localDataSource.getTransactions())
          .map((value) => value.toEntity())
          .where(
            (value) =>
                (query.accountUuid == null ||
                    value.accountUuid == query.accountUuid) &&
                (query.start == null ||
                    !value.occurredAt.isBefore(query.start!)) &&
                (query.endExclusive == null ||
                    value.occurredAt.isBefore(query.endExclusive!)),
          );
      var income = 0;
      var expense = 0;
      final incomeDaily = <DateTime, int>{};
      final daily = <DateTime, int>{};
      final categories = <String?, int>{};

      for (final transaction in transactions) {
        if (transaction.type == TransactionType.income) {
          income += transaction.amountMinor;
          final date = DateTime(
            transaction.occurredAt.year,
            transaction.occurredAt.month,
            transaction.occurredAt.day,
          );
          incomeDaily.update(
            date,
            (value) => value + transaction.amountMinor,
            ifAbsent: () => transaction.amountMinor,
          );
          continue;
        }
        if (transaction.type != TransactionType.expense) continue;
        expense += transaction.amountMinor;
        final date = DateTime(
          transaction.occurredAt.year,
          transaction.occurredAt.month,
          transaction.occurredAt.day,
        );
        daily.update(
          date,
          (value) => value + transaction.amountMinor,
          ifAbsent: () => transaction.amountMinor,
        );
        categories.update(
          transaction.categoryUuid,
          (value) => value + transaction.amountMinor,
          ifAbsent: () => transaction.amountMinor,
        );
      }

      final trend =
          daily.entries
              .map(
                (entry) =>
                    AnalyticsPoint(date: entry.key, amountMinor: entry.value),
              )
              .toList()
            ..sort((first, second) => first.date.compareTo(second.date));
      final incomeTrend =
          incomeDaily.entries
              .map(
                (entry) =>
                    AnalyticsPoint(date: entry.key, amountMinor: entry.value),
              )
              .toList()
            ..sort((first, second) => first.date.compareTo(second.date));
      final categoryTotals =
          categories.entries
              .map(
                (entry) => AnalyticsCategoryTotal(
                  categoryUuid: entry.key,
                  amountMinor: entry.value,
                ),
              )
              .toList()
            ..sort(
              (first, second) =>
                  second.amountMinor.compareTo(first.amountMinor),
            );
      final biggestDay = daily.values.fold<int>(0, math.max);

      return Right(
        AnalyticsEntity(
          incomeMinor: income,
          expenseMinor: expense,
          biggestDayMinor: biggestDay,
          dailyAverageMinor: daily.isEmpty ? 0 : expense ~/ daily.length,
          incomeTrend: List.unmodifiable(incomeTrend),
          spendingTrend: List.unmodifiable(trend),
          categoryTotals: List.unmodifiable(categoryTotals),
        ),
      );
    } on Object catch (error) {
      Log.e('Failed to get analytics: $error', label: 'analytics_repository');
      return const Left(DatabaseFailure('Failed to get analytics'));
    }
  }
}
