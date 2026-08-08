import 'package:get_it/get_it.dart';
import 'package:woolet/core/database/app_database.dart';
import 'package:woolet/features/data/datasources/category_local_data_source.dart';
import 'package:woolet/features/data/datasources/category_local_data_source_impl.dart';
import 'package:woolet/features/data/repositories/category_repository_impl.dart';
import 'package:woolet/features/domain/constants/default_categories.dart';
import 'package:woolet/features/domain/repositories/category_repository.dart';
import 'package:woolet/features/domain/usecases/category/category_usecases.dart';
import 'package:woolet/features/presentation/blocs/category/category_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  sl.registerLazySingleton<AppDatabase>(
    AppDatabase.new,
    dispose: (database) => database.close(),
  );

  _initCategoryFeature();
}

void _initCategoryFeature() {
  sl.registerLazySingleton<CategoryLocalDataSource>(
    () => CategoryLocalDataSourceImpl(database: sl()),
  );

  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(localDataSource: sl()),
  );

  sl.registerLazySingleton(() => GetCategories(sl()));
  sl.registerLazySingleton(() => GetCategoryById(sl()));
  sl.registerLazySingleton(() => CreateCategory(sl()));
  sl.registerLazySingleton(() => CreateCategories(sl()));
  sl.registerLazySingleton(() => UpdateCategory(sl()));
  sl.registerLazySingleton(() => DeleteCategory(sl()));
  sl.registerLazySingleton(
    () => SeedDefaultCategories(sl(), DefaultCategories.create()),
  );

  sl.registerFactory(
    () => CategoryBloc(
      getCategories: sl(),
      createCategory: sl(),
      updateCategory: sl(),
      deleteCategory: sl(),
    ),
  );
}
