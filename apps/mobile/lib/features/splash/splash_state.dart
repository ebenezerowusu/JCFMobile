import 'package:flutter/foundation.dart';

/// Asset paths, named once so a filename cannot drift.
class SplashAssets {
  SplashAssets._();

  static const String brandLogo =
      'assets/images/splash/splash_brand_logo.png';

  /// WebP rather than PNG: this is a full-screen gradient the Flutter side
  /// alone renders, and it is 121KB here against 1.5MB as a PNG. The logo
  /// stays PNG because flutter_native_splash generates the native
  /// drawables from it.
  static const String cosmicBackground =
      'assets/images/splash/splash_cosmic_background.webp';
}

/// Where startup has got to. An explicit model, because inferring "are we
/// still loading" from a handful of booleans is how a splash ends up stuck
/// on a spinner that nothing will ever clear.
enum SplashStage {
  initializing,
  restoringSession,
  loadingConfiguration,
  ready,
  offlineReady,
  updateRequired,
  maintenance,
  recoverableError,
  fatalError,
}

/// The routes bootstrap is allowed to send someone to.
///
/// The server may suggest an `initial_route`, but it is checked against
/// this list before use. A route name that arrives over the network is
/// data, never an instruction — without this, the API could navigate the
/// app anywhere it liked.
const splashRouteAllowlist = <String>{
  '/home',
  '/welcome',
  '/onboarding',
  '/language-selection',
  '/lessons',
  '/practice',
  '/programs',
  '/more',
  '/activities',
  '/learning/continue',
  '/announcements',
};

/// Returns [route] when the app is willing to navigate there, else null.
String? allowedRoute(String? route) {
  if (route == null || route.isEmpty) return null;
  // Only exact matches: a prefix test would let "/home/../admin" through,
  // and an external URL must never reach the router at all.
  return splashRouteAllowlist.contains(route) ? route : null;
}

@immutable
class MaintenanceInfo {
  const MaintenanceInfo({
    required this.enabled,
    this.title,
    this.message,
    this.allowOffline = false,
  });

  final bool enabled;
  final String? title;
  final String? message;
  final bool allowOffline;

  factory MaintenanceInfo.fromJson(Map<String, dynamic>? json) =>
      MaintenanceInfo(
        enabled: json?['enabled'] as bool? ?? false,
        title: json?['title'] as String?,
        message: json?['message'] as String?,
        allowOffline: json?['allow_offline'] as bool? ?? false,
      );
}

@immutable
class VersionInfo {
  const VersionInfo({
    this.updateRequired = false,
    this.minimumSupported = '',
    this.latest = '',
    this.storeUrl,
  });

  final bool updateRequired;
  final String minimumSupported;
  final String latest;
  final String? storeUrl;

  /// Only an official store link is ever opened. A URL from the network is
  /// otherwise a way to send someone anywhere.
  String? get safeStoreUrl {
    final url = storeUrl;
    if (url == null) return null;
    final uri = Uri.tryParse(url);
    if (uri == null || uri.scheme != 'https') return null;
    const hosts = {'apps.apple.com', 'itunes.apple.com', 'play.google.com'};
    return hosts.contains(uri.host) ? url : null;
  }

  factory VersionInfo.fromJson(Map<String, dynamic>? json) => VersionInfo(
        updateRequired: json?['update_required'] as bool? ?? false,
        minimumSupported: json?['minimum_supported'] as String? ?? '',
        latest: json?['latest'] as String? ?? '',
        storeUrl: json?['store_url'] as String?,
      );
}

@immutable
class BootstrapResult {
  const BootstrapResult({
    required this.stage,
    this.destination = '/welcome',
    this.maintenance = const MaintenanceInfo(enabled: false),
    this.version = const VersionInfo(),
    this.offlineEligible = false,
    this.error,
  });

  final SplashStage stage;
  final String destination;
  final MaintenanceInfo maintenance;
  final VersionInfo version;

  /// Whether Continue Offline is genuinely available — never merely
  /// because the network failed.
  final bool offlineEligible;
  final Object? error;

  bool get canProceed =>
      stage == SplashStage.ready || stage == SplashStage.offlineReady;
}

@immutable
class SplashScreenState {
  const SplashScreenState({
    this.stage = SplashStage.initializing,
    this.result,
    this.slow = false,
    this.retrying = false,
  });

  final SplashStage stage;
  final BootstrapResult? result;

  /// True once startup has taken long enough to say so.
  final bool slow;
  final bool retrying;

  bool get isLoading =>
      stage == SplashStage.initializing ||
      stage == SplashStage.restoringSession ||
      stage == SplashStage.loadingConfiguration;

  SplashScreenState copyWith({
    SplashStage? stage,
    BootstrapResult? result,
    bool? slow,
    bool? retrying,
  }) =>
      SplashScreenState(
        stage: stage ?? this.stage,
        result: result ?? this.result,
        slow: slow ?? this.slow,
        retrying: retrying ?? this.retrying,
      );
}
