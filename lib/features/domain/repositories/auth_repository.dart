import 'package:dartz/dartz.dart';
import 'package:woolet/core/errors/failures.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, bool>> isSignedIn();

  Future<Either<Failure, Unit>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, Unit>> register({
    required String email,
    required String password,
  });

  Future<Either<Failure, Unit>> sendPasswordResetEmail(String email);
}
