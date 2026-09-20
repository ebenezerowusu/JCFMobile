import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Records the "Stay connected" choice. When FCM lands (Track 6), enabling
/// here is where the OS permission request + token registration will hook in.
class NotificationPrefs {
  static const _promptedKey = 'notify_prompted';
  static const _optedInKey = 'notify_opted_in';

  Future<bool> wasPrompted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_promptedKey) ?? false;
  }

  Future<void> choose({required bool optedIn}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_promptedKey, true);
    await prefs.setBool(_optedInKey, optedIn);
  }
}

final notificationPrefsProvider =
    Provider<NotificationPrefs>((ref) => NotificationPrefs());
