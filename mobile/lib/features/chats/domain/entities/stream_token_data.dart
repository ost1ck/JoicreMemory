class StreamTokenData {
  const StreamTokenData({
    required this.streamUserId,
    required this.fullName,
    this.token,
    this.message,
    this.avatarUrl,
  });

  final String streamUserId;
  final String fullName;
  final String? token;
  final String? message;
  final String? avatarUrl;
}
