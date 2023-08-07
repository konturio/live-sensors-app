class AppConfig {
  late String email;
  late String password;

  read() {
    email = const String.fromEnvironment('email');
    password = const String.fromEnvironment('password');
    if (email.isEmpty || password.isEmpty) {
      throw Exception("Setup .env first");
    }
    return this;
  }
}
