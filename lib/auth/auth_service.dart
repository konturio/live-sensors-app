import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:live_sensors/logger/logger.dart';
import 'package:live_sensors/user/user.dart';
import 'package:flutter/widgets.dart';

import 'auth_service_error.dart';

class SecureStorageService {
  static const storage = FlutterSecureStorage();
  static const String userKey = 'user';
}

class AuthService {
  final Logger logger = Logger();
  bool isAuthorized = false;
  AuthService();

  restoreSession() async {
    try {
      User user = await _loadUser();
      isAuthorized = true;
      return user;
    } on NeverAuthorized {
      isAuthorized = false;
      return null;
    }
  }

  static Future<User> _loadUser() async {
    final json = await SecureStorageService.storage.read(
      key: SecureStorageService.userKey,
    );
    if (json != null) {
      return User.fromJson(jsonDecode(json));
    } else {
      throw NeverAuthorized();
    }
  }

  static void saveUser(User user) async {
    WidgetsFlutterBinding.ensureInitialized();
    await SecureStorageService.storage.write(
      key: SecureStorageService.userKey,
      value: jsonEncode(user.toJson()),
    );
  }

  Future<void> logout() async {

  }

  Future<User> login({
    required String email,
    required String password,
  }) async {
   
  }
}
