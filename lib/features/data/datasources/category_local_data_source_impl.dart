import 'package:drift/drift.dart';
import 'package:woolet/core/database/app_database.dart';
import 'package:woolet/features/data/datasources/category_local_data_source.dart';
import 'package:woolet/features/data/models/category_model.dart';

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  final AppDatabase _database;

  const CategoryLocalDataSourceImpl({required AppDatabase database})
    : _database = database;

  @override
  Future<List<CategoryModel>> getCategories() async {
    final rows =
        await (_database.select(_database.categories)..orderBy([
              (table) => OrderingTerm.asc(table.sortOrder),
              (table) => OrderingTerm.asc(table.name),
            ]))
            .get();

    return rows.map(CategoryModel.fromDrift).toList(growable: false);
  }

  @override
  Future<CategoryModel?> getCategoryById(String uuid) async {
    final row = await (_database.select(
      _database.categories,
    )..where((table) => table.uuid.equals(uuid))).getSingleOrNull();

    return row == null ? null : CategoryModel.fromDrift(row);
  }

  @override
  Future<CategoryModel> createCategory(CategoryModel category) async {
    await _database.into(_database.categories).insert(category.toCompanion());
    return category;
  }

  @override
  Future<void> createCategories(List<CategoryModel> categories) async {
    if (categories.isEmpty) return;

    await _database.transaction(() async {
      await _database.batch((batch) {
        batch.insertAll(
          _database.categories,
          categories.map((category) => category.toCompanion()).toList(),
        );
      });
    });
  }

  @override
  Future<CategoryModel?> updateCategory(CategoryModel category) async {
    final updatedRows =
        await (_database.update(_database.categories)
              ..where((table) => table.uuid.equals(category.uuid)))
            .write(category.toCompanion());

    return updatedRows == 0 ? null : category;
  }

  @override
  Future<void> deleteCategory(String uuid) async {
    await (_database.delete(
      _database.categories,
    )..where((table) => table.uuid.equals(uuid))).go();
  }
}
