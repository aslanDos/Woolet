part of 'auth_bloc.dart';

enum AuthStatus {
  initial,
  processing,
  authenticated,
  passwordResetSent,
  failure,
}

final class AuthState extends Equatable {
  const AuthState({this.status = AuthStatus.initial, this.errorMessage});

  final AuthStatus status;
  final String? errorMessage;

  bool get isProcessing => status == AuthStatus.processing;

  @override
  List<Object?> get props => [status, errorMessage];
}
