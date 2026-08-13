import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:woolet/core/errors/failures.dart';
import 'package:woolet/core/usecases/usecase.dart';
import 'package:woolet/features/domain/entities/account_entity.dart';
import 'package:woolet/features/domain/repositories/account_repository.dart';

class CreateAccount implements UseCase<AccountEntity, CreateAccountParams> {
  final AccountRepository _repository;

  const CreateAccount(this._repository);

  @override
  Future<Either<Failure, AccountEntity>> call(CreateAccountParams params) {
    return _repository.createAccount(params.account);
  }
}

class CreateAccountParams extends Equatable {
  final AccountEntity account;

  const CreateAccountParams({required this.account});

  @override
  List<Object?> get props => [account];
}
