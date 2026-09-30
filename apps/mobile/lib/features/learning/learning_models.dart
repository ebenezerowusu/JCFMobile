import 'package:flutter/foundation.dart';

/// How a lesson is opened. Anything unrecognised reads as [written], the
/// one type that needs no player and so can never fail to open.
enum LessonType {
  video,
  audio,
  written,
  reflection,
  practice,
  quiz,
  live,
  resource,
}

LessonType lessonTypeFrom(String? raw) => switch (raw) {
      'video' => LessonType.video,
      'audio' => LessonType.audio,
      'reflection' => LessonType.reflection,
      'practice' => LessonType.practice,
      'quiz' => LessonType.quiz,
      'live' => LessonType.live,
      'resource' => LessonType.resource,
      _ => LessonType.written,
    };

enum LessonStatus { notStarted, inProgress, completed, locked, unavailable }

LessonStatus lessonStatusFrom(String? raw) => switch (raw) {
      'in_progress' => LessonStatus.inProgress,
      'completed' => LessonStatus.completed,
      'locked' => LessonStatus.locked,
      'unavailable' => LessonStatus.unavailable,
      _ => LessonStatus.notStarted,
    };

enum CourseProgressStatus {
  notStarted,
  inProgress,
  completed,
  paused,
  expired,
  withdrawn,
  unavailable,
}

CourseProgressStatus courseStatusFrom(String? raw) => switch (raw) {
      'in_progress' => CourseProgressStatus.inProgress,
      'completed' => CourseProgressStatus.completed,
      'paused' => CourseProgressStatus.paused,
      'expired' => CourseProgressStatus.expired,
      'withdrawn' => CourseProgressStatus.withdrawn,
      'unavailable' => CourseProgressStatus.unavailable,
      _ => CourseProgressStatus.notStarted,
    };

enum DownloadState {
  unavailable,
  notDownloaded,
  queued,
  downloading,
  paused,
  downloaded,
  failed,
  expired,
  updateRequired,
}

DownloadState downloadStateFrom(String? raw) => switch (raw) {
      'not_downloaded' => DownloadState.notDownloaded,
      'queued' => DownloadState.queued,
      'downloading' => DownloadState.downloading,
      'paused' => DownloadState.paused,
      'downloaded' => DownloadState.downloaded,
      'failed' => DownloadState.failed,
      'expired' => DownloadState.expired,
      'update_required' => DownloadState.updateRequired,
      _ => DownloadState.unavailable,
    };

/// Clamped on the way in. A malformed percentage is a display problem, not
/// a reason to drop the row, but it must never render as a bar past its end.
int clampPercent(Object? raw) {
  final value = raw is num ? raw.round() : int.tryParse('$raw') ?? 0;
  return value < 0 ? 0 : (value > 100 ? 100 : value);
}

DateTime? _date(Object? raw) =>
    raw is String && raw.isNotEmpty ? DateTime.tryParse(raw)?.toLocal() : null;

@immutable
class ContentAccess {
  const ContentAccess({
    required this.allowed,
    this.requiredTier = 'general',
    this.enrolmentRequired = false,
    this.expiresAt,
    this.restrictionReason = '',
  });

  final bool allowed;
  final String requiredTier;
  final bool enrolmentRequired;
  final DateTime? expiresAt;

  /// '' | 'tier' | 'expired'
  final String restrictionReason;

  bool get isExpired => restrictionReason == 'expired';

  factory ContentAccess.fromJson(Map<String, dynamic>? json) => ContentAccess(
        allowed: json?['allowed'] as bool? ?? true,
        requiredTier: json?['required_tier'] as String? ?? 'general',
        enrolmentRequired: json?['enrolment_required'] as bool? ?? false,
        expiresAt: _date(json?['expires_at']),
        restrictionReason: json?['restriction_reason'] as String? ?? '',
      );
}

@immutable
class LessonPrerequisite {
  const LessonPrerequisite({
    required this.required_,
    required this.satisfied,
    this.prerequisiteLessonId,
    this.prerequisiteTitle = '',
    this.reason = '',
  });

  final bool required_;
  final bool satisfied;
  final int? prerequisiteLessonId;
  final String prerequisiteTitle;
  final String reason;

  bool get blocks => required_ && !satisfied;

  factory LessonPrerequisite.fromJson(Map<String, dynamic>? json) =>
      LessonPrerequisite(
        required_: json?['required'] as bool? ?? false,
        satisfied: json?['satisfied'] as bool? ?? true,
        prerequisiteLessonId: json?['prerequisite_lesson_id'] as int?,
        prerequisiteTitle: json?['prerequisite_title'] as String? ?? '',
        reason: json?['reason'] as String? ?? '',
      );
}

@immutable
class LearningDownload {
  const LearningDownload({
    required this.downloadable,
    required this.state,
    this.progressPercentage = 0,
    this.downloadedBytes,
    this.totalBytes,
    this.expiresAt,
    this.failureCode = '',
  });

  final bool downloadable;
  final DownloadState state;
  final int progressPercentage;
  final int? downloadedBytes;
  final int? totalBytes;
  final DateTime? expiresAt;
  final String failureCode;

  bool get isAvailableOffline => state == DownloadState.downloaded;

  bool get isBusy =>
      state == DownloadState.queued || state == DownloadState.downloading;

  factory LearningDownload.fromJson(Map<String, dynamic>? json) =>
      LearningDownload(
        downloadable: json?['downloadable'] as bool? ?? false,
        state: downloadStateFrom(json?['state'] as String?),
        progressPercentage: clampPercent(json?['progress_percentage']),
        downloadedBytes: json?['downloaded_bytes'] as int?,
        totalBytes: json?['total_bytes'] as int?,
        expiresAt: _date(json?['expires_at']),
        failureCode: json?['failure_code'] as String? ?? '',
      );
}

/// Where a lesson or course opens. An identifier, never a route string:
/// the app maps it to a path it already knows.
@immutable
class LearningDestination {
  const LearningDestination({required this.type, required this.id});

  final String type;
  final int id;

  factory LearningDestination.fromJson(
      Map<String, dynamic>? json, int fallbackId) {
    final id = json?['lesson_id'] as int? ??
        json?['course_id'] as int? ??
        fallbackId;
    return LearningDestination(
      type: json?['type'] as String? ?? 'written',
      id: id,
    );
  }
}

@immutable
class LearningSummary {
  const LearningSummary({
    this.completedLessons = 0,
    this.completedCourses = 0,
    this.currentStreakDays = 0,
    this.downloadedItems = 0,
    this.totalLearningSeconds = 0,
  });

  final int completedLessons;
  final int completedCourses;
  final int currentStreakDays;
  final int downloadedItems;
  final int totalLearningSeconds;

  factory LearningSummary.fromJson(Map<String, dynamic>? json) =>
      LearningSummary(
        completedLessons: json?['completed_lessons'] as int? ?? 0,
        completedCourses: json?['completed_courses'] as int? ?? 0,
        currentStreakDays: json?['current_streak_days'] as int? ?? 0,
        downloadedItems: json?['downloaded_items'] as int? ?? 0,
        totalLearningSeconds: json?['total_learning_seconds'] as int? ?? 0,
      );
}

/// One lesson row, and also the shape of the resume hero.
@immutable
class LessonSummary {
  const LessonSummary({
    required this.lessonId,
    required this.title,
    required this.type,
    required this.status,
    required this.access,
    required this.prerequisite,
    required this.download,
    required this.destination,
    this.courseId,
    this.courseTitle = '',
    this.moduleId,
    this.moduleTitle = '',
    this.imageUrl = '',
    this.courseCategory = 'other',
    this.durationSeconds,
    this.positionSeconds,
    this.progressPercentage = 0,
    this.enrolmentId,
    this.courseImageUrl = '',
    this.remainingSeconds,
    this.lastAccessedAt,
  });

  final int lessonId;
  final String title;
  final LessonType type;
  final LessonStatus status;
  final ContentAccess access;
  final LessonPrerequisite prerequisite;
  final LearningDownload download;
  final LearningDestination destination;
  final int? courseId;
  final String courseTitle;
  final int? moduleId;
  final String moduleTitle;
  final String imageUrl;
  final String courseCategory;
  final int? durationSeconds;
  final int? positionSeconds;
  final int progressPercentage;

  // Resume-hero extras; absent on ordinary rows.
  final int? enrolmentId;
  final String courseImageUrl;
  final int? remainingSeconds;
  final DateTime? lastAccessedAt;

  bool get isLocked => status == LessonStatus.locked;

  bool get isCompleted => status == LessonStatus.completed;

  /// The course and module, as one line, skipping whichever is missing.
  String get contextLine =>
      [courseTitle, moduleTitle].where((s) => s.isNotEmpty).join(' · ');

  factory LessonSummary.fromJson(Map<String, dynamic> json) {
    final id = json['lesson_id'] as int;
    return LessonSummary(
      lessonId: id,
      title: json['title'] as String? ?? '',
      type: lessonTypeFrom(json['type'] as String?),
      status: lessonStatusFrom(json['status'] as String?),
      access: ContentAccess.fromJson(json['access'] as Map<String, dynamic>?),
      prerequisite: LessonPrerequisite.fromJson(
          json['prerequisite'] as Map<String, dynamic>?),
      download:
          LearningDownload.fromJson(json['download'] as Map<String, dynamic>?),
      destination: LearningDestination.fromJson(
          json['destination'] as Map<String, dynamic>?, id),
      courseId: json['course_id'] as int?,
      courseTitle: json['course_title'] as String? ?? '',
      moduleId: json['module_id'] as int?,
      moduleTitle: json['module_title'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      courseCategory: json['course_category'] as String? ?? 'other',
      durationSeconds: json['duration_seconds'] as int?,
      positionSeconds: json['position_seconds'] as int?,
      progressPercentage: clampPercent(json['progress_percentage']),
      enrolmentId: json['enrolment_id'] as int?,
      courseImageUrl: json['course_image_url'] as String? ?? '',
      remainingSeconds: json['remaining_seconds'] as int?,
      lastAccessedAt: _date(json['last_accessed_at']),
    );
  }
}

@immutable
class ActiveCourse {
  const ActiveCourse({
    required this.courseId,
    required this.title,
    required this.status,
    required this.access,
    required this.destination,
    this.enrolmentId,
    this.description = '',
    this.imageUrl = '',
    this.category = 'other',
    this.facilitator = '',
    this.totalModules = 0,
    this.completedModules = 0,
    this.totalLessons = 0,
    this.completedLessons = 0,
    this.progressPercentage = 0,
    this.currentModuleId,
    this.currentLessonId,
    this.lastAccessedAt,
  });

  final int courseId;
  final String title;
  final CourseProgressStatus status;
  final ContentAccess access;
  final LearningDestination destination;
  final int? enrolmentId;
  final String description;
  final String imageUrl;
  final String category;
  final String facilitator;
  final int totalModules;
  final int completedModules;
  final int totalLessons;
  final int completedLessons;
  final int progressPercentage;
  final int? currentModuleId;
  final int? currentLessonId;
  final DateTime? lastAccessedAt;

  factory ActiveCourse.fromJson(Map<String, dynamic> json) {
    final id = json['course_id'] as int;
    return ActiveCourse(
      courseId: id,
      title: json['title'] as String? ?? '',
      status: courseStatusFrom(json['status'] as String?),
      access: ContentAccess.fromJson(json['access'] as Map<String, dynamic>?),
      destination: LearningDestination.fromJson(
          json['destination'] as Map<String, dynamic>?, id),
      enrolmentId: json['enrolment_id'] as int?,
      description: json['description'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      category: json['category'] as String? ?? 'other',
      facilitator: json['facilitator'] as String? ?? '',
      totalModules: json['total_modules'] as int? ?? 0,
      completedModules: json['completed_modules'] as int? ?? 0,
      totalLessons: json['total_lessons'] as int? ?? 0,
      completedLessons: json['completed_lessons'] as int? ?? 0,
      progressPercentage: clampPercent(json['progress_percentage']),
      currentModuleId: json['current_module_id'] as int?,
      currentLessonId: json['current_lesson_id'] as int?,
      lastAccessedAt: _date(json['last_accessed_at']),
    );
  }
}

@immutable
class CourseRecommendation {
  const CourseRecommendation({
    required this.courseId,
    required this.title,
    required this.destination,
    this.imageUrl = '',
    this.category = 'other',
    this.facilitator = '',
    this.moduleCount = 0,
    this.lessonCount = 0,
    this.accessLevel = 'general',
    this.recommendationReason = '',
  });

  final int courseId;
  final String title;
  final LearningDestination destination;
  final String imageUrl;
  final String category;
  final String facilitator;
  final int moduleCount;
  final int lessonCount;
  final String accessLevel;
  final String recommendationReason;

  factory CourseRecommendation.fromJson(Map<String, dynamic> json) {
    final id = json['course_id'] as int;
    return CourseRecommendation(
      courseId: id,
      title: json['title'] as String? ?? '',
      destination: LearningDestination.fromJson(
          json['destination'] as Map<String, dynamic>?, id),
      imageUrl: json['image_url'] as String? ?? '',
      category: json['category'] as String? ?? 'other',
      facilitator: json['facilitator'] as String? ?? '',
      moduleCount: json['module_count'] as int? ?? 0,
      lessonCount: json['lesson_count'] as int? ?? 0,
      accessLevel: json['access_level'] as String? ?? 'general',
      recommendationReason: json['recommendation_reason'] as String? ?? '',
    );
  }
}

/// One cursor-paginated slice.
@immutable
class LearningPage<T> {
  const LearningPage({
    this.results = const [],
    this.nextCursor,
    this.hasMore = false,
  });

  final List<T> results;
  final String? nextCursor;
  final bool hasMore;

  static LearningPage<T> parse<T>(
      Map<String, dynamic>? json, T Function(Map<String, dynamic>) item) {
    final cursor = json?['next_cursor'] as String?;
    return LearningPage<T>(
      results: [
        for (final row in (json?['results'] as List? ?? []))
          item(row as Map<String, dynamic>)
      ],
      nextCursor: cursor,
      // Trust has_more, but never claim more without a cursor to fetch it.
      hasMore: (json?['has_more'] as bool? ?? false) && cursor != null,
    );
  }
}

@immutable
class ContinueLearningPayload {
  const ContinueLearningPayload({
    required this.summary,
    required this.activeCourses,
    required this.upNextLessons,
    required this.fetchedAt,
    this.resumeItem,
    this.recommendations = const [],
  });

  final LearningSummary summary;
  final LearningPage<ActiveCourse> activeCourses;
  final LearningPage<LessonSummary> upNextLessons;
  final DateTime fetchedAt;
  final LessonSummary? resumeItem;
  final List<CourseRecommendation> recommendations;

  bool get isEmpty =>
      resumeItem == null &&
      activeCourses.results.isEmpty &&
      upNextLessons.results.isEmpty &&
      recommendations.isEmpty;

  factory ContinueLearningPayload.fromJson(Map<String, dynamic> json) {
    final resume = json['resume_item'] as Map<String, dynamic>?;
    return ContinueLearningPayload(
      summary:
          LearningSummary.fromJson(json['learning_summary'] as Map<String, dynamic>?),
      activeCourses: LearningPage.parse(
          json['active_courses'] as Map<String, dynamic>?,
          ActiveCourse.fromJson),
      upNextLessons: LearningPage.parse(
          json['up_next_lessons'] as Map<String, dynamic>?,
          LessonSummary.fromJson),
      fetchedAt: _date(json['fetched_at']) ?? DateTime.now(),
      resumeItem: resume == null ? null : LessonSummary.fromJson(resume),
      recommendations: [
        for (final row in (json['recommendations'] as List? ?? []))
          CourseRecommendation.fromJson(row as Map<String, dynamic>)
      ],
    );
  }
}

/// What narrows the Up Next list. Held as one value so a change resets the
/// cursor in a single place.
@immutable
class LearningFilter {
  const LearningFilter({this.status, this.contentType, this.downloadedOnly = false});

  /// null | not_started | in_progress | completed
  final String? status;

  /// null | video | audio | written | practice | …
  final String? contentType;
  final bool downloadedOnly;

  int get activeCount =>
      (status == null ? 0 : 1) +
      (contentType == null ? 0 : 1) +
      (downloadedOnly ? 1 : 0);

  bool get isEmpty => activeCount == 0;

  LearningFilter copyWith({
    String? status,
    String? contentType,
    bool? downloadedOnly,
    bool clearStatus = false,
    bool clearContentType = false,
  }) =>
      LearningFilter(
        status: clearStatus ? null : (status ?? this.status),
        contentType:
            clearContentType ? null : (contentType ?? this.contentType),
        downloadedOnly: downloadedOnly ?? this.downloadedOnly,
      );

  Map<String, String> toParams() {
    final params = <String, String>{};
    final status = this.status;
    final contentType = this.contentType;
    if (status != null) params['status'] = status;
    if (contentType != null) params['content_type'] = contentType;
    if (downloadedOnly) params['downloaded'] = 'true';
    return params;
  }

  @override
  bool operator ==(Object other) =>
      other is LearningFilter &&
      other.status == status &&
      other.contentType == contentType &&
      other.downloadedOnly == downloadedOnly;

  @override
  int get hashCode => Object.hash(status, contentType, downloadedOnly);
}
