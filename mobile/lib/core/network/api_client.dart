import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/app_config.dart';
import '../../features/auth/data/auth_identity.dart';

class ApiClient {
  ApiClient()
      : dio = Dio(
          BaseOptions(
            baseUrl: AppConfig.apiBaseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 20),
            headers: {'Content-Type': 'application/json'},
          ),
        ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              type: error.type,
              error: _friendlyError(error),
            ),
          );
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
        ),
      );
    }
  }

  final Dio dio;

  void setAuth(AuthIdentity identity) {
    dio.options.headers.remove('Authorization');
    dio.options.headers.remove('x-dev-firebase-uid');
    dio.options.headers.remove('x-dev-email');

    if (identity.isDev) {
      dio.options.headers['x-dev-firebase-uid'] = identity.firebaseUid;
      dio.options.headers['x-dev-email'] = identity.email;
      return;
    }

    if (identity.token != null) {
      dio.options.headers['Authorization'] = 'Bearer ${identity.token}';
    }
  }

  void clearAuth() {
    dio.options.headers.remove('Authorization');
    dio.options.headers.remove('x-dev-firebase-uid');
    dio.options.headers.remove('x-dev-email');
  }

  static String _friendlyError(DioException error) {
    if (error.type == DioExceptionType.connectionError) {
      return 'Сервер недоступний. Перевір, що backend запущений.';
    }

    final data = error.response?.data;
    if (data is Map<String, dynamic> && data['message'] is String) {
      return data['message'] as String;
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Сервер відповідає занадто довго. Спробуй ще раз.';
    }

    if (error.error != null) {
      return error.error.toString().replaceFirst('Exception: ', '');
    }

    return 'Не вдалося виконати запит.';
  }
}
