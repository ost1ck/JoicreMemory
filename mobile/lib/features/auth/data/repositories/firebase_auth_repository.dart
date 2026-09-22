import '../../../../core/network/api_client.dart';
import '../../../../core/network/guard_data.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/auth_identity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/identity_provider.dart';
import '../datasources/auth_api_service.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._identity, this._profiles, this._client);
  final IdentityProvider _identity;
  final AuthApiService _profiles;
  final ApiClient _client;

  @override
  Future<AppUser?> restoreSession() => guardData(() async {
    await _identity.initialize();
    final identity = await _identity.currentIdentity();
    return identity == null ? null : await _sync(identity);
  });

  @override
  Future<AppUser> signIn({required String email, required String password}) =>
      guardData(() async {
        await _identity.initialize();
        final identity = await _identity.signIn(
          email: email,
          password: password,
        );
        return _sync(identity);
      });

  Future<AppUser> _sync(AuthIdentity identity) async {
    _client.setAuth(identity);
    try {
      return await _profiles.syncCurrentUser(
        email: identity.email,
        fullName: identity.fullName,
      );
    } catch (_) {
      _client.clearAuth();
      rethrow;
    }
  }

  @override
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) => guardData(() async {
    await _identity.initialize();
    await _identity.register(
      email: email,
      password: password,
      fullName: fullName,
    );
    await signOut();
  });

  @override
  Future<void> signOut() async {
    await _identity.signOut();
    _client.clearAuth();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) => guardData(() async {
    await _identity.initialize();
    await _identity.sendPasswordResetEmail(email);
  });

  @override
  Future<AppUser> updateProfile({
    required String fullName,
    required String bio,
    required String avatarUrl,
  }) => guardData(
    () => _profiles.updateMe(
      fullName: fullName,
      bio: bio,
      avatarUrl: avatarUrl.isEmpty ? null : avatarUrl,
    ),
  );
}
