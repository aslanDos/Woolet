import 'package:dartz/dartz.dart';
import 'package:woolet/core/errors/failures.dart';
import 'package:woolet/core/usecases/usecase.dart';
import 'package:woolet/features/domain/entities/category_entity.dart';
import 'package:woolet/features/domain/repositories/category_repository.dart';

class GetCategories implements UseCase<List<CategoryEntity>, NoParams> {
  final CategoryRepository _repository;

  const GetCategories(this._repository);

  @override
  Future<Either<Failure, List<CategoryEntity>>> call(NoParams params) {
    return _repository.getCategories();
  }
}
