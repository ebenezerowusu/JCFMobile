import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:jcf_mobile/features/splash/app_bootstrap_service.dart';
import 'package:jcf_mobile/features/splash/splash_controller.dart';
import 'package:jcf_mobile/features/splash/splash_state.dart';
import 'package:jcf_mobile/features/splash/splash_widgets.dart';
import 'package:jcf_mobile/features/splash/startup_splash_screen.dart';
import 'package:jcf_mobile/l10n/app_localizations.dart';

/// A bootstrap that answers from memory and counts how often it ran.
class FakeBootstrap implements AppBootstrapService {
  FakeBootstrap(this.results, {this.delay});

  /// One per call, in order; the last is reused once exhausted.
  final List<BootstrapResult> results;
  final Duration? delay;
  int runs = 0;

  @override
  Future<BootstrapResult> run() async {
    final index = runs++;
    if (delay != null) await Future<void>.delayed(delay!);
    return results[index < results.length ? index : results.length - 1];
  }
}

class ThrowingBootstrap implements AppBootstrapService {
  int runs = 0;

  @override
  Future<BootstrapResult> run() async {
    runs++;
    throw StateError('bootstrap blew up');
  }
}

Widget harness(
  AppBootstrapService service, {
  Locale locale = const Locale('en'),
  double textScale = 1.0,
  TextDirection direction = TextDirection.ltr,
  bool reduceMotion = false,
  // Never a const default: the route builder appends to this, and a const
  // list is unmodifiable, so any test that navigated without passing one
  // crashed inside GoRouter rather than failing its own assertion.
  List<String>? visited,
}) =>
    ProviderScope(
      overrides: [
        appBootstrapServiceProvider.overrideWithValue(service),
      ],
      child: MaterialApp.router(
        locale: locale,
        routerConfig: GoRouter(
          initialLocation: '/splash',
          routes: [
            GoRoute(
                path: '/splash',
                builder: (_, _) => const StartupSplashScreen()),
            for (final path in ['/home', '/welcome', '/onboarding'])
              GoRoute(
                path: path,
                builder: (_, _) {
                  visited?.add(path);
                  return Scaffold(body: Text('at $path'));
                },
              ),
          ],
        ),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
            disableAnimations: reduceMotion,
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

/// Sets the real render surface, not just MediaQuery.
///
/// Faking only MediaQuery.size lays the screen out at phone height inside
/// the default 800x600 test surface, so anything below 600 is genuinely
/// off-screen and cannot be tapped — which looks like a missing button
/// rather than the harness lying about the viewport.
Future<void> setSurface(WidgetTester tester, Size size) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

/// The splash animates its dots forever by design, so pumpAndSettle would
/// never return while it is on screen. This pumps in steps, then settles
/// properly once the splash has gone and nothing is looping any more.
Future<void> advance(WidgetTester tester,
    [Duration total = const Duration(milliseconds: 2400)]) async {
  // Enough for the minimum display floor plus the route transition; the
  // loop exits as soon as the splash is actually gone.
  final step = Duration(milliseconds: total.inMilliseconds ~/ 16);
  for (var i = 0; i < 16; i++) {
    await tester.pump(step);
    if (find.byType(StartupSplashScreen).evaluate().isEmpty) {
      await tester.pumpAndSettle();
      return;
    }
  }
}

BootstrapResult ready({String destination = '/home'}) =>
    BootstrapResult(stage: SplashStage.ready, destination: destination);

void main() {
  // --- route allowlist -------------------------------------------------

  group('the route allowlist', () {
    test('lets a known route through', () {
      expect(allowedRoute('/home'), '/home');
      expect(allowedRoute('/activities'), '/activities');
    });

    test('refuses an unknown route', () {
      expect(allowedRoute('/admin'), isNull);
      expect(allowedRoute('/settings/secret'), isNull);
    });

    test('refuses traversal and external URLs outright', () {
      for (final hostile in [
        '/home/../admin',
        'https://evil.example.com',
        '//evil.example.com',
        'javascript:alert(1)',
        '',
      ]) {
        expect(allowedRoute(hostile), isNull, reason: hostile);
      }
    });

    test('refuses null', () => expect(allowedRoute(null), isNull));
  });

  // --- store URL -------------------------------------------------------

  group('the store URL', () {
    VersionInfo withUrl(String? url) => VersionInfo(storeUrl: url);

    test('accepts the official stores over https', () {
      expect(withUrl('https://apps.apple.com/app/id1').safeStoreUrl,
          isNotNull);
      expect(
          withUrl('https://play.google.com/store/apps/details?id=x')
              .safeStoreUrl,
          isNotNull);
    });

    test('refuses anywhere else, and refuses plain http', () {
      for (final hostile in [
        'https://evil.example.com/app',
        'http://play.google.com/store',
        'market://details?id=x',
        'not a url at all',
      ]) {
        expect(withUrl(hostile).safeStoreUrl, isNull, reason: hostile);
      }
    });

    test('is null when the server sent none', () {
      expect(withUrl(null).safeStoreUrl, isNull);
    });
  });

  // --- parsing ---------------------------------------------------------

  group('parsing', () {
    test('maintenance defaults to off', () {
      final info = MaintenanceInfo.fromJson(null);
      expect(info.enabled, isFalse);
      expect(info.allowOffline, isFalse);
    });

    test('version defaults to not requiring an update', () {
      expect(VersionInfo.fromJson(null).updateRequired, isFalse);
    });

    test('only ready and offlineReady may proceed', () {
      for (final stage in SplashStage.values) {
        final canProceed =
            BootstrapResult(stage: stage).canProceed;
        expect(
          canProceed,
          stage == SplashStage.ready || stage == SplashStage.offlineReady,
          reason: '$stage',
        );
      }
    });
  });

  // --- navigation ------------------------------------------------------

  group('navigation', () {
    testWidgets('a ready bootstrap replaces the splash', (tester) async {
      final visited = <String>[];
      await tester.pumpWidget(harness(
          FakeBootstrap([ready()]), visited: visited));
      await advance(tester);
      expect(visited, contains('/home'));
      expect(find.byType(StartupSplashScreen), findsNothing);
    });

    testWidgets('a first run goes to welcome', (tester) async {
      final visited = <String>[];
      await tester.pumpWidget(harness(
        FakeBootstrap([ready(destination: '/welcome')]),
        visited: visited,
      ));
      await advance(tester);
      expect(visited, contains('/welcome'));
    });

    testWidgets('a fast launch still shows the splash briefly',
        (tester) async {
      await tester.pumpWidget(harness(FakeBootstrap([ready()])));
      await tester.pump();
      // Bootstrap has already answered, but the minimum display keeps the
      // splash up long enough not to flash.
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(StartupSplashScreen), findsOneWidget);
      await advance(tester);
    });

    testWidgets('an error state does not navigate', (tester) async {
      final visited = <String>[];
      await tester.pumpWidget(harness(
        FakeBootstrap([
          const BootstrapResult(stage: SplashStage.recoverableError),
        ]),
        visited: visited,
      ));
      await advance(tester);
      expect(visited, isEmpty);
      expect(find.byType(StartupSplashScreen), findsOneWidget);
    });
  });

  // --- loading ---------------------------------------------------------

  group('loading', () {
    testWidgets('shows the preparing message', (tester) async {
      await tester.pumpWidget(harness(
          FakeBootstrap([ready()],
              delay: const Duration(seconds: 10))));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Preparing your experience…'), findsOneWidget);
      await tester.pump(const Duration(seconds: 11));
    });

    testWidgets('acknowledges a slow start after the threshold',
        (tester) async {
      await tester.pumpWidget(harness(
          FakeBootstrap([ready()],
              delay: const Duration(seconds: 10))));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Still preparing…'), findsNothing);

      await tester.pump(slowStartupThreshold);
      expect(find.text('Still preparing…'), findsOneWidget);
      await tester.pump(const Duration(seconds: 11));
    });

    testWidgets('the brand content is native text, not baked artwork',
        (tester) async {
      await tester.pumpWidget(harness(
          FakeBootstrap([ready()],
              delay: const Duration(seconds: 10))));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.text('JAN COSMIC FOUNDATION'), findsOneWidget);
      expect(find.text('Awaken. Learn. Transform.'), findsOneWidget);
      await tester.pump(const Duration(seconds: 11));
    });
  });

  // --- native handover -------------------------------------------------

  group('the handover from the native launch screen', () {
    testWidgets('the first frame is the native frame: navy, logo centred',
        (tester) async {
      await setSurface(tester, const Size(360, 740));
      await tester.pumpWidget(harness(
          FakeBootstrap([ready()], delay: const Duration(seconds: 10))));

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, splashNativeNavy);

      // The stand-in is the last logo in the tree, painted over the layout.
      final standIn = tester.getRect(find.byType(SplashLogoImage).last);
      expect(standIn.center, const Offset(180, 370));
      expect(standIn.width, splashNativeLogoWidth);
      await tester.pump(const Duration(seconds: 11));
    });

    testWidgets('ends with a single logo, in the layout', (tester) async {
      await tester.pumpWidget(harness(
          FakeBootstrap([ready()], delay: const Duration(seconds: 10))));
      await tester.pump();
      expect(find.byType(SplashLogoImage), findsNWidgets(2));
      await tester.pump(const Duration(milliseconds: 1500));
      expect(find.byType(SplashLogoImage), findsOneWidget);
      await tester.pump(const Duration(seconds: 11));
    });

    testWidgets('reduced motion skips the handover entirely',
        (tester) async {
      await tester.pumpWidget(harness(
        FakeBootstrap([ready()], delay: const Duration(seconds: 10)),
        reduceMotion: true,
      ));
      await tester.pump();
      expect(find.byType(SplashLogoImage), findsOneWidget);
      await tester.pump(const Duration(seconds: 11));
    });
  });

  // --- error, update, maintenance --------------------------------------

  group('recoverable error', () {
    testWidgets('offers Try Again and retries once per tap',
        (tester) async {
      final service = FakeBootstrap([
        const BootstrapResult(stage: SplashStage.recoverableError),
        ready(),
      ]);
      final visited = <String>[];
      await tester.pumpWidget(harness(service, visited: visited));
      await advance(tester);

      expect(find.text("We couldn't start the app."), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      // The panel sits below the fold in the scrollable layout, which is
      // what lets large text avoid clipping — so scroll to it first.
      await tester.ensureVisible(find.text('Try Again'));
      await tester.pump();
      await tester.tap(find.text('Try Again'));
      await advance(tester);
      expect(service.runs, 2);
      expect(visited, contains('/home'));
    });

    testWidgets('withholds Continue Offline when nothing is cached',
        (tester) async {
      await tester.pumpWidget(harness(FakeBootstrap([
        const BootstrapResult(
            stage: SplashStage.recoverableError, offlineEligible: false),
      ])));
      await advance(tester);
      expect(find.text('Continue Offline'), findsNothing);
    });

    testWidgets('offers Continue Offline when it is genuinely available',
        (tester) async {
      final visited = <String>[];
      await tester.pumpWidget(harness(
        FakeBootstrap([
          const BootstrapResult(
            stage: SplashStage.recoverableError,
            destination: '/home',
            offlineEligible: true,
          ),
        ]),
        visited: visited,
      ));
      await advance(tester);
      expect(find.text('Continue Offline'), findsOneWidget);

      await tester.ensureVisible(find.text('Continue Offline'));
      await tester.pump();
      await tester.tap(find.text('Continue Offline'));
      await advance(tester);
      expect(visited, contains('/home'));
    });

    testWidgets('a thrown bootstrap becomes an error, not a dead spinner',
        (tester) async {
      final service = ThrowingBootstrap();
      await tester.pumpWidget(harness(service));
      await advance(tester);
      expect(find.text("We couldn't start the app."), findsOneWidget);
      expect(find.byType(SplashLoadingIndicator), findsNothing);
    });
  });

  group('mandatory update', () {
    testWidgets('shows the update panel and does not navigate',
        (tester) async {
      final visited = <String>[];
      await tester.pumpWidget(harness(
        FakeBootstrap([
          const BootstrapResult(
            stage: SplashStage.updateRequired,
            version: VersionInfo(
              updateRequired: true,
              storeUrl: 'https://apps.apple.com/app/id1',
            ),
          ),
        ]),
        visited: visited,
      ));
      await advance(tester);
      expect(find.text('A new version is required'), findsOneWidget);
      expect(find.text('Update App'), findsOneWidget);
      expect(visited, isEmpty);
    });

    testWidgets('hides the button when the store URL is not trustworthy',
        (tester) async {
      await tester.pumpWidget(harness(FakeBootstrap([
        const BootstrapResult(
          stage: SplashStage.updateRequired,
          version: VersionInfo(
            updateRequired: true,
            storeUrl: 'https://evil.example.com/app',
          ),
        ),
      ])));
      await advance(tester);
      expect(find.text('A new version is required'), findsOneWidget);
      expect(find.text('Update App'), findsNothing);
    });
  });

  group('maintenance', () {
    testWidgets("uses the server's own words when it has them",
        (tester) async {
      await tester.pumpWidget(harness(FakeBootstrap([
        const BootstrapResult(
          stage: SplashStage.maintenance,
          maintenance: MaintenanceInfo(
            enabled: true,
            title: 'Back shortly',
            message: 'We are making an improvement.',
          ),
        ),
      ])));
      await advance(tester);
      expect(find.text('Back shortly'), findsOneWidget);
      expect(find.text('We are making an improvement.'), findsOneWidget);
    });

    testWidgets('falls back to localized copy when it does not',
        (tester) async {
      await tester.pumpWidget(harness(FakeBootstrap([
        const BootstrapResult(
          stage: SplashStage.maintenance,
          maintenance: MaintenanceInfo(enabled: true),
        ),
      ])));
      await advance(tester);
      expect(find.text('We’ll be back shortly'), findsOneWidget);
    });
  });

  // --- accessibility and layout ----------------------------------------

  group('accessibility and layout', () {
    testWidgets('reduced motion still shows the status in words',
        (tester) async {
      await tester.pumpWidget(harness(
        FakeBootstrap([ready()], delay: const Duration(seconds: 10)),
        reduceMotion: true,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      // Status is never carried by animation alone.
      expect(find.text('Preparing your experience…'), findsOneWidget);
      expect(find.text('JAN COSMIC FOUNDATION'), findsOneWidget);
      await tester.pump(const Duration(seconds: 11));
    });

    testWidgets('a short device does not overflow', (tester) async {
      await setSurface(tester, const Size(320, 568));
      await tester.pumpWidget(harness(
        FakeBootstrap([ready()], delay: const Duration(seconds: 10)),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      expect(tester.takeException(), isNull);
      await tester.pump(const Duration(seconds: 11));
    });

    testWidgets('large text does not clip', (tester) async {
      await setSurface(tester, const Size(360, 640));
      await tester.pumpWidget(harness(
        FakeBootstrap([
          const BootstrapResult(
              stage: SplashStage.recoverableError, offlineEligible: true),
        ]),
        textScale: 1.8,
      ));
      await advance(tester);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders right-to-left without overflow', (tester) async {
      await tester.pumpWidget(harness(
        FakeBootstrap([
          const BootstrapResult(stage: SplashStage.recoverableError),
        ]),
        direction: TextDirection.rtl,
      ));
      await advance(tester);
      expect(tester.takeException(), isNull);
    });

    testWidgets('French localizes the splash', (tester) async {
      await tester.pumpWidget(harness(
        FakeBootstrap([ready()], delay: const Duration(seconds: 10)),
        locale: const Locale('fr'),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.text('Éveillez-vous. Apprenez. Transformez.'),
          findsOneWidget);
      expect(find.text('Préparation de votre expérience…'), findsOneWidget);
      await tester.pump(const Duration(seconds: 11));
    });
  });
}
