class AuthIdentity {
  const AuthIdentity({
    required this.firebaseUid,
    required this.email,
    required this.fullName,
    required this.isDev,
    this.token,
  });

  final String firebaseUid;
  final String email;
  final String fullName;
  final bool isDev;
  final String? token;
}

