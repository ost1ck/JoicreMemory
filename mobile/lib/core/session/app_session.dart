import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/app_user.dart';
import '../../features/auth/data/auth_api_service.dart';
import '../../features/auth/data/auth_identity.dart';
import '../../features/auth/data/auth_service.dart';
import '../../features/chats/data/chat_api_service.dart';
import '../../features/events/data/event_api_service.dart';
import '../../features/reports/data/report_api_service.dart';
import '../network/api_client.dart';

class AppSession extends ChangeNotifier {
  static const _darkThemeKey = 'joicrememory_dark_theme';

  final ApiClient apiClient = ApiClient();
  late final AuthService authService = AuthService();
  late final AuthApiService authApi = AuthApiService(apiClient);
  late final EventApiService eventApi = EventApiService(apiClient);
  late final ChatApiService chatApi = ChatApiService(apiClient);
  late final ReportApiService reportApi = ReportApiService(apiClient);

  AppUser? currentUser;
  bool isBusy = false;
  String? errorMessage;
  bool isDarkTheme = false;

  bool get isAuthenticated => currentUser != null;
  ThemeMode get themeMode => isDarkTheme ? ThemeMode.dark : ThemeMode.light;

  Future<void> initialize() async {
    await _loadThemeMode();
    await authService.initialize();

    final identity = await authService.currentIdentity();
    if (identity == null) {
      return;
    }

    try {
      await _syncIdentity(identity);
    } catch (error) {
      errorMessage = error.toString();
      apiClient.clearAuth();
      currentUser = null;
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    await _runBusy(() async {
      final identity = await authService.signIn(
        email: email,
        password: password,
      );
      await _syncIdentity(identity);
    });
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    await _runBusy(() async {
      await authService.register(
        email: email,
        password: password,
        fullName: fullName,
      );
      await authService.signOut();
      apiClient.clearAuth();
      currentUser = null;
    });
  }

  Future<void> signOut() async {
    await authService.signOut();
    apiClient.clearAuth();
    currentUser = null;
    notifyListeners();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _runBusy(() async {
      await authService.sendPasswordResetEmail(email);
    });
  }

  Future<void> updateProfile({
    required String fullName,
    required String bio,
    required String avatarUrl,
  }) async {
    await _runBusy(() async {
      currentUser = await authApi.updateMe(
        fullName: fullName,
        bio: bio,
        avatarUrl: avatarUrl.isEmpty ? null : avatarUrl,
      );
    });
  }

  Future<void> setDarkTheme(bool value) async {
    isDarkTheme = value;
    notifyListeners();

    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_darkThemeKey, value);
  }

  Future<void> _loadThemeMode() async {
    final preferences = await SharedPreferences.getInstance();
    isDarkTheme = preferences.getBool(_darkThemeKey) ?? false;
  }

  Future<void> _syncIdentity(AuthIdentity identity) async {
    apiClient.setAuth(identity);
    currentUser = await authApi.syncCurrentUser(
      email: identity.email,
      fullName: identity.fullName,
    );
    notifyListeners();
  }

  Future<void> _runBusy(Future<void> Function() action) async {
    isBusy = true;
    errorMessage = null;
    notifyListeners();

    try {
      await action();
    } catch (error) {
      errorMessage = error.toString();
      rethrow;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }
}
