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

  AuthService();

  static const String loginPath =
      'https://keycloak01.kontur.io/auth/realms/kontur/protocol/openid-connect/token';
  static const String refreshPath =
      'https://keycloak01.kontur.io/auth/realms/kontur/protocol/openid-connect/token';

  static Future<User> loadUser() async {
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

  static Future<void> refreshToken(User user) async {
    final response = await http.post(
      Uri.parse(refreshPath),
      body: {
        'client_id': 'kontur_platform',
        'refresh_token': user.refreshToken,
        'grant_type': 'refresh_token'
      },
    );

    final statusType = (response.statusCode / 100).floor() * 100;
    switch (statusType) {
      case 200:
        final json = jsonDecode(response.body);
        final tokenType = json['token_type'];
        user.refreshToken = json['refresh_token'];
        user.accessToken = json['access_token'];
        saveUser(user);
        break;
      case 400:
      case 300:
      case 500:
      default:
        throw Exception('Error contacting the server!');
    }
  }

  Future<void> logout() async {
    stopRefreshCycle();
    await SecureStorageService.storage.delete(
      key: SecureStorageService.userKey,
    );
  }

  Future<User> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(loginPath),
      body: {
        'username': email,
        'password': password,
        'client_id': 'kontur_platform',
        'grant_type': 'password'
      },
    );

    final statusType = (response.statusCode / 100).floor() * 100;
    switch (statusType) {
      case 200:
        final json = jsonDecode(response.body);
        final user = User.fromJson({
          'id': json['session_state'],
          'accessToken': json['access_token'],
          'refreshToken': json['refresh_token'],
          'expiresIn': json['expires_in'],
          'refreshExpiresIn': json['refresh_expires_in'],
        });
        saveUser(user);
        startRefreshCycle(user);
        return user;
      case 400:
        final json = jsonDecode(response.body);
        throw LoginError();
      case 300:
      case 500:
      default:
        throw LoginError();
    }
  }

  bool keepTokenFresh = false;
  startRefreshCycle(User user) async {
    keepTokenFresh = true;
    while (keepTokenFresh) {
      // TODO - read duration from token
      await Future.delayed(const Duration(minutes: 3));
      refreshToken(user);
    }
  }

  stopRefreshCycle() {
    keepTokenFresh = false;
  }
}
