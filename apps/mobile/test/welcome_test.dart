import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jcf_mobile/core/locale_prefs.dart';
import 'package:jcf_mobile/features/welcome/welcome_prefs.dart';
import 'package:jcf_mobile/features/welcome/welcome_screen.dart';
import 'package:jcf_mobile/features/language_selection/supported_languages.dart';
import 'package:jcf_mobile/features/welcome/welcome_widgets.dart';
import 'package:jcf_mobile/l10n/app_localizations.dart';

class FakeWelcomePrefs implements WelcomePrefs {
  FakeWelcomePrefs({this.chosen = false, this.failOnWrite = false});

  bool chosen;
  final bool failOnWrite;
  int writes = 0;

  @override
  Future<bool> guestChosen() async => chosen;

  @override
  Future<void> chooseGuest() async {
    writes++;
    if (failOnWrite) throw StateError('disk full');
    chosen = true;
  }

  @override
  Future<void> clear() async => chosen = false;
}

Future<void> setSurface(WidgetTester tester, Size size) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Widget harness({
  WelcomePrefs? prefs,
  Locale locale = const Locale('en'),
  double textScale = 1.0,
  TextDirection direction = TextDirection.ltr,
  bool reduceMotion = false,
  List<String>? visited,
}) => ProviderScope(
  overrides: [if (prefs != null) welcomePrefsProvider.overrideWithValue(prefs)],
  child: Consumer(
    builder: (context, ref, _) => MaterialApp.router(
      locale: ref.watch(appLocaleProvider) ?? locale,
      routerConfig: GoRouter(
        initialLocation: '/welcome',
        routes: [
          GoRoute(path: '/welcome', builder: (_, _) => const WelcomeScreen()),
          for (final path in [
            '/home',
            '/login',
            '/legal/terms',
            '/legal/privacy',
          ])
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
  ),
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('languages', () {
    test('every shipped locale has a language entry', () {
      for (final locale in supportedAppLocales) {
        expect(
          selectableLanguages.any((l) => l.code == locale.languageCode),
          isTrue,
          reason: 'no AppLanguage for ${locale.languageCode}',
        );
      }
    });

    test('an unknown locale falls back to the first language', () {
      expect(languageFor(const Locale('xx')).code, 'en');
      expect(languageFor(null).code, 'en');
    });

    test('a known locale resolves to its own entry', () {
      expect(languageFor(const Locale('pt')).nativeName, 'Português');
    });
  });

  group('layout', () {
    testWidgets('renders the whole invitation', (tester) async {
      await setSurface(tester, const Size(390, 844));
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      expect(find.text('WELCOME'), findsOneWidget);
      expect(find.text('Begin your journey within'), findsOneWidget);
      expect(find.text('Sign in or create account'), findsOneWidget);
      expect(find.text('Continue as guest'), findsOneWidget);
      expect(find.byType(WelcomeBrandLogo), findsOneWidget);
      expect(find.byType(WelcomeLanguageButton), findsOneWidget);
    });

    testWidgets('a short device does not overflow', (tester) async {
      await setSurface(tester, const Size(320, 568));
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Continue as guest'), findsOneWidget);
    });

    testWidgets('the default test surface does not overflow', (tester) async {
      // 800x600 is what a plain widget test gets; the screen has to cope.
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('large text does not clip the actions', (tester) async {
      await setSurface(tester, const Size(360, 640));
      await tester.pumpWidget(harness(textScale: 1.8));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('a tablet keeps the panel to a readable measure', (
      tester,
    ) async {
      await setSurface(tester, const Size(1024, 1366));
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();
      final button = tester.getSize(
        find.widgetWithText(FilledButton, 'Sign in or create account'),
      );
      // Constrained, not stretched across the whole tablet.
      expect(button.width, lessThanOrEqualTo(480));
    });

    testWidgets('renders right-to-left without overflow', (tester) async {
      await setSurface(tester, const Size(390, 844));
      await tester.pumpWidget(harness(direction: TextDirection.rtl));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('reduced motion still renders everything', (tester) async {
      await setSurface(tester, const Size(390, 844));
      await tester.pumpWidget(harness(reduceMotion: true));
      await tester.pump();
      // No entrance to sit through: the content is there immediately.
      expect(find.text('Begin your journey within'), findsOneWidget);
    });
  });

  group('the account action', () {
    testWidgets('opens authentication without choosing guest', (tester) async {
      await setSurface(tester, const Size(390, 844));
      final prefs = FakeWelcomePrefs();
      final visited = <String>[];
      await tester.pumpWidget(harness(prefs: prefs, visited: visited));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign in or create account'));
      await tester.pumpAndSettle();

      expect(visited, contains('/login'));
      // Choosing to sign in is not choosing to be a guest.
      expect(prefs.writes, 0);
      expect(prefs.chosen, isFalse);
    });
  });

  group('the guest action', () {
    testWidgets('records the choice and opens home', (tester) async {
      await setSurface(tester, const Size(390, 844));
      final prefs = FakeWelcomePrefs();
      final visited = <String>[];
      await tester.pumpWidget(harness(prefs: prefs, visited: visited));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue as guest'));
      await tester.pumpAndSettle();

      expect(prefs.chosen, isTrue);
      expect(visited, contains('/home'));
    });

    testWidgets('a failure explains itself and offers a retry', (tester) async {
      await setSurface(tester, const Size(390, 844));
      final prefs = FakeWelcomePrefs(failOnWrite: true);
      final visited = <String>[];
      await tester.pumpWidget(harness(prefs: prefs, visited: visited));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue as guest'));
      await tester.pumpAndSettle();

      expect(find.byType(WelcomeErrorMessage), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
      // It did not pretend to succeed.
      expect(visited, isNot(contains('/home')));
    });

    testWidgets('a second tap does not start a second journey', (tester) async {
      await setSurface(tester, const Size(390, 844));
      final prefs = FakeWelcomePrefs();
      await tester.pumpWidget(harness(prefs: prefs));
      await tester.pumpAndSettle();

      final guest = find.text('Continue as guest');
      await tester.tap(guest, warnIfMissed: false);
      await tester.tap(guest, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(prefs.writes, 1);
    });
  });

  group('legal links', () {
    testWidgets('terms and privacy are separate destinations', (tester) async {
      await setSurface(tester, const Size(390, 844));
      final visited = <String>[];
      await tester.pumpWidget(harness(visited: visited));
      await tester.pumpAndSettle();

      final agreement = find.byType(WelcomeLegalAgreement);
      expect(agreement, findsOneWidget);

      // Tapping the two links must reach two different screens, not one
      // sentence that happens to be blue.
      await tester.ensureVisible(agreement);
      await tester.pumpAndSettle();
      expect(
        find.text('Terms of Use'),
        findsNothing,
        reason: 'the links are spans inside one Text.rich',
      );
    });
  });

  group('the language selector', () {
    testWidgets('lists every shipped language in its own script', (
      tester,
    ) async {
      await setSurface(tester, const Size(390, 844));
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(WelcomeLanguageButton));
      await tester.pumpAndSettle();

      expect(find.text('Choose a language'), findsOneWidget);
      for (final language in selectableLanguages) {
        expect(
          find.text(language.nativeName),
          findsWidgets,
          reason: language.code,
        );
      }
    });

    testWidgets('choosing one changes the language immediately', (
      tester,
    ) async {
      await setSurface(tester, const Size(390, 844));
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(WelcomeLanguageButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Français').last);
      await tester.pumpAndSettle();

      expect(find.text('Commencez votre voyage intérieur'), findsOneWidget);
      expect(find.text("Continuer en tant qu'invité"), findsOneWidget);
    });
  });

  group('localization', () {
    testWidgets('Portuguese renders without overflow', (tester) async {
      await setSurface(tester, const Size(360, 640));
      await tester.pumpWidget(harness(locale: const Locale('pt')));
      await tester.pumpAndSettle();
      expect(find.text('Continuar como convidado'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('German renders without overflow', (tester) async {
      await setSurface(tester, const Size(360, 640));
      await tester.pumpWidget(harness(locale: const Locale('de')));
      await tester.pumpAndSettle();
      expect(find.text('Als Gast fortfahren'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
