import 'package:dartz/dartz.dart';
import 'package:woolet/core/errors/failures.dart';
import 'package:woolet/core/utils/logger.dart';
import 'package:woolet/features/data/datasources/account_local_data_source.dart';
import 'package:woolet/features/data/models/account_model.dart';
import 'package:woolet/features/domain/entities/account_entity.dart';
import 'package:woolet/features/domain/repositories/account_repository.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountLocalDataSource _localDataSource;

  const AccountRepositoryImpl({required AccountLocalDataSource localDataSource})
    : _localDataSource = localDataSource;

  @override
  Future<Either<Failure, List<AccountEntity>>> getAccounts() async {
    try {
      final models = await _localDataSource.getAccounts();
      return Right(models.map((model) => model.toEntity()).toList());
    } on Object catch (error) {
      return _databaseFailure('get accounts', error);
    }
  }

  @override
  Future<Either<Failure, AccountEntity>> getAccountById(String uuid) async {
    try {
      final model = await _localDataSource.getAccountById(uuid);
      if (model == null) {
        return Left(NotFoundFailure('Account $uuid was not found'));
      }

      return Right(model.toEntity());
    } on Object catch (error) {
      return _databaseFailure('get account $uuid', error);
    }
  }

  @override
  Future<Either<Failure, AccountEntity>> createAccount(
    AccountEntity account,
  ) async {
    try {
      final model = await _localDataSource.createAccount(
        AccountModel.fromEntity(account),
      );
      return Right(model.toEntity());
    } on Object catch (error) {
      return _databaseFailure('create account ${account.uuid}', error);
    }
  }

  @override
  Future<Either<Failure, Unit>> createAccounts(
    List<AccountEntity> accounts,
  ) async {
    try {
      await _localDataSource.createAccounts(
        accounts.map(AccountModel.fromEntity).toList(growable: false),
      );
      return const Right(unit);
    } on Object catch (error) {
      return _databaseFailure('create accounts', error);
    }
  }

  @override
  Future<Either<Failure, AccountEntity>> updateAccount(
    AccountEntity account,
  ) async {
    try {
      final model = await _localDataSource.updateAccount(
        AccountModel.fromEntity(account),
      );
      if (model == null) {
        return Left(NotFoundFailure('Account ${account.uuid} was not found'));
      }

      return Right(model.toEntity());
    } on Object catch (error) {
      return _databaseFailure('update account ${account.uuid}', error);
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAccount(String uuid) async {
    try {
      await _localDataSource.deleteAccount(uuid);
      return const Right(unit);
    } on Object catch (error) {
      return _databaseFailure('delete account $uuid', error);
    }
  }

  Left<Failure, T> _databaseFailure<T>(String operation, Object error) {
    Log.e('Failed to $operation: $error', label: 'account_repository');
    return Left(DatabaseFailure('Failed to $operation'));
  }
}
