import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcf_models/jcf_models.dart';

import '../../core/providers.dart';
import '../auth/auth_controller.dart';

class LessonsRepository {
  LessonsRepository(this._dio);

  final Dio _dio;

  Future<Paginated<Teaching>> list({String? search}) async {
    final res = await _dio.get<Map<String, dynamic>>(
      'teachings/',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    return Paginated.fromJson(res.data!, Teaching.fromJson);
  }

  Future<Teaching> detail(String slug) async {
    final res = await _dio.get<Map<String, dynamic>>('teachings/$slug/');
    return Teaching.fromJson(res.data!);
  }
}

final lessonsRepositoryProvider = Provider<LessonsRepository>(
  (ref) => LessonsRepository(ref.watch(dioProvider)),
);

/// Lesson list. Re-fetches when auth changes (premium unlocks on login).
final lessonsListProvider =
    FutureProvider.autoDispose<Paginated<Teaching>>((ref) {
  ref.watch(authControllerProvider);
  return ref.watch(lessonsRepositoryProvider).list();
});

final lessonDetailProvider =
    FutureProvider.autoDispose.family<Teaching, String>((ref, slug) {
  ref.watch(authControllerProvider);
  return ref.watch(lessonsRepositoryProvider).detail(slug);
});
