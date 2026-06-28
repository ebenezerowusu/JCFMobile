import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcf_api_client/jcf_api_client.dart';
import 'package:jcf_models/jcf_models.dart';

import '../../core/providers.dart';

class AuthRepository {
  AuthRepository(this._client);

  final JcfApiClient _client;
  Dio get _dio => _client.dio;

  /// Ask the backend to email a one-time code to the matching member.
  Future<void> requestCode(String identifier) async {
    await _dio.post('auth/request-code/', data: {'identifier': identifier});
  }

  /// Verify the code; on success tokens are persisted and the member returned.
  Future<Member> verifyCode(String identifier, String code) async {
    final res = await _dio.post<Map<String, dynamic>>(
      'auth/verify-code/',
      data: {'identifier': identifier, 'code': code},
    );
    final session = AuthSession.fromJson(res.data!);
    await _client.tokens.save(access: session.access, refresh: session.refresh);
    return session.member;
  }

  /// Returns the current member if a valid token is stored, else null.
  Future<Member?> currentMember() async {
    final token = await _client.tokens.accessToken;
    if (token == null || token.isEmpty) return null;
    try {
      final res = await _dio.get<Map<String, dynamic>>('auth/me/');
      return Member.fromJson(res.data!);
    } on DioException {
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _dio.delete('auth/me/');
    } on DioException {
      // ignore — clear locally regardless
    }
    await _client.tokens.clear();
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(apiClientProvider)),
);
