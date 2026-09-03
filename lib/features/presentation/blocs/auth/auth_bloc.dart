import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:woolet/features/domain/usecases/auth/auth_usecases.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required SignIn signIn,
    required Register register,
    required SendPasswordResetEmail sendPasswordResetEmail,
  }) : _signIn = signIn,
       _register = register,
       _sendPasswordResetEmail = sendPasswordResetEmail,
       super(const AuthState()) {
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
  }

  final SignIn _signIn;
  final Register _register;
  final SendPasswordResetEmail _sendPasswordResetEmail;

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState(status: AuthStatus.processing));
    final result = await _signIn(
      AuthCredentials(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(
        AuthState(status: AuthStatus.failure, errorMessage: failure.message),
      ),
      (_) => emit(const AuthState(status: AuthStatus.authenticated)),
    );
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState(status: AuthStatus.processing));
    final result = await _register(
      AuthCredentials(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(
        AuthState(status: AuthStatus.failure, errorMessage: failure.message),
      ),
      (_) => emit(const AuthState(status: AuthStatus.authenticated)),
    );
  }

  Future<void> _onPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState(status: AuthStatus.processing));
    final result = await _sendPasswordResetEmail(
      PasswordResetParams(event.email),
    );
    result.fold(
      (failure) => emit(
        AuthState(status: AuthStatus.failure, errorMessage: failure.message),
      ),
      (_) => emit(const AuthState(status: AuthStatus.passwordResetSent)),
    );
  }
}
