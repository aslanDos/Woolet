import 'package:dartz/dartz.dart';
import 'package:woolet/core/errors/failures.dart';
import 'package:woolet/core/utils/logger.dart';
import 'package:woolet/features/data/datasources/transaction_local_data_source.dart';
import 'package:woolet/features/data/models/transaction_model.dart';
import 'package:woolet/features/domain/entities/transaction_entity.dart';
import 'package:woolet/features/domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource _localDataSource;
  const TransactionRepositoryImpl({
    required TransactionLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions() async {
    try {
      final values = await _localDataSource.getTransactions();
      return Right(values.map((value) => value.toEntity()).toList());
    } on Object catch (error) {
      return _failure('get transactions', error);
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> createTransaction(
    TransactionEntity value,
  ) async {
    try {
      final result = await _localDataSource.createTransaction(
        TransactionModel.fromEntity(value),
      );
      return Right(result.toEntity());
    } on Object catch (error) {
      return _failure('create transaction', error);
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> updateTransaction(
    TransactionEntity value,
  ) async {
    try {
      final result = await _localDataSource.updateTransaction(
        TransactionModel.fromEntity(value),
      );
      return result == null
          ? Left(NotFoundFailure('Transaction ${value.uuid} was not found'))
          : Right(result.toEntity());
    } on Object catch (error) {
      return _failure('update transaction', error);
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTransaction(String uuid) async {
    try {
      await _localDataSource.deleteTransaction(uuid);
      return const Right(unit);
    } on Object catch (error) {
      return _failure('delete transaction', error);
    }
  }

  Left<Failure, T> _failure<T>(String operation, Object error) {
    Log.e('Failed to $operation: $error', label: 'transaction_repository');
    return Left(DatabaseFailure('Failed to $operation'));
  }
}
