import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';
import 'learning_models.dart';
import 'learning_repository.dart';

@immutable
class ContinueLearningState {
  const ContinueLearningState({
    this.filter = const LearningFilter(),
    this.summary = const LearningSummary(),
    this.activeCourses = const [],
    this.upNextLessons = const [],
    this.recommendations = const [],
    this.resumeItem,
    this.courseCursor,
    this.lessonCursor,
    this.loading = true,
    this.refreshing = false,
    this.loadingMoreCourses = false,
    this.loadingMoreLessons = false,
    this.error,
    this.fromCache = false,
    this.cachedAt,
  });

  final LearningFilter filter;
  final LearningSummary summary;
  final List<ActiveCourse> activeCourses;
  final List<LessonSummary> upNextLessons;
  final List<CourseRecommendation> recommendations;
  final LessonSummary? resumeItem;
  final String? courseCursor;
  final String? lessonCursor;
  final bool loading;
  final bool refreshing;
  final bool loadingMoreCourses;
  final bool loadingMoreLessons;
  final Object? error;
  final bool fromCache;
  final DateTime? cachedAt;

  bool get hasMoreCourses => courseCursor != null;

  bool get hasMoreLessons => lessonCursor != null;

  bool get hasContent =>
      resumeItem != null ||
      activeCourses.isNotEmpty ||
      upNextLessons.isNotEmpty ||
      recommendations.isNotEmpty;

  /// An error with nothing readable behind it is a full-page state; one
  /// with content still on screen is a snack bar.
  bool get isFatalError => error != null && !hasContent;

  bool get isEmpty => !loading && error == null && !hasContent;

  ContinueLearningState copyWith({
    LearningFilter? filter,
    LearningSummary? summary,
    List<ActiveCourse>? activeCourses,
    List<LessonSummary>? upNextLessons,
    List<CourseRecommendation>? recommendations,
    LessonSummary? resumeItem,
    bool clearResume = false,
    String? courseCursor,
    bool clearCourseCursor = false,
    String? lessonCursor,
    bool clearLessonCursor = false,
    bool? loading,
    bool? refreshing,
    bool? loadingMoreCourses,
    bool? loadingMoreLessons,
    Object? error,
    bool clearError = false,
    bool? fromCache,
    DateTime? cachedAt,
  }) =>
      ContinueLearningState(
        filter: filter ?? this.filter,
        summary: summary ?? this.summary,
        activeCourses: activeCourses ?? this.activeCourses,
        upNextLessons: upNextLessons ?? this.upNextLessons,
        recommendations: recommendations ?? this.recommendations,
        resumeItem: clearResume ? null : (resumeItem ?? this.resumeItem),
        courseCursor:
            clearCourseCursor ? null : (courseCursor ?? this.courseCursor),
        lessonCursor:
            clearLessonCursor ? null : (lessonCursor ?? this.lessonCursor),
        loading: loading ?? this.loading,
        refreshing: refreshing ?? this.refreshing,
        loadingMoreCourses: loadingMoreCourses ?? this.loadingMoreCourses,
        loadingMoreLessons: loadingMoreLessons ?? this.loadingMoreLessons,
        error: clearError ? null : (error ?? this.error),
        fromCache: fromCache ?? this.fromCache,
        cachedAt: cachedAt ?? this.cachedAt,
      );
}

class ContinueLearningController extends Notifier<ContinueLearningState> {
  late LearningRepository _repository;

  /// Guards against a slow request landing after a newer one.
  int _ticket = 0;

  @override
  ContinueLearningState build() {
    ref.watch(authControllerProvider);
    _repository = ref.watch(learningRepositoryProvider);
    Future.microtask(load);
    return const ContinueLearningState();
  }

  Future<void> load({bool refresh = false}) async {
    final ticket = ++_ticket;
    state = state.copyWith(
      loading: !refresh && !state.hasContent,
      refreshing: refresh,
      clearError: true,
    );

    if (!refresh && !state.hasContent && state.filter.isEmpty) {
      await _showCacheWhileLoading(ticket);
    }

    try {
      final payload = await _repository.hub(filter: state.filter);
      if (ticket != _ticket) return;
      state = state.copyWith(
        summary: payload.summary,
        activeCourses: payload.activeCourses.results,
        upNextLessons: payload.upNextLessons.results,
        recommendations: payload.recommendations,
        resumeItem: payload.resumeItem,
        clearResume: payload.resumeItem == null,
        courseCursor: payload.activeCourses.nextCursor,
        clearCourseCursor: payload.activeCourses.nextCursor == null,
        lessonCursor: payload.upNextLessons.nextCursor,
        clearLessonCursor: payload.upNextLessons.nextCursor == null,
        loading: false,
        refreshing: false,
        fromCache: false,
        clearError: true,
      );
    } catch (error) {
      if (ticket != _ticket) return;
      state = state.copyWith(
        loading: false, refreshing: false, error: error);
    }
  }

  Future<void> _showCacheWhileLoading(int ticket) async {
    final cached = await _repository.cached();
    if (cached == null || ticket != _ticket || state.hasContent) return;
    final payload = cached.payload;
    state = state.copyWith(
      summary: payload.summary,
      activeCourses: payload.activeCourses.results,
      upNextLessons: payload.upNextLessons.results,
      recommendations: payload.recommendations,
      resumeItem: payload.resumeItem,
      loading: false,
      fromCache: true,
      cachedAt: cached.cachedAt,
    );
  }

  Future<void> loadMoreCourses() async {
    final cursor = state.courseCursor;
    if (cursor == null || state.loadingMoreCourses || state.loading) return;
    final ticket = _ticket;
    state = state.copyWith(loadingMoreCourses: true);
    try {
      final payload =
          await _repository.hub(filter: state.filter, courseCursor: cursor);
      if (ticket != _ticket) return;
      final seen = {for (final c in state.activeCourses) c.courseId};
      state = state.copyWith(
        activeCourses: [
          ...state.activeCourses,
          ...payload.activeCourses.results
              .where((c) => seen.add(c.courseId)),
        ],
        courseCursor: payload.activeCourses.nextCursor,
        clearCourseCursor: payload.activeCourses.nextCursor == null,
        loadingMoreCourses: false,
      );
    } catch (error) {
      if (ticket != _ticket) return;
      state = state.copyWith(loadingMoreCourses: false, error: error);
    }
  }

  Future<void> loadMoreLessons() async {
    final cursor = state.lessonCursor;
    if (cursor == null || state.loadingMoreLessons || state.loading) return;
    final ticket = _ticket;
    state = state.copyWith(loadingMoreLessons: true);
    try {
      final payload =
          await _repository.hub(filter: state.filter, lessonCursor: cursor);
      if (ticket != _ticket) return;
      // The server pages on id, but a row edited between pages could still
      // arrive twice. Dedupe so no lesson appears in two places.
      final seen = {for (final l in state.upNextLessons) l.lessonId};
      state = state.copyWith(
        upNextLessons: [
          ...state.upNextLessons,
          ...payload.upNextLessons.results
              .where((l) => seen.add(l.lessonId)),
        ],
        lessonCursor: payload.upNextLessons.nextCursor,
        clearLessonCursor: payload.upNextLessons.nextCursor == null,
        loadingMoreLessons: false,
      );
    } catch (error) {
      if (ticket != _ticket) return;
      state = state.copyWith(loadingMoreLessons: false, error: error);
    }
  }

  /// A filter change drops both cursors and both lists. Keeping a cursor
  /// across a filter change silently skips the new first page.
  void applyFilter(LearningFilter filter) {
    if (filter == state.filter) return;
    state = state.copyWith(
      filter: filter,
      activeCourses: const [],
      upNextLessons: const [],
      clearCourseCursor: true,
      clearLessonCursor: true,
      clearError: true,
      loading: true,
    );
    load();
  }

  void clearFilters() => applyFilter(const LearningFilter());
}

/// Named for the hub rather than the screen: `continueLearningProvider` in
/// lessons_repository.dart is the older, compact summary the home card
/// reads, and two providers with one name would be a trap.
final learningHubProvider = NotifierProvider<ContinueLearningController,
    ContinueLearningState>(ContinueLearningController.new);
