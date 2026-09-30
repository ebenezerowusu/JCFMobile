import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcf_models/jcf_models.dart';

import '../../core/providers.dart';
import '../auth/auth_controller.dart';
import '../onboarding/onboarding_prefs.dart';
import '../welcome/welcome_prefs.dart';
import 'splash_state.dart';

/// Everything that must be true before the app can show a real screen.
///
/// The splash screen observes this; it does not own the logic. Anything
/// that can wait until after navigation — analytics, preloading, content
/// sync, notification registration — is deliberately not here.
class AppBootstrapService {
  AppBootstrapService(
      this._dio, this._onboarding, this._welcome, this._session);

  final Dio _dio;
  final OnboardingPrefs _onboarding;
  final WelcomePrefs _welcome;

  /// Reads the stored session. Returns the member, or null for a guest.
  final Future<Member?> Function() _session;

  Future<BootstrapResult> run() async {
    final seenOnboarding = await _onboarding.isSeen();
    final guestChosen = await _welcome.guestChosen();

    Map<String, dynamic>? config;
    Object? networkError;
    try {
      final response =
          await _dio.get<Map<String, dynamic>>('bootstrap/');
      config = response.data;
    } on DioException catch (error) {
      networkError = error;
    } catch (error) {
      networkError = error;
    }

    final maintenance =
        MaintenanceInfo.fromJson(config?['maintenance'] as Map<String, dynamic>?);
    final version =
        VersionInfo.fromJson(config?['version'] as Map<String, dynamic>?);

    // A build the API will not speak to cannot be routed anywhere useful,
    // so this outranks every other outcome including maintenance.
    if (version.updateRequired) {
      return BootstrapResult(
        stage: SplashStage.updateRequired,
        version: version,
        maintenance: maintenance,
      );
    }

    if (maintenance.enabled) {
      return BootstrapResult(
        stage: SplashStage.maintenance,
        maintenance: maintenance,
        version: version,
        offlineEligible: maintenance.allowOffline && seenOnboarding,
      );
    }

    // The session is read locally whether or not the network answered: a
    // member who opens the app on a train is still a member.
    Member? member;
    try {
      member = await _session();
    } catch (_) {
      // A session that will not load is a guest, not a crash.
      member = null;
    }

    if (networkError != null) {
      // A first-time user with no connection goes to onboarding rather
      // than a dead end. They have nothing cached to "continue offline"
      // into, and blocking the very first launch behind a version check
      // they cannot reach is a worse failure than letting them read the
      // welcome screens — the check applies again on the next launch that
      // does reach the server, and nothing here can be used offline
      // anyway.
      if (!seenOnboarding) {
        return BootstrapResult(
          stage: SplashStage.ready,
          destination: '/onboarding',
          maintenance: maintenance,
          version: version,
        );
      }
      // A returning user gets the error, with Continue Offline offered
      // because there is genuinely something to go back to — never merely
      // because a request failed.
      return BootstrapResult(
        stage: SplashStage.recoverableError,
        destination:
            _destinationFor(member, seenOnboarding, guestChosen, config),
        maintenance: maintenance,
        version: version,
        offlineEligible: true,
        error: networkError,
      );
    }

    return BootstrapResult(
      stage: SplashStage.ready,
      destination:
          _destinationFor(member, seenOnboarding, guestChosen, config),
      maintenance: maintenance,
      version: version,
      offlineEligible: seenOnboarding,
    );
  }

  /// Where this launch should land.
  ///
  /// Onboarding first for anyone who has not finished it, then Welcome
  /// for anyone who has not yet said how they want to enter. A signed-in
  /// member skips Welcome entirely — they answered that question by
  /// signing in — and so does anyone who already chose guest, which is
  /// what stops Welcome reappearing on every launch.
  ///
  /// Members and guests both land on /home: it is one role-adaptive home
  /// rather than three routes.
  String _destinationFor(Member? member, bool seenOnboarding,
      bool guestChosen, Map<String, dynamic>? config) {
    if (!seenOnboarding) return '/onboarding';
    if (member == null && !guestChosen) return '/welcome';
    // The server may suggest a route; it is checked against the allowlist
    // before it is used, and ignored entirely if it is not on it.
    return allowedRoute(config?['initial_route'] as String?) ?? '/home';
  }
}

final appBootstrapServiceProvider = Provider<AppBootstrapService>((ref) {
  return AppBootstrapService(
    ref.watch(dioProvider),
    ref.watch(onboardingPrefsProvider),
    ref.watch(welcomePrefsProvider),
    () => ref.read(authControllerProvider.future),
  );
});
