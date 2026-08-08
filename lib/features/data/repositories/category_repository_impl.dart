import 'package:dartz/dartz.dart';
import 'package:woolet/core/errors/failures.dart';
import 'package:woolet/core/utils/logger.dart';
import 'package:woolet/features/data/datasources/category_local_data_source.dart';
import 'package:woolet/features/data/models/category_model.dart';
import 'package:woolet/features/domain/entities/category_entity.dart';
import 'package:woolet/features/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDataSource _localDataSource;

  const CategoryRepositoryImpl({
    required CategoryLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    try {
      final models = await _localDataSource.getCategories();
      return Right(models.map((model) => model.toEntity()).toList());
    } on Object catch (error) {
      return _databaseFailure('get categories', error);
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> getCategoryById(String uuid) async {
    try {
      final model = await _localDataSource.getCategoryById(uuid);
      if (model == null) {
        return Left(NotFoundFailure('Category $uuid was not found'));
      }

      return Right(model.toEntity());
    } on Object catch (error) {
      return _databaseFailure('get category $uuid', error);
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> createCategory(
    CategoryEntity category,
  ) async {
    try {
      final model = await _localDataSource.createCategory(
        CategoryModel.fromEntity(category),
      );
      return Right(model.toEntity());
    } on Object catch (error) {
      return _databaseFailure('create category ${category.uuid}', error);
    }
  }

  @override
  Future<Either<Failure, Unit>> createCategories(
    List<CategoryEntity> categories,
  ) async {
    try {
      await _localDataSource.createCategories(
        categories.map(CategoryModel.fromEntity).toList(growable: false),
      );
      return const Right(unit);
    } on Object catch (error) {
      return _databaseFailure('create categories', error);
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> updateCategory(
    CategoryEntity category,
  ) async {
    try {
      final model = await _localDataSource.updateCategory(
        CategoryModel.fromEntity(category),
      );
      if (model == null) {
        return Left(NotFoundFailure('Category ${category.uuid} was not found'));
      }

      return Right(model.toEntity());
    } on Object catch (error) {
      return _databaseFailure('update category ${category.uuid}', error);
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteCategory(String uuid) async {
    try {
      await _localDataSource.deleteCategory(uuid);
      return const Right(unit);
    } on Object catch (error) {
      return _databaseFailure('delete category $uuid', error);
    }
  }

  Left<Failure, T> _databaseFailure<T>(String operation, Object error) {
    Log.e('Failed to $operation: $error', label: 'category_repository');
    return Left(DatabaseFailure('Failed to $operation'));
  }
}
