import 'package:dartz/dartz.dart';
import 'package:woolet/core/errors/failures.dart';
import 'package:woolet/core/usecases/usecase.dart';
import 'package:woolet/features/domain/repositories/auth_repository.dart';
import 'package:woolet/features/domain/usecases/auth/auth_params.dart';

class SendPasswordResetEmail implements UseCase<Unit, PasswordResetParams> {
  const SendPasswordResetEmail(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(PasswordResetParams params) {
    return _repository.sendPasswordResetEmail(params.email);
  }
}
