import 'package:drift/drift.dart';
import 'package:woolet/core/database/app_database.dart';
import 'package:woolet/features/data/datasources/account_local_data_source.dart';
import 'package:woolet/features/data/models/account_model.dart';

class AccountLocalDataSourceImpl implements AccountLocalDataSource {
  final AppDatabase _database;

  const AccountLocalDataSourceImpl({required AppDatabase database})
    : _database = database;

  @override
  Future<List<AccountModel>> getAccounts() async {
    final rows =
        await (_database.select(_database.accounts)..orderBy([
              (table) => OrderingTerm.asc(table.sortOrder),
              (table) => OrderingTerm.asc(table.name),
            ]))
            .get();

    return rows.map(AccountModel.fromDrift).toList(growable: false);
  }

  @override
  Future<AccountModel?> getAccountById(String uuid) async {
    final row = await (_database.select(
      _database.accounts,
    )..where((table) => table.uuid.equals(uuid))).getSingleOrNull();

    return row == null ? null : AccountModel.fromDrift(row);
  }

  @override
  Future<AccountModel> createAccount(AccountModel account) async {
    await _database.into(_database.accounts).insert(account.toCompanion());
    return account;
  }

  @override
  Future<void> createAccounts(List<AccountModel> accounts) async {
    if (accounts.isEmpty) return;

    await _database.transaction(() async {
      await _database.batch((batch) {
        batch.insertAll(
          _database.accounts,
          accounts.map((account) => account.toCompanion()).toList(),
        );
      });
    });
  }

  @override
  Future<AccountModel?> updateAccount(AccountModel account) async {
    final updatedRows =
        await (_database.update(_database.accounts)
              ..where((table) => table.uuid.equals(account.uuid)))
            .write(account.toCompanion());

    return updatedRows == 0 ? null : account;
  }

  @override
  Future<void> deleteAccount(String uuid) async {
    await (_database.delete(
      _database.accounts,
    )..where((table) => table.uuid.equals(uuid))).go();
  }
}
