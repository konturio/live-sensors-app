import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:live_sensors/http_client/tokens.dart';
import 'package:live_sensors/http_client/utils.dart';
import 'errors.dart';
import 'open_id_api.dart';

class OpenIdClient extends http.BaseClient {
  final http.Client _inner;
  final OpenIdApi openIdApi;
  Tokens? tokens;

  OpenIdClient(this.openIdApi, {http.Client? inner, this.tokens})
      : _inner = inner ?? http.Client();

  String _getAuthString() {
    String? accessToken = tokens?.accessToken;
    if (accessToken != null) {
      return 'Bearer $accessToken';
    }
    throw ErrorDescription('Access token missing');
  }

  Future? _updateTokensActiveRequest;
  _updateTokens() async {
    if (_updateTokensActiveRequest != null) {
      return _updateTokensActiveRequest;
    } else {
      String? refreshToken = tokens?.refreshToken;
      if (refreshToken != null) {
        _updateTokensActiveRequest = openIdApi.refreshTokens(refreshToken);
      } else {
        throw ErrorDescription('Refresh token missing');
      }
    }
  }

  /// Add middleware for process token expiration case
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request,
      {num attempt = 0}) async {
    request.headers['Authorization'] = _getAuthString();
    try {
      final response = await _inner.send(request);
      if (response.statusCode == 401) {
        throw AccessTokenExpiredException();
      }
      return response;
    } on AccessTokenExpiredException {
      if (attempt > 5) {
        throw TooMuchAuthAttemptsException();
      }
      try {
        tokens = await _updateTokens();
      } catch (e) {
        // TODO: check exact error code for give user better feedback
        throw RefreshTokenExpiredException();
      }
      return send(cloneRequest(request), attempt: attempt + 1);
    } on RefreshTokenExpiredException {
      logout();
      rethrow;
    } on TooMuchAuthAttemptsException {
      logout();
      rethrow;
    }
  }

  /// Refresh cycle allow us update token before 401 error happens
  Timer? preRefresh;
  startRefreshCycle() async {
    // TODO - read duration from token;
    preRefresh = Timer.periodic(const Duration(minutes: 3), (timer) {
      _updateTokens();
    });
  }

  stopRefreshCycle() {
    preRefresh?.cancel();
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    tokens = await openIdApi.login(email: email, password: password);
    startRefreshCycle();
  }

  logout() {
    tokens = null;
    stopRefreshCycle();
  }
}
