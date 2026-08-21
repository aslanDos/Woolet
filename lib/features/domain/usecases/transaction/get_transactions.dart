import 'package:dartz/dartz.dart';
import 'package:woolet/core/errors/failures.dart';
import 'package:woolet/core/usecases/usecase.dart';
import 'package:woolet/features/domain/entities/transaction_entity.dart';
import 'package:woolet/features/domain/repositories/transaction_repository.dart';

class GetTransactions implements UseCase<List<TransactionEntity>, NoParams> {
  final TransactionRepository repository;
  const GetTransactions(this.repository);
  @override
  Future<Either<Failure, List<TransactionEntity>>> call(NoParams params) =>
      repository.getTransactions();
}
