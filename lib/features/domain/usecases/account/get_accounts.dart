import 'package:dartz/dartz.dart';
import 'package:woolet/core/errors/failures.dart';
import 'package:woolet/core/usecases/usecase.dart';
import 'package:woolet/features/domain/entities/account_entity.dart';
import 'package:woolet/features/domain/repositories/account_repository.dart';

class GetAccounts implements UseCase<List<AccountEntity>, NoParams> {
  final AccountRepository _repository;

  const GetAccounts(this._repository);

  @override
  Future<Either<Failure, List<AccountEntity>>> call(NoParams params) {
    return _repository.getAccounts();
  }
}
