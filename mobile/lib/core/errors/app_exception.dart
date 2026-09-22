enum FailureKind {
  network,
  unauthorized,
  forbidden,
  validation,
  server,
  unknown,
}

/// UI-independent error contract shared by repositories and controllers.
class AppException implements Exception {
  const AppException(this.kind, this.message);
  final FailureKind kind;
  final String message;
  @override
  String toString() => message;
}
