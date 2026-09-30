import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_bootstrap_service.dart';
import 'splash_state.dart';

/// How long startup may take before the wording acknowledges the wait.
const slowStartupThreshold = Duration(seconds: 4);

/// Long enough that an instant launch does not flash the splash and vanish,
/// short enough that nobody waits for branding. This is a floor, not a
/// delay: a launch slower than this is never held back.
const minimumSplashDisplay = Duration(milliseconds: 400);

class SplashController extends Notifier<SplashScreenState> {
  late AppBootstrapService _service;
  Timer? _slowTimer;

  /// Guards against two bootstraps racing — a rebuild, or an impatient
  /// second tap on Try Again.
  bool _running = false;
  DateTime? _startedAt;

  @override
  SplashScreenState build() {
    _service = ref.watch(appBootstrapServiceProvider);
    ref.onDispose(() => _slowTimer?.cancel());
    Future.microtask(start);
    return const SplashScreenState();
  }

  Future<void> start({bool retry = false}) async {
    if (_running) return;
    _running = true;
    _startedAt = DateTime.now();

    state = state.copyWith(
      stage: SplashStage.restoringSession,
      slow: false,
      retrying: retry,
    );

    _slowTimer?.cancel();
    _slowTimer = Timer(slowStartupThreshold, () {
      if (state.isLoading) state = state.copyWith(slow: true);
    });

    BootstrapResult result;
    try {
      result = await _service.run();
    } catch (error) {
      // Nothing is allowed to leave the splash on an endless spinner, so
      // even an unexpected throw becomes a state the screen can render.
      result = BootstrapResult(
        stage: SplashStage.recoverableError,
        error: error,
      );
    }

    await _holdForMinimumDisplay();

    _slowTimer?.cancel();
    _running = false;
    state = state.copyWith(
      stage: result.stage,
      result: result,
      slow: false,
      retrying: false,
    );
  }

  /// Keeps a very fast launch on screen just long enough not to flash.
  Future<void> _holdForMinimumDisplay() async {
    final startedAt = _startedAt;
    if (startedAt == null) return;
    final elapsed = DateTime.now().difference(startedAt);
    if (elapsed < minimumSplashDisplay) {
      await Future<void>.delayed(minimumSplashDisplay - elapsed);
    }
  }

  Future<void> retry() => start(retry: true);

  /// Proceeds with what is cached. Only reachable when bootstrap said the
  /// app is genuinely eligible, never merely because a request failed.
  void continueOffline() {
    final result = state.result;
    if (result == null || !result.offlineEligible) return;
    state = state.copyWith(
      stage: SplashStage.offlineReady,
      result: BootstrapResult(
        stage: SplashStage.offlineReady,
        destination: result.destination,
        maintenance: result.maintenance,
        version: result.version,
        offlineEligible: true,
      ),
    );
  }
}

final splashControllerProvider =
    NotifierProvider<SplashController, SplashScreenState>(
        SplashController.new);
