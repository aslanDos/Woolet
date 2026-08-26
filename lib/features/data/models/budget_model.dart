import 'package:drift/drift.dart';
import 'package:woolet/core/constants/app_enums.dart';
import 'package:woolet/core/database/app_database.dart';
import 'package:woolet/features/domain/entities/budget_entity.dart';

class BudgetModel {
  const BudgetModel(this.entity);
  final BudgetEntity entity;

  factory BudgetModel.fromDrift(BudgetRow row, List<String> categoryUuids) =>
      BudgetModel(
        BudgetEntity(
          uuid: row.uuid,
          name: row.name,
          amountMinor: row.amountMinor,
          categoryUuids: List.unmodifiable(categoryUuids),
          period: BudgetPeriod.values.byName(row.period),
          startDay: row.startDay,
          iconCode: row.iconCode,
          colorValue: row.colorValue,
          accountUuid: row.accountUuid,
          createdAt: row.createdAt.toLocal(),
        ),
      );

  BudgetEntity toEntity() => entity;

  BudgetsCompanion toCompanion() => BudgetsCompanion.insert(
    uuid: entity.uuid,
    name: Value(entity.name.trim()),
    amountMinor: entity.amountMinor,
    period: entity.period.name,
    startDay: entity.startDay,
    iconCode: entity.iconCode,
    colorValue: entity.colorValue,
    accountUuid: Value(entity.accountUuid),
    createdAt: entity.createdAt.toUtc(),
  );
}
