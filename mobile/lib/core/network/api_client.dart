import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/app_config.dart';
import '../../features/auth/domain/entities/auth_identity.dart';

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
        onRequest: (options, handler) async {
          try {
            if (options.headers.containsKey('Authorization') &&
                tokenProvider != null) {
              final token = await tokenProvider!();
              if (token == null) {
                handler.reject(
                  DioException(
                    requestOptions: options,
                    response: Response(
                      requestOptions: options,
                      statusCode: 401,
                    ),
                  ),
                );
                return;
              }
              options.headers['Authorization'] = 'Bearer $token';
            }
            handler.next(options);
          } catch (error) {
            handler.reject(DioException(requestOptions: options, error: error));
          }
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: false,
          responseBody: false,
          requestHeader: false,
          responseHeader: false,
        ),
      );
    }
  }

  final Dio dio;
  Future<String?> Function()? tokenProvider;

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
}
