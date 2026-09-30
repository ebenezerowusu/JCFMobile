import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/providers.dart';
import 'activity_models.dart';

/// The first page of the unfiltered list, kept on disk so the schedule is
/// readable on a cold start with no network. Only page one is cached:
/// further pages are cheap to refetch and a stale cursor is worse than none.
const _cacheKey = 'activities.upcoming.page1.v1';
const _cacheStampKey = 'activities.upcoming.page1.stamp.v1';

/// How long a cached page may be shown before it is labelled as stale.
const cacheFreshness = Duration(hours: 6);

class CachedActivityPage {
  const CachedActivityPage(this.page, this.cachedAt);

  final ActivityPage page;
  final DateTime cachedAt;

  bool get isStale =>
      DateTime.now().difference(cachedAt) > cacheFreshness;
}

class ActivitiesRepository {
  ActivitiesRepository(this._dio);

  final Dio _dio;

  Future<ActivityPage> browse({
    ActivityQuery query = const ActivityQuery(),
    String? cursor,
    int limit = 20,
  }) async {
    final params = <String, String>{
      ...query.toParams(),
      'limit': '$limit',
    };
    if (cursor != null) params['cursor'] = cursor;
    final res = await _dio.get<Map<String, dynamic>>(
      'activities/upcoming/',
      queryParameters: params,
    );
    final page = ActivityPage.fromJson(res.data ?? const {});
    // Only an unfiltered first page is worth keeping: it is what a cold
    // start shows before anything is chosen.
    if (cursor == null && !query.hasAnyFilter && query.from == null) {
      await _writeCache(res.data);
    }
    return page;
  }

  Future<List<CalendarDay>> calendar({
    required DateTime month,
    ActivityQuery query = const ActivityQuery(),
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      'activities/calendar/',
      queryParameters: {
        ...query.toParams()..remove('from')..remove('to'),
        'month': '${month.year.toString().padLeft(4, '0')}-'
            '${month.month.toString().padLeft(2, '0')}',
      },
    );
    return [
      for (final row in (res.data?['days'] as List? ?? []))
        CalendarDay.fromJson(row as Map<String, dynamic>)
    ];
  }

  /// Toggles a "remind me" on an activity or a programme; returns the new
  /// state. Programmes still take reminders even though they left the
  /// browse list.
  Future<bool> toggleReminder({int? activityId, String? programSlug}) async {
    final res = await _dio.post<Map<String, dynamic>>(
      'activities/reminder/',
      data: activityId != null
          ? {'activity_id': activityId}
          : {'program_slug': programSlug},
    );
    return res.data?['reminder_set'] as bool? ?? false;
  }

  Future<bool> toggleSave(int activityId) async {
    final res = await _dio.post<Map<String, dynamic>>(
      'activities/save/',
      data: {'activity_id': activityId},
    );
    return res.data?['saved'] as bool? ?? false;
  }

  /// Takes or releases a place. Returns the server's account of the seat —
  /// the app never guesses whether a registration became a waitlist entry.
  Future<ActivityRegistrationInfo> register(
    int activityId, {
    bool cancel = false,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      'activities/register/',
      data: {'activity_id': activityId, if (cancel) 'cancel': true},
    );
    return ActivityRegistrationInfo.fromJson(
        res.data?['registration'] as Map<String, dynamic>?);
  }

  Future<void> _writeCache(Map<String, dynamic>? body) async {
    if (body == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(body));
      await prefs.setString(
          _cacheStampKey, DateTime.now().toIso8601String());
    } catch (_) {
      // A cache that cannot be written is not a reason to fail the load.
    }
  }

  Future<CachedActivityPage?> cachedFirstPage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw == null) return null;
      final stamp = DateTime.tryParse(prefs.getString(_cacheStampKey) ?? '');
      return CachedActivityPage(
        ActivityPage.fromJson(jsonDecode(raw) as Map<String, dynamic>),
        stamp ?? DateTime.now(),
      );
    } catch (_) {
      return null;
    }
  }
}

final activitiesRepositoryProvider = Provider<ActivitiesRepository>(
    (ref) => ActivitiesRepository(ref.watch(dioProvider)));
