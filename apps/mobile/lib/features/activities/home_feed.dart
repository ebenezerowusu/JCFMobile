import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';
import 'activities_repository.dart';
import 'activity_models.dart';

export 'activities_repository.dart' show activitiesRepositoryProvider;

/// The compact shape the home screens' "Live & upcoming" card reads.
///
/// It is deliberately smaller than [Activity]: a single card needs a title,
/// a time and a status, not seats, fees and facets. The member and student
/// home screens also build one of these by hand from their own payload, so
/// the constructor is part of the contract.
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
    // All-day items are dated, not broadcast — never "live".
    if (allDay) return 'upcoming';
    final ends = startsAt.add(Duration(minutes: durationMinutes ?? 60));
    if (!now.isBefore(startsAt) && now.isBefore(ends)) return 'live';
    if (liveSoon && now.isBefore(startsAt)) return 'starting_soon';
    return 'upcoming';
  }

  factory ActivityItem.fromActivity(Activity activity) => ActivityItem(
        kind: activity.kind,
        title: activity.title,
        description: activity.summary,
        startsAt: activity.startsAt,
        allDay: activity.allDay,
        venue: activity.isOnline && !activity.isInPerson
            ? ''
            : activity.locationLine,
        audience: activity.access.requiredAudience,
        liveSoon: activity.startingSoon,
        reminderSet: activity.reminderSet,
        durationMinutes: activity.durationMinutes,
        activityId: activity.id,
      );
}

/// The home cards' feed. Refetches on sign-in/out so audience items appear.
///
/// Locked items are dropped here. The browse screen shows them with a lock
/// because a full schedule is the point there; a single home card promising
/// something the reader cannot open is just a dead end.
final upcomingActivitiesProvider =
    FutureProvider.autoDispose<List<ActivityItem>>((ref) async {
  ref.watch(authControllerProvider);
  final page = await ref.watch(activitiesRepositoryProvider).browse();
  return [
    for (final activity in page.results)
      if (activity.access.allowed && !activity.cancelled)
        ActivityItem.fromActivity(activity)
  ];
});
