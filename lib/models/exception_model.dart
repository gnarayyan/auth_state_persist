class UnAuthorizedException implements Exception {
  final String message;

  const UnAuthorizedException(this.message);

  @override
  String toString() {
    return "CustomException: $message";
  }
}

class InvalidTokenException implements Exception {
  final String message;

  const InvalidTokenException(this.message);

  @override
  String toString() {
    return "InvalidTokenException: $message";
  }
}
