import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../welcome/welcome_widgets.dart' show warmWhite, deepNavy;
import 'notification_permission_controller.dart';
import 'notification_permission_state.dart';
import 'notification_permission_widgets.dart';

/// Where the primer is allowed to send the reader next.
///
/// An allowlist rather than a free-text return route: a destination that
/// arrives from a notification payload or a deep link must not be able to
/// turn this screen into an open redirect.
const notificationPrimerReturnAllowlist = <String>{
  '/home',
  '/more',
  '/lessons',
  '/practice',
  '/programs',
  '/activities',
  '/learning/continue',
};

String notificationPrimerReturnRoute(String? requested) =>
    requested != null && notificationPrimerReturnAllowlist.contains(requested)
        ? requested
        : '/home';

/// Notification Permission Primer (owner spec).
///
/// An explanation, not the system dialog. The operating system is asked
/// only when the reader taps Enable notifications; Not now records the
/// deferral and moves on without prompting. Nothing on this screen can
/// stop someone using the app.
class NotificationPermissionScreen extends ConsumerStatefulWidget {
  const NotificationPermissionScreen({
    super.key,
    this.entryPoint = NotificationPermissionEntryPoint.onboarding,
    this.returnRoute,
  });

  final NotificationPermissionEntryPoint entryPoint;

  /// Where to go when the reader is done, for the onboarding and
  /// contextual entry points. Validated against the allowlist.
  final String? returnRoute;

  @override
  ConsumerState<NotificationPermissionScreen> createState() =>
      _NotificationPermissionScreenState();
}

class _NotificationPermissionScreenState
    extends ConsumerState<NotificationPermissionScreen>
    with WidgetsBindingObserver {
  bool _initialized = false;
  bool _leaving = false;

  bool get _isOnboarding =>
      widget.entryPoint == NotificationPermissionEntryPoint.onboarding;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Permission may have been granted or revoked in the system settings
    // app while this screen was in the background.
    if (state == AppLifecycleState.resumed && _initialized) {
      ref
          .read(notificationPermissionControllerProvider.notifier)
          .refreshStatus();
    }
  }

  Future<void> _initialize() async {
    final controller =
        ref.read(notificationPermissionControllerProvider.notifier);
    await controller.initialize(widget.entryPoint);
    if (!mounted) return;
    setState(() => _initialized = true);
    // Already allowed, and nobody asked to be here: say nothing and get
    // out of the way.
    if (controller.shouldSkip) _continue();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final state = ref.watch(notificationPermissionControllerProvider);
    final media = MediaQuery.of(context);
    // The illustration yields space first on a short device; the pinned
    // footer below means it is never competing with the actions.
    final illustration = media.size.height < 680 ? 150.0 : 200.0;

    return Scaffold(
      backgroundColor: warmWhite,
      appBar: _isOnboarding
          ? null
          : AppBar(
              backgroundColor: warmWhite,
              surfaceTintColor: warmWhite,
              foregroundColor: deepNavy,
              title: Text(t.notificationSettingsTitle),
            ),
      body: PopScope(
        // Nothing behind this during onboarding that should be returned
        // to; from Settings, back is ordinary.
        canPop: !_isOnboarding,
        child: NotificationPermissionCanvas(
          // The explanation scrolls; the decision does not. Both actions
          // and the line promising this can be changed later stay on
          // screen at every size and text scale — a reader must never
          // have to scroll to find out that saying no is easy.
          child: Column(
            children: [
              Expanded(
                child: SafeArea(
                  bottom: false,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                    child: Column(
                      children: [
                        if (_isOnboarding) ...[
                          const NotificationPermissionLogo(),
                          const SizedBox(height: 4),
                        ],
                        NotificationPermissionIllustration(
                            size: illustration),
                        const SizedBox(height: 4),
                        const NotificationPermissionIntro(),
                        const SizedBox(height: 16),
                        if (state.hasResult)
                          _outcome(t, state)
                        else
                          const NotificationBenefitList(),
                      ],
                    ),
                  ),
                ),
              ),
              // A hairline, so content scrolling under the footer reads as
              // "there is more above" rather than as a clipped row.
              DecoratedBox(
                decoration: const BoxDecoration(
                  color: warmWhite,
                  border: Border(top: BorderSide(color: Color(0xFFE3E6EC))),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_failureMessage(t, state) case final message?) ...[
                          NotificationPermissionError(
                            message: message,
                            onRetry: _retryable(state)
                                ? () => ref
                                    .read(
                                        notificationPermissionControllerProvider
                                            .notifier)
                                    .retry()
                                : null,
                          ),
                          const SizedBox(height: 12),
                        ],
                        _actions(t, state),
                        const SizedBox(height: 10),
                        const NotificationPermissionControlNote(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- pieces ---------------------------------------------------------

  Widget _outcome(AppLocalizations t, NotificationPermissionState state) {
    if (state.isAuthorized) {
      return NotificationPermissionResult(
        title: t.notificationPermissionEnabled,
        // Permission is not delivery. Say which one the reader has.
        message: state.deviceRegistered
            ? ''
            : t.notificationPermissionNotReachableMessage,
        granted: true,
      );
    }
    if (state.status == NotificationPermissionStatus.permanentlyDenied) {
      return NotificationSettingsGuidance(
        title: t.notificationPermissionBlockedTitle,
        message: t.notificationPermissionBlockedMessage,
      );
    }
    if (state.status == NotificationPermissionStatus.restricted) {
      return NotificationSettingsGuidance(
        title: t.notificationPermissionBlockedTitle,
        message: t.notificationPermissionRestrictedMessage,
      );
    }
    if (state.status == NotificationPermissionStatus.unsupported) {
      return NotificationSettingsGuidance(
        title: t.notificationPermissionDeniedTitle,
        message: t.notificationPermissionUnsupportedMessage,
      );
    }
    return NotificationSettingsGuidance(
      title: t.notificationPermissionDeniedTitle,
      message: t.notificationPermissionDeniedMessage,
    );
  }

  Widget _actions(AppLocalizations t, NotificationPermissionState state) {
    // Permission held: there is nothing left to ask for.
    if (state.isAuthorized) {
      return NotificationPermissionActions(
        primaryLabel: _isOnboarding
            ? t.notificationPermissionContinue
            : t.notificationPermissionDone,
        onPrimary: state.canContinue ? _continue : null,
        secondaryLabel: t.notificationPermissionOpenSettings,
        onSecondary: _openSettings,
        loading: state.isRegisteringDevice,
        loadingLabel: t.notificationPermissionRequesting,
      );
    }

    // Blocked or restricted: asking again would do nothing, so the only
    // real action is Settings — offered, never insisted on.
    if (state.needsSettings ||
        state.status == NotificationPermissionStatus.denied) {
      return NotificationPermissionActions(
        primaryLabel: t.notificationPermissionOpenSettings,
        onPrimary: state.canOpenSettings ? _openSettings : null,
        secondaryLabel: t.notificationPermissionContinueWithout,
        onSecondary: _continue,
      );
    }

    if (state.status == NotificationPermissionStatus.unsupported) {
      return NotificationPermissionActions(
        primaryLabel: t.notificationPermissionContinue,
        onPrimary: _continue,
        secondaryLabel: t.notificationPermissionContinueWithout,
        onSecondary: _continue,
      );
    }

    return NotificationPermissionActions(
      primaryLabel: t.notificationPermissionEnable,
      onPrimary: state.canEnable ? _enable : null,
      secondaryLabel: t.notificationPermissionNotNow,
      onSecondary: _notNow,
      loading: state.isBusy,
      loadingLabel: t.notificationPermissionRequesting,
    );
  }

  String? _failureMessage(
      AppLocalizations t, NotificationPermissionState state) =>
      switch (state.failure) {
        NotificationPermissionFailure.requestFailed =>
          t.notificationPermissionRequestFailed,
        NotificationPermissionFailure.registrationFailed =>
          t.notificationPermissionRegistrationFailed,
        NotificationPermissionFailure.saveFailed =>
          t.notificationPermissionSaveFailed,
        NotificationPermissionFailure.settingsUnavailable =>
          t.notificationPermissionSettingsUnavailable,
        NotificationPermissionFailure.none => null,
      };

  /// Settings cannot be retried into working, so it gets instructions
  /// instead of a button that would fail the same way again.
  bool _retryable(NotificationPermissionState state) =>
      state.failure != NotificationPermissionFailure.none &&
      state.failure != NotificationPermissionFailure.settingsUnavailable;

  // --- actions --------------------------------------------------------

  Future<void> _enable() async {
    await ref
        .read(notificationPermissionControllerProvider.notifier)
        .enableNotifications();
    // Deliberately no automatic navigation: the result is shown and the
    // reader moves on when they have read it.
  }

  Future<void> _notNow() async {
    final saved = await ref
        .read(notificationPermissionControllerProvider.notifier)
        .notNow();
    // A failed write keeps the reader here with a retry rather than
    // continuing and asking the same question again next launch.
    if (saved) _continue();
  }

  Future<void> _openSettings() => ref
      .read(notificationPermissionControllerProvider.notifier)
      .openSettings();

  void _continue() {
    if (_leaving || !mounted) return;
    _leaving = true;
    if (_isOnboarding) {
      // Replace: the first-run chain must not be walked backwards into.
      context.go(notificationPrimerReturnRoute(widget.returnRoute));
      return;
    }
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(notificationPrimerReturnRoute(widget.returnRoute));
    }
  }
}
