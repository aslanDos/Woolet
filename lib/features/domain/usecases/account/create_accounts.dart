import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:woolet/core/errors/failures.dart';
import 'package:woolet/core/usecases/usecase.dart';
import 'package:woolet/features/domain/entities/account_entity.dart';
import 'package:woolet/features/domain/repositories/account_repository.dart';

class CreateAccounts implements UseCase<Unit, CreateAccountsParams> {
  final AccountRepository _repository;

  const CreateAccounts(this._repository);

  @override
  Future<Either<Failure, Unit>> call(CreateAccountsParams params) {
    return _repository.createAccounts(params.accounts);
  }
}

class CreateAccountsParams extends Equatable {
  final List<AccountEntity> accounts;

  CreateAccountsParams({required List<AccountEntity> accounts})
    : accounts = List.unmodifiable(accounts);

  @override
  List<Object?> get props => [accounts];
}
