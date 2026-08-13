import 'package:drift/drift.dart';
import 'package:woolet/core/database/app_database.dart';
import 'package:woolet/features/domain/entities/account_entity.dart';

class AccountModel {
  final String uuid;
  final String name;
  final int sortOrder;
  final String iconCode;
  final String currencyCode;
  final int balanceMinor;
  final DateTime createdAt;
  final int? colorValue;
  final bool visible;

  const AccountModel({
    required this.uuid,
    required this.name,
    required this.sortOrder,
    required this.iconCode,
    required this.currencyCode,
    required this.balanceMinor,
    required this.createdAt,
    required this.colorValue,
    required this.visible,
  });

  factory AccountModel.fromEntity(AccountEntity entity) {
    return AccountModel(
      uuid: entity.uuid,
      name: entity.name,
      sortOrder: entity.sortOrder,
      iconCode: entity.iconCode,
      currencyCode: entity.currencyCode.trim().toUpperCase(),
      balanceMinor: entity.balanceMinor,
      createdAt: entity.createdAt,
      colorValue: entity.colorValue,
      visible: entity.visible,
    );
  }

  factory AccountModel.fromDrift(AccountRow row) {
    return AccountModel(
      uuid: row.uuid,
      name: row.name,
      sortOrder: row.sortOrder,
      iconCode: row.iconCode,
      currencyCode: row.currencyCode,
      balanceMinor: row.balanceMinor,
      createdAt: row.createdAt.toUtc(),
      colorValue: row.colorValue,
      visible: row.visible,
    );
  }

  AccountEntity toEntity() {
    return AccountEntity(
      uuid: uuid,
      name: name,
      sortOrder: sortOrder,
      iconCode: iconCode,
      currencyCode: currencyCode,
      balanceMinor: balanceMinor,
      createdAt: createdAt.toUtc(),
      colorValue: colorValue,
      visible: visible,
    );
  }

  AccountsCompanion toCompanion() {
    return AccountsCompanion.insert(
      uuid: uuid,
      name: name,
      sortOrder: sortOrder,
      iconCode: iconCode,
      currencyCode: currencyCode.toUpperCase(),
      balanceMinor: Value(balanceMinor),
      createdAt: createdAt.toUtc(),
      colorValue: Value(colorValue),
      visible: Value(visible),
    );
  }
}
