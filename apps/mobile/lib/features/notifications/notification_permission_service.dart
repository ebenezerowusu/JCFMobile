import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import 'notification_permission_state.dart';

/// Reading and requesting the operating system's notification permission.
///
/// An interface so the screen never touches a platform enum, and so tests
/// can drive every outcome — including the ones that are hard to produce
/// on a real device, like "permanently denied".
abstract interface class NotificationPermissionService {
  Future<NotificationPermissionStatus> getStatus();

  /// Shows the system prompt. Only ever called from an explicit tap.
  Future<NotificationPermissionStatus> requestPermission();

  Future<bool> openSystemSettings();
}

/// `permission_handler` implementation.
///
/// On Android 13+ this is the POST_NOTIFICATIONS runtime permission. On
/// Android 12 and earlier there is no runtime permission, and the plugin
/// reports granted unless the reader has turned notifications off for the
/// app — in which case only Settings can turn them back on, so that maps
/// to permanentlyDenied rather than to something we could re-ask for.
class PlatformNotificationPermissionService
    implements NotificationPermissionService {
  const PlatformNotificationPermissionService();

  @override
  Future<NotificationPermissionStatus> getStatus() async {
    if (kIsWeb) return NotificationPermissionStatus.unsupported;
    try {
      return _map(await Permission.notification.status);
    } catch (_) {
      return NotificationPermissionStatus.error;
    }
  }

  @override
  Future<NotificationPermissionStatus> requestPermission() async {
    if (kIsWeb) return NotificationPermissionStatus.unsupported;
    try {
      return _map(await Permission.notification.request());
    } catch (_) {
      return NotificationPermissionStatus.error;
    }
  }

  @override
  Future<bool> openSystemSettings() async {
    try {
      return await openAppSettings();
    } catch (_) {
      return false;
    }
  }

  NotificationPermissionStatus _map(PermissionStatus status) =>
      switch (status) {
        PermissionStatus.granted => NotificationPermissionStatus.authorized,
        PermissionStatus.limited ||
        PermissionStatus.provisional =>
          NotificationPermissionStatus.provisionallyAuthorized,
        PermissionStatus.denied =>
          NotificationPermissionStatus.notDetermined,
        // Asking again would do nothing; only Settings can change it.
        PermissionStatus.permanentlyDenied =>
          NotificationPermissionStatus.permanentlyDenied,
        PermissionStatus.restricted =>
          NotificationPermissionStatus.restricted,
      };
}

final notificationPermissionServiceProvider =
    Provider<NotificationPermissionService>(
        (ref) => const PlatformNotificationPermissionService());
