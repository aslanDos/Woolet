import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:woolet/core/constants/app_enums.dart';
import 'package:woolet/core/database/app_database.dart';
import 'package:woolet/features/data/datasources/transaction_local_data_source_impl.dart';
import 'package:woolet/features/data/repositories/transaction_repository_impl.dart';
import 'package:woolet/features/domain/entities/transaction_entity.dart';

void main() {
  late AppDatabase database;
  late TransactionRepositoryImpl repository;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    repository = TransactionRepositoryImpl(
      localDataSource: TransactionLocalDataSourceImpl(database: database),
    );
    final now = DateTime.utc(2026, 1, 1);
    await database
        .into(database.accounts)
        .insert(
          AccountsCompanion.insert(
            uuid: 'source',
            name: 'Source',
            sortOrder: 0,
            iconCode: 'wallet',
            currencyCode: 'KZT',
            createdAt: now,
          ),
        );
    await database
        .into(database.accounts)
        .insert(
          AccountsCompanion.insert(
            uuid: 'target',
            name: 'Target',
            sortOrder: 1,
            iconCode: 'wallet',
            currencyCode: 'KZT',
            createdAt: now,
          ),
        );
  });

  tearDown(() => database.close());

  test(
    'creates and deletes transfer while keeping account balances in sync',
    () async {
      final transaction = TransactionEntity(
        uuid: 'transaction',
        type: TransactionType.transfer,
        amountMinor: 2500,
        accountUuid: 'source',
        toAccountUuid: 'target',
        occurredAt: DateTime(2026, 1, 2),
        createdAt: DateTime.utc(2026, 1, 2),
      );

      expect(
        (await repository.createTransaction(transaction)).isRight(),
        isTrue,
      );
      var accounts = await database.select(database.accounts).get();
      expect(
        accounts.singleWhere((a) => a.uuid == 'source').balanceMinor,
        -2500,
      );
      expect(
        accounts.singleWhere((a) => a.uuid == 'target').balanceMinor,
        2500,
      );

      expect(
        (await repository.deleteTransaction(transaction.uuid)).isRight(),
        isTrue,
      );
      accounts = await database.select(database.accounts).get();
      expect(accounts.every((account) => account.balanceMinor == 0), isTrue);
      expect(await database.select(database.transactions).get(), isEmpty);
    },
  );
}
