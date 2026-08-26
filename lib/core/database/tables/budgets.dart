import 'package:drift/drift.dart';
import 'package:woolet/core/database/tables/accounts.dart';
import 'package:woolet/core/database/tables/categories.dart';

@DataClassName('BudgetRow')
class Budgets extends Table {
  TextColumn get uuid => text()();
  TextColumn get name => text()
      .withLength(min: 1, max: 48)
      .withDefault(const Constant('Budget'))();
  IntColumn get amountMinor => integer()();
  TextColumn get period => text()();
  IntColumn get startDay => integer()();
  TextColumn get iconCode => text()();
  IntColumn get colorValue => integer()();
  TextColumn get accountUuid => text().nullable().references(Accounts, #uuid)();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {uuid};
}

@DataClassName('BudgetCategoryRow')
class BudgetCategories extends Table {
  TextColumn get budgetUuid =>
      text().references(Budgets, #uuid, onDelete: KeyAction.cascade)();
  TextColumn get categoryUuid =>
      text().references(Categories, #uuid, onDelete: KeyAction.cascade)();

  @override
  Set<Column<Object>> get primaryKey => {budgetUuid, categoryUuid};
}
