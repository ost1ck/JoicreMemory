import '../errors/app_exception.dart';

String apiErrorMessage(Object error) {
  if (error is AppException) return error.message;
  return error.toString().replaceFirst('Exception: ', '');
}
