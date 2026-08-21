import 'package:dartz/dartz.dart';
import 'package:woolet/core/errors/failures.dart';
import 'package:woolet/features/domain/entities/transaction_entity.dart';

abstract interface class TransactionRepository {
  Future<Either<Failure, List<TransactionEntity>>> getTransactions();
  Future<Either<Failure, TransactionEntity>> createTransaction(
    TransactionEntity value,
  );
  Future<Either<Failure, TransactionEntity>> updateTransaction(
    TransactionEntity value,
  );
  Future<Either<Failure, Unit>> deleteTransaction(String uuid);
}
