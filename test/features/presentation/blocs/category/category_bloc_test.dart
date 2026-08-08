import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:woolet/core/constants/app_enums.dart';
import 'package:woolet/core/database/app_database.dart';
import 'package:woolet/features/data/datasources/category_local_data_source_impl.dart';
import 'package:woolet/features/data/repositories/category_repository_impl.dart';
import 'package:woolet/features/domain/entities/category_entity.dart';
import 'package:woolet/features/domain/usecases/category/category_usecases.dart';
import 'package:woolet/features/presentation/blocs/category/category_bloc.dart';

void main() {
  late AppDatabase database;
  late CategoryBloc bloc;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    final repository = CategoryRepositoryImpl(
      localDataSource: CategoryLocalDataSourceImpl(database: database),
    );

    bloc = CategoryBloc(
      getCategories: GetCategories(repository),
      createCategory: CreateCategory(repository),
      updateCategory: UpdateCategory(repository),
      deleteCategory: DeleteCategory(repository),
    );
  });

  tearDown(() async {
    await bloc.close();
    await database.close();
  });

  test('loads and applies category CRUD events', () async {
    final loadedState = _nextSuccess(bloc);
    bloc.add(const CategoryLoadRequested());
    expect((await loadedState).categories, isEmpty);

    final category = _category(name: 'Salary');
    final createdState = _nextSuccess(bloc, processingMustStart: true);
    bloc.add(CategoryCreateRequested(category));
    expect((await createdState).categories, [category]);

    final updatedCategory = category.copyWith(name: 'Main salary');
    final updatedState = _nextSuccess(bloc, processingMustStart: true);
    bloc.add(CategoryUpdateRequested(updatedCategory));
    expect((await updatedState).categories, [updatedCategory]);

    final deletedState = _nextSuccess(bloc, processingMustStart: true);
    bloc.add(CategoryDeleteRequested(category.uuid));
    expect((await deletedState).categories, isEmpty);
  });
}

Future<CategoryState> _nextSuccess(
  CategoryBloc bloc, {
  bool processingMustStart = false,
}) async {
  if (processingMustStart) {
    await bloc.stream.firstWhere((state) => state.isProcessing);
  }

  return bloc.stream.firstWhere(
    (state) => state.status == CategoryStatus.success && !state.isProcessing,
  );
}

CategoryEntity _category({required String name}) {
  return CategoryEntity(
    uuid: '59da9e01-f829-46e9-b05e-d75764910edd',
    name: name,
    sortOrder: 0,
    iconCode: 'briefcase',
    createdAt: DateTime.utc(2026),
    type: CategoryType.income,
  );
}
