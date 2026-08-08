import 'package:dartz/dartz.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:woolet/core/constants/app_enums.dart';
import 'package:woolet/core/database/app_database.dart';
import 'package:woolet/core/errors/failures.dart';
import 'package:woolet/core/usecases/usecase.dart';
import 'package:woolet/features/data/datasources/category_local_data_source_impl.dart';
import 'package:woolet/features/data/repositories/category_repository_impl.dart';
import 'package:woolet/features/domain/constants/default_categories.dart';
import 'package:woolet/features/domain/entities/category_entity.dart';
import 'package:woolet/features/domain/usecases/category/seed_default_categories.dart';

void main() {
  late AppDatabase database;
  late CategoryRepositoryImpl repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = CategoryRepositoryImpl(
      localDataSource: CategoryLocalDataSourceImpl(database: database),
    );
  });

  tearDown(() => database.close());

  test('creates, reads, updates and deletes a category', () async {
    final category = _category(uuid: 'category-1', name: 'Salary');

    final created = await repository.createCategory(category);
    expect(created, Right<Failure, CategoryEntity>(category));

    final loaded = await repository.getCategoryById(category.uuid);
    expect(loaded, Right<Failure, CategoryEntity>(category));

    final updatedCategory = category.copyWith(name: 'Main salary');
    final updated = await repository.updateCategory(updatedCategory);
    expect(updated, Right<Failure, CategoryEntity>(updatedCategory));

    await repository.deleteCategory(category.uuid);

    final deleted = await repository.getCategoryById(category.uuid);
    expect(
      deleted.fold((failure) => failure, (_) => null),
      isA<NotFoundFailure>(),
    );
  });

  test('creates categories atomically and returns them sorted', () async {
    final second = _category(uuid: 'category-2', name: 'Second', sortOrder: 2);
    final first = _category(uuid: 'category-1', name: 'First', sortOrder: 1);

    final result = await repository.createCategories([second, first]);
    expect(result, const Right<Failure, Unit>(unit));

    final categories = await repository.getCategories();
    expect(categories.fold((_) => <CategoryEntity>[], (value) => value), [
      first,
      second,
    ]);
  });

  test('backfills a missing color for an existing default category', () async {
    final defaultCategory = DefaultCategories.create(
      createdAt: DateTime.utc(2026),
    ).first;
    final categoryWithoutColor = defaultCategory.copyWith(colorValue: null);
    await repository.createCategory(categoryWithoutColor);

    final result = await SeedDefaultCategories(repository, [defaultCategory])(
      const NoParams(),
    );

    expect(result, const Right<Failure, Unit>(unit));

    final loaded = await repository.getCategoryById(defaultCategory.uuid);
    expect(
      loaded.fold((_) => null, (category) => category.colorValue),
      defaultCategory.colorValue,
    );
  });
}

CategoryEntity _category({
  required String uuid,
  required String name,
  int sortOrder = 0,
}) {
  return CategoryEntity(
    uuid: uuid,
    name: name,
    sortOrder: sortOrder,
    iconCode: 'wallet',
    createdAt: DateTime.utc(2026),
    type: CategoryType.expense,
  );
}
