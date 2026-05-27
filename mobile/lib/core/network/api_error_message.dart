import 'package:dio/dio.dart';

String apiErrorMessage(Object error) {
  if (error is DioException && error.error != null) {
    return error.error.toString();
  }

  return error.toString().replaceFirst('Exception: ', '');
}

