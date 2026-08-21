import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:woolet/core/errors/failures.dart';
import 'package:woolet/core/usecases/usecase.dart';
import 'package:woolet/features/domain/entities/transaction_entity.dart';
import 'package:woolet/features/domain/repositories/transaction_repository.dart';

class CreateTransaction
    implements UseCase<TransactionEntity, CreateTransactionParams> {
  final TransactionRepository repository;
  const CreateTransaction(this.repository);
  @override
  Future<Either<Failure, TransactionEntity>> call(
    CreateTransactionParams params,
  ) => repository.createTransaction(params.transaction);
}

class CreateTransactionParams extends Equatable {
  final TransactionEntity transaction;
  const CreateTransactionParams(this.transaction);
  @override
  List<Object?> get props => [transaction];
}
