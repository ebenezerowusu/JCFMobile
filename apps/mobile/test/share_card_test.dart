import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:jcf_mobile/features/inspiration/inspiration_detail_repository.dart'
    show InspirationNotFound;
import 'package:jcf_mobile/features/inspiration/share_card/share_card_canvas.dart';
import 'package:jcf_mobile/features/inspiration/share_card/share_card_models.dart';
import 'package:jcf_mobile/features/inspiration/share_card/share_card_renderer.dart';
import 'package:jcf_mobile/features/inspiration/share_card/share_card_screen.dart';
import 'package:jcf_mobile/l10n/app_localizations.dart';

const _cosmic = ShareCardTemplate(
  id: 'cosmic',
  name: 'Cosmic',
  recommendedTextColor: ShareCardTextColorMode.light,
  formats: [ShareCardFormat.square, ShareCardFormat.story],
  enabled: true,
);
const _dawn = ShareCardTemplate(
  id: 'dawn',
  name: 'Dawn',
  recommendedTextColor: ShareCardTextColorMode.light,
  formats: [ShareCardFormat.square],
  enabled: true,
);
const _light = ShareCardTemplate(
  id: 'light',
  name: 'Light',
  recommendedTextColor: ShareCardTextColorMode.dark,
  formats: [ShareCardFormat.square],
  enabled: true,
);

ShareCardData data({
  String? author = 'Dr. Baffour Jan',
  String? source = 'Awareness',
  String excerpt =
      'Freedom begins when awareness becomes your way of living.',
  bool sharingAllowed = true,
  String website = 'www.jancosmicfoundation.org',
  List<ShareCardTemplate> templates = const [_cosmic, _dawn, _light],
}) =>
    ShareCardData(
      inspirationId: 1,
      slug: 'freedom-begins-with-awareness',
      shareExcerpt: excerpt,
      canonicalUrl:
          'https://www.jancosmicfoundation.org/inspirations/freedom-begins-with-awareness',
      sharingAllowed: sharingAllowed,
      defaultTemplateId: 'cosmic',
      templates: templates,
      websiteLabel: website,
      author: author,
      source: source,
    );

void usePhone(WidgetTester tester, {double width = 390, double height = 3000}) {
  tester.view.physicalSize = Size(width * 3, height * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Widget harness(
  ShareCardData? value, {
  Object? error,
  Locale locale = const Locale('en'),
  double textScale = 1,
  TextDirection direction = TextDirection.ltr,
}) {
  final router = GoRouter(
    initialLocation: '/inspirations/freedom-begins-with-awareness/share-card',
    routes: [
      GoRoute(
        path: '/inspirations/:identifier/share-card',
        builder: (_, state) =>
            ShareCardScreen(identifier: state.pathParameters['identifier']!),
      ),
      GoRoute(path: '/home', builder: (_, _) => const Placeholder()),
    ],
  );

  return ProviderScope(
    overrides: [
      shareCardDataProvider.overrideWith((ref, arg) async {
        if (error != null) throw error;
        if (value == null) return Completer<ShareCardData>().future;
        return value;
      }),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      locale: locale,
      builder: (context, child) => Directionality(
        textDirection: direction,
        child: MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
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
  group('template registry', () {
    test('assets resolve per format and are never stretched', () {
      expect(_cosmic.assetFor(ShareCardFormat.square),
          endsWith('daily_inspiration_share_card_cosmic_square.webp'));
      expect(_cosmic.assetFor(ShareCardFormat.story),
          endsWith('daily_inspiration_share_card_cosmic_story.webp'));
      // Dawn has no story artwork, so it offers none rather than stretching.
      expect(_dawn.assetFor(ShareCardFormat.story), isNull);
      expect(_dawn.supports(ShareCardFormat.story), isFalse);
    });

    test('formats keep their export sizes and ratios', () {
      expect(ShareCardFormat.square.exportSize, const Size(1080, 1080));
      expect(ShareCardFormat.story.exportSize, const Size(1080, 1920));
      expect(ShareCardFormat.square.aspectRatio, 1);
      expect(ShareCardFormat.story.aspectRatio, 9 / 16);
    });

    test('defaults follow the template recommendation', () {
      final config = ShareCardConfiguration.defaults(data());
      expect(config.format, ShareCardFormat.square);
      expect(config.templateId, 'cosmic');
      expect(config.alignment, ShareCardTextAlignment.center);
      expect(config.textColor, ShareCardTextColorMode.light);
      expect(config.textSize, ShareCardTextSize.medium);
      expect(config.showLogo, isTrue);
      expect(config.matchesDefaults(data()), isTrue);
    });

    test('no source means the source switch starts off', () {
      final config =
          ShareCardConfiguration.defaults(data(author: null, source: null));
      expect(config.showSource, isFalse);
    });

    test('text sizes grow with the format', () {
      for (final format in ShareCardFormat.values) {
        expect(ShareCardTextSize.small.quoteSize(format),
            lessThan(ShareCardTextSize.medium.quoteSize(format)));
        expect(ShareCardTextSize.medium.quoteSize(format),
            lessThan(ShareCardTextSize.large.quoteSize(format)));
      }
    });

    test('the export filename is sanitised and carries the format', () {
      final name = shareCardFileName(data(), ShareCardFormat.story);
      expect(name, startsWith('jcf_daily_inspiration_'));
      expect(name, contains('_story_'));
      expect(name, endsWith('.png'));
      expect(RegExp(r'^[A-Za-z0-9_.\-]+$').hasMatch(name), isTrue);
    });
  });

  group('canvas', () {
    testWidgets('renders excerpt, source and branding', (tester) async {
      usePhone(tester);
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: Scaffold(
          body: Center(
            child: ShareCardCanvas(
              data: data(),
              config: ShareCardConfiguration.defaults(data()),
              scale: 0.3,
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.textContaining('Freedom begins when awareness'),
          findsOneWidget);
      expect(find.text('Jan Cosmic Foundation'), findsOneWidget);
      expect(find.text('— Dr. Baffour Jan'), findsOneWidget);
      expect(find.text('www.jancosmicfoundation.org'), findsOneWidget);
    });

    testWidgets('hidden logo, source and website leave the card clean',
        (tester) async {
      usePhone(tester);
      final d = data();
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: Scaffold(
          body: Center(
            child: ShareCardCanvas(
              data: d,
              config: ShareCardConfiguration.defaults(d).copyWith(
                  showLogo: false, showSource: false, showWebsite: false),
              scale: 0.3,
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('— Dr. Baffour Jan'), findsNothing);
      expect(find.text('www.jancosmicfoundation.org'), findsNothing);
      // The foundation name stays even without the graphical logo.
      expect(find.text('Jan Cosmic Foundation'), findsOneWidget);
    });

    testWidgets('a long excerpt does not overflow the card', (tester) async {
      usePhone(tester);
      final d = data(excerpt: 'Awareness is the doorway to freedom. ' * 14);
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: Scaffold(
          body: Center(
            child: ShareCardCanvas(
              data: d,
              config: ShareCardConfiguration.defaults(d)
                  .copyWith(textSize: ShareCardTextSize.large),
              scale: 0.3,
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('story format keeps its 9:16 ratio', (tester) async {
      usePhone(tester);
      final d = data();
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: Scaffold(
          body: Center(
            child: ShareCardCanvas(
              data: d,
              config: ShareCardConfiguration.defaults(d)
                  .copyWith(format: ShareCardFormat.story),
              scale: 0.2,
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      final size = tester.getSize(find.byType(ShareCardCanvas));
      expect(size.width / size.height, closeTo(9 / 16, 0.01));
    });

    testWidgets('renders right-to-left without overflow', (tester) async {
      usePhone(tester);
      final d = data();
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: Center(
              child: ShareCardCanvas(
                data: d,
                config: ShareCardConfiguration.defaults(d)
                    .copyWith(alignment: ShareCardTextAlignment.start),
                scale: 0.3,
              ),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('composer', () {
    testWidgets('shows every control with defaults applied', (tester) async {
      usePhone(tester);
      await tester.pumpWidget(harness(data()));
      await tester.pumpAndSettle();

      expect(find.text('Create Share Card'), findsOneWidget);
      expect(find.text('Square'), findsOneWidget);
      expect(find.text('Story'), findsOneWidget);
      expect(find.text('Choose a Style'), findsOneWidget);
      expect(find.text('Text Alignment'), findsOneWidget);
      expect(find.text('Text Color'), findsOneWidget);
      expect(find.text('Text Size'), findsOneWidget);
      expect(find.text('Show Logo'), findsOneWidget);
      expect(find.text('Save Image'), findsOneWidget);
      expect(find.byType(ShareCardCanvas), findsOneWidget);
    });

    testWidgets('Reset is disabled until something changes', (tester) async {
      usePhone(tester);
      await tester.pumpWidget(harness(data()));
      await tester.pumpAndSettle();

      TextButton reset() =>
          tester.widget<TextButton>(find.widgetWithText(TextButton, 'Reset'));
      expect(reset().onPressed, isNull);

      await tester.tap(find.text('Large'));
      await tester.pumpAndSettle();
      expect(reset().onPressed, isNotNull);

      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();
      expect(reset().onPressed, isNull);
    });

    testWidgets('switching to Story drops templates without story artwork',
        (tester) async {
      usePhone(tester);
      await tester.pumpWidget(harness(data()));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('template-dawn')), findsOneWidget);

      await tester.tap(find.text('Story'));
      await tester.pumpAndSettle();
      // Only Cosmic has a story background.
      expect(find.byKey(const ValueKey('template-dawn')), findsNothing);
      expect(find.byKey(const ValueKey('template-light')), findsNothing);
      expect(find.byKey(const ValueKey('template-cosmic')), findsOneWidget);
    });

    testWidgets('choosing a template that is story-less falls back on switch',
        (tester) async {
      usePhone(tester);
      await tester.pumpWidget(harness(data()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('template-dawn')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Story'));
      await tester.pumpAndSettle();

      final canvas =
          tester.widget<ShareCardCanvas>(find.byType(ShareCardCanvas));
      expect(canvas.config.format, ShareCardFormat.story);
      // Never left pointing at artwork that does not exist.
      expect(canvas.config.templateId, 'cosmic');
    });

    testWidgets('the Light template switches the text to dark',
        (tester) async {
      usePhone(tester);
      await tester.pumpWidget(harness(data()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('template-light')));
      await tester.pumpAndSettle();
      final canvas =
          tester.widget<ShareCardCanvas>(find.byType(ShareCardCanvas));
      expect(canvas.config.textColor, ShareCardTextColorMode.dark);
    });

    testWidgets('alignment and size controls update the preview',
        (tester) async {
      usePhone(tester);
      await tester.pumpWidget(harness(data()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('End'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Small'));
      await tester.pumpAndSettle();

      final canvas =
          tester.widget<ShareCardCanvas>(find.byType(ShareCardCanvas));
      expect(canvas.config.alignment, ShareCardTextAlignment.end);
      expect(canvas.config.textSize, ShareCardTextSize.small);
    });

    testWidgets('Show Source is disabled when there is no attribution',
        (tester) async {
      usePhone(tester);
      await tester.pumpWidget(harness(data(author: null, source: null)));
      await tester.pumpAndSettle();
      final tile = tester.widget<SwitchListTile>(
          find.widgetWithText(SwitchListTile, 'Show Source'));
      expect(tile.onChanged, isNull);
      expect(tile.value, isFalse);
    });

    testWidgets('prohibited sharing blocks the composer', (tester) async {
      usePhone(tester);
      await tester.pumpWidget(harness(data(sharingAllowed: false)));
      await tester.pumpAndSettle();
      expect(find.text('This inspiration cannot be shared.'), findsOneWidget);
      expect(find.byType(ShareCardCanvas), findsNothing);
      // No export actions are offered at all.
      expect(find.text('Save Image'), findsNothing);
    });

    testWidgets('a removed inspiration explains itself', (tester) async {
      usePhone(tester);
      await tester.pumpWidget(
          harness(null, error: const InspirationNotFound()));
      await tester.pumpAndSettle();
      expect(find.text('This inspiration is no longer available.'),
          findsOneWidget);
    });

    testWidgets('a network error offers retry', (tester) async {
      usePhone(tester);
      await tester.pumpWidget(harness(null, error: Exception('offline')));
      await tester.pumpAndSettle();
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('French locale localizes the composer', (tester) async {
      usePhone(tester);
      await tester.pumpWidget(harness(data(), locale: const Locale('fr')));
      await tester.pumpAndSettle();
      expect(find.text('Créer une carte'), findsOneWidget);
      expect(find.text('Choisissez un style'), findsOneWidget);
    });

    testWidgets('renders at large text scale without overflow',
        (tester) async {
      usePhone(tester, height: 4200);
      await tester.pumpWidget(harness(data(), textScale: 1.6));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders right-to-left without overflow', (tester) async {
      usePhone(tester);
      await tester.pumpWidget(
          harness(data(), direction: TextDirection.rtl));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
