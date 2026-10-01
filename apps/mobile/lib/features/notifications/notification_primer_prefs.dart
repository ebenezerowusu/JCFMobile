import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The explanation the app currently shows before asking.
///
/// Raise this only when the reasons given change materially. Never raise
/// it to get another go at someone who said Not now — that is the whole
/// pattern this versioning exists to make deliberate rather than casual.
const currentNotificationPrimerVersion = 1;

/// How long after Not now the primer may be offered again, if the product
/// ever decides to. Nothing re-shows it automatically today.
const primerDeferralPeriod = Duration(days: 30);

enum PrimerDecision { none, enabled, deferred }

/// What the reader has already been asked, and what they said.
class NotificationPrimerPrefs {
  static const _versionKey = 'notification_primer_version';
  static const _decisionKey = 'notification_primer_decision';
  static const _decidedAtKey = 'notification_primer_decided_at';

  Future<int> shownVersion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_versionKey) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<PrimerDecision> decision() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return switch (prefs.getString(_decisionKey)) {
        'enabled' => PrimerDecision.enabled,
        'deferred' => PrimerDecision.deferred,
        _ => PrimerDecision.none,
      };
    } catch (_) {
      return PrimerDecision.none;
    }
  }

  Future<DateTime?> decidedAt() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return DateTime.tryParse(prefs.getString(_decidedAtKey) ?? '');
    } catch (_) {
      return null;
    }
  }

  Future<void> record(PrimerDecision decision) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_versionKey, currentNotificationPrimerVersion);
    await prefs.setString(
        _decisionKey, decision == PrimerDecision.enabled
            ? 'enabled'
            : 'deferred');
    await prefs.setString(
        _decidedAtKey, DateTime.now().toIso8601String());
  }

  /// Whether the primer should be shown at all.
  ///
  /// A deferral is respected for a defined period rather than forever,
  /// but nothing in the app re-shows it on its own — this exists so a
  /// contextual prompt can ask the question honestly later.
  Future<bool> shouldShow({DateTime? now}) async {
    if (await shownVersion() < currentNotificationPrimerVersion) {
      return true;
    }
    final decided = await decision();
    if (decided == PrimerDecision.enabled) return false;
    final when = await decidedAt();
    if (when == null) return true;
    return (now ?? DateTime.now()).difference(when) > primerDeferralPeriod;
  }
}

final notificationPrimerPrefsProvider =
    Provider<NotificationPrimerPrefs>((ref) => NotificationPrimerPrefs());
