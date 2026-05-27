import '../../../core/network/api_client.dart';
import 'app_user.dart';

class AuthApiService {
  const AuthApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<AppUser> syncCurrentUser({
    required String email,
    required String fullName,
  }) async {
    final response = await _apiClient.dio.post(
      '/auth/sync',
      data: {'email': email, 'fullName': fullName},
    );

    return AppUser.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<AppUser> getMe() async {
    final response = await _apiClient.dio.get('/users/me');
    return AppUser.fromJson(response.data['data'] as Map<String, dynamic>);
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

    return AppUser.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}
