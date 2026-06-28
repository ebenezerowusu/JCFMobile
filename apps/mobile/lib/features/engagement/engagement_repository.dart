import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcf_models/jcf_models.dart';

import '../../core/providers.dart';
import '../auth/auth_controller.dart';

class EngagementRepository {
  EngagementRepository(this._dio);
  final Dio _dio;

  Future<Paginated<Announcement>> announcements() async {
    final res = await _dio.get<Map<String, dynamic>>('announcements/');
    return Paginated.fromJson(res.data!, Announcement.fromJson);
  }

  Future<Paginated<AppNotification>> notifications() async {
    final res = await _dio.get<Map<String, dynamic>>('notifications/');
    return Paginated.fromJson(res.data!, AppNotification.fromJson);
  }

  Future<void> markRead(int id) async {
    await _dio.post('notifications/$id/read/');
  }

  Future<Paginated<Appointment>> appointments() async {
    final res = await _dio.get<Map<String, dynamic>>('appointments/');
    return Paginated.fromJson(res.data!, Appointment.fromJson);
  }

  Future<void> bookAppointment({
    required String mode,
    required String scheduledDate,
    String note = '',
  }) async {
    await _dio.post('appointments/book/', data: {
      'mode': mode,
      'scheduled_date': scheduledDate,
      'note': note,
    });
  }

  Future<void> registerDevice({required String token, required String platform}) async {
    await _dio.post('devices/register/', data: {'token': token, 'platform': platform});
  }
}

final engagementRepositoryProvider = Provider<EngagementRepository>(
  (ref) => EngagementRepository(ref.watch(dioProvider)),
);

final announcementsProvider = FutureProvider.autoDispose<Paginated<Announcement>>((ref) {
  ref.watch(authControllerProvider);
  return ref.watch(engagementRepositoryProvider).announcements();
});

final notificationsProvider = FutureProvider.autoDispose<Paginated<AppNotification>>(
  (ref) => ref.watch(engagementRepositoryProvider).notifications(),
);

final appointmentsProvider = FutureProvider.autoDispose<Paginated<Appointment>>(
  (ref) => ref.watch(engagementRepositoryProvider).appointments(),
);
