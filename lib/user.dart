class User {
  final String id;
  String accessToken;
  String refreshToken;
  int expiresIn;
  int refreshExpiresIn;

  User({
    required this.id,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.refreshExpiresIn,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      expiresIn: json['expiresIn'],
      refreshExpiresIn: json['refreshExpiresIn'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'expiresIn': expiresIn,
        'refreshExpiresIn': refreshExpiresIn,
      };
}
