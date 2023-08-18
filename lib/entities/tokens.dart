class Tokens {
  String sessionId;
  String refreshToken;
  String accessToken;
  int expiresIn;
  int refreshExpiresIn;

  Tokens({
    required this.sessionId,
    required this.refreshToken,
    required this.accessToken,
    required this.expiresIn,
    required this.refreshExpiresIn,
  });

  factory Tokens.fromJson(Map<String, dynamic> json) {
    return Tokens(
      sessionId: json['sessionId'],
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      expiresIn: json['expiresIn'],
      refreshExpiresIn: json['refreshExpiresIn'],
    );
  }

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'expiresIn': expiresIn,
        'refreshExpiresIn': refreshExpiresIn,
      };
}
