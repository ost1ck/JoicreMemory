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
}
