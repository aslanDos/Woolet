import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:woolet/core/errors/failures.dart';
import 'package:woolet/core/usecases/usecase.dart';
import 'package:woolet/features/domain/entities/category_entity.dart';
import 'package:woolet/features/domain/repositories/category_repository.dart';

class CreateCategories implements UseCase<Unit, CreateCategoriesParams> {
  final CategoryRepository _repository;

  const CreateCategories(this._repository);

  @override
  Future<Either<Failure, Unit>> call(CreateCategoriesParams params) {
    return _repository.createCategories(params.categories);
  }
}

class CreateCategoriesParams extends Equatable {
  final List<CategoryEntity> categories;

  CreateCategoriesParams({required List<CategoryEntity> categories})
    : categories = List.unmodifiable(categories);

  @override
  List<Object?> get props => [categories];
}
