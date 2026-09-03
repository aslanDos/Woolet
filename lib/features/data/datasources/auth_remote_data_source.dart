abstract interface class AuthRemoteDataSource {
  bool get isSignedIn;

  Future<void> signIn({required String email, required String password});

  Future<void> register({required String email, required String password});

  Future<void> sendPasswordResetEmail(String email);
}
