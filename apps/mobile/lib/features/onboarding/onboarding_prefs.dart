import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The onboarding the app currently ships.
///
/// Raise this only when the sequence changes materially enough that
/// someone who has already seen it should see it again — new pages, a
/// different proposition. Not for wording or styling, which would drag
/// every existing member back through a carousel they have answered.
const currentOnboardingVersion = 1;

/// Persists how far through onboarding the reader has got.
///
/// A version rather than a boolean, so a genuinely new onboarding can be
/// shown later without clearing application data — which would take
/// everything else with it.
class OnboardingPrefs {
  static const _versionKey = 'onboarding_seen_version';
  static const _completedAtKey = 'onboarding_completed_at';
  static const _methodKey = 'onboarding_completion_method';

  /// The original boolean. Still read so that anyone who onboarded on an
  /// earlier build is not asked again.
  static const _legacyKey = 'onboarding_seen';

  Future<int> seenVersion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final version = prefs.getInt(_versionKey);
      if (version != null) return version;
      // Migrate: the old flag meant "saw version 1".
      return (prefs.getBool(_legacyKey) ?? false) ? 1 : 0;
    } catch (_) {
      // Unreadable preferences mean "not seen", which shows onboarding
      // again — harmless, and better than failing a launch.
      return 0;
    }
  }

  /// True when the reader has seen onboarding at least as new as the one
  /// this build ships.
  Future<bool> isSeen() async =>
      await seenVersion() >= currentOnboardingVersion;

  /// Records completion. [method] is 'completed' or 'skipped' — kept
  /// because the two mean different things to whoever reads the numbers,
  /// even though they lead to the same screen.
  Future<void> markSeen({String method = 'completed'}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_versionKey, currentOnboardingVersion);
    await prefs.setString(
        _completedAtKey, DateTime.now().toIso8601String());
    await prefs.setString(_methodKey, method);
    // Keep the legacy flag true so an older build installed side by side
    // does not start asking again.
    await prefs.setBool(_legacyKey, true);
  }

  Future<void> reset() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_versionKey);
      await prefs.remove(_completedAtKey);
      await prefs.remove(_methodKey);
      await prefs.remove(_legacyKey);
    } catch (_) {
      // Nothing to do; the next read simply misses.
    }
  }
}

final onboardingPrefsProvider =
    Provider<OnboardingPrefs>((ref) => OnboardingPrefs());
