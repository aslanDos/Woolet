import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:woolet/core/errors/failures.dart';
import 'package:woolet/core/usecases/usecase.dart';
import 'package:woolet/features/domain/entities/account_entity.dart';
import 'package:woolet/features/domain/repositories/account_repository.dart';

class GetAccountById implements UseCase<AccountEntity, GetAccountByIdParams> {
  final AccountRepository _repository;

  const GetAccountById(this._repository);

  @override
  Future<Either<Failure, AccountEntity>> call(GetAccountByIdParams params) {
    return _repository.getAccountById(params.uuid);
  }
}

class GetAccountByIdParams extends Equatable {
  final String uuid;

  const GetAccountByIdParams({required this.uuid});

  @override
  List<Object?> get props => [uuid];
}
