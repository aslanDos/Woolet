import 'package:drift/drift.dart';
import 'package:woolet/core/constants/app_enums.dart';
import 'package:woolet/core/database/app_database.dart';
import 'package:woolet/features/data/datasources/transaction_local_data_source.dart';
import 'package:woolet/features/data/models/transaction_model.dart';
import 'package:woolet/features/domain/entities/transaction_entity.dart';

class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  final AppDatabase _database;

  const TransactionLocalDataSourceImpl({required AppDatabase database})
    : _database = database;

  @override
  Future<List<TransactionModel>> getTransactions() async {
    final rows =
        await (_database.select(_database.transactions)..orderBy([
              (table) => OrderingTerm.desc(table.occurredAt),
              (table) => OrderingTerm.desc(table.createdAt),
            ]))
            .get();
    return rows.map(TransactionModel.fromDrift).toList(growable: false);
  }

  @override
  Future<TransactionModel> createTransaction(TransactionModel model) async {
    await _database.transaction(() async {
      await _database.into(_database.transactions).insert(model.toCompanion());
      await _applyBalance(model.entity, 1);
    });
    return model;
  }

  @override
  Future<TransactionModel?> updateTransaction(TransactionModel model) async {
    return _database.transaction(() async {
      final oldRow =
          await (_database.select(_database.transactions)
                ..where((table) => table.uuid.equals(model.entity.uuid)))
              .getSingleOrNull();
      if (oldRow == null) return null;
      await _applyBalance(TransactionModel.fromDrift(oldRow).entity, -1);
      await (_database.update(_database.transactions)
            ..where((table) => table.uuid.equals(model.entity.uuid)))
          .write(model.toCompanion());
      await _applyBalance(model.entity, 1);
      return model;
    });
  }

  @override
  Future<void> deleteTransaction(String uuid) async {
    await _database.transaction(() async {
      final row = await (_database.select(
        _database.transactions,
      )..where((table) => table.uuid.equals(uuid))).getSingleOrNull();
      if (row == null) return;
      await _applyBalance(TransactionModel.fromDrift(row).entity, -1);
      await (_database.delete(
        _database.transactions,
      )..where((table) => table.uuid.equals(uuid))).go();
    });
  }

  Future<void> _applyBalance(TransactionEntity value, int direction) async {
    final sourceDelta =
        switch (value.type) {
          TransactionType.income => value.amountMinor,
          TransactionType.expense ||
          TransactionType.transfer => -value.amountMinor,
        } *
        direction;
    await _changeAccountBalance(value.accountUuid, sourceDelta);
    if (value.type == TransactionType.transfer) {
      await _changeAccountBalance(
        value.toAccountUuid!,
        value.amountMinor * direction,
      );
    }
  }

  Future<void> _changeAccountBalance(String uuid, int delta) async {
    final account = await (_database.select(
      _database.accounts,
    )..where((table) => table.uuid.equals(uuid))).getSingleOrNull();
    if (account == null) throw StateError('Account $uuid was not found');
    await (_database.update(
      _database.accounts,
    )..where((table) => table.uuid.equals(uuid))).write(
      AccountsCompanion(balanceMinor: Value(account.balanceMinor + delta)),
    );
  }
}
