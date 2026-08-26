import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:woolet/core/database/tables/accounts.dart';
import 'package:woolet/core/database/tables/categories.dart';
import 'package:woolet/core/database/tables/transactions.dart';
import 'package:woolet/core/database/tables/budgets.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Categories, Accounts, Transactions, Budgets, BudgetCategories],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'woolet'));

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(accounts);
      }
      if (from < 3) {
        await migrator.createTable(transactions);
      }
      if (from < 4) {
        await migrator.createTable(budgets);
        await migrator.createTable(budgetCategories);
      }
      if (from >= 4 && from < 5) {
        await migrator.addColumn(budgets, budgets.name);
      }
    },
  );
}
