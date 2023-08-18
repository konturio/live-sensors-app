class Tokens {
  String sessionId;
  String refreshToken;
  String accessToken;
  String expiresIn;
  String refreshExpiresIn;

  Tokens({
    required this.sessionId,
    required this.refreshToken,
    required this.accessToken,
    required this.expiresIn,
    required this.refreshExpiresIn,
  });
}