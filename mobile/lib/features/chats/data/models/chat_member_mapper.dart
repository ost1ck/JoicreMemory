import '../../domain/entities/chat_member.dart';

class ChatMemberMapper {
  static ChatMember fromJson(Map<String, dynamic> json) {
    return ChatMember(
      userId: json['userId'] as String,
      fullName: json['fullName'] as String,
      role: json['role'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      streamUserId: json['streamUserId'] as String?,
    );
  }
}
