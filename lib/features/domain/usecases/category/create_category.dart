import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:woolet/core/errors/failures.dart';
import 'package:woolet/core/usecases/usecase.dart';
import 'package:woolet/features/domain/entities/category_entity.dart';
import 'package:woolet/features/domain/repositories/category_repository.dart';

class CreateCategory implements UseCase<CategoryEntity, CreateCategoryParams> {
  final CategoryRepository _repository;

  const CreateCategory(this._repository);

  @override
  Future<Either<Failure, CategoryEntity>> call(CreateCategoryParams params) {
    return _repository.createCategory(params.category);
  }
}

class CreateCategoryParams extends Equatable {
  final CategoryEntity category;

  const CreateCategoryParams({required this.category});

  @override
  List<Object?> get props => [category];
}
