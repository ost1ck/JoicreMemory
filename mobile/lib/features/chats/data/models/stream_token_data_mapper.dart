import '../../domain/entities/stream_token_data.dart';

class StreamTokenDataMapper {
  static StreamTokenData fromJson(Map<String, dynamic> json) {
    return StreamTokenData(
      streamUserId: json['streamUserId'] as String,
      fullName: json['fullName'] as String? ?? 'Користувач',
      token: json['token'] as String?,
      message: json['message'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}
