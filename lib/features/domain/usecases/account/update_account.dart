import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:woolet/core/errors/failures.dart';
import 'package:woolet/core/usecases/usecase.dart';
import 'package:woolet/features/domain/entities/account_entity.dart';
import 'package:woolet/features/domain/repositories/account_repository.dart';

class UpdateAccount implements UseCase<AccountEntity, UpdateAccountParams> {
  final AccountRepository _repository;

  const UpdateAccount(this._repository);

  @override
  Future<Either<Failure, AccountEntity>> call(UpdateAccountParams params) {
    return _repository.updateAccount(params.account);
  }
}

class UpdateAccountParams extends Equatable {
  final AccountEntity account;

  const UpdateAccountParams({required this.account});

  @override
  List<Object?> get props => [account];
}
