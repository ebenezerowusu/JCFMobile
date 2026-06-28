import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists whether the user has completed onboarding.
class OnboardingPrefs {
  static const _key = 'onboarding_seen';

  Future<bool> isSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}

final onboardingPrefsProvider = Provider<OnboardingPrefs>((ref) => OnboardingPrefs());
