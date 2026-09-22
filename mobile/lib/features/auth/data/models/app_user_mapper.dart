import '../../domain/entities/app_user.dart';

class AppUserMapper {
  static AppUser fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      firebaseUid: json['firebaseUid'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      bio: json['bio'] as String?,
      phone: json['phone'] as String?,
      streamUserId: json['streamUserId'] as String?,
    );
  }
}
