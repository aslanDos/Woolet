import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:woolet/core/database/app_database.dart';
import 'package:woolet/core/settings/currency_controller.dart';
import 'package:woolet/core/theme/theme_controller.dart';
import 'package:woolet/features/data/datasources/account_local_data_source.dart';
import 'package:woolet/features/data/datasources/account_local_data_source_impl.dart';
import 'package:woolet/features/data/datasources/category_local_data_source.dart';
import 'package:woolet/features/data/datasources/category_local_data_source_impl.dart';
import 'package:woolet/features/data/repositories/account_repository_impl.dart';
import 'package:woolet/features/data/repositories/category_repository_impl.dart';
import 'package:woolet/features/domain/constants/default_accounts.dart';
import 'package:woolet/features/domain/constants/default_categories.dart';
import 'package:woolet/features/domain/repositories/account_repository.dart';
import 'package:woolet/features/domain/repositories/category_repository.dart';
import 'package:woolet/features/domain/usecases/account/account_usecases.dart';
import 'package:woolet/features/domain/usecases/category/category_usecases.dart';
import 'package:woolet/features/presentation/blocs/account/account_bloc.dart';
import 'package:woolet/features/presentation/blocs/category/category_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  final preferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<ThemeController>(() => ThemeController(preferences));
  final currencyController = await CurrencyController.create(preferences);
  sl.registerSingleton<CurrencyController>(currencyController);

  sl.registerLazySingleton<AppDatabase>(
    AppDatabase.new,
    dispose: (database) => database.close(),
  );

  _initAccountFeature();
  _initCategoryFeature();
}

void _initAccountFeature() {
  sl.registerLazySingleton<AccountLocalDataSource>(
    () => AccountLocalDataSourceImpl(database: sl()),
  );

  sl.registerLazySingleton<AccountRepository>(
    () => AccountRepositoryImpl(localDataSource: sl()),
  );

  sl.registerLazySingleton(() => GetAccounts(sl()));
  sl.registerLazySingleton(() => GetAccountById(sl()));
  sl.registerLazySingleton(() => CreateAccount(sl()));
  sl.registerLazySingleton(() => CreateAccounts(sl()));
  sl.registerLazySingleton(() => UpdateAccount(sl()));
  sl.registerLazySingleton(() => DeleteAccount(sl()));
  sl.registerLazySingleton(
    () => SeedDefaultAccounts(sl(), DefaultAccounts.create()),
  );

  sl.registerFactory(
    () => AccountBloc(
      getAccounts: sl(),
      createAccount: sl(),
      updateAccount: sl(),
      deleteAccount: sl(),
    ),
  );
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
