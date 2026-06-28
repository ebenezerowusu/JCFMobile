import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcf_models/jcf_models.dart';

import '../../core/providers.dart';
import '../auth/auth_controller.dart';

class ProgramsRepository {
  ProgramsRepository(this._dio);
  final Dio _dio;

  Future<Paginated<Program>> list() async {
    final res = await _dio.get<Map<String, dynamic>>('programs/');
    return Paginated.fromJson(res.data!, Program.fromJson);
  }

  Future<Program> detail(String slug) async {
    final res = await _dio.get<Map<String, dynamic>>('programs/$slug/');
    return Program.fromJson(res.data!);
  }

  Future<({bool requiresPayment, Registration registration})> register(
    String slug, {
    required int quantity,
    int? tierId,
    Map<String, dynamic> answers = const {},
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      'programs/$slug/register/',
      data: {
        'quantity': quantity,
        'accommodation_tier_id': ?tierId,
        'answers': answers,
      },
    );
    return (
      requiresPayment: res.data!['requires_payment'] as bool? ?? false,
      registration: Registration.fromJson(res.data!['registration'] as Map<String, dynamic>),
    );
  }

  Future<({String authorizationUrl, String reference})> initializePayment(
      String reference) async {
    final res = await _dio.post<Map<String, dynamic>>(
      'registrations/$reference/initialize/',
    );
    return (
      authorizationUrl: res.data!['authorization_url'] as String,
      reference: res.data!['reference'] as String,
    );
  }

  Future<Registration> verify(String reference) async {
    final res = await _dio.post<Map<String, dynamic>>(
      'registrations/$reference/verify/',
    );
    return Registration.fromJson(res.data!['registration'] as Map<String, dynamic>);
  }

  Future<Paginated<Registration>> myRegistrations() async {
    final res = await _dio.get<Map<String, dynamic>>('registrations/mine/');
    return Paginated.fromJson(res.data!, Registration.fromJson);
  }
}

final programsRepositoryProvider = Provider<ProgramsRepository>(
  (ref) => ProgramsRepository(ref.watch(dioProvider)),
);

final programsListProvider = FutureProvider.autoDispose<Paginated<Program>>((ref) {
  ref.watch(authControllerProvider);
  return ref.watch(programsRepositoryProvider).list();
});

final programDetailProvider =
    FutureProvider.autoDispose.family<Program, String>((ref, slug) {
  ref.watch(authControllerProvider);
  return ref.watch(programsRepositoryProvider).detail(slug);
});

final myRegistrationsProvider =
    FutureProvider.autoDispose<Paginated<Registration>>((ref) {
  ref.watch(authControllerProvider);
  return ref.watch(programsRepositoryProvider).myRegistrations();
});
