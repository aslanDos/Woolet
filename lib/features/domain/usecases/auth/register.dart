import 'package:dartz/dartz.dart';
import 'package:woolet/core/errors/failures.dart';
import 'package:woolet/core/usecases/usecase.dart';
import 'package:woolet/features/domain/repositories/auth_repository.dart';
import 'package:woolet/features/domain/usecases/auth/auth_params.dart';

class Register implements UseCase<Unit, AuthCredentials> {
  const Register(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(AuthCredentials params) {
    return _repository.register(email: params.email, password: params.password);
  }
}
