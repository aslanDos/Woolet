import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:woolet/core/errors/failures.dart';
import 'package:woolet/core/utils/logger.dart';
import 'package:woolet/features/data/datasources/auth_remote_data_source.dart';
import 'package:woolet/features/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, bool>> isSignedIn() async {
    return Right(_remoteDataSource.isSignedIn);
  }

  @override
  Future<Either<Failure, Unit>> signIn({
    required String email,
    required String password,
  }) => _execute(
    () => _remoteDataSource.signIn(email: email, password: password),
  );

  @override
  Future<Either<Failure, Unit>> register({
    required String email,
    required String password,
  }) => _execute(
    () => _remoteDataSource.register(email: email, password: password),
  );

  @override
  Future<Either<Failure, Unit>> sendPasswordResetEmail(String email) {
    return _execute(() => _remoteDataSource.sendPasswordResetEmail(email));
  }

  Future<Either<Failure, Unit>> _execute(Future<void> Function() action) async {
    try {
      await action();
      return const Right(unit);
    } on FirebaseAuthException catch (error) {
      Log.e(
        'Firebase auth failed (${error.code}): ${error.message}',
        label: 'auth_repository',
      );
      return Left(AuthFailure(_messageFor(error)));
    } on Object catch (error) {
      Log.e('Authentication failed: $error', label: 'auth_repository');
      return const Left(AuthFailure('Authentication failed'));
    }
  }

  String _messageFor(FirebaseAuthException error) => switch (error.code) {
    'email-already-in-use' => 'An account already exists for this email',
    'invalid-credential' => 'Incorrect email or password',
    'invalid-email' => 'Enter a valid email',
    'network-request-failed' => 'Check your internet connection',
    'too-many-requests' => 'Too many attempts. Try again later',
    'user-disabled' => 'This account has been disabled',
    'user-not-found' => 'No account found for this email',
    'weak-password' => 'Use a stronger password',
    'wrong-password' => 'Incorrect email or password',
    _ => error.message ?? 'Authentication failed',
  };
}
