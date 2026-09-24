import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../auth/auth_controller.dart';

/// One row of the unified Upcoming Activities feed (design 25): a scheduled
/// activity or a published programme.
class ActivityItem {
  const ActivityItem({
    required this.kind,
    required this.title,
    required this.description,
    required this.startsAt,
    required this.allDay,
    required this.venue,
    required this.audience,
    required this.liveSoon,
    required this.reminderSet,
    this.durationMinutes,
    this.activityId,
    this.programSlug,
  });

  final String kind; // live | practice | gathering | programme
  final String title;
  final String description;
  final DateTime startsAt;
  final bool allDay;
  final String venue;
  final String audience; // public | members | students
  final bool liveSoon;
  final bool reminderSet;
  final int? durationMinutes;
  final int? activityId;
  final String? programSlug;

  /// live | starting_soon | upcoming — derived, so a cached item can never
  /// claim to be live after it has ended.
  String status(DateTime now) {
    // All-day items (programmes) are dated, not broadcast — never "live".
    if (allDay) return 'upcoming';
    final ends =
        startsAt.add(Duration(minutes: durationMinutes ?? 60));
    if (!now.isBefore(startsAt) && now.isBefore(ends)) return 'live';
    if (liveSoon && now.isBefore(startsAt)) return 'starting_soon';
    return 'upcoming';
  }

  factory ActivityItem.fromJson(Map<String, dynamic> json) => ActivityItem(
        kind: json['kind'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        startsAt: DateTime.parse(json['starts_at'] as String).toLocal(),
        allDay: json['all_day'] as bool? ?? false,
        venue: json['venue'] as String? ?? '',
        audience: json['audience'] as String? ?? 'public',
        liveSoon: json['live_soon'] as bool? ?? false,
        reminderSet: json['reminder_set'] as bool? ?? false,
        durationMinutes: json['duration_minutes'] as int?,
        activityId: json['activity_id'] as int?,
        programSlug: json['program_slug'] as String?,
      );
}

class ActivitiesRepository {
  ActivitiesRepository(this._dio);

  final Dio _dio;

  Future<List<ActivityItem>> upcoming() async {
    final res = await _dio.get<Map<String, dynamic>>('activities/upcoming/');
    return [
      for (final row in (res.data?['results'] as List? ?? []))
        ActivityItem.fromJson(row as Map<String, dynamic>)
    ];
  }

  /// Toggles a "remind me" on one feed item; returns the new state.
  Future<bool> toggleReminder(ActivityItem item) async {
    final res = await _dio.post<Map<String, dynamic>>(
      'activities/reminder/',
      data: item.activityId != null
          ? {'activity_id': item.activityId}
          : {'program_slug': item.programSlug},
    );
    return res.data?['reminder_set'] as bool? ?? false;
  }
}

final activitiesRepositoryProvider = Provider<ActivitiesRepository>(
    (ref) => ActivitiesRepository(ref.watch(dioProvider)));

/// The unified feed; refetches on sign-in/out so audience items appear.
final upcomingActivitiesProvider =
    FutureProvider.autoDispose<List<ActivityItem>>((ref) {
  ref.watch(authControllerProvider);
  return ref.watch(activitiesRepositoryProvider).upcoming();
});
