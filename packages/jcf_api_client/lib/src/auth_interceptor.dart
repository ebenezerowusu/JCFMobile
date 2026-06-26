import 'package:dio/dio.dart';

import 'token_store.dart';

/// Injects the JWT access token as a Bearer header on every request, and
/// logs requests in debug. Token refresh (on 401) is wired in a later phase.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokens);

  final TokenStore _tokens;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokens.accessToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
