import 'package:dartz/dartz.dart';
import 'package:woolet/core/errors/failures.dart';
import 'package:woolet/core/utils/logger.dart';
import 'package:woolet/features/data/datasources/budget_local_data_source.dart';
import 'package:woolet/features/data/models/budget_model.dart';
import 'package:woolet/features/domain/entities/budget_entity.dart';
import 'package:woolet/features/domain/repositories/budget_repository.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  const BudgetRepositoryImpl({required BudgetLocalDataSource localDataSource})
    : _localDataSource = localDataSource;
  final BudgetLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, List<BudgetEntity>>> getBudgets() async {
    try {
      final values = await _localDataSource.getBudgets();
      return Right(values.map((value) => value.toEntity()).toList());
    } on Object catch (error) {
      return _failure('get budgets', error);
    }
  }

  @override
  Future<Either<Failure, BudgetEntity>> createBudget(BudgetEntity value) async {
    try {
      return Right(
        (await _localDataSource.createBudget(BudgetModel(value))).toEntity(),
      );
    } on Object catch (error) {
      return _failure('create budget', error);
    }
  }

  @override
  Future<Either<Failure, BudgetEntity>> updateBudget(BudgetEntity value) async {
    try {
      final result = await _localDataSource.updateBudget(BudgetModel(value));
      return result == null
          ? Left(NotFoundFailure('Budget ${value.uuid} was not found'))
          : Right(result.toEntity());
    } on Object catch (error) {
      return _failure('update budget', error);
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteBudget(String uuid) async {
    try {
      await _localDataSource.deleteBudget(uuid);
      return const Right(unit);
    } on Object catch (error) {
      return _failure('delete budget', error);
    }
  }

  Left<Failure, T> _failure<T>(String operation, Object error) {
    Log.e('Failed to $operation: $error', label: 'budget_repository');
    return Left(DatabaseFailure('Failed to $operation'));
  }
}
