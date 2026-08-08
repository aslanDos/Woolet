import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:woolet/core/errors/failures.dart';
import 'package:woolet/core/usecases/usecase.dart';
import 'package:woolet/features/domain/repositories/category_repository.dart';

class DeleteCategory implements UseCase<Unit, DeleteCategoryParams> {
  final CategoryRepository _repository;

  const DeleteCategory(this._repository);

  @override
  Future<Either<Failure, Unit>> call(DeleteCategoryParams params) {
    return _repository.deleteCategory(params.uuid);
  }
}

class DeleteCategoryParams extends Equatable {
  final String uuid;

  const DeleteCategoryParams({required this.uuid});

  @override
  List<Object?> get props => [uuid];
}
