import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:woolet/core/errors/failures.dart';
import 'package:woolet/core/usecases/usecase.dart';
import 'package:woolet/features/domain/entities/category_entity.dart';
import 'package:woolet/features/domain/repositories/category_repository.dart';

class GetCategoryById
    implements UseCase<CategoryEntity, GetCategoryByIdParams> {
  final CategoryRepository _repository;

  const GetCategoryById(this._repository);

  @override
  Future<Either<Failure, CategoryEntity>> call(GetCategoryByIdParams params) {
    return _repository.getCategoryById(params.uuid);
  }
}

class GetCategoryByIdParams extends Equatable {
  final String uuid;

  const GetCategoryByIdParams({required this.uuid});

  @override
  List<Object?> get props => [uuid];
}
