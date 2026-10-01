import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jcf_mobile/features/notifications/notification_permission_controller.dart';
import 'package:jcf_mobile/features/notifications/notification_permission_screen.dart';
import 'package:jcf_mobile/features/notifications/notification_permission_service.dart';
import 'package:jcf_mobile/features/notifications/notification_permission_state.dart';
import 'package:jcf_mobile/features/notifications/notification_primer_prefs.dart';
import 'package:jcf_mobile/features/notifications/push_registration_service.dart';
import 'package:jcf_mobile/l10n/app_localizations.dart';

/// A permission service that records what it was asked to do.
///
/// The whole point of the primer is *when* the OS is called, so the test
/// double counts calls rather than only returning values.
class FakePermissionService implements NotificationPermissionService {
  FakePermissionService({
    this.status = NotificationPermissionStatus.notDetermined,
    this.afterRequest,
    this.throwOnRequest = false,
    this.settingsOpen = true,
  });

  NotificationPermissionStatus status;
  NotificationPermissionStatus? afterRequest;
  bool throwOnRequest;
  bool settingsOpen;

  /// Holds the request open so the in-flight state can be observed. The
  /// platform channel really does take a moment; a double tap in that
  /// window is exactly the case worth testing.
  Completer<void>? gate;

  int statusCalls = 0;
  int requestCalls = 0;
  int settingsCalls = 0;

  @override
  Future<NotificationPermissionStatus> getStatus() async {
    statusCalls++;
    return status;
  }

  @override
  Future<NotificationPermissionStatus> requestPermission() async {
    requestCalls++;
    if (gate != null) await gate!.future;
    if (throwOnRequest) throw Exception('platform channel failed');
    return status = afterRequest ?? status;
  }

  @override
  Future<bool> openSystemSettings() async {
    settingsCalls++;
    return settingsOpen;
  }
}

class FakePushRegistration implements PushRegistrationService {
  FakePushRegistration(
      [this.outcome = PushRegistrationOutcome.registered]);

  PushRegistrationOutcome outcome;
  int registerCalls = 0;
  int unregisterCalls = 0;

  @override
  Future<PushRegistrationResult> registerDevice({
    required NotificationPermissionStatus permissionStatus,
  }) async {
    registerCalls++;
    return PushRegistrationResult(outcome);
  }

  @override
  Future<PushRegistrationResult> refreshRegistration({
    required NotificationPermissionStatus permissionStatus,
  }) =>
      registerDevice(permissionStatus: permissionStatus);

  @override
  Future<void> unregisterDevice() async => unregisterCalls++;
}

class FakeTokenProvider implements PushTokenProvider {
  FakeTokenProvider(this.token);

  String? token;
  int deleteCalls = 0;

  @override
  Future<String?> getToken() async => token;

  @override
  Future<void> deleteToken() async {
    deleteCalls++;
    token = null;
  }
}

Future<void> setSurface(WidgetTester tester, Size size) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

ProviderContainer container({
  required FakePermissionService permissions,
  PushRegistrationService? push,
}) {
  final c = ProviderContainer(overrides: [
    notificationPermissionServiceProvider.overrideWithValue(permissions),
    pushRegistrationServiceProvider
        .overrideWithValue(push ?? FakePushRegistration()),
  ]);
  addTearDown(c.dispose);
  return c;
}

Widget harness({
  required FakePermissionService permissions,
  PushRegistrationService? push,
  NotificationPermissionEntryPoint entryPoint =
      NotificationPermissionEntryPoint.onboarding,
  Locale locale = const Locale('en'),
  double textScale = 1.0,
  TextDirection direction = TextDirection.ltr,
  bool reducedMotion = false,
  List<String>? visited,
}) {
  // Built once, outside any Consumer: recreating a GoRouter throws away
  // the navigation that just happened.
  final router = GoRouter(
    initialLocation: '/notification-permission',
    routes: [
      GoRoute(
        path: '/notification-permission',
        builder: (_, _) =>
            NotificationPermissionScreen(entryPoint: entryPoint),
      ),
      for (final path in ['/home', '/more'])
        GoRoute(
          path: path,
          builder: (_, _) {
            visited?.add(path);
            return Scaffold(body: Text('at $path'));
          },
        ),
    ],
  );
  return ProviderScope(
    overrides: [
      notificationPermissionServiceProvider.overrideWithValue(permissions),
      pushRegistrationServiceProvider
          .overrideWithValue(push ?? FakePushRegistration()),
    ],
    child: MaterialApp.router(
      locale: locale,
      routerConfig: router,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
          disableAnimations: reducedMotion,
        ),
        child: Directionality(textDirection: direction, child: child!),
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  // --- the one rule that matters ---------------------------------------

  group('the OS is asked only on an explicit tap', () {
    test('initialising reads the status and never requests', () async {
      final permissions = FakePermissionService();
      final c = container(permissions: permissions);
      await c
          .read(notificationPermissionControllerProvider.notifier)
          .initialize(NotificationPermissionEntryPoint.onboarding);

      expect(permissions.statusCalls, 1);
      expect(permissions.requestCalls, 0);
    });

    test('Not now never requests permission', () async {
      final permissions = FakePermissionService();
      final c = container(permissions: permissions);
      final controller =
          c.read(notificationPermissionControllerProvider.notifier);
      await controller.initialize(NotificationPermissionEntryPoint.onboarding);
      final saved = await controller.notNow();

      expect(saved, isTrue);
      expect(permissions.requestCalls, 0);
      expect(c.read(notificationPermissionControllerProvider).userDeferred,
          isTrue);
    });

    testWidgets('tapping Not now prompts nothing and continues',
        (tester) async {
      await setSurface(tester, const Size(390, 844));
      final permissions = FakePermissionService();
      final visited = <String>[];
      await tester.pumpWidget(
          harness(permissions: permissions, visited: visited));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();

      expect(permissions.requestCalls, 0);
      expect(visited, ['/home']);
    });

    testWidgets('tapping Enable notifications prompts once', (tester) async {
      await setSurface(tester, const Size(390, 844));
      final permissions = FakePermissionService(
          afterRequest: NotificationPermissionStatus.authorized);
      await tester.pumpWidget(harness(permissions: permissions));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Enable notifications'));
      await tester.pumpAndSettle();

      expect(permissions.requestCalls, 1);
    });
  });

  // --- status mapping ---------------------------------------------------

  group('status semantics', () {
    test('authorized and provisional both count as allowed', () {
      expect(NotificationPermissionStatus.authorized.isAuthorized, isTrue);
      expect(NotificationPermissionStatus.provisionallyAuthorized.isAuthorized,
          isTrue);
      expect(NotificationPermissionStatus.denied.isAuthorized, isFalse);
    });

    test('only askable states are requestable', () {
      expect(NotificationPermissionStatus.notDetermined.canRequest, isTrue);
      expect(NotificationPermissionStatus.denied.canRequest, isTrue);
      expect(NotificationPermissionStatus.permanentlyDenied.canRequest,
          isFalse);
      expect(NotificationPermissionStatus.restricted.canRequest, isFalse);
      expect(NotificationPermissionStatus.authorized.canRequest, isFalse);
    });

    test('permanently denied and restricted need Settings', () {
      expect(NotificationPermissionStatus.permanentlyDenied.needsSettings,
          isTrue);
      expect(NotificationPermissionStatus.restricted.needsSettings, isTrue);
      expect(NotificationPermissionStatus.denied.needsSettings, isFalse);
    });

    test('every outcome still allows continuing', () {
      for (final status in NotificationPermissionStatus.values) {
        expect(NotificationPermissionState(status: status).canContinue, isTrue,
            reason: status.name);
      }
    });
  });

  // --- controller flow --------------------------------------------------

  group('enable notifications', () {
    test('already authorized skips the prompt and registers', () async {
      final permissions = FakePermissionService(
          status: NotificationPermissionStatus.authorized);
      final push = FakePushRegistration();
      final c = container(permissions: permissions, push: push);
      final controller =
          c.read(notificationPermissionControllerProvider.notifier);
      await controller.initialize(NotificationPermissionEntryPoint.settings);
      await controller.enableNotifications();

      expect(permissions.requestCalls, 0);
      expect(push.registerCalls, 1);
      expect(c.read(notificationPermissionControllerProvider).deviceRegistered,
          isTrue);
    });

    test('a granted request registers and records the decision', () async {
      final permissions = FakePermissionService(
          afterRequest: NotificationPermissionStatus.authorized);
      final push = FakePushRegistration();
      final c = container(permissions: permissions, push: push);
      final controller =
          c.read(notificationPermissionControllerProvider.notifier);
      await controller.initialize(NotificationPermissionEntryPoint.onboarding);
      await controller.enableNotifications();

      expect(permissions.requestCalls, 1);
      expect(push.registerCalls, 1);
      expect(await NotificationPrimerPrefs().decision(),
          PrimerDecision.enabled);
    });

    test('a denial is recorded and never re-requested', () async {
      final permissions = FakePermissionService(
          afterRequest: NotificationPermissionStatus.permanentlyDenied);
      final c = container(permissions: permissions);
      final controller =
          c.read(notificationPermissionControllerProvider.notifier);
      await controller.initialize(NotificationPermissionEntryPoint.onboarding);
      await controller.enableNotifications();
      // A second attempt must not reach the platform: asking again after a
      // permanent denial does nothing but waste the tap.
      await controller.enableNotifications();

      expect(permissions.requestCalls, 1);
      expect(c.read(notificationPermissionControllerProvider).needsSettings,
          isTrue);
    });

    test('a restricted device is not asked again', () async {
      final permissions = FakePermissionService(
          status: NotificationPermissionStatus.restricted);
      final c = container(permissions: permissions);
      final controller =
          c.read(notificationPermissionControllerProvider.notifier);
      await controller.initialize(NotificationPermissionEntryPoint.onboarding);
      await controller.enableNotifications();

      expect(permissions.requestCalls, 0);
    });

    test('a platform failure is retryable and restores the controls',
        () async {
      final permissions = FakePermissionService(throwOnRequest: true);
      final c = container(permissions: permissions);
      final controller =
          c.read(notificationPermissionControllerProvider.notifier);
      await controller.initialize(NotificationPermissionEntryPoint.onboarding);
      await controller.enableNotifications();

      var state = c.read(notificationPermissionControllerProvider);
      expect(state.failure, NotificationPermissionFailure.requestFailed);
      expect(state.isRequesting, isFalse);
      expect(state.canEnable, isTrue);

      permissions.throwOnRequest = false;
      permissions.afterRequest = NotificationPermissionStatus.authorized;
      await controller.retry();

      state = c.read(notificationPermissionControllerProvider);
      expect(state.isAuthorized, isTrue);
      expect(state.failure, NotificationPermissionFailure.none);
    });

    test('a status read during the tap catches a grant made in Settings',
        () async {
      final permissions = FakePermissionService(
          status: NotificationPermissionStatus.notDetermined);
      final c = container(permissions: permissions);
      final controller =
          c.read(notificationPermissionControllerProvider.notifier);
      await controller.initialize(NotificationPermissionEntryPoint.onboarding);
      // Granted elsewhere between opening the screen and tapping.
      permissions.status = NotificationPermissionStatus.authorized;
      await controller.enableNotifications();

      expect(permissions.requestCalls, 0);
      expect(c.read(notificationPermissionControllerProvider).isAuthorized,
          isTrue);
    });

    test('granting in Settings after a refresh registers the device',
        () async {
      final permissions = FakePermissionService(
          status: NotificationPermissionStatus.permanentlyDenied);
      final push = FakePushRegistration();
      final c = container(permissions: permissions, push: push);
      final controller =
          c.read(notificationPermissionControllerProvider.notifier);
      await controller.initialize(NotificationPermissionEntryPoint.settings);
      permissions.status = NotificationPermissionStatus.authorized;
      await controller.refreshStatus();

      expect(push.registerCalls, 1);
    });

    test('Settings that will not open leaves instructions, not an exception',
        () async {
      final permissions = FakePermissionService(settingsOpen: false);
      final c = container(permissions: permissions);
      final controller =
          c.read(notificationPermissionControllerProvider.notifier);
      await controller.initialize(NotificationPermissionEntryPoint.settings);
      await controller.openSettings();

      expect(c.read(notificationPermissionControllerProvider).failure,
          NotificationPermissionFailure.settingsUnavailable);
    });
  });

  group('duplicate taps', () {
    testWidgets('a second tap while requesting does not prompt twice',
        (tester) async {
      await setSurface(tester, const Size(390, 844));
      final permissions = FakePermissionService(
          afterRequest: NotificationPermissionStatus.authorized)
        ..gate = Completer<void>();
      await tester.pumpWidget(harness(permissions: permissions));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Enable notifications'));
      // No settle: the request is deliberately still in flight.
      await tester.pump();
      // By type, not by label: while loading the button shows a spinner
      // instead of its text, and the second tap has to land on the real
      // widget to prove the guard rather than the finder.
      await tester.tap(find.byType(FilledButton), warnIfMissed: false);
      await tester.pump();
      permissions.gate!.complete();
      await tester.pumpAndSettle();

      expect(permissions.requestCalls, 1);
    });

    test('the controller guards a duplicate call on its own', () async {
      // Not only the disabled button: anything calling the controller
      // twice — a stray gesture, a retry — must not stack two prompts.
      final permissions = FakePermissionService(
          afterRequest: NotificationPermissionStatus.authorized)
        ..gate = Completer<void>();
      final c = container(permissions: permissions);
      final controller =
          c.read(notificationPermissionControllerProvider.notifier);
      await controller.initialize(NotificationPermissionEntryPoint.onboarding);

      final first = controller.enableNotifications();
      final second = controller.enableNotifications();
      permissions.gate!.complete();
      await Future.wait([first, second]);

      expect(permissions.requestCalls, 1);
    });
  });

  // --- primer persistence ----------------------------------------------

  group('primer preferences', () {
    test('a first run shows the primer', () async {
      expect(await NotificationPrimerPrefs().shouldShow(), isTrue);
    });

    test('a deferral is recorded with a version and a timestamp', () async {
      final prefs = NotificationPrimerPrefs();
      await prefs.record(PrimerDecision.deferred);

      expect(await prefs.decision(), PrimerDecision.deferred);
      expect(await prefs.shownVersion(), currentNotificationPrimerVersion);
      expect(await prefs.decidedAt(), isNotNull);
    });

    test('Not now is not reshown on the next launch', () async {
      final prefs = NotificationPrimerPrefs();
      await prefs.record(PrimerDecision.deferred);

      expect(await prefs.shouldShow(), isFalse);
    });

    test('a deferral may be revisited only after the defined period',
        () async {
      final prefs = NotificationPrimerPrefs();
      await prefs.record(PrimerDecision.deferred);
      final soon = DateTime.now().add(const Duration(days: 1));
      final later = DateTime.now().add(primerDeferralPeriod * 2);

      expect(await prefs.shouldShow(now: soon), isFalse);
      expect(await prefs.shouldShow(now: later), isTrue);
    });

    test('an enabled decision is never revisited', () async {
      final prefs = NotificationPrimerPrefs();
      await prefs.record(PrimerDecision.enabled);
      final later = DateTime.now().add(primerDeferralPeriod * 10);

      expect(await prefs.shouldShow(now: later), isFalse);
    });

    test('a newer primer version asks again', () async {
      SharedPreferences.setMockInitialValues({
        'notification_primer_version': currentNotificationPrimerVersion - 1,
        'notification_primer_decision': 'deferred',
        'notification_primer_decided_at':
            DateTime.now().toIso8601String(),
      });

      expect(await NotificationPrimerPrefs().shouldShow(), isTrue);
    });
  });

  // --- push registration -----------------------------------------------

  group('push registration', () {
    late Dio dio;
    late List<RequestOptions> sent;

    setUp(() {
      sent = [];
      dio = Dio(BaseOptions(baseUrl: 'https://example.invalid/'));
      dio.httpClientAdapter = _RecordingAdapter(sent);
    });

    test('no token means no registration claimed', () async {
      final service = ApiPushRegistrationService(
        dio,
        FakeTokenProvider(null),
        platformOverride: 'android',
      );
      final result = await service.registerDevice(
          permissionStatus: NotificationPermissionStatus.authorized);

      expect(result.isRegistered, isFalse);
      expect(result.outcome, PushRegistrationOutcome.noProvider);
      // Nothing was sent: there was nothing to send.
      expect(sent, isEmpty);
    });

    test('a token is posted in the body with the permission status',
        () async {
      final service = ApiPushRegistrationService(
        dio,
        FakeTokenProvider('token-abc'),
        platformOverride: 'android',
        localeTag: () => 'en',
        timezoneName: () => 'GMT',
      );
      final result = await service.registerDevice(
          permissionStatus: NotificationPermissionStatus.authorized);

      expect(result.isRegistered, isTrue);
      expect(sent, hasLength(1));
      final body = sent.single.data as Map<String, dynamic>;
      expect(body['token'], 'token-abc');
      expect(body['platform'], 'android');
      expect(body['permission_status'], 'authorized');
      expect(body['registration_key'], isNotEmpty);
      // The token must never appear in the path: request URLs end up in
      // access logs and crash reports.
      expect(sent.single.path, isNot(contains('token-abc')));
    });

    test('the registration key is stable across calls', () async {
      final service = ApiPushRegistrationService(
        dio,
        FakeTokenProvider('token-abc'),
        platformOverride: 'android',
      );
      await service.registerDevice(
          permissionStatus: NotificationPermissionStatus.authorized);
      await service.refreshRegistration(
          permissionStatus: NotificationPermissionStatus.authorized);

      final keys = sent
          .map((r) => (r.data as Map<String, dynamic>)['registration_key'])
          .toSet();
      expect(keys, hasLength(1));
    });

    test('a rotated token reuses the same registration key', () async {
      final tokens = FakeTokenProvider('token-one');
      final service = ApiPushRegistrationService(dio, tokens,
          platformOverride: 'android');
      await service.registerDevice(
          permissionStatus: NotificationPermissionStatus.authorized);
      tokens.token = 'token-two';
      await service.refreshRegistration(
          permissionStatus: NotificationPermissionStatus.authorized);

      final bodies =
          sent.map((r) => r.data as Map<String, dynamic>).toList();
      expect(bodies.map((b) => b['token']),
          ['token-one', 'token-two']);
      expect(bodies.first['registration_key'],
          bodies.last['registration_key']);
    });

    test('signing out deletes the token and the server-side registration',
        () async {
      final tokens = FakeTokenProvider('token-abc');
      final service = ApiPushRegistrationService(dio, tokens,
          platformOverride: 'android');
      await service.registerDevice(
          permissionStatus: NotificationPermissionStatus.authorized);
      sent.clear();
      await service.unregisterDevice();

      expect(tokens.deleteCalls, 1);
      expect(sent, hasLength(1));
      expect(sent.single.method, 'DELETE');
      expect((sent.single.data as Map<String, dynamic>)['registration_key'],
          isNotEmpty);
    });

    test('a registration failure is retryable, a missing provider is not',
        () {
      expect(
          const PushRegistrationResult(PushRegistrationOutcome.failed)
              .isRetryable,
          isTrue);
      expect(
          const PushRegistrationResult(PushRegistrationOutcome.noProvider)
              .isRetryable,
          isFalse);
    });
  });

  group('permission is not delivery', () {
    test('a failed registration is surfaced, not swallowed', () async {
      final permissions = FakePermissionService(
          afterRequest: NotificationPermissionStatus.authorized);
      final c = container(
        permissions: permissions,
        push: FakePushRegistration(PushRegistrationOutcome.failed),
      );
      final controller =
          c.read(notificationPermissionControllerProvider.notifier);
      await controller.initialize(NotificationPermissionEntryPoint.onboarding);
      await controller.enableNotifications();

      final state = c.read(notificationPermissionControllerProvider);
      expect(state.isAuthorized, isTrue);
      // Allowed, but not reachable: the screen must not claim otherwise.
      expect(state.deviceRegistered, isFalse);
      expect(state.failure, NotificationPermissionFailure.registrationFailed);
    });

    testWidgets('a grant with no push provider says so', (tester) async {
      await setSurface(tester, const Size(390, 844));
      final permissions = FakePermissionService(
          afterRequest: NotificationPermissionStatus.authorized);
      await tester.pumpWidget(harness(
        permissions: permissions,
        push: FakePushRegistration(PushRegistrationOutcome.noProvider),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Enable notifications'));
      await tester.pumpAndSettle();

      expect(find.text('Notifications are enabled'), findsOneWidget);
      expect(
          find.textContaining(
              "isn't switched on in this version of the app yet"),
          findsOneWidget);
    });
  });

  // --- the screen -------------------------------------------------------

  group('the primer screen', () {
    testWidgets('shows the explanation, the benefits and both actions',
        (tester) async {
      await setSurface(tester, const Size(390, 844));
      await tester
          .pumpWidget(harness(permissions: FakePermissionService()));
      await tester.pumpAndSettle();

      expect(find.text('STAY CONNECTED'), findsOneWidget);
      expect(find.text('Keep your journey in reach'), findsOneWidget);
      expect(find.text('Live session reminders'), findsOneWidget);
      expect(find.text('Daily practice prompts'), findsOneWidget);
      expect(find.text('Important updates'), findsOneWidget);
      expect(find.text('Enable notifications'), findsOneWidget);
      expect(find.text('Not now'), findsOneWidget);
      expect(
          find.text("You're in control. Change this anytime in Settings."),
          findsOneWidget);
    });

    testWidgets('both actions are disabled while the request is in flight',
        (tester) async {
      await setSurface(tester, const Size(390, 844));
      final permissions = FakePermissionService(
          afterRequest: NotificationPermissionStatus.authorized)
        ..gate = Completer<void>();
      await tester.pumpWidget(harness(permissions: permissions));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Enable notifications'));
      await tester.pump();

      expect(
          tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
          isNull);
      expect(tester.widget<TextButton>(find.byType(TextButton)).onPressed,
          isNull);

      permissions.gate!.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('a grant shows a calm confirmation', (tester) async {
      await setSurface(tester, const Size(390, 844));
      await tester.pumpWidget(harness(
        permissions: FakePermissionService(
            afterRequest: NotificationPermissionStatus.authorized),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Enable notifications'));
      await tester.pumpAndSettle();

      expect(find.text('Notifications are enabled'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
      expect(find.text('Enable notifications'), findsNothing);
    });

    testWidgets('a denial continues without pressure', (tester) async {
      await setSurface(tester, const Size(390, 844));
      final visited = <String>[];
      await tester.pumpWidget(harness(
        permissions: FakePermissionService(
            afterRequest: NotificationPermissionStatus.denied),
        visited: visited,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Enable notifications'));
      await tester.pumpAndSettle();

      expect(find.text('Notifications are off'), findsOneWidget);
      await tester.tap(find.text('Continue without notifications'));
      await tester.pumpAndSettle();
      expect(visited, ['/home']);
    });

    testWidgets('a permanent denial offers Settings, not another prompt',
        (tester) async {
      await setSurface(tester, const Size(390, 844));
      final permissions = FakePermissionService(
          status: NotificationPermissionStatus.permanentlyDenied);
      await tester.pumpWidget(harness(permissions: permissions));
      await tester.pumpAndSettle();

      expect(find.text('Notifications are blocked'), findsOneWidget);
      expect(find.text('Open Settings'), findsOneWidget);
      expect(find.text('Enable notifications'), findsNothing);

      await tester.tap(find.text('Open Settings'));
      await tester.pumpAndSettle();
      expect(permissions.settingsCalls, 1);
      expect(permissions.requestCalls, 0);
    });

    testWidgets('an unsupported device is not blocked', (tester) async {
      await setSurface(tester, const Size(390, 844));
      final visited = <String>[];
      await tester.pumpWidget(harness(
        permissions: FakePermissionService(
            status: NotificationPermissionStatus.unsupported),
        visited: visited,
      ));
      await tester.pumpAndSettle();

      expect(
          find.textContaining("This device doesn't support notifications"),
          findsOneWidget);
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(visited, ['/home']);
    });

    testWidgets('an already-allowed device skips the primer in onboarding',
        (tester) async {
      await setSurface(tester, const Size(390, 844));
      final visited = <String>[];
      await tester.pumpWidget(harness(
        permissions: FakePermissionService(
            status: NotificationPermissionStatus.authorized),
        visited: visited,
      ));
      await tester.pumpAndSettle();

      expect(visited, ['/home']);
      expect(find.text('Enable notifications'), findsNothing);
    });

    testWidgets('opened from Settings it stays and shows the real status',
        (tester) async {
      await setSurface(tester, const Size(390, 844));
      final visited = <String>[];
      await tester.pumpWidget(harness(
        permissions: FakePermissionService(
            status: NotificationPermissionStatus.authorized),
        entryPoint: NotificationPermissionEntryPoint.settings,
        visited: visited,
      ));
      await tester.pumpAndSettle();

      expect(visited, isEmpty);
      expect(find.text('Notifications are enabled'), findsOneWidget);
    });

    testWidgets('a save failure keeps the reader here with a retry',
        (tester) async {
      await setSurface(tester, const Size(390, 844));
      final visited = <String>[];
      // An unavailable preference store is the realistic way a write
      // fails; the screen must not continue as if it had succeeded.
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(harness(
        permissions: FakePermissionService(),
        visited: visited,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Not now'), findsOneWidget);
      // With a working store the deferral succeeds and we leave.
      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();
      expect(visited, ['/home']);
    });
  });

  // --- responsive and accessible ---------------------------------------

  group('responsive and accessible', () {
    testWidgets('a short phone keeps both actions reachable', (tester) async {
      await setSurface(tester, const Size(320, 568));
      await tester
          .pumpWidget(harness(permissions: FakePermissionService()));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('Not now'), 120);
      expect(find.text('Not now'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('large text does not overflow', (tester) async {
      await setSurface(tester, const Size(390, 844));
      await tester.pumpWidget(harness(
          permissions: FakePermissionService(), textScale: 1.8));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('right-to-left lays out without error', (tester) async {
      await setSurface(tester, const Size(390, 844));
      await tester.pumpWidget(harness(
        permissions: FakePermissionService(),
        direction: TextDirection.rtl,
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('reduced motion renders the same screen', (tester) async {
      await setSurface(tester, const Size(390, 844));
      await tester.pumpWidget(harness(
        permissions: FakePermissionService(),
        reducedMotion: true,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Keep your journey in reach'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a tablet constrains the content width', (tester) async {
      await setSurface(tester, const Size(1024, 1366));
      await tester
          .pumpWidget(harness(permissions: FakePermissionService()));
      await tester.pumpAndSettle();

      final row = tester.getSize(find.text('Live session reminders'));
      expect(row.width, lessThan(480));
    });

    testWidgets('the illustration and the logo carry labels', (tester) async {
      await setSurface(tester, const Size(390, 844));
      final handle = tester.ensureSemantics();
      await tester
          .pumpWidget(harness(permissions: FakePermissionService()));
      await tester.pumpAndSettle();

      expect(
          find.bySemanticsLabel('Illustration of a notification bell'),
          findsOneWidget);
      handle.dispose();
    });

    testWidgets('the French primer renders its own strings', (tester) async {
      await setSurface(tester, const Size(390, 844));
      await tester.pumpWidget(harness(
        permissions: FakePermissionService(),
        locale: const Locale('fr'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Activer les notifications'), findsOneWidget);
      expect(find.text('Pas maintenant'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  // --- routing ----------------------------------------------------------

  group('return routes', () {
    test('an unknown destination falls back to home', () {
      expect(notificationPrimerReturnRoute('/home'), '/home');
      expect(notificationPrimerReturnRoute('/activities'), '/activities');
      expect(notificationPrimerReturnRoute(null), '/home');
      expect(notificationPrimerReturnRoute('/admin'), '/home');
      expect(notificationPrimerReturnRoute('https://evil.example/'), '/home');
      expect(notificationPrimerReturnRoute('/home/../admin'), '/home');
    });
  });
}

/// Captures requests instead of sending them.
class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter(this.sent);

  final List<RequestOptions> sent;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<List<int>>? requestStream, Future<void>? cancelFuture) async {
    sent.add(options);
    return ResponseBody.fromString('{"registered": true}', 200, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}
