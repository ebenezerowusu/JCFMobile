import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jcf_mobile/features/onboarding/onboarding_pages.dart';
import 'package:jcf_mobile/features/onboarding/onboarding_prefs.dart';
import 'package:jcf_mobile/features/onboarding/onboarding_screen.dart';
import 'package:jcf_mobile/features/onboarding/onboarding_widgets.dart';
import 'package:jcf_mobile/l10n/app_localizations.dart';

class FakeOnboardingPrefs implements OnboardingPrefs {
  FakeOnboardingPrefs({this.version = 0, this.failOnWrite = false});

  int version;
  final bool failOnWrite;
  int writes = 0;
  String? lastMethod;

  @override
  Future<int> seenVersion() async => version;

  @override
  Future<bool> isSeen() async => version >= currentOnboardingVersion;

  @override
  Future<void> markSeen({String method = 'completed'}) async {
    writes++;
    if (failOnWrite) throw StateError('disk full');
    version = currentOnboardingVersion;
    lastMethod = method;
  }

  @override
  Future<void> reset() async => version = 0;
}

Future<void> setSurface(WidgetTester tester, Size size) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Widget harness({
  OnboardingPrefs? prefs,
  Locale locale = const Locale('en'),
  double textScale = 1.0,
  TextDirection direction = TextDirection.ltr,
  bool reduceMotion = false,
  List<String>? visited,
}) =>
    ProviderScope(
      overrides: [
        if (prefs != null) onboardingPrefsProvider.overrideWithValue(prefs),
      ],
      child: MaterialApp.router(
        locale: locale,
        routerConfig: GoRouter(
          initialLocation: '/onboarding',
          routes: [
            GoRoute(
                path: '/onboarding',
                builder: (_, _) => const OnboardingScreen()),
            GoRoute(
              path: '/welcome',
              builder: (_, _) {
                visited?.add('/welcome');
                return const Scaffold(body: Text('at welcome'));
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

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  // --- versioned persistence -------------------------------------------

  group('versioned completion', () {
    test('a fresh install has seen nothing', () async {
      SharedPreferences.setMockInitialValues({});
      expect(await OnboardingPrefs().seenVersion(), 0);
      expect(await OnboardingPrefs().isSeen(), isFalse);
    });

    test('the old boolean is honoured as version 1', () async {
      // Someone who onboarded on an earlier build must not be asked again.
      SharedPreferences.setMockInitialValues({'onboarding_seen': true});
      expect(await OnboardingPrefs().seenVersion(), 1);
      expect(await OnboardingPrefs().isSeen(), isTrue);
    });

    test('a stored version older than the current one shows it again',
        () async {
      SharedPreferences.setMockInitialValues({
        'onboarding_seen_version': currentOnboardingVersion - 1,
      });
      expect(await OnboardingPrefs().isSeen(), isFalse);
    });

    test('the current version counts as seen', () async {
      SharedPreferences.setMockInitialValues({
        'onboarding_seen_version': currentOnboardingVersion,
      });
      expect(await OnboardingPrefs().isSeen(), isTrue);
    });

    test('a newer stored version still counts as seen', () async {
      // A downgrade must not drag someone back through onboarding.
      SharedPreferences.setMockInitialValues({
        'onboarding_seen_version': currentOnboardingVersion + 5,
      });
      expect(await OnboardingPrefs().isSeen(), isTrue);
    });

    test('marking seen records the version and the method', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = OnboardingPrefs();
      await prefs.markSeen(method: 'skipped');
      expect(await prefs.seenVersion(), currentOnboardingVersion);
      expect(await prefs.isSeen(), isTrue);
    });
  });

  // --- page data --------------------------------------------------------

  group('page data', () {
    test('there are three pages with stable ids', () {
      expect(onboardingPages.map((p) => p.id).toList(),
          ['teachings', 'inner_space', 'community_service']);
    });

    test('each page has its own artwork', () {
      final assets = onboardingPages.map((p) => p.imageAsset).toSet();
      expect(assets.length, onboardingPages.length);
    });
  });

  // --- content ----------------------------------------------------------

  group('content', () {
    testWidgets('page one is Teachings, with Skip and no Back',
        (tester) async {
      await setSurface(tester, const Size(390, 844));
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      expect(find.text('TEACHINGS'), findsOneWidget);
      expect(find.text('Discover timeless teachings'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      // Hidden, not disabled: nothing invites a tap that does nothing.
      expect(find.byType(OnboardingBackButton), findsNothing);
    });

    testWidgets('page two is InnerSpace, with Back', (tester) async {
      await setSurface(tester, const Size(390, 844));
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('INNERSPACE'), findsOneWidget);
      expect(find.text('Go deeper within'), findsOneWidget);
      expect(find.byType(OnboardingBackButton), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('page three drops Skip and offers Get started',
        (tester) async {
      await setSurface(tester, const Size(390, 844));
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('COMMUNITY & SERVICE'), findsOneWidget);
      expect(find.text('Grow together. Serve with purpose.'),
          findsOneWidget);
      // There is nothing left to skip past.
      expect(find.text('Skip'), findsNothing);
      expect(find.text('Get started'), findsOneWidget);
      expect(find.text('Next'), findsNothing);
    });

    testWidgets('Back returns to the previous page', (tester) async {
      await setSurface(tester, const Size(390, 844));
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OnboardingBackButton));
      await tester.pumpAndSettle();

      expect(find.text('Discover timeless teachings'), findsOneWidget);
    });

    testWidgets('swiping moves between pages', (tester) async {
      await setSurface(tester, const Size(390, 844));
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      await tester.drag(
          find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();
      expect(find.text('Go deeper within'), findsOneWidget);
    });
  });

  // --- progress ---------------------------------------------------------

  group('the progress indicator', () {
    testWidgets('announces the position rather than only colouring a dot',
        (tester) async {
      await setSurface(tester, const Size(390, 844));
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      final handle = tester.ensureSemantics();
      expect(find.bySemanticsLabel('Page 1 of 3'), findsOneWidget);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Page 2 of 3'), findsOneWidget);
      handle.dispose();
    });
  });

  // --- completion -------------------------------------------------------

  group('completion', () {
    testWidgets('Skip records the choice and opens Welcome',
        (tester) async {
      await setSurface(tester, const Size(390, 844));
      final prefs = FakeOnboardingPrefs();
      final visited = <String>[];
      await tester.pumpWidget(harness(prefs: prefs, visited: visited));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(prefs.version, currentOnboardingVersion);
      expect(prefs.lastMethod, 'skipped');
      expect(visited, contains('/welcome'));
    });

    testWidgets('Get started records completion and opens Welcome',
        (tester) async {
      await setSurface(tester, const Size(390, 844));
      final prefs = FakeOnboardingPrefs();
      final visited = <String>[];
      await tester.pumpWidget(harness(prefs: prefs, visited: visited));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Get started'));
      await tester.pumpAndSettle();

      expect(prefs.lastMethod, 'completed');
      expect(visited, contains('/welcome'));
    });

    testWidgets('a second tap does not complete twice', (tester) async {
      await setSurface(tester, const Size(390, 844));
      final prefs = FakeOnboardingPrefs();
      await tester.pumpWidget(harness(prefs: prefs));
      await tester.pumpAndSettle();

      final skip = find.text('Skip');
      await tester.tap(skip, warnIfMissed: false);
      await tester.tap(skip, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(prefs.writes, 1);
    });

    testWidgets('a failed write stays put and explains itself',
        (tester) async {
      await setSurface(tester, const Size(390, 844));
      final prefs = FakeOnboardingPrefs(failOnWrite: true);
      final visited = <String>[];
      await tester.pumpWidget(harness(prefs: prefs, visited: visited));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // Navigating without persisting would show onboarding again next
      // launch, so it must not pretend to have succeeded.
      expect(visited, isEmpty);
      expect(find.text("We couldn't save your progress. Please try again."),
          findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });
  });

  // --- responsiveness and accessibility ---------------------------------

  group('layout', () {
    testWidgets('a short device does not overflow', (tester) async {
      await setSurface(tester, const Size(320, 568));
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('the default test surface does not overflow',
        (tester) async {
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('large text does not clip', (tester) async {
      await setSurface(tester, const Size(360, 640));
      await tester.pumpWidget(harness(textScale: 1.8));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders right-to-left without overflow', (tester) async {
      await setSurface(tester, const Size(390, 844));
      await tester.pumpWidget(harness(direction: TextDirection.rtl));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('reduced motion still changes page', (tester) async {
      await setSurface(tester, const Size(390, 844));
      await tester.pumpWidget(harness(reduceMotion: true));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Go deeper within'), findsOneWidget);
    });
  });

  group('localization', () {
    testWidgets('French renders the carousel', (tester) async {
      await setSurface(tester, const Size(390, 844));
      await tester.pumpWidget(harness(locale: const Locale('fr')));
      await tester.pumpAndSettle();
      expect(find.text('ENSEIGNEMENTS'), findsOneWidget);
      expect(find.text('Passer'), findsOneWidget);
      expect(find.text('Suivant'), findsOneWidget);
    });

    testWidgets('German renders without overflow', (tester) async {
      await setSurface(tester, const Size(360, 640));
      await tester.pumpWidget(harness(locale: const Locale('de')));
      await tester.pumpAndSettle();
      expect(find.text('Überspringen'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
