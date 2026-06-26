import 'package:dio/dio.dart';

import 'auth_interceptor.dart';
import 'token_store.dart';

/// Thin wrapper around [Dio] configured for the JCF API.
///
/// The base URL points at the Django backend's mobile API namespace
/// (e.g. `https://<host>/api/mobile/v1/`). All DB access is server-side —
/// the client never talks to Postgres directly (product doc §2, critical rule).
class JcfApiClient {
  JcfApiClient({
    required String baseUrl,
    TokenStore? tokenStore,
    Dio? dio,
  })  : tokens = tokenStore ?? TokenStore(),
        dio = dio ?? Dio() {
    this.dio.options
      ..baseUrl = baseUrl
      ..connectTimeout = const Duration(seconds: 15)
      ..receiveTimeout = const Duration(seconds: 20)
      ..headers['Accept'] = 'application/json';
    this.dio.interceptors.add(AuthInterceptor(tokens));
  }

  final Dio dio;
  final TokenStore tokens;
}
