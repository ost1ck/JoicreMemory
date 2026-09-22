import 'package:dio/dio.dart';
import '../models/app_user_mapper.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/app_user.dart';

class AuthApiService {
  const AuthApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<AppUser> syncCurrentUser({
    required String email,
    required String fullName,
  }) async {
    // Profile synchronization is an upsert, so one retry is safe even if
    // the first response was lost. Never retry event creation or chat writes.
    for (var attempt = 0; ; attempt++) {
      try {
        final response = await _apiClient.dio.post(
          '/auth/sync',
          data: {'email': email, 'fullName': fullName},
          options: Options(receiveTimeout: const Duration(seconds: 60)),
        );
        return AppUserMapper.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      } on DioException catch (error) {
        final transient =
            error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.connectionError ||
            [502, 503, 504].contains(error.response?.statusCode);
        if (attempt != 0 || !transient) rethrow;
      }
    }
  }

  Future<AppUser> getMe() async {
    final response = await _apiClient.dio.get('/users/me');
    return AppUserMapper.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  Future<AppUser> updateMe({
    String? fullName,
    String? avatarUrl,
    String? bio,
    String? phone,
  }) async {
    final response = await _apiClient.dio.patch(
      '/users/me',
      data: {
        if (fullName != null) 'fullName': fullName,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        if (bio != null) 'bio': bio,
        if (phone != null) 'phone': phone,
      },
    );

    return AppUserMapper.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }
}
