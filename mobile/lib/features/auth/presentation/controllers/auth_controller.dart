import 'package:flutter/foundation.dart';
import '../../../../core/network/api_error_message.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._repository);
  final AuthRepository _repository;
  AppUser? currentUser;
  bool isBusy = false;
  bool isInitializing = true;
  String? errorMessage;
  bool restorationFailed = false;
  bool get isAuthenticated => currentUser != null;

  Future<void> initialize() async {
    if (isBusy) return;
    isBusy = true;
    errorMessage = null;
    restorationFailed = false;
    notifyListeners();
    try {
      currentUser = await _repository.restoreSession();
    } catch (error) {
      currentUser = null;
      restorationFailed = true;
      errorMessage = apiErrorMessage(error);
    } finally {
      isInitializing = false;
      isBusy = false;
      notifyListeners();
    }
  }

  Future<void> signIn({required String email, required String password}) =>
      _runBusy(() async {
        currentUser = await _repository.signIn(
          email: email,
          password: password,
        );
      });

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) => _runBusy(() async {
    await _repository.register(
      email: email,
      password: password,
      fullName: fullName,
    );
    currentUser = null;
  });

  Future<void> signOut() => _runBusy(() async {
    await _repository.signOut();
    currentUser = null;
  });

  Future<void> sendPasswordResetEmail(String email) =>
      _runBusy(() => _repository.sendPasswordResetEmail(email));

  Future<void> updateProfile({
    required String fullName,
    required String bio,
    required String avatarUrl,
  }) => _runBusy(() async {
    currentUser = await _repository.updateProfile(
      fullName: fullName,
      bio: bio,
      avatarUrl: avatarUrl,
    );
  });

  Future<void> _runBusy(Future<void> Function() action) async {
    if (isBusy) return;
    isBusy = true;
    errorMessage = null;
    restorationFailed = false;
    notifyListeners();
    try {
      await action();
    } catch (error) {
      errorMessage = apiErrorMessage(error);
      rethrow;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }
}
