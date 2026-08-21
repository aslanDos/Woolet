import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:woolet/core/errors/failures.dart';
import 'package:woolet/core/usecases/usecase.dart';
import 'package:woolet/features/domain/entities/transaction_entity.dart';
import 'package:woolet/features/domain/repositories/transaction_repository.dart';

class UpdateTransaction
    implements UseCase<TransactionEntity, UpdateTransactionParams> {
  final TransactionRepository repository;
  const UpdateTransaction(this.repository);
  @override
  Future<Either<Failure, TransactionEntity>> call(
    UpdateTransactionParams params,
  ) => repository.updateTransaction(params.transaction);
}

class UpdateTransactionParams extends Equatable {
  final TransactionEntity transaction;
  const UpdateTransactionParams(this.transaction);
  @override
  List<Object?> get props => [transaction];
}
