import '../entities/auth_identity.dart';

abstract interface class IdentityProvider {
  Future<void> initialize();

  Future<AuthIdentity?> currentIdentity();

  Future<AuthIdentity> signIn({
    required String email,
    required String password,
  });

  Future<AuthIdentity> register({
    required String email,
    required String password,
    required String fullName,
  });

  Future<void> signOut();

  Future<void> sendPasswordResetEmail(String email);
}
