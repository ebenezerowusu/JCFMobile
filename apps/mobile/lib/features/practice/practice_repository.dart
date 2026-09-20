import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../auth/auth_controller.dart';

class Practice {
  const Practice({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.minutes,
    this.audioUrl = '',
  });

  final int id;
  final String title;
  final String description;
  final String category;
  final int minutes;
  final String audioUrl;

  factory Practice.fromJson(Map<String, dynamic> json) => Practice(
        id: json['id'] as int,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        category: json['category'] as String? ?? 'general',
        minutes: json['minutes'] as int? ?? 10,
        audioUrl: json['audio_url'] as String? ?? '',
      );
}

class WeekDay {
  const WeekDay({required this.date, required this.count, required this.done});

  final DateTime date;
  final int count;
  final bool done;

  factory WeekDay.fromJson(Map<String, dynamic> json) => WeekDay(
        date: DateTime.parse(json['date'] as String),
        count: json['count'] as int? ?? 0,
        done: json['done'] as bool? ?? false,
      );
}

/// The design-27 summary.
class PracticeSummary {
  const PracticeSummary({
    required this.streakDays,
    required this.week,
    required this.weekTotal,
    required this.weekDaysDone,
    required this.weeklyGoal,
    required this.goalPercent,
    required this.doneToday,
    required this.todaysPractice,
    required this.practices,
  });

  final int streakDays;
  final List<WeekDay> week;
  final int weekTotal;
  final int weekDaysDone;
  final int weeklyGoal;
  final int goalPercent;
  final bool doneToday;
  final Practice? todaysPractice;
  final List<Practice> practices;

  factory PracticeSummary.fromJson(Map<String, dynamic> json) =>
      PracticeSummary(
        streakDays: json['streak_days'] as int? ?? 0,
        week: [
          for (final day in (json['week'] as List? ?? []))
            WeekDay.fromJson(day as Map<String, dynamic>)
        ],
        weekTotal: json['week_total'] as int? ?? 0,
        weekDaysDone: json['week_days_done'] as int? ?? 0,
        weeklyGoal: json['weekly_goal'] as int? ?? 7,
        goalPercent: json['goal_percent'] as int? ?? 0,
        doneToday: json['done_today'] as bool? ?? false,
        todaysPractice: json['todays_practice'] == null
            ? null
            : Practice.fromJson(
                json['todays_practice'] as Map<String, dynamic>),
        practices: [
          for (final practice in (json['practices'] as List? ?? []))
            Practice.fromJson(practice as Map<String, dynamic>)
        ],
      );
}

class PracticeRepository {
  PracticeRepository(this._dio);

  final Dio _dio;

  Future<List<Practice>> list() async {
    final res = await _dio.get<Map<String, dynamic>>('practices/');
    return [
      for (final row in (res.data?['results'] as List? ?? []))
        Practice.fromJson(row as Map<String, dynamic>)
    ];
  }

  Future<PracticeSummary> summary() async {
    final res = await _dio.get<Map<String, dynamic>>('practice/summary/');
    return PracticeSummary.fromJson(res.data!);
  }

  Future<void> log(int practiceId) async {
    await _dio.post('practice/log/', data: {'practice_id': practiceId});
  }
}

final practiceRepositoryProvider = Provider<PracticeRepository>(
    (ref) => PracticeRepository(ref.watch(dioProvider)));

/// Guest-visible practice library.
final practiceListProvider =
    FutureProvider.autoDispose<List<Practice>>((ref) {
  ref.watch(authControllerProvider);
  return ref.watch(practiceRepositoryProvider).list();
});

/// Member practice dashboard (null for guests).
final practiceSummaryProvider =
    FutureProvider.autoDispose<PracticeSummary?>((ref) async {
  if (!ref.watch(isLoggedInProvider)) return null;
  return ref.watch(practiceRepositoryProvider).summary();
});
