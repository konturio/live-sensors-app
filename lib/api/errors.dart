class ApiServiceException implements Exception {
  final String message;
  const ApiServiceException(this.message);
  @override
  String toString() => 'ApiServiceException: $message';
}

class UnauthorizedException extends ApiServiceException {
  UnauthorizedException([super.message = 'Unauthorized']);
}

class ApiBackendException extends ApiServiceException {
  ApiBackendException([super.message = 'ApiBackendException']);
}

class ApiClientException extends ApiServiceException {
  ApiClientException([super.message = 'ApiClientException']);
}