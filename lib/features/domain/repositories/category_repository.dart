import 'package:dartz/dartz.dart';
import 'package:woolet/core/errors/failures.dart';
import 'package:woolet/features/domain/entities/category_entity.dart';

abstract interface class CategoryRepository {
  Future<Either<Failure, List<CategoryEntity>>> getCategories();

  Future<Either<Failure, CategoryEntity>> getCategoryById(String uuid);

  Future<Either<Failure, CategoryEntity>> createCategory(
    CategoryEntity category,
  );

  Future<Either<Failure, Unit>> createCategories(
    List<CategoryEntity> categories,
  );

  Future<Either<Failure, CategoryEntity>> updateCategory(
    CategoryEntity category,
  );

  Future<Either<Failure, Unit>> deleteCategory(String uuid);
}
