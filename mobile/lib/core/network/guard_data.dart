import 'package:dio/dio.dart';
import '../errors/app_exception.dart';

Future<T> guardData<T>(Future<T> Function() action) async {
  try {
    return await action();
  } on AppException {
    rethrow;
  } on DioException catch (error) {
    final status = error.response?.statusCode;
    if (error.requestOptions.path == '/events/drafts' &&
        (status == 404 || status == 405)) {
      throw const AppException(FailureKind.server, 'draft_server_unavailable');
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      throw const AppException(
        FailureKind.network,
        'Сервер не відповів вчасно. Спробуй ще раз.',
      );
    }
    if (error.type == DioExceptionType.connectionError) {
      throw const AppException(
        FailureKind.network,
        'Немає з’єднання із сервером. Перевір інтернет і спробуй ще раз.',
      );
    }
    if (status == 401) {
      throw const AppException(
        FailureKind.unauthorized,
        'Сесія завершилася. Увійди ще раз.',
      );
    }
    if (status == 403) {
      throw const AppException(
        FailureKind.forbidden,
        'Недостатньо прав для цієї дії.',
      );
    }
    if (status != null && status >= 500) {
      throw const AppException(
        FailureKind.server,
        'Сервіс тимчасово недоступний. Спробуй пізніше.',
      );
    }
    final data = error.response?.data;
    throw AppException(
      FailureKind.validation,
      data is Map && data['message'] is String
          ? data['message'] as String
          : 'Не вдалося виконати запит.',
    );
  } on FormatException {
    throw const AppException(
      FailureKind.server,
      'Сервер повернув некоректні дані.',
    );
  } on TypeError {
    throw const AppException(
      FailureKind.server,
      'Сервер повернув некоректні дані.',
    );
  }
}
