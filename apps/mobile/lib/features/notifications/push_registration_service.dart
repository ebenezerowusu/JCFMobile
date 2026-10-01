import 'dart:convert' show base64Url;
import 'dart:io' show Platform;
import 'dart:math' show Random;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/providers.dart';
import 'notification_permission_state.dart';

/// Why a registration attempt ended as it did.
enum PushRegistrationOutcome {
  registered,

  /// No push provider is configured, so there is no token to send. Not a
  /// failure of this device or of the network — there is simply nothing
  /// to register yet.
  noProvider,

  /// The provider refused to issue a token (permission revoked at the
  /// provider level, Play Services missing, and so on).
  noToken,

  /// The backend could not be reached or refused the registration. Worth
  /// retrying later.
  failed,
}

@immutable
class PushRegistrationResult {
  const PushRegistrationResult(this.outcome);

  const PushRegistrationResult.registered()
      : outcome = PushRegistrationOutcome.registered;

  final PushRegistrationOutcome outcome;

  bool get isRegistered => outcome == PushRegistrationOutcome.registered;

  /// Whether a later attempt could plausibly succeed. `noProvider` cannot
  /// — nothing changes until the app ships a push provider — so retrying
  /// it would just burn requests.
  bool get isRetryable => outcome == PushRegistrationOutcome.failed ||
      outcome == PushRegistrationOutcome.noToken;
}

/// Registering this device to receive remote notifications.
///
/// Separate from permission on purpose: being allowed to show a
/// notification and being reachable by the server are different things,
/// and conflating them is how an app ends up claiming push works when no
/// token was ever sent.
abstract interface class PushRegistrationService {
  Future<PushRegistrationResult> registerDevice({
    required NotificationPermissionStatus permissionStatus,
  });

  Future<void> unregisterDevice();

  /// Re-sends the current token, for provider-side rotation and for
  /// re-associating the device after a sign-in.
  Future<PushRegistrationResult> refreshRegistration({
    required NotificationPermissionStatus permissionStatus,
  });
}

/// Source of the provider's device token.
///
/// A seam, not indirection for its own sake: the whole question of whether
/// remote notifications can work reduces to whether this returns a token,
/// and that keeps the honest "it cannot yet" answer in one place.
abstract interface class PushTokenProvider {
  /// Null when no token can be obtained. Never logged, never passed to
  /// analytics — it identifies a device.
  Future<String?> getToken();

  Future<void> deleteToken();
}

/// There is no push provider in this project yet.
///
/// No Firebase, no APNs integration, so there is no token to obtain. This
/// reports the absence rather than succeeding silently, because telling
/// someone notifications are set up when nothing can ever arrive is worse
/// than telling them nothing.
class UnavailablePushTokenProvider implements PushTokenProvider {
  const UnavailablePushTokenProvider();

  @override
  Future<String?> getToken() async => null;

  @override
  Future<void> deleteToken() async {}
}

final pushTokenProviderProvider = Provider<PushTokenProvider>(
    (ref) => const UnavailablePushTokenProvider());

/// Registers the device with JCFAdmin's `devices/register/` endpoint.
///
/// The token travels in the POST body and never in a URL or a log line:
/// request paths end up in server access logs and crash reports, and a
/// push token in one of those is a standing way to send a stranger's
/// device a notification.
class ApiPushRegistrationService implements PushRegistrationService {
  ApiPushRegistrationService(
    this._dio,
    this._tokens, {
    this.platformOverride,
    this.localeTag,
    this.timezoneName,
  });

  static const _registrationKeyPref = 'push.registration_key.v1';

  final Dio _dio;
  final PushTokenProvider _tokens;

  /// Test seams. The defaults read the real platform; a test cannot,
  /// because `Platform.isAndroid` throws under the Flutter test binding.
  final String? platformOverride;
  final String Function()? localeTag;
  final String Function()? timezoneName;

  @override
  Future<PushRegistrationResult> registerDevice({
    required NotificationPermissionStatus permissionStatus,
  }) async {
    final platform = _platform();
    if (platform == null) {
      return const PushRegistrationResult(
          PushRegistrationOutcome.noProvider);
    }

    final String? token;
    try {
      token = await _tokens.getToken();
    } catch (_) {
      return const PushRegistrationResult(PushRegistrationOutcome.noToken);
    }
    if (token == null || token.isEmpty) {
      // No provider configured yet, so no token exists — distinct from a
      // provider that exists and declined.
      return const PushRegistrationResult(
          PushRegistrationOutcome.noProvider);
    }

    try {
      await _dio.post<Map<String, dynamic>>(
        'devices/register/',
        data: {
          'token': token,
          'platform': platform,
          // No `app_version`: the app has no version source of its own
          // yet, and pulling in a plugin for one string is not worth it.
          // It can be added with the force-upgrade check, which needs the
          // same value.
          'locale': _locale(),
          'timezone': _timezone(),
          'permission_status': permissionStatus.name,
          // Idempotency key the app owns: a random value kept in
          // preferences, not a hardware identifier. Re-registering from
          // the same install updates one row instead of accumulating
          // duplicates, and it cannot be used to track the device across
          // reinstalls.
          'registration_key': await _registrationKey(),
        },
      );
      return const PushRegistrationResult.registered();
    } on DioException {
      // Deliberately no error body in any log: the request carried a
      // token and Dio echoes the request in its message.
      return const PushRegistrationResult(PushRegistrationOutcome.failed);
    } catch (_) {
      return const PushRegistrationResult(PushRegistrationOutcome.failed);
    }
  }

  @override
  Future<PushRegistrationResult> refreshRegistration({
    required NotificationPermissionStatus permissionStatus,
  }) =>
      registerDevice(permissionStatus: permissionStatus);

  @override
  Future<void> unregisterDevice() async {
    final key = await _existingRegistrationKey();
    if (key == null) return;
    try {
      // Keyed on the registration key, never on the token: the token
      // would have to appear in the request path.
      await _dio.delete<void>('devices/register/', data: {
        'registration_key': key,
      });
    } catch (_) {
      // Best effort. A token the server keeps after sign-out is a privacy
      // problem, but it is not one the reader can act on from here, and
      // blocking sign-out on it would be worse.
    }
    try {
      await _tokens.deleteToken();
    } catch (_) {}
  }

  String? _platform() {
    if (platformOverride != null) return platformOverride;
    if (kIsWeb) return null;
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    // The backend only models ios/android; sending anything else would be
    // rejected, so say so here instead.
    return null;
  }

  String _locale() =>
      localeTag?.call() ??
      PlatformDispatcher.instance.locale.toLanguageTag();

  String _timezone() => timezoneName?.call() ?? DateTime.now().timeZoneName;

  Future<String> _registrationKey() async {
    final existing = await _existingRegistrationKey();
    if (existing != null) return existing;
    // Cryptographic randomness, not a timestamp: this key is the handle
    // used to deactivate a registration, so a guessable one would let a
    // stranger switch off someone else's notifications.
    final random = Random.secure();
    final key = base64Url.encode(
        List<int>.generate(16, (_) => random.nextInt(256)));
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_registrationKeyPref, key);
    } catch (_) {
      // Unwritable preferences mean a new key next launch, which the
      // backend treats as another device. Acceptable; losing the ability
      // to register at all would not be.
    }
    return key;
  }

  Future<String?> _existingRegistrationKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_registrationKeyPref);
    } catch (_) {
      return null;
    }
  }
}

final pushRegistrationServiceProvider = Provider<PushRegistrationService>(
    (ref) => ApiPushRegistrationService(
          ref.watch(dioProvider),
          ref.watch(pushTokenProviderProvider),
        ));
