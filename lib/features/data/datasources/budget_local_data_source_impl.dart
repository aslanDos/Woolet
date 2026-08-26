import 'package:woolet/core/database/app_database.dart';
import 'package:woolet/features/data/datasources/budget_local_data_source.dart';
import 'package:woolet/features/data/models/budget_model.dart';

class BudgetLocalDataSourceImpl implements BudgetLocalDataSource {
  const BudgetLocalDataSourceImpl({required AppDatabase database})
    : _database = database;

  final AppDatabase _database;

  @override
  Future<List<BudgetModel>> getBudgets() async {
    final rows = await _database.select(_database.budgets).get();
    final links = await _database.select(_database.budgetCategories).get();
    final categories = <String, List<String>>{};
    for (final link in links) {
      categories.putIfAbsent(link.budgetUuid, () => []).add(link.categoryUuid);
    }
    return rows
        .map(
          (row) => BudgetModel.fromDrift(row, categories[row.uuid] ?? const []),
        )
        .toList(growable: false);
  }

  @override
  Future<BudgetModel> createBudget(BudgetModel model) async {
    await _database.transaction(() async {
      await _database.into(_database.budgets).insert(model.toCompanion());
      await _replaceCategories(model);
    });
    return model;
  }

  @override
  Future<BudgetModel?> updateBudget(BudgetModel model) async {
    return _database.transaction(() async {
      final changed =
          await (_database.update(_database.budgets)
                ..where((table) => table.uuid.equals(model.entity.uuid)))
              .write(model.toCompanion());
      if (changed == 0) return null;
      await _replaceCategories(model);
      return model;
    });
  }

  Future<void> _replaceCategories(BudgetModel model) async {
    await (_database.delete(
      _database.budgetCategories,
    )..where((table) => table.budgetUuid.equals(model.entity.uuid))).go();
    await _database.batch((batch) {
      batch.insertAll(
        _database.budgetCategories,
        model.entity.categoryUuids
            .map(
              (uuid) => BudgetCategoriesCompanion.insert(
                budgetUuid: model.entity.uuid,
                categoryUuid: uuid,
              ),
            )
            .toList(growable: false),
      );
    });
  }

  @override
  Future<void> deleteBudget(String uuid) async {
    await (_database.delete(
      _database.budgets,
    )..where((table) => table.uuid.equals(uuid))).go();
  }
}
