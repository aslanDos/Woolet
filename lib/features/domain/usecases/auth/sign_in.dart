import 'package:dartz/dartz.dart';
import 'package:woolet/core/errors/failures.dart';
import 'package:woolet/core/usecases/usecase.dart';
import 'package:woolet/features/domain/repositories/auth_repository.dart';
import 'package:woolet/features/domain/usecases/auth/auth_params.dart';

class SignIn implements UseCase<Unit, AuthCredentials> {
  const SignIn(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(AuthCredentials params) {
    return _repository.signIn(email: params.email, password: params.password);
  }
}
