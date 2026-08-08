import 'package:dartz/dartz.dart';
import 'package:woolet/core/errors/failures.dart';
import 'package:woolet/core/usecases/usecase.dart';
import 'package:woolet/features/domain/entities/category_entity.dart';
import 'package:woolet/features/domain/repositories/category_repository.dart';

class SeedDefaultCategories implements UseCase<Unit, NoParams> {
  final CategoryRepository _repository;
  final List<CategoryEntity> _defaultCategories;

  SeedDefaultCategories(
    this._repository,
    List<CategoryEntity> defaultCategories,
  ) : _defaultCategories = List.unmodifiable(defaultCategories);

  @override
  Future<Either<Failure, Unit>> call(NoParams params) async {
    final categoriesResult = await _repository.getCategories();

    return categoriesResult.fold(Left.new, (categories) async {
      if (_defaultCategories.isEmpty) {
        return const Right(unit);
      }

      if (categories.isEmpty) {
        return _repository.createCategories(_defaultCategories);
      }

      final defaultsByUuid = {
        for (final category in _defaultCategories) category.uuid: category,
      };

      for (final category in categories) {
        final defaultCategory = defaultsByUuid[category.uuid];
        if (category.colorValue != null || defaultCategory == null) continue;

        final updateResult = await _repository.updateCategory(
          category.copyWith(colorValue: defaultCategory.colorValue),
        );
        final failure = updateResult.fold<Failure?>(
          (value) => value,
          (_) => null,
        );
        if (failure != null) return Left(failure);
      }

      return const Right(unit);
    });
  }
}
