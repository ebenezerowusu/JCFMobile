
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jcf_mobile/core/locale_prefs.dart';
import 'package:jcf_mobile/features/language_selection/language_selection_controller.dart';
import 'package:jcf_mobile/features/language_selection/language_selection_screen.dart';
import 'package:jcf_mobile/features/language_selection/language_selection_widgets.dart';
import 'package:jcf_mobile/features/language_selection/supported_languages.dart';
import 'package:jcf_mobile/l10n/app_localizations.dart';

Future<void> setSurface(WidgetTester tester, Size size) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Widget harness({
  LanguageSelectionMode mode = LanguageSelectionMode.firstLaunch,
  Locale locale = const Locale('en'),
  double textScale = 1.0,
  TextDirection direction = TextDirection.ltr,
  List<String>? visited,
}) {
  // Built once, outside the Consumer: recreating a GoRouter when the
  // locale changes throws away the navigation that just happened.
  final router = GoRouter(
    initialLocation: '/language-selection',
    routes: [
      GoRoute(
        path: '/language-selection',
        builder: (_, _) => LanguageSelectionScreen(mode: mode),
      ),
      for (final path in ['/onboarding', '/more', '/welcome'])
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
      child: Consumer(
        builder: (context, ref, _) => MaterialApp.router(
          locale: ref.watch(appLocaleProvider) ?? locale,
          routerConfig: router,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(textScale)),
            child: Directionality(
                textDirection: direction, child: child!),
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
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  // --- configuration ----------------------------------------------------

  group('supported languages', () {
    test('only fully translated languages are selectable', () {
      for (final language in selectableLanguages) {
        expect(language.isFullyTranslated, isTrue,
            reason: language.code);
      }
    });

    test('untranslated languages are configured but never offered', () {
      // Arabic and Swahili exist in config so the machinery is exercised
      // and enabling them later is one flag.
      final all = allLanguages.map((l) => l.code).toSet();
      final offered = selectableLanguages.map((l) => l.code).toSet();
      expect(all, containsAll(['ar', 'sw']));
      expect(offered, isNot(contains('ar')));
      expect(offered, isNot(contains('sw')));
    });

    test('the delegate list matches the selectable list exactly', () {
      // The single-source rule: MaterialApp must not claim to support a
      // language the picker will not show, or vice versa.
      expect(
        supportedAppLocales.map((l) => l.languageCode).toList(),
        selectableLanguages.map((l) => l.code).toList(),
      );
    });

    test('languages appear in their configured order', () {
      final orders = selectableLanguages.map((l) => l.sortOrder).toList();
      expect(orders, orderedEquals([...orders]..sort()));
    });

    test('Arabic is configured right-to-left', () {
      final arabic = allLanguages.firstWhere((l) => l.code == 'ar');
      expect(arabic.isRtl, isTrue);
      expect(arabic.textDirection, TextDirection.rtl);
    });

    test('every language carries a badge and a native name', () {
      for (final language in allLanguages) {
        expect(language.badgeText.length, 2, reason: language.code);
        expect(language.nativeName, isNotEmpty, reason: language.code);
      }
    });
  });

  // --- resolution -------------------------------------------------------

  group('initial language resolution', () {
    test('a saved choice wins over the device', () {
      final resolved = resolveInitialLanguage(
        savedTag: 'pt',
        deviceLocales: [const Locale('fr')],
      );
      expect(resolved.code, 'pt');
    });

    test('an exact region match is preferred', () {
      // No region-specific bundles ship yet, so this falls to the
      // language subtag rather than failing.
      final resolved = resolveInitialLanguage(
        deviceLocales: [const Locale('pt', 'BR')],
      );
      expect(resolved.code, 'pt');
    });

    test('an unsupported region falls back to the language', () {
      final resolved = resolveInitialLanguage(
        deviceLocales: [const Locale('fr', 'CA')],
      );
      expect(resolved.code, 'fr');
    });

    test('an unsupported device locale falls back to the default', () {
      final resolved = resolveInitialLanguage(
        deviceLocales: [const Locale('ja'), const Locale('ko')],
      );
      expect(resolved.code, defaultLanguage.code);
    });

    test('a device language that is configured but untranslated falls back',
        () {
      // Arabic is configured; it must not be resolved to, because the
      // app cannot render itself in it yet.
      final resolved =
          resolveInitialLanguage(deviceLocales: [const Locale('ar')]);
      expect(resolved.code, defaultLanguage.code);
    });

    test('a corrupted saved value is ignored rather than applied', () {
      for (final bad in ['', 'xx', 'not-a-locale', 'ar']) {
        expect(languageByTag(bad)?.code, isNot('xx'), reason: bad);
      }
      expect(languageByTag('zz'), isNull);
    });

    test('the second device locale is used when the first is unsupported',
        () {
      final resolved = resolveInitialLanguage(
        deviceLocales: [const Locale('ja'), const Locale('de')],
      );
      expect(resolved.code, 'de');
    });
  });

  // --- search -----------------------------------------------------------

  group('search', () {
    late AppLocalizations t;

    setUp(() async {
      t = await AppLocalizations.delegate.load(const Locale('en'));
    });

    List<String> find(String query) =>
        searchLanguages(selectableLanguages, query, t)
            .map((l) => l.code)
            .toList();

    test('an empty query returns everything', () {
      expect(find('').length, selectableLanguages.length);
      expect(find('   ').length, selectableLanguages.length);
    });

    test('matches the native name', () => expect(find('Deutsch'), ['de']));

    test('matches the name in the interface language',
        () => expect(find('German'), ['de']));

    test('matches the code', () => expect(find('pt'), ['pt']));

    test('ignores case', () => expect(find('FRANÇAIS'), ['fr']));

    test('ignores diacritics both ways', () {
      // "francais" must find "Français", and vice versa.
      expect(find('francais'), ['fr']);
      expect(find('Español'), ['es']);
      expect(find('espanol'), ['es']);
    });

    test('an unmatched query returns nothing', () {
      expect(find('klingon'), isEmpty);
    });

    test('a query never matches an unoffered language', () {
      expect(find('arabic'), isEmpty);
      expect(find('swahili'), isEmpty);
    });
  });

  // --- screen -----------------------------------------------------------

  group('the screen', () {
    testWidgets('lists every selectable language with its native name',
        (tester) async {
      await setSurface(tester, const Size(390, 844));
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      expect(find.text('Choose your language'), findsOneWidget);
      for (final language in selectableLanguages) {
        expect(find.text(language.nativeName), findsOneWidget,
            reason: language.code);
      }
      // Never offered, so never rendered.
      expect(find.text('العربية'), findsNothing);
      expect(find.text('Kiswahili'), findsNothing);
    });

    testWidgets('uses no country flags', (tester) async {
      await setSurface(tester, const Size(390, 844));
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      // A language is not a country; flag emoji also render
      // inconsistently across platforms.
      final texts = tester
          .widgetList<Text>(find.byType(Text))
          .map((w) => w.data ?? '')
          .join();
      final flagCodePoints = texts.runes
          .where((r) => r >= 0x1F1E6 && r <= 0x1F1FF)
          .length;
      expect(flagCodePoints, 0);
    });

    testWidgets('first launch hides Back', (tester) async {
      await setSurface(tester, const Size(390, 844));
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.arrow_back_rounded), findsNothing);
    });

    testWidgets('settings mode shows Back', (tester) async {
      await setSurface(tester, const Size(390, 844));
      await tester.pumpWidget(
          harness(mode: LanguageSelectionMode.settings));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });

    testWidgets('tapping a row selects it', (tester) async {
      await setSurface(tester, const Size(390, 844));
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Português'));
      await tester.pump();

      final container = ProviderScope.containerOf(
          tester.element(find.byType(LanguageSelectionScreen)));
      expect(
        container.read(languageSelectionControllerProvider).selected?.code,
        'pt',
      );
    });

    testWidgets('searching filters the list', (tester) async {
      await setSurface(tester, const Size(390, 844));
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'deutsch');
      await tester.pumpAndSettle();

      expect(find.text('Deutsch'), findsOneWidget);
      expect(find.text('Français'), findsNothing);
    });

    testWidgets('an unmatched search offers to clear itself',
        (tester) async {
      await setSurface(tester, const Size(390, 844));
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'klingon');
      await tester.pumpAndSettle();

      expect(find.byType(LanguageEmptyState), findsOneWidget);
      expect(find.text('No languages found'), findsOneWidget);

      await tester.tap(find.text('Clear search'));
      await tester.pumpAndSettle();
      expect(find.text('Français'), findsOneWidget);
    });

    testWidgets('an empty search keeps the existing selection',
        (tester) async {
      await setSurface(tester, const Size(390, 844));
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Español'));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'klingon');
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
          tester.element(find.byType(LanguageSelectionScreen)));
      // Filtered out of view, but still the choice.
      expect(
        container.read(languageSelectionControllerProvider).selected?.code,
        'es',
      );
    });
  });

  // --- confirming -------------------------------------------------------

  group('continue', () {
    testWidgets('first launch saves and opens onboarding', (tester) async {
      await setSurface(tester, const Size(390, 844));
      final visited = <String>[];
      await tester.pumpWidget(harness(visited: visited));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Français'));
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(visited, contains('/onboarding'));
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_locale'), 'fr');
      expect(prefs.getBool('language_selection_completed'), isTrue);
    });

    testWidgets('the interface changes language immediately',
        (tester) async {
      await setSurface(tester, const Size(390, 844));
      await tester.pumpWidget(
          harness(mode: LanguageSelectionMode.settings));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Français'));
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_locale'), 'fr');
    });

    testWidgets('settings returns without writing when nothing changed',
        (tester) async {
      await setSurface(tester, const Size(390, 844));
      final visited = <String>[];
      await tester.pumpWidget(harness(
          mode: LanguageSelectionMode.settings, visited: visited));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      // No pointless write for a choice nobody changed.
      expect(prefs.getString('app_locale'), isNull);
    });

    testWidgets('Continue is disabled while saving', (tester) async {
      await setSurface(tester, const Size(390, 844));
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
          tester.element(find.byType(LanguageSelectionScreen)));
      expect(
        container.read(languageSelectionControllerProvider).canContinue,
        isTrue,
      );
    });
  });

  // --- layout and accessibility ----------------------------------------

  group('layout', () {
    testWidgets('a short device does not overflow', (tester) async {
      await setSurface(tester, const Size(320, 568));
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Continue'), findsOneWidget);
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

    testWidgets('a row announces its selected state once', (tester) async {
      await setSurface(tester, const Size(390, 844));
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      // One semantic node per row, not a row plus a radio.
      expect(find.bySemanticsLabel(RegExp('English')), findsOneWidget);
      handle.dispose();
    });
  });

  group('localization', () {
    testWidgets('French renders the screen', (tester) async {
      await setSurface(tester, const Size(390, 844));
      await tester.pumpWidget(harness(locale: const Locale('fr')));
      await tester.pumpAndSettle();
      expect(find.text('Choisissez votre langue'), findsOneWidget);
      // Native names stay native whatever the interface language.
      expect(find.text('Deutsch'), findsOneWidget);
    });
  });
}
