import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../inspiration/inspiration_repository.dart';

/// Destination identifiers the API may send. The app maps these to its own
/// routes — a raw route string from the server is never navigated to.
enum MemberDestination {
  journey,
  lesson,
  series,
  practice,
  teaching,
  event,
  announcement,
  unknown;

  static MemberDestination parse(String? id) => switch (id) {
        'journey' => MemberDestination.journey,
        'lesson' => MemberDestination.lesson,
        'series' => MemberDestination.series,
        'practice' => MemberDestination.practice,
        'teaching' => MemberDestination.teaching,
        'event' => MemberDestination.event,
        'announcement' => MemberDestination.announcement,
        _ => MemberDestination.unknown,
      };
}

class MemberSummary {
  const MemberSummary({
    required this.preferredName,
    required this.firstName,
    required this.membershipLabel,
    required this.membershipStatus,
    this.avatarUrl = '',
  });

  final String preferredName;
  final String firstName;
  final String membershipLabel;
  final String membershipStatus;
  final String avatarUrl;

  /// preferredName → firstName → null (the app then shows a generic
  /// localized greeting). Contact details are never used as a name.
  String? get displayName {
    if (preferredName.trim().isNotEmpty) return preferredName.trim();
    if (firstName.trim().isNotEmpty) return firstName.trim();
    return null;
  }

  factory MemberSummary.fromJson(Map<String, dynamic> json) => MemberSummary(
        preferredName: json['preferred_name'] as String? ?? '',
        firstName: json['first_name'] as String? ?? '',
        membershipLabel: json['membership_label'] as String? ?? '',
        membershipStatus: json['membership_status'] as String? ?? 'member',
        avatarUrl: json['avatar_url'] as String? ?? '',
      );
}

class WelcomeContent {
  const WelcomeContent({
    required this.eyebrow,
    required this.titleTemplate,
    required this.message,
    required this.actionLabel,
    required this.destination,
    this.imageUrl = '',
  });

  final String eyebrow;
  final String titleTemplate;
  final String message;
  final String actionLabel;
  final MemberDestination destination;
  final String imageUrl;

  /// Fills the server's template rather than concatenating translated parts.
  String title(String? name) => name == null
      ? titleTemplate.replaceAll(', {name}', '').replaceAll('{name}', '')
      : titleTemplate.replaceAll('{name}', name);

  factory WelcomeContent.fromJson(Map<String, dynamic> json) => WelcomeContent(
        eyebrow: json['eyebrow'] as String? ?? '',
        titleTemplate: json['title_template'] as String? ?? '',
        message: json['message'] as String? ?? '',
        actionLabel: json['action_label'] as String? ?? '',
        destination: MemberDestination.parse(json['destination_id'] as String?),
        imageUrl: json['image_url'] as String? ?? '',
      );
}

class LearningProgress {
  const LearningProgress({
    required this.contentId,
    required this.title,
    required this.subtitle,
    required this.currentUnitTitle,
    required this.completedUnits,
    required this.totalUnits,
    required this.destination,
    this.currentUnitId,
    this.progressPercentage,
    this.remainingSeconds,
    this.imageUrl = '',
  });

  final String contentId;
  final String title;
  final String subtitle;
  final String currentUnitTitle;
  final int completedUnits;
  final int totalUnits;
  final MemberDestination destination;
  final String? currentUnitId;

  /// Null means indeterminate — the bar is hidden rather than showing 0%.
  final int? progressPercentage;
  final int? remainingSeconds;
  final String imageUrl;

  int? get clampedPercent => progressPercentage?.clamp(0, 100);

  factory LearningProgress.fromJson(Map<String, dynamic> json) =>
      LearningProgress(
        contentId: json['content_id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        subtitle: json['subtitle'] as String? ?? '',
        currentUnitTitle: json['current_unit_title'] as String? ?? '',
        completedUnits: json['completed_units'] as int? ?? 0,
        totalUnits: json['total_units'] as int? ?? 0,
        destination: MemberDestination.parse(json['destination_id'] as String?),
        currentUnitId: json['current_unit_id'] as String?,
        progressPercentage: json['progress_percentage'] as int?,
        remainingSeconds: json['remaining_seconds'] as int?,
        imageUrl: json['image_url'] as String? ?? '',
      );
}

class PracticeProgress {
  const PracticeProgress({
    required this.practiceId,
    required this.title,
    required this.subtitle,
    required this.currentStreak,
    required this.destination,
    this.progressPercentage,
    this.durationSeconds,
    this.imageUrl = '',
  });

  final String practiceId;
  final String title;
  final String subtitle;
  final int currentStreak;
  final MemberDestination destination;
  final int? progressPercentage;
  final int? durationSeconds;
  final String imageUrl;

  factory PracticeProgress.fromJson(Map<String, dynamic> json) =>
      PracticeProgress(
        practiceId: json['practice_id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        subtitle: json['subtitle'] as String? ?? '',
        currentStreak: json['current_streak'] as int? ?? 0,
        destination: MemberDestination.parse(json['destination_id'] as String?),
        progressPercentage: json['progress_percentage'] as int?,
        durationSeconds: json['duration_seconds'] as int?,
        imageUrl: json['image_url'] as String? ?? '',
      );
}

class FeaturedContent {
  const FeaturedContent({
    required this.id,
    required this.contentType,
    required this.title,
    required this.speaker,
    required this.accessGranted,
    required this.destination,
    this.durationSeconds,
    this.readingTimeMinutes,
    this.imageUrl = '',
  });

  final String id;
  final String contentType; // video | audio | article | course | series
  final String title;
  final String speaker;
  final bool accessGranted;
  final MemberDestination destination;
  final int? durationSeconds;
  final int? readingTimeMinutes;
  final String imageUrl;

  factory FeaturedContent.fromJson(Map<String, dynamic> json) =>
      FeaturedContent(
        id: json['id'] as String? ?? '',
        contentType: json['content_type'] as String? ?? 'video',
        title: json['title'] as String? ?? '',
        speaker: json['speaker'] as String? ?? '',
        accessGranted: json['access_granted'] as bool? ?? false,
        destination: MemberDestination.parse(json['destination_id'] as String?),
        durationSeconds: json['duration_seconds'] as int?,
        readingTimeMinutes: json['reading_time_minutes'] as int?,
        imageUrl: json['image_url'] as String? ?? '',
      );
}

class MemberEvent {
  const MemberEvent({
    required this.title,
    required this.facilitator,
    required this.startsAt,
    required this.allDay,
    required this.format,
    required this.reminderEnabled,
    required this.destination,
    this.endsAt,
    this.timezone = '',
    this.joinUrl = '',
    this.replayUrl = '',
    this.activityId,
    this.programSlug,
    this.imageUrl = '',
  });

  final String title;
  final String facilitator;
  final DateTime startsAt;
  final DateTime? endsAt;
  final bool allDay;
  final String format;
  final bool reminderEnabled;
  final MemberDestination destination;
  final String timezone;
  final String joinUrl;
  final String replayUrl;
  final int? activityId;
  final String? programSlug;
  final String imageUrl;

  /// live | starting_soon | upcoming | replay — recomputed locally from the
  /// server's times, so cached content can never be shown as live once it
  /// has ended.
  String status(DateTime now) {
    if (allDay) return 'upcoming';
    final end = endsAt;
    if (!now.isBefore(startsAt)) {
      if (end != null && now.isBefore(end)) return 'live';
      return replayUrl.isNotEmpty ? 'replay' : 'upcoming';
    }
    if (startsAt.difference(now) <= const Duration(minutes: 60)) {
      return 'starting_soon';
    }
    return 'upcoming';
  }

  factory MemberEvent.fromJson(Map<String, dynamic> json) => MemberEvent(
        title: json['title'] as String? ?? '',
        facilitator: json['facilitator'] as String? ?? '',
        startsAt: DateTime.parse(json['starts_at'] as String).toLocal(),
        endsAt: json['ends_at'] == null
            ? null
            : DateTime.parse(json['ends_at'] as String).toLocal(),
        allDay: json['all_day'] as bool? ?? false,
        format: (json['venue'] as String?)?.isNotEmpty == true
            ? json['venue'] as String
            : '',
        reminderEnabled: json['reminder_set'] as bool? ?? false,
        destination: MemberDestination.parse(json['destination_id'] as String?),
        timezone: json['timezone'] as String? ?? '',
        joinUrl: json['join_url'] as String? ?? '',
        replayUrl: json['replay_url'] as String? ?? '',
        activityId: json['activity_id'] as int?,
        programSlug: json['program_slug'] as String?,
        imageUrl: json['image_url'] as String? ?? '',
      );
}

class CommunityAnnouncement {
  const CommunityAnnouncement({
    required this.id,
    required this.category,
    required this.title,
    required this.summary,
    required this.read,
    required this.destination,
    this.publishedAt,
    this.imageUrl = '',
  });

  final int id;
  final String category;
  final String title;
  final String summary;
  final bool read;
  final MemberDestination destination;
  final DateTime? publishedAt;
  final String imageUrl;

  factory CommunityAnnouncement.fromJson(Map<String, dynamic> json) =>
      CommunityAnnouncement(
        id: json['id'] as int? ?? 0,
        category: json['category'] as String? ?? '',
        title: json['title'] as String? ?? '',
        summary: json['summary'] as String? ?? json['body'] as String? ?? '',
        read: json['read'] as bool? ?? json['is_read'] as bool? ?? true,
        destination: MemberDestination.parse(json['destination_id'] as String?),
        publishedAt: json['created_at'] == null
            ? null
            : DateTime.tryParse(json['created_at'] as String)?.toLocal(),
        imageUrl: json['image_url'] as String? ?? '',
      );
}

class QuickActionItem {
  const QuickActionItem({required this.id, required this.sortOrder});

  final String id; // my_library | my_programs | saved | downloads
  final int sortOrder;

  factory QuickActionItem.fromJson(Map<String, dynamic> json) =>
      QuickActionItem(
        id: json['id'] as String? ?? '',
        sortOrder: json['sort_order'] as int? ?? 0,
      );
}

/// Everything the member home renders, in one payload.
class MemberHomePayload {
  const MemberHomePayload({
    required this.summary,
    required this.welcome,
    required this.continueLearning,
    required this.continuePractice,
    required this.inspirations,
    required this.quickActions,
    required this.announcements,
    required this.unreadNotificationCount,
    required this.fetchedAt,
    this.featuredContent,
    this.featuredEvent,
  });

  final MemberSummary summary;
  final WelcomeContent welcome;
  final List<LearningProgress> continueLearning;
  final List<PracticeProgress> continuePractice;
  final List<Inspiration> inspirations;
  final List<QuickActionItem> quickActions;
  final List<CommunityAnnouncement> announcements;
  final int unreadNotificationCount;
  final DateTime fetchedAt;
  final FeaturedContent? featuredContent;
  final MemberEvent? featuredEvent;

  bool get hasResumable =>
      continueLearning.isNotEmpty || continuePractice.isNotEmpty;

  /// True when nothing but the header has anything to show.
  bool get isEmpty =>
      !hasResumable &&
      inspirations.isEmpty &&
      announcements.isEmpty &&
      featuredContent == null &&
      featuredEvent == null;

  factory MemberHomePayload.fromJson(Map<String, dynamic> json) {
    List<T> list<T>(String key, T Function(Map<String, dynamic>) parse) => [
          for (final row in (json[key] as List? ?? []))
            parse(row as Map<String, dynamic>)
        ];
    final event = json['featured_event'] as Map<String, dynamic>?;
    final featured = json['featured_member_content'] as Map<String, dynamic>?;
    return MemberHomePayload(
      summary: MemberSummary.fromJson(
          json['member_summary'] as Map<String, dynamic>? ?? const {}),
      welcome: WelcomeContent.fromJson(
          json['welcome'] as Map<String, dynamic>? ?? const {}),
      continueLearning: list('continue_learning', LearningProgress.fromJson),
      continuePractice: list('continue_practice', PracticeProgress.fromJson),
      inspirations: list('daily_inspirations', Inspiration.fromJson),
      quickActions: list('quick_actions', QuickActionItem.fromJson)
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)),
      announcements: list('announcements', CommunityAnnouncement.fromJson),
      unreadNotificationCount: json['unread_notification_count'] as int? ?? 0,
      fetchedAt: DateTime.tryParse(json['fetched_at'] as String? ?? '')
              ?.toLocal() ??
          DateTime.now(),
      featuredContent:
          featured == null ? null : FeaturedContent.fromJson(featured),
      featuredEvent: event == null ? null : MemberEvent.fromJson(event),
    );
  }
}

class MemberHomeRepository {
  MemberHomeRepository(this._dio);

  final Dio _dio;

  Future<MemberHomePayload> load() async {
    final res = await _dio.get<Map<String, dynamic>>('home/member/');
    return MemberHomePayload.fromJson(res.data!);
  }
}

final memberHomeRepositoryProvider = Provider<MemberHomeRepository>(
    (ref) => MemberHomeRepository(ref.watch(dioProvider)));

/// The member home payload. Kept alive so pull-to-refresh can hold the
/// previous content on screen while the new one loads.
final memberHomeProvider = FutureProvider<MemberHomePayload>(
    (ref) => ref.watch(memberHomeRepositoryProvider).load());
