import 'package:flutter/foundation.dart';

/// Asset paths, named once so a filename cannot drift.
class NotificationPermissionAssets {
  NotificationPermissionAssets._();

  /// WebP keeps the transparency and is 117KB against 1340KB as a PNG.
  static const String bell =
      'assets/images/notification_permission/notification_permission_bell.webp';

  /// The same file the splash, welcome, onboarding and language screens
  /// use — one piece of artwork, not five copies in the bundle.
  static const String brandLogo =
      'assets/images/splash/splash_brand_logo.png';
}

/// Notification permission, described in the app's own terms rather than
/// either platform's.
///
/// Android and iOS disagree about what "denied" means — iOS distinguishes
/// "not asked yet" from "said no", Android 12 and earlier have no runtime
/// permission at all — so the screen reasons about this, never about a
/// platform enum.
enum NotificationPermissionStatus {
  unknown,

  /// Never asked. The only state in which asking is appropriate.
  notDetermined,
  requesting,
  authorized,

  /// iOS provisional: notifications arrive quietly, without a prompt.
  provisionallyAuthorized,

  /// Declined, but asking again later may still be allowed.
  denied,

  /// Declined for good. Asking again does nothing but waste a tap —
  /// only Settings can change this.
  permanentlyDenied,

  /// Blocked by policy or parental controls; not the reader's choice.
  restricted,
  unsupported,
  error,
}

extension NotificationPermissionStatusX on NotificationPermissionStatus {
  bool get isAuthorized =>
      this == NotificationPermissionStatus.authorized ||
      this == NotificationPermissionStatus.provisionallyAuthorized;

  /// Whether asking the operating system could still achieve anything.
  bool get canRequest =>
      this == NotificationPermissionStatus.notDetermined ||
      this == NotificationPermissionStatus.unknown ||
      this == NotificationPermissionStatus.denied;

  /// Whether the only remaining route is the system settings app.
  bool get needsSettings =>
      this == NotificationPermissionStatus.permanentlyDenied ||
      this == NotificationPermissionStatus.restricted;
}

/// Where the primer was opened from. It decides where "continue" goes,
/// not what the screen is allowed to ask for.
enum NotificationPermissionEntryPoint {
  onboarding,
  settings,
  contextualPrompt,
}

/// Which message the screen has to show, if any. A separate axis from the
/// permission status because "we could not save your choice" and "you said
/// no" are different problems with different remedies.
enum NotificationPermissionFailure {
  none,

  /// The OS request itself threw. Retryable.
  requestFailed,

  /// Permission is held, but the device could not be registered for remote
  /// notifications — so nothing will actually arrive.
  registrationFailed,

  /// The preference could not be written. Retryable.
  saveFailed,

  /// Settings would not open. Fall back to telling the reader where to go.
  settingsUnavailable,
}

@immutable
class NotificationPermissionState {
  const NotificationPermissionState({
    this.status = NotificationPermissionStatus.unknown,
    this.entryPoint = NotificationPermissionEntryPoint.onboarding,
    this.primerPreviouslyShown = false,
    this.userDeferred = false,
    this.isRequesting = false,
    this.isRegisteringDevice = false,
    this.deviceRegistered = false,
    this.failure = NotificationPermissionFailure.none,
  });

  final NotificationPermissionStatus status;
  final NotificationPermissionEntryPoint entryPoint;
  final bool primerPreviouslyShown;

  /// The reader chose Not now. Deliberately distinct from an OS denial:
  /// one is "not yet", the other is "no".
  final bool userDeferred;
  final bool isRequesting;
  final bool isRegisteringDevice;

  /// Whether this device is genuinely reachable by the server. Permission
  /// alone does not make it so, and the screen must not claim it does.
  final bool deviceRegistered;
  final NotificationPermissionFailure failure;

  bool get isAuthorized => status.isAuthorized;

  bool get needsSettings => status.needsSettings;

  bool get isBusy => isRequesting || isRegisteringDevice;

  /// Enable is only offered while asking could still do something.
  bool get canEnable => status.canRequest && !isBusy;

  /// Whether a system settings trip is worth offering. Only where the OS
  /// can still be changed — never for `unsupported`, where there is no
  /// notification setting to find.
  bool get canOpenSettings =>
      status == NotificationPermissionStatus.permanentlyDenied ||
      status == NotificationPermissionStatus.denied ||
      (entryPoint == NotificationPermissionEntryPoint.settings &&
          status != NotificationPermissionStatus.unsupported);

  /// Nothing here may block the app. Every outcome continues.
  bool get canContinue => !isBusy;

  /// Whether the reader has reached an outcome, rather than still looking
  /// at the explanation.
  bool get hasResult =>
      isAuthorized ||
      status == NotificationPermissionStatus.denied ||
      needsSettings ||
      status == NotificationPermissionStatus.unsupported;

  NotificationPermissionState copyWith({
    NotificationPermissionStatus? status,
    NotificationPermissionEntryPoint? entryPoint,
    bool? primerPreviouslyShown,
    bool? userDeferred,
    bool? isRequesting,
    bool? isRegisteringDevice,
    bool? deviceRegistered,
    NotificationPermissionFailure? failure,
  }) =>
      NotificationPermissionState(
        status: status ?? this.status,
        entryPoint: entryPoint ?? this.entryPoint,
        primerPreviouslyShown:
            primerPreviouslyShown ?? this.primerPreviouslyShown,
        userDeferred: userDeferred ?? this.userDeferred,
        isRequesting: isRequesting ?? this.isRequesting,
        isRegisteringDevice: isRegisteringDevice ?? this.isRegisteringDevice,
        deviceRegistered: deviceRegistered ?? this.deviceRegistered,
        failure: failure ?? this.failure,
      );
}
