import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:woolet/core/errors/failures.dart';
import 'package:woolet/core/usecases/usecase.dart';
import 'package:woolet/features/domain/repositories/transaction_repository.dart';

class DeleteTransaction implements UseCase<Unit, DeleteTransactionParams> {
  final TransactionRepository repository;
  const DeleteTransaction(this.repository);
  @override
  Future<Either<Failure, Unit>> call(DeleteTransactionParams params) =>
      repository.deleteTransaction(params.uuid);
}

class DeleteTransactionParams extends Equatable {
  final String uuid;
  const DeleteTransactionParams(this.uuid);
  @override
  List<Object?> get props => [uuid];
}
