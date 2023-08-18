import 'package:http/http.dart' as http;
import 'package:live_sensors/http_client/tokens.dart';
import 'dart:convert';

import 'errors.dart';


class OpenIdApi {
  Uri refreshPath;

  OpenIdApi({required this.refreshPath});

  Future<Tokens> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      refreshPath,
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
        return Tokens(
          sessionId: json['id'],
          expiresIn: json['expires_in'],
          refreshExpiresIn: json['refresh_expires_in'],
          refreshToken: json['refresh_token'],
          accessToken: json['access_token'],
        );
      case 400:
        final json = jsonDecode(response.body);
        throw BadCredentialsException(json['error_description'] ?? 'Unknown error');
      case 300:
      case 500:
      default:
        throw const AuthBackendUnavailableException();
    }
  }

  Future<Tokens> refreshTokens(String refreshToken) async {
    final response = await http.post(
      refreshPath,
      body: {
        'client_id': 'kontur_platform',
        'refresh_token': refreshToken,
        'grant_type': 'refresh_token'
      },
    );

    final statusType = (response.statusCode / 100).floor() * 100;
    switch (statusType) {
      case 200:
        final json = jsonDecode(response.body);
        return Tokens(
          sessionId: json['id'],
          expiresIn: json['expires_in'],
          refreshExpiresIn: json['refresh_expires_in'],
          refreshToken: json['refresh_token'],
          accessToken: json['access_token'],
        );
      case 400:
      case 300:
      case 500:
      default:
        throw Exception('Error contacting the server!');
    }
  }
}
