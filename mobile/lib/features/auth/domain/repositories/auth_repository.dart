import '../entities/app_user.dart';

abstract interface class AuthRepository {
  Future<AppUser?> restoreSession();
  Future<AppUser> signIn({required String email, required String password});
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  });
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Future<AppUser> updateProfile({
    required String fullName,
    required String bio,
    required String avatarUrl,
  });
}
