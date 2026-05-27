import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../core/constants/app_config.dart';
import 'auth_identity.dart';

class AuthService {
  bool _firebaseReady = false;

  Future<void> initialize() async {
    if (AppConfig.useDevAuth) {
      return;
    }

    if (Firebase.apps.isEmpty) {
      await _initializeFirebase();
    }
    FirebaseAuth.instance.setLanguageCode('uk');
    _firebaseReady = true;
  }

  Future<AuthIdentity?> currentIdentity() async {
    if (AppConfig.useDevAuth || !_firebaseReady) {
      return null;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      return null;
    }

    return AuthIdentity(
      firebaseUid: user.uid,
      email: user.email!,
      fullName: user.displayName ?? user.email!,
      token: await user.getIdToken(),
      isDev: false,
    );
  }

  Future<AuthIdentity> signIn({
    required String email,
    required String password,
  }) async {
    if (AppConfig.useDevAuth) {
      return _devIdentity(email: email);
    }

    final UserCredential credential;

    try {
      credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw Exception(_firebaseAuthMessage(error));
    }

    final user = credential.user;
    if (user == null || user.email == null) {
      throw Exception('Не вдалося увійти.');
    }

    return AuthIdentity(
      firebaseUid: user.uid,
      email: user.email!,
      fullName: user.displayName ?? user.email!,
      token: await user.getIdToken(),
      isDev: false,
    );
  }

  Future<AuthIdentity> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    if (AppConfig.useDevAuth) {
      return _devIdentity(email: email, fullName: fullName);
    }

    final UserCredential credential;

    try {
      credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw Exception(_firebaseAuthMessage(error));
    }

    await credential.user?.updateDisplayName(fullName);
    final user = credential.user;

    if (user == null || user.email == null) {
      throw Exception('Не вдалося створити користувача.');
    }

    return AuthIdentity(
      firebaseUid: user.uid,
      email: user.email!,
      fullName: fullName,
      token: await user.getIdToken(),
      isDev: false,
    );
  }

  Future<void> signOut() async {
    if (!AppConfig.useDevAuth && _firebaseReady) {
      await FirebaseAuth.instance.signOut();
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    if (AppConfig.useDevAuth) {
      throw Exception('Скидання пароля доступне тільки через Firebase Auth.');
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (error) {
      throw Exception(_firebaseAuthMessage(error));
    }
  }

  AuthIdentity _devIdentity({required String email, String? fullName}) {
    final uid = email
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');

    return AuthIdentity(
      firebaseUid: uid.isEmpty ? 'dev-user' : uid,
      email: email,
      fullName: fullName?.trim().isNotEmpty == true ? fullName!.trim() : email,
      isDev: true,
    );
  }

  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp();
    } catch (_) {
      await Firebase.initializeApp(options: _firebaseOptionsFromEnv());
    }
  }

  FirebaseOptions _firebaseOptionsFromEnv() {
    final apiKey = dotenv.env['FIREBASE_API_KEY'];
    final appId = dotenv.env['FIREBASE_APP_ID'];
    final messagingSenderId = dotenv.env['FIREBASE_MESSAGING_SENDER_ID'];
    final projectId = dotenv.env['FIREBASE_PROJECT_ID'];

    if ([apiKey, appId, messagingSenderId, projectId]
        .any((value) => value == null || value.startsWith('your-'))) {
      throw Exception(
        'Firebase config is missing. Fill mobile/.env or set USE_DEV_AUTH=true.',
      );
    }

    return FirebaseOptions(
      apiKey: apiKey!,
      appId: appId!,
      messagingSenderId: messagingSenderId!,
      projectId: projectId!,
      authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN'],
      storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET'],
      iosBundleId: dotenv.env['FIREBASE_IOS_BUNDLE_ID'],
      androidClientId: dotenv.env['FIREBASE_ANDROID_CLIENT_ID'],
      iosClientId: dotenv.env['FIREBASE_IOS_CLIENT_ID'],
    );
  }

  String _firebaseAuthMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'Ця пошта вже використовується.';
      case 'invalid-email':
        return 'Некоректна адреса пошти.';
      case 'weak-password':
        return 'Пароль занадто слабкий.';
      case 'user-not-found':
        return 'Користувача з такою поштою не знайдено.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Невірна пошта або пароль.';
      case 'network-request-failed':
        return 'Немає зʼєднання з Firebase.';
      default:
        return error.message ?? 'Помилка Firebase Auth.';
    }
  }
}
