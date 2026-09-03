import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:woolet/core/errors/failures.dart';
import 'package:woolet/features/domain/repositories/auth_repository.dart';
import 'package:woolet/features/domain/usecases/auth/auth_usecases.dart';
import 'package:woolet/features/presentation/blocs/auth/auth_bloc.dart';

void main() {
  late _FakeAuthRepository repository;
  late AuthBloc bloc;

  setUp(() {
    repository = _FakeAuthRepository();
    bloc = AuthBloc(
      signIn: SignIn(repository),
      register: Register(repository),
      sendPasswordResetEmail: SendPasswordResetEmail(repository),
    );
  });

  tearDown(() => bloc.close());

  test('signs in and emits authenticated', () async {
    final result = bloc.stream.firstWhere(
      (state) => state.status == AuthStatus.authenticated,
    );

    bloc.add(
      const AuthSignInRequested(
        email: 'user@example.com',
        password: 'password',
      ),
    );

    await result;
    expect(repository.lastEmail, 'user@example.com');
  });

  test('emits repository failure', () async {
    repository.failure = const AuthFailure('Incorrect email or password');
    final result = bloc.stream.firstWhere(
      (state) => state.status == AuthStatus.failure,
    );

    bloc.add(
      const AuthSignInRequested(
        email: 'user@example.com',
        password: 'wrong-password',
      ),
    );

    expect((await result).errorMessage, 'Incorrect email or password');
  });
}

class _FakeAuthRepository implements AuthRepository {
  Failure? failure;
  String? lastEmail;

  @override
  Future<Either<Failure, bool>> isSignedIn() async => const Right(false);

  @override
  Future<Either<Failure, Unit>> signIn({
    required String email,
    required String password,
  }) async {
    lastEmail = email;
    return _result();
  }

  @override
  Future<Either<Failure, Unit>> register({
    required String email,
    required String password,
  }) async {
    lastEmail = email;
    return _result();
  }

  @override
  Future<Either<Failure, Unit>> sendPasswordResetEmail(String email) async {
    lastEmail = email;
    return _result();
  }

  Either<Failure, Unit> _result() {
    final currentFailure = failure;
    return currentFailure == null ? const Right(unit) : Left(currentFailure);
  }
}
