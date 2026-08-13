import 'package:dartz/dartz.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:woolet/core/database/app_database.dart';
import 'package:woolet/core/errors/failures.dart';
import 'package:woolet/core/usecases/usecase.dart';
import 'package:woolet/features/data/datasources/account_local_data_source_impl.dart';
import 'package:woolet/features/data/repositories/account_repository_impl.dart';
import 'package:woolet/features/domain/constants/default_accounts.dart';
import 'package:woolet/features/domain/entities/account_entity.dart';
import 'package:woolet/features/domain/usecases/account/seed_default_accounts.dart';

void main() {
  late AppDatabase database;
  late AccountRepositoryImpl repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = AccountRepositoryImpl(
      localDataSource: AccountLocalDataSourceImpl(database: database),
    );
  });

  tearDown(() => database.close());

  test('creates, reads, updates and deletes an account', () async {
    final account = _account(uuid: 'account-1', name: 'Kaspi');

    expect(
      await repository.createAccount(account),
      Right<Failure, AccountEntity>(account),
    );
    expect(
      await repository.getAccountById(account.uuid),
      Right<Failure, AccountEntity>(account),
    );

    final updatedAccount = account.copyWith(
      name: 'Kaspi Gold',
      balanceMinor: 125000,
    );
    expect(
      await repository.updateAccount(updatedAccount),
      Right<Failure, AccountEntity>(updatedAccount),
    );

    await repository.deleteAccount(account.uuid);
    final deleted = await repository.getAccountById(account.uuid);
    expect(
      deleted.fold((failure) => failure, (_) => null),
      isA<NotFoundFailure>(),
    );
  });

  test('creates accounts atomically and returns them sorted', () async {
    final second = _account(uuid: 'account-2', name: 'Second', sortOrder: 2);
    final first = _account(uuid: 'account-1', name: 'First', sortOrder: 1);

    expect(
      await repository.createAccounts([second, first]),
      const Right<Failure, Unit>(unit),
    );

    final accounts = await repository.getAccounts();
    expect(accounts.fold((_) => <AccountEntity>[], (value) => value), [
      first,
      second,
    ]);
  });

  test('seeds the default account only into an empty database', () async {
    final defaults = DefaultAccounts.create(createdAt: DateTime.utc(2026));
    final seed = SeedDefaultAccounts(repository, defaults);

    expect(await seed(const NoParams()), const Right<Failure, Unit>(unit));
    expect(await seed(const NoParams()), const Right<Failure, Unit>(unit));

    final accounts = await repository.getAccounts();
    expect(accounts.fold((_) => <AccountEntity>[], (value) => value), defaults);
  });
}

AccountEntity _account({
  required String uuid,
  required String name,
  int sortOrder = 0,
}) {
  return AccountEntity(
    uuid: uuid,
    name: name,
    sortOrder: sortOrder,
    iconCode: 'wallet',
    currencyCode: 'KZT',
    createdAt: DateTime.utc(2026),
  );
}
