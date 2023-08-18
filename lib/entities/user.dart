class User {
  final String id;

  User({required this.id});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
      };
}
