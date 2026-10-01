import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notification_permission_service.dart';
import 'notification_permission_state.dart';
import 'notification_primer_prefs.dart';
import 'push_registration_service.dart';

/// The primer's behaviour.
///
/// The one rule everything here is arranged around: the operating system
/// is asked only from [enableNotifications], and only once per tap. Not
/// now records a deferral and never touches the OS — a reader who has not
/// said yes has not been asked.
class NotificationPermissionController
    extends Notifier<NotificationPermissionState> {
  @override
  NotificationPermissionState build() => const NotificationPermissionState();

  NotificationPermissionService get _permissions =>
      ref.read(notificationPermissionServiceProvider);

  PushRegistrationService get _push =>
      ref.read(pushRegistrationServiceProvider);

  NotificationPrimerPrefs get _prefs =>
      ref.read(notificationPrimerPrefsProvider);

  /// Reads the real OS status and what the reader has already been asked.
  ///
  /// Called once when the screen opens. It never requests permission —
  /// reading a status does not prompt on either platform.
  Future<void> initialize(
      NotificationPermissionEntryPoint entryPoint) async {
    final status = await _permissions.getStatus();
    final shownVersion = await _prefs.shownVersion();
    final decision = await _prefs.decision();

    state = state.copyWith(
      status: status,
      entryPoint: entryPoint,
      primerPreviouslyShown: shownVersion > 0,
      userDeferred: decision == PrimerDecision.deferred,
    );
  }

  /// Whether the screen should get out of the way without being seen.
  ///
  /// Only during onboarding, and only when permission is already held:
  /// opened from Settings the reader asked to be here, so the screen shows
  /// the current state instead of vanishing.
  bool get shouldSkip =>
      state.entryPoint == NotificationPermissionEntryPoint.onboarding &&
      state.isAuthorized;

  /// The only path that may prompt the operating system.
  Future<void> enableNotifications() async {
    // A second tap while the first is in flight would stack system
    // prompts on Android and be ignored on iOS. Neither is useful.
    if (state.isBusy) return;
    if (!state.status.canRequest && !state.isAuthorized) return;

    state = state.copyWith(
      isRequesting: true,
      failure: NotificationPermissionFailure.none,
    );

    NotificationPermissionStatus status;
    try {
      // Re-read first: permission may have been granted in Settings since
      // this screen opened, and prompting again would be a wasted tap.
      status = await _permissions.getStatus();
      if (!status.isAuthorized) {
        status = await _permissions.requestPermission();
      }
    } catch (_) {
      state = state.copyWith(
        isRequesting: false,
        failure: NotificationPermissionFailure.requestFailed,
      );
      return;
    }

    state = state.copyWith(status: status, isRequesting: false);

    if (status == NotificationPermissionStatus.error) {
      state = state.copyWith(
          failure: NotificationPermissionFailure.requestFailed);
      return;
    }

    if (status.isAuthorized) {
      await _recordDecision(PrimerDecision.enabled);
      await _registerDevice(status);
      return;
    }

    // Denied, permanently denied, restricted, unsupported: record that the
    // reader was asked so the primer does not reappear, and let them move
    // on. No second request, here or on the next launch.
    await _recordDecision(PrimerDecision.deferred);
  }

  /// Records the deferral. Deliberately does not call the OS.
  ///
  /// Returns true when the caller may navigate on. A failed write still
  /// returns false so the reader is not asked the same thing again on the
  /// next launch as if nothing had happened.
  Future<bool> notNow() async {
    if (state.isBusy) return false;
    state = state.copyWith(
        userDeferred: true, failure: NotificationPermissionFailure.none);
    return _recordDecision(PrimerDecision.deferred);
  }

  Future<bool> _recordDecision(PrimerDecision decision) async {
    try {
      await _prefs.record(decision);
      return true;
    } catch (_) {
      state = state.copyWith(
          failure: NotificationPermissionFailure.saveFailed);
      return false;
    }
  }

  /// Sends this device's push token to the backend.
  ///
  /// Permission without registration means the reader has agreed to
  /// notifications that cannot arrive, so the outcome is shown rather than
  /// swallowed — except where no provider exists at all, which is the
  /// app's own gap and not something the reader can retry away.
  Future<void> _registerDevice(NotificationPermissionStatus status) async {
    state = state.copyWith(isRegisteringDevice: true);
    final result = await _push.registerDevice(permissionStatus: status);
    state = state.copyWith(
      isRegisteringDevice: false,
      deviceRegistered: result.isRegistered,
      failure: result.isRetryable
          ? NotificationPermissionFailure.registrationFailed
          : NotificationPermissionFailure.none,
    );
  }

  /// Retries whatever failed, rather than guessing from the button.
  Future<void> retry() async {
    switch (state.failure) {
      case NotificationPermissionFailure.registrationFailed:
        state =
            state.copyWith(failure: NotificationPermissionFailure.none);
        await _registerDevice(state.status);
      case NotificationPermissionFailure.saveFailed:
        await _recordDecision(state.isAuthorized
            ? PrimerDecision.enabled
            : PrimerDecision.deferred);
      case NotificationPermissionFailure.requestFailed:
        state =
            state.copyWith(failure: NotificationPermissionFailure.none);
        await enableNotifications();
      case NotificationPermissionFailure.settingsUnavailable:
      case NotificationPermissionFailure.none:
        break;
    }
  }

  /// Opens the system settings app. Not a permission request.
  Future<void> openSettings() async {
    if (state.isBusy) return;
    final opened = await _permissions.openSystemSettings();
    state = state.copyWith(
      failure: opened
          ? NotificationPermissionFailure.none
          // Tell the reader where to go by hand rather than showing a
          // platform exception.
          : NotificationPermissionFailure.settingsUnavailable,
    );
  }

  /// Re-reads the OS status, for coming back from Settings.
  Future<void> refreshStatus() async {
    final status = await _permissions.getStatus();
    if (status == state.status) return;
    state = state.copyWith(status: status);
    // Granting it in Settings deserves the same registration that
    // granting it in the prompt would have had.
    if (status.isAuthorized && !state.deviceRegistered) {
      await _recordDecision(PrimerDecision.enabled);
      await _registerDevice(status);
    }
  }
}

final notificationPermissionControllerProvider = NotifierProvider<
    NotificationPermissionController,
    NotificationPermissionState>(NotificationPermissionController.new);
