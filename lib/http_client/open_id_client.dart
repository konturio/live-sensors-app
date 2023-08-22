import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:live_sensors/entities/tokens.dart';
import 'package:live_sensors/http_client/utils.dart';
import 'errors.dart';
import 'open_id_api.dart';

class OpenIdClient extends http.BaseClient {
  final http.Client _inner;
  final OpenIdApi openIdApi;
  final void Function(Tokens) postLogin;
  final void Function() postLogout;
  final void Function(Tokens) postRefresh;
  Tokens? _tokens;

  OpenIdClient(
    this.openIdApi, {
    http.Client? inner,
    required this.postLogin,
    required this.postLogout,
    required this.postRefresh,
  }) : _inner = inner ?? http.Client();

  static _getAuthString(Tokens tokens) {
    String? accessToken = tokens.accessToken;
    return 'Bearer $accessToken';
  }

  // Tokens getter / setter
  set tokens(Tokens t) {
    _tokens = t;
  }

  Tokens get tokens {
    Tokens? t = _tokens;
    if (t != null) {
      return t;
    }
    throw Error();
  }

  clearTokens() {
    _tokens = null;
  }

  /// Debounce update token requests.
  /// All request that comes when update request active - wait this request
  /// Instead of create new one
  Future? _updateTokensActiveRequest;
  _tokensUpdated() async {
    if (_updateTokensActiveRequest != null) {
      return _updateTokensActiveRequest;
    } else {
      String? refreshToken = tokens?.refreshToken;
      if (refreshToken != null) {
        _updateTokensActiveRequest = _updateTokens(refreshToken);
      } else {
        throw ErrorDescription('Refresh token missing');
      }
    }
  }

  Future<Tokens> _updateTokens(refreshToken) async {
    try {
      Tokens refreshedTokens = await openIdApi.refreshTokens(refreshToken);
      tokens = refreshedTokens;
      postRefresh(refreshedTokens);
      return refreshedTokens;
    } on RefreshTokenExpiredException {
      logout();
      rethrow;
    }
  }

  /// Add middleware for process token expiration case
  @override
  Future<http.StreamedResponse> send(
    http.BaseRequest request, {
    num attempt = 0,
  }) async {
    request.headers['Authorization'] = _getAuthString(tokens);
    try {
      final response = await _inner.send(request);
      if (response.statusCode == 401) {
        throw AccessTokenExpiredException();
      }
      return response;
    } on AccessTokenExpiredException {
      if (attempt > 5) {
        throw TooMuchAuthAttemptsException();
      } else {
        tokens = await _tokensUpdated();
        return send(cloneRequest(request), attempt: attempt + 1);
      }
    } on TooMuchAuthAttemptsException {
      logout();
      rethrow;
    }
  }

  /// Login methods
  Future<void> loginByPassword({
    required String email,
    required String password,
  }) async {
    tokens = await openIdApi.login(email: email, password: password);
    _postLogin(tokens);
  }

  loginByTokens(Tokens t) {
    tokens = t;
    _postLogin(t);
  }

  _postLogin(Tokens tokens) {
    startRefreshCycle();
    postLogin(tokens);
  }

  logout() {
    clearTokens();
    stopRefreshCycle();
    postLogout();
  }

  /// Refresh cycle allow us update token before 401 error happens
  Timer? preRefresh;
  startRefreshCycle() async {
    // TODO - read duration from token;
    preRefresh = Timer.periodic(const Duration(minutes: 3), (timer) {
      _tokensUpdated();
    });
  }

  stopRefreshCycle() {
    preRefresh?.cancel();
  }
}
