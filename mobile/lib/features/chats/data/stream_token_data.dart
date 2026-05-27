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

  factory StreamTokenData.fromJson(Map<String, dynamic> json) {
    return StreamTokenData(
      streamUserId: json['streamUserId'] as String,
      fullName: json['fullName'] as String? ?? 'Користувач',
      token: json['token'] as String?,
      message: json['message'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}
