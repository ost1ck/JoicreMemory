class ChatMember {
  const ChatMember({
    required this.userId,
    required this.fullName,
    required this.role,
    this.avatarUrl,
    this.streamUserId,
  });

  final String userId;
  final String fullName;
  final String role;
  final String? avatarUrl;
  final String? streamUserId;

  bool get isOrganizer => role == 'organizer';

  factory ChatMember.fromJson(Map<String, dynamic> json) {
    return ChatMember(
      userId: json['userId'] as String,
      fullName: json['fullName'] as String,
      role: json['role'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      streamUserId: json['streamUserId'] as String?,
    );
  }
}
