import 'package:dio/dio.dart';

import 'token_store.dart';

/// Injects the access token as a Bearer header, and transparently refreshes it
/// once on a 401 using the stored refresh token.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor(this._tokens, {required this.baseUrl});

  final TokenStore _tokens;
  final String baseUrl;

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

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final alreadyRetried = err.requestOptions.extra['__retried'] == true;
    if (err.response?.statusCode != 401 || alreadyRetried) {
      return handler.next(err);
    }

    final refresh = await _tokens.refreshToken;
    if (refresh == null || refresh.isEmpty) {
      return handler.next(err);
    }

    final newAccess = await _refresh(refresh);
    if (newAccess == null) {
      await _tokens.clear();
      return handler.next(err);
    }

    final opts = err.requestOptions;
    opts.extra['__retried'] = true;
    opts.headers['Authorization'] = 'Bearer $newAccess';
    try {
      final retried = await Dio().fetch<dynamic>(opts);
      return handler.resolve(retried);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  /// Calls the refresh endpoint with a bare Dio (no interceptor → no loop).
  Future<String?> _refresh(String refresh) async {
    try {
      final res = await Dio().post<Map<String, dynamic>>(
        '${baseUrl}auth/refresh/',
        data: {'refresh': refresh},
      );
      final access = res.data?['access'] as String?;
      if (access != null && access.isNotEmpty) {
        await _tokens.save(access: access, refresh: refresh);
        return access;
      }
    } on DioException {
      // fall through to failure
    }
    return null;
  }
}
