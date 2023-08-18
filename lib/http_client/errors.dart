class AuthException implements Exception {
  final String? message;
  const AuthException([this.message]);
  @override
  String toString() =>
      message != null ? 'AuthException: $message' : 'AuthException';
}

class AccessTokenExpiredException extends AuthException {}

class RefreshTokenExpiredException extends AuthException {}

class TooMuchAuthAttemptsException extends AuthException {}

class BadCredentialsException extends AuthException {
  const BadCredentialsException([super.message]);
}

class AuthBackendUnavailableException extends AuthException {
  const AuthBackendUnavailableException([super.message]);
}

