import 'package:woolet/core/di/service_locator.dart';
import 'package:woolet/core/usecases/usecase.dart';
import 'package:woolet/core/utils/logger.dart';
import 'package:woolet/features/domain/usecases/account/account_usecases.dart';
import 'package:woolet/features/domain/usecases/category/category_usecases.dart';

Future<void> bootstrapApp() async {
  await initDependencies();

  final accountSeedResult = await sl<SeedDefaultAccounts>()(const NoParams());
  accountSeedResult.fold(
    (failure) => Log.e(failure.message, label: 'account_seed'),
    (_) => Log.i('Default accounts are ready', label: 'account_seed'),
  );

  final categorySeedResult = await sl<SeedDefaultCategories>()(
    const NoParams(),
  );
  categorySeedResult.fold(
    (failure) => Log.e(failure.message, label: 'category_seed'),
    (_) => Log.i('Default categories are ready', label: 'category_seed'),
  );
}
