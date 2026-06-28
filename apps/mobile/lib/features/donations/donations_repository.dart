import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcf_models/jcf_models.dart';

import '../../core/providers.dart';

class DonationsRepository {
  DonationsRepository(this._dio);
  final Dio _dio;

  Future<Paginated<Cause>> causes() async {
    final res = await _dio.get<Map<String, dynamic>>('causes/');
    return Paginated.fromJson(res.data!, Cause.fromJson);
  }

  /// Returns the Paystack authorization_url + reference.
  Future<({String authorizationUrl, String reference})> initialize({
    required num amount,
    required String email,
    int? causeId,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      'donations/initialize/',
      data: {'amount': amount, 'email': email, 'cause_id': ?causeId},
    );
    return (
      authorizationUrl: res.data!['authorization_url'] as String,
      reference: res.data!['reference'] as String,
    );
  }

  Future<bool> verify({required String reference, int? causeId}) async {
    final res = await _dio.post<Map<String, dynamic>>(
      'donations/verify/',
      data: {'reference': reference, 'cause_id': ?causeId},
    );
    final status = res.data?['status'] as String?;
    return status == 'success' || status == 'already_processed';
  }
}

final donationsRepositoryProvider = Provider<DonationsRepository>(
  (ref) => DonationsRepository(ref.watch(dioProvider)),
);

final causesListProvider = FutureProvider.autoDispose<Paginated<Cause>>(
  (ref) => ref.watch(donationsRepositoryProvider).causes(),
);
