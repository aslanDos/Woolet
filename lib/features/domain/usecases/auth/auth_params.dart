import 'package:equatable/equatable.dart';

class AuthCredentials extends Equatable {
  const AuthCredentials({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class PasswordResetParams extends Equatable {
  const PasswordResetParams(this.email);

  final String email;

  @override
  List<Object?> get props => [email];
}
