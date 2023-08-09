class AuthServiceError extends Error {}

class NotAuthorized extends AuthServiceError {}

class NeverAuthorized extends AuthServiceError {}

class LoginError extends AuthServiceError {}

class BadCredentials implements Exception {
  final String message;

  const BadCredentials(this.message);

  @override
  String toString() => message;
}
