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

  Future<void> markCompleted(String slug) async {
    await _dio.post('teachings/$slug/progress/', data: {'completed': true});
  }

  Future<ContinueLearning> continueLearning() async {
    final res = await _dio.get<Map<String, dynamic>>('learning/continue/');
    return ContinueLearning.fromJson(res.data!);
  }
}

/// Continue Learning summary (design 26).
class ContinueLearning {
  const ContinueLearning({
    required this.activeSeries,
    required this.lessonsCompleted,
    required this.series,
    required this.recentlyViewed,
  });

  final int activeSeries;
  final int lessonsCompleted;
  final List<SeriesProgress> series;
  final List<ViewedLesson> recentlyViewed;

  factory ContinueLearning.fromJson(Map<String, dynamic> json) =>
      ContinueLearning(
        activeSeries: json['active_series'] as int? ?? 0,
        lessonsCompleted: json['lessons_completed'] as int? ?? 0,
        series: [
          for (final row in (json['series'] as List? ?? []))
            SeriesProgress.fromJson(row as Map<String, dynamic>)
        ],
        recentlyViewed: [
          for (final row in (json['recently_viewed'] as List? ?? []))
            ViewedLesson.fromJson(row as Map<String, dynamic>)
        ],
      );
}

class SeriesProgress {
  const SeriesProgress({
    required this.slug,
    required this.title,
    required this.author,
    required this.percent,
    required this.lessonsTotal,
    required this.currentLesson,
    this.resumeSlug,
  });

  final String slug;
  final String title;
  final String author;
  final int percent;
  final int lessonsTotal;
  final int currentLesson;
  final String? resumeSlug;

  factory SeriesProgress.fromJson(Map<String, dynamic> json) => SeriesProgress(
        slug: json['slug'] as String,
        title: json['title'] as String,
        author: json['author'] as String? ?? '',
        percent: json['percent'] as int? ?? 0,
        lessonsTotal: json['lessons_total'] as int? ?? 0,
        currentLesson: json['current_lesson'] as int? ?? 0,
        resumeSlug: json['resume_slug'] as String?,
      );
}

class ViewedLesson {
  const ViewedLesson({
    required this.slug,
    required this.topic,
    required this.mediaKind,
    required this.completed,
    required this.lastViewedAt,
    this.seriesTitle,
    this.durationSeconds,
    this.thumbnailUrl = '',
  });

  final String slug;
  final String topic;
  final String mediaKind;
  final bool completed;
  final DateTime lastViewedAt;
  final String? seriesTitle;
  final int? durationSeconds;
  final String thumbnailUrl;

  factory ViewedLesson.fromJson(Map<String, dynamic> json) => ViewedLesson(
        slug: json['slug'] as String,
        topic: json['topic'] as String,
        mediaKind: json['media_kind'] as String? ?? 'video',
        completed: json['completed'] as bool? ?? false,
        lastViewedAt: DateTime.parse(json['last_viewed_at'] as String),
        seriesTitle: json['series_title'] as String?,
        durationSeconds: json['duration_seconds'] as int?,
        thumbnailUrl: json['thumbnail_url'] as String? ?? '',
      );
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


/// Continue Learning summary for the signed-in member.
final continueLearningProvider =
    FutureProvider.autoDispose<ContinueLearning?>((ref) async {
  final loggedIn = ref.watch(isLoggedInProvider);
  if (!loggedIn) return null;
  return ref.watch(lessonsRepositoryProvider).continueLearning();
});
