import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:woolet/core/errors/failures.dart';
import 'package:woolet/core/usecases/usecase.dart';
import 'package:woolet/features/domain/entities/category_entity.dart';
import 'package:woolet/features/domain/repositories/category_repository.dart';

class UpdateCategory implements UseCase<CategoryEntity, UpdateCategoryParams> {
  final CategoryRepository _repository;

  const UpdateCategory(this._repository);

  @override
  Future<Either<Failure, CategoryEntity>> call(UpdateCategoryParams params) {
    return _repository.updateCategory(params.category);
  }
}

class UpdateCategoryParams extends Equatable {
  final CategoryEntity category;

  const UpdateCategoryParams({required this.category});

  @override
  List<Object?> get props => [category];
}
