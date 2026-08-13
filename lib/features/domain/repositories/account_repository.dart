import 'package:dartz/dartz.dart';
import 'package:woolet/core/errors/failures.dart';
import 'package:woolet/features/domain/entities/account_entity.dart';

abstract interface class AccountRepository {
  Future<Either<Failure, List<AccountEntity>>> getAccounts();

  Future<Either<Failure, AccountEntity>> getAccountById(String uuid);

  Future<Either<Failure, AccountEntity>> createAccount(AccountEntity account);

  Future<Either<Failure, Unit>> createAccounts(List<AccountEntity> accounts);

  Future<Either<Failure, AccountEntity>> updateAccount(AccountEntity account);

  Future<Either<Failure, Unit>> deleteAccount(String uuid);
}
