import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/providers.dart';
import 'learning_models.dart';

/// The unfiltered first page, kept on disk so the hub is readable on a cold
/// start with no network. Keyed per member so signing in as someone else
/// never shows the previous member's progress.
const _cachePrefix = 'learning.continue.v1';

const cacheFreshness = Duration(hours: 6);

class CachedLearningPayload {
  const CachedLearningPayload(this.payload, this.cachedAt);

  final ContinueLearningPayload payload;
  final DateTime cachedAt;

  bool get isStale => DateTime.now().difference(cachedAt) > cacheFreshness;
}

class LearningRepository {
  LearningRepository(this._dio);

  final Dio _dio;

  Future<ContinueLearningPayload> hub({
    LearningFilter filter = const LearningFilter(),
    String? courseCursor,
    String? lessonCursor,
    int limit = 20,
  }) async {
    final params = <String, String>{
      ...filter.toParams(),
      'limit': '$limit',
    };
    if (courseCursor != null) params['course_cursor'] = courseCursor;
    if (lessonCursor != null) params['lesson_cursor'] = lessonCursor;

    final res = await _dio.get<Map<String, dynamic>>(
      'learning/continue/',
      queryParameters: params,
    );
    final payload = ContinueLearningPayload.fromJson(res.data ?? const {});
    if (courseCursor == null && lessonCursor == null && filter.isEmpty) {
      await _writeCache(res.data);
    }
    return payload;
  }

  /// Reports how far through a lesson the member is. The server decides
  /// what that means for completion; this only sends what was observed.
  Future<LessonSummary?> reportProgress(
    int lessonId, {
    required int percent,
    int? positionSeconds,
  }) async {
    await _dio.post<Map<String, dynamic>>(
      'learning/lessons/$lessonId/progress/',
      data: <String, Object>{
        'percent': percent,
        if (positionSeconds != null)
          'position_seconds': positionSeconds as Object,
      },
    );
    return null;
  }

  String _key(String suffix) => '$_cachePrefix.$suffix';

  Future<void> _writeCache(Map<String, dynamic>? body) async {
    if (body == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key('body'), jsonEncode(body));
      await prefs.setString(_key('stamp'), DateTime.now().toIso8601String());
    } catch (_) {
      // A cache that will not write is not a reason to fail the load.
    }
  }

  Future<CachedLearningPayload?> cached() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key('body'));
      if (raw == null) return null;
      final stamp = DateTime.tryParse(prefs.getString(_key('stamp')) ?? '');
      return CachedLearningPayload(
        ContinueLearningPayload.fromJson(
            jsonDecode(raw) as Map<String, dynamic>),
        stamp ?? DateTime.now(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Called on sign-out: private progress must not survive into the next
  /// session on a shared device.
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key('body'));
      await prefs.remove(_key('stamp'));
    } catch (_) {
      // Nothing to do; the next read will simply miss.
    }
  }
}

final learningRepositoryProvider = Provider<LearningRepository>(
    (ref) => LearningRepository(ref.watch(dioProvider)));
