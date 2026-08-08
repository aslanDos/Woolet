import 'package:woolet/core/di/service_locator.dart';
import 'package:woolet/core/usecases/usecase.dart';
import 'package:woolet/core/utils/logger.dart';
import 'package:woolet/features/domain/usecases/category/category_usecases.dart';

Future<void> bootstrapApp() async {
  await initDependencies();

  final seedResult = await sl<SeedDefaultCategories>()(const NoParams());

  seedResult.fold(
    (failure) => Log.e(failure.message, label: 'category_seed'),
    (_) => Log.i('Default categories are ready', label: 'category_seed'),
  );
}
