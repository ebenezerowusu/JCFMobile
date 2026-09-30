import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Remembers that the reader has made their choice on the Welcome screen.
///
/// Separate from onboarding: finishing the carousel and deciding how to
/// enter are different facts, and conflating them is what makes a welcome
/// screen reappear after someone has already answered it.
///
/// Guest mode here is purely local. Nothing about it grants access —
/// every protected surface still asks the server — so there is no session
/// to create and no identifier to store.
class WelcomePrefs {
  static const _guestKey = 'welcome.guest_chosen.v1';

  Future<bool> guestChosen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_guestKey) ?? false;
    } catch (_) {
      // Unreadable preferences mean "not yet chosen", which shows the
      // Welcome screen again — harmless, and better than crashing a launch.
      return false;
    }
  }

  Future<void> chooseGuest() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_guestKey, true);
  }

  /// Called on sign-out so the reader is asked again rather than being
  /// silently returned to a guest session they did not choose this time.
  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_guestKey);
    } catch (_) {
      // Nothing to do; the next read simply misses.
    }
  }
}

final welcomePrefsProvider = Provider<WelcomePrefs>((ref) => WelcomePrefs());
