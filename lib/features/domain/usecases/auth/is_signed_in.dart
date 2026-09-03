import 'package:dartz/dartz.dart';
import 'package:woolet/core/errors/failures.dart';
import 'package:woolet/core/usecases/usecase.dart';
import 'package:woolet/features/domain/repositories/auth_repository.dart';

class IsSignedIn implements UseCase<bool, NoParams> {
  const IsSignedIn(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, bool>> call(NoParams params) {
    return _repository.isSignedIn();
  }
}
