class AppUser {
  const AppUser({
    required this.id,
    required this.firebaseUid,
    required this.email,
    required this.fullName,
    this.avatarUrl,
    this.bio,
    this.phone,
    this.streamUserId,
  });

  final String id;
  final String firebaseUid;
  final String email;
  final String fullName;
  final String? avatarUrl;
  final String? bio;
  final String? phone;
  final String? streamUserId;

  AppUser copyWith({
    String? fullName,
    String? avatarUrl,
    String? bio,
    String? phone,
  }) {
    return AppUser(
      id: id,
      firebaseUid: firebaseUid,
      email: email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      streamUserId: streamUserId,
    );
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
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
