import 'package:drift/drift.dart';
import 'package:woolet/core/constants/app_enums.dart';
import 'package:woolet/core/database/app_database.dart';
import 'package:woolet/features/domain/entities/transaction_entity.dart';

class TransactionModel {
  final TransactionEntity entity;

  const TransactionModel(this.entity);

  factory TransactionModel.fromDrift(TransactionRow row) => TransactionModel(
    TransactionEntity(
      uuid: row.uuid,
      type: TransactionType.values.byName(row.type),
      amountMinor: row.amountMinor,
      accountUuid: row.accountUuid,
      toAccountUuid: row.toAccountUuid,
      categoryUuid: row.categoryUuid,
      note: row.note,
      occurredAt: row.occurredAt.toLocal(),
      createdAt: row.createdAt.toUtc(),
    ),
  );

  factory TransactionModel.fromEntity(TransactionEntity entity) =>
      TransactionModel(entity);

  TransactionEntity toEntity() => entity;

  TransactionsCompanion toCompanion() => TransactionsCompanion.insert(
    uuid: entity.uuid,
    type: entity.type.name,
    amountMinor: entity.amountMinor,
    accountUuid: entity.accountUuid,
    toAccountUuid: Value(entity.toAccountUuid),
    categoryUuid: Value(entity.categoryUuid),
    note: Value(entity.note.trim()),
    occurredAt: entity.occurredAt,
    createdAt: entity.createdAt.toUtc(),
  );
}
