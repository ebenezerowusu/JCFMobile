import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:jcf_mobile/features/auth/auth_controller.dart';
import 'package:jcf_mobile/features/inspiration/inspiration_detail_repository.dart';
import 'package:jcf_mobile/features/inspiration/inspiration_detail_screen.dart';
import 'package:jcf_mobile/features/inspiration/inspiration_share_sheet.dart';
import 'package:jcf_mobile/l10n/app_localizations.dart';

DailyInspirationDetail detail({
  String title = 'Freedom begins with awareness',
  String? author = 'Dr. Baffour Jan',
  List<InspirationBlock> blocks = const [],
  ReflectionPrompt? prompt,
  InspirationAudio? audio,
  List<InspirationSummary> related = const [],
  InspirationSummary? previous,
  InspirationSummary? next,
  bool saved = false,
  bool reflected = false,
  bool sharingAllowed = true,
  int readingTime = 3,
}) =>
    DailyInspirationDetail(
      id: 1,
      slug: 'freedom-begins-with-awareness',
      category: 'Awareness',
      title: title,
      primaryQuote: 'Freedom begins when awareness becomes your way of living.',
      shareExcerpt: 'Freedom begins when awareness becomes your way of living.',
      readingTimeMinutes: readingTime,
      heroImageUrl: '',
      heroAltText: 'Sunrise above the Earth',
      bodyBlocks: blocks,
      saved: saved,
      reflected: reflected,
      sharingAllowed: sharingAllowed,
      canonicalUrl:
          'https://www.jancosmicfoundation.org/inspirations/freedom-begins-with-awareness',
      related: related,
      author: author,
      publishedAt: DateTime(2026, 9, 25),
      prompt: prompt,
      audio: audio,
      previous: previous,
      next: next,
    );

InspirationBlock block(BlockType type,
        {String text = '', List<String> items = const [], String source = ''}) =>
    InspirationBlock(
      id: 1,
      type: type,
      text: text,
      source: source,
      imageUrl: '',
      altText: '',
      caption: '',
      items: items,
    );

InspirationSummary summary({
  String slug = 'stillness-speaks',
  String title = 'Stillness speaks',
  bool saved = false,
}) =>
    InspirationSummary(
      id: 2,
      slug: slug,
      category: 'Stillness',
      title: title,
      readingTimeMinutes: 2,
      saved: saved,
      publishedAt: DateTime(2026, 9, 24),
    );

void useTallPhone(WidgetTester tester, {double width = 390}) {
  tester.view.physicalSize = Size(width * 3, 4200 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Widget harness(
  DailyInspirationDetail? data, {
  Object? error,
  bool loggedIn = false,
  Locale locale = const Locale('en'),
  double textScale = 1,
  String identifier = 'freedom-begins-with-awareness',
}) {
  final router = GoRouter(
    initialLocation: '/inspirations/$identifier',
    routes: [
      GoRoute(
        path: '/inspirations/:identifier',
        builder: (_, state) => InspirationDetailScreen(
            identifier: state.pathParameters['identifier']!),
      ),
      for (final path in ['/home', '/login'])
        GoRoute(path: path, builder: (_, _) => const Placeholder()),
    ],
  );

  return ProviderScope(
    overrides: [
      isLoggedInProvider.overrideWith((ref) => loggedIn),
      // An async body that throws gives Riverpod a properly handled error
      // future; a bare Future.error is treated as unhandled and never
      // reaches the provider.
      inspirationDetailProvider.overrideWith((ref, arg) async {
        if (error != null) throw error;
        if (data == null) return Completer<DailyInspirationDetail>().future;
        return data;
      }),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      locale: locale,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
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
  testWidgets('renders the article for a guest', (tester) async {
    useTallPhone(tester);
    await tester.pumpWidget(harness(detail(
      blocks: [
        block(BlockType.paragraph, text: 'Awareness is not a technique.'),
        block(BlockType.heading, text: 'Living with awareness'),
        block(BlockType.pullQuote,
            text: 'Notice, and you are already free.',
            source: 'Dr. Baffour Jan'),
      ],
    )));
    await tester.pumpAndSettle();

    expect(find.text('Freedom begins with awareness'), findsOneWidget);
    expect(find.text('AWARENESS'), findsOneWidget);
    expect(find.text('Dr. Baffour Jan'), findsWidgets);
    expect(find.textContaining('3 min read'), findsOneWidget);
    expect(find.text('Awareness is not a technique.'), findsOneWidget);
    expect(find.text('Living with awareness'), findsOneWidget);
    expect(find.text('Notice, and you are already free.'), findsOneWidget);
  });

  testWidgets('an unsupported block does not break the article',
      (tester) async {
    useTallPhone(tester);
    await tester.pumpWidget(harness(detail(blocks: [
      block(BlockType.unsupported, text: 'from a newer backend'),
      block(BlockType.paragraph, text: 'This paragraph still renders.'),
    ])));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('This paragraph still renders.'), findsOneWidget);
    expect(find.text('from a newer backend'), findsNothing);
  });

  testWidgets('list blocks render their items', (tester) async {
    useTallPhone(tester);
    await tester.pumpWidget(harness(detail(blocks: [
      block(BlockType.numberedList, items: ['Notice', 'Pause', 'Choose']),
    ])));
    await tester.pumpAndSettle();
    expect(find.text('Notice'), findsOneWidget);
    expect(find.text('1.'), findsOneWidget);
    expect(find.text('3.'), findsOneWidget);
  });

  testWidgets('an inspiration without an author omits the byline',
      (tester) async {
    useTallPhone(tester);
    await tester.pumpWidget(harness(detail(author: null)));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Dr. Baffour Jan'), findsNothing);
  });

  testWidgets('shows the skeleton while loading', (tester) async {
    await tester.pumpWidget(harness(null));
    await tester.pump();
    expect(find.byType(InspirationDetailSkeleton), findsOneWidget);
  });

  testWidgets('a removed link explains itself and offers a way out',
      (tester) async {
    await tester.pumpWidget(
        harness(null, error: const InspirationNotFound()));
    await tester.pumpAndSettle();
    expect(find.text('This inspiration is no longer available.'),
        findsOneWidget);
    expect(find.text('Explore Latest Inspirations'), findsOneWidget);
    // Not a retry — retrying a deleted record would never succeed.
    expect(find.text('Retry'), findsNothing);
  });

  testWidgets('a network error offers retry', (tester) async {
    await tester.pumpWidget(harness(null, error: Exception('offline')));
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('guest tapping Save is asked to sign in', (tester) async {
    useTallPhone(tester);
    await tester.pumpWidget(harness(detail()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.bookmark_border_rounded).first);
    await tester.pumpAndSettle();
    expect(find.text('Sign in to save this inspiration.'), findsOneWidget);
  });

  testWidgets('guest tapping Mark as Reflected is asked to sign in',
      (tester) async {
    useTallPhone(tester);
    await tester.pumpWidget(harness(detail(
      prompt: const ReflectionPrompt(
        question: 'Where are you reacting automatically?',
        guidance: 'Sit with this for a moment.',
        status: 'open',
      ),
    )));
    await tester.pumpAndSettle();

    expect(find.text('Pause and Reflect'), findsOneWidget);
    expect(find.text('Where are you reacting automatically?'), findsOneWidget);
    await tester.tap(find.text('Mark as Reflected'));
    await tester.pumpAndSettle();
    expect(find.text('Sign in to record your reflection.'), findsOneWidget);
  });

  testWidgets('a reflected inspiration shows its completed state',
      (tester) async {
    useTallPhone(tester);
    await tester.pumpWidget(harness(
      detail(
        reflected: true,
        saved: true,
        prompt: const ReflectionPrompt(
            question: 'Where are you reacting?',
            guidance: '',
            status: 'reflected'),
      ),
      loggedIn: true,
    ));
    await tester.pumpAndSettle();
    expect(find.text('Reflected'), findsOneWidget);
    expect(find.text('Saved'), findsWidgets);
    expect(find.byIcon(Icons.bookmark_rounded), findsWidgets);
  });

  testWidgets('share is hidden when the server disallows it', (tester) async {
    useTallPhone(tester);
    await tester.pumpWidget(harness(detail(sharingAllowed: false)));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.share_rounded), findsNothing);
  });

  testWidgets('the share sheet offers image, link and copy', (tester) async {
    useTallPhone(tester);
    await tester.pumpWidget(harness(detail()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.share_rounded).first);
    await tester.pumpAndSettle();
    expect(find.text('Share as Image'), findsOneWidget);
    expect(find.text('Share Link'), findsOneWidget);
    expect(find.text('Copy Link'), findsOneWidget);
    expect(find.byType(InspirationShareCard), findsOneWidget);
  });

  testWidgets('the share card shows the excerpt and branding, not the body',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: Scaffold(
        body: Center(child: InspirationShareCard(detail: detail())),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Jan Cosmic Foundation'), findsOneWidget);
    expect(
        find.textContaining('www.jancosmicfoundation.org'), findsOneWidget);
    expect(find.textContaining('Freedom begins when awareness'),
        findsOneWidget);
  });

  testWidgets('a very long excerpt stays inside the share card',
      (tester) async {
    final long = detail();
    final stretched = DailyInspirationDetail(
      id: long.id,
      slug: long.slug,
      category: long.category,
      title: long.title,
      primaryQuote: long.primaryQuote,
      shareExcerpt: 'Awareness is the doorway to freedom. ' * 12,
      readingTimeMinutes: long.readingTimeMinutes,
      heroImageUrl: '',
      heroAltText: '',
      bodyBlocks: const [],
      saved: false,
      reflected: false,
      sharingAllowed: true,
      canonicalUrl: long.canonicalUrl,
      related: const [],
      author: long.author,
    );
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: Scaffold(
        body: Center(child: InspirationShareCard(detail: stretched)),
      ),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('the share card renders right-to-left', (tester) async {
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: Center(child: InspirationShareCard(detail: detail())),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('related cards render and exclude nothing supplied',
      (tester) async {
    useTallPhone(tester);
    await tester.pumpWidget(harness(detail(
      related: [summary(), summary(slug: 'service', title: 'Service', saved: true)],
    )));
    await tester.pumpAndSettle();
    expect(find.text('Continue Reflecting'), findsOneWidget);
    expect(find.text('Stillness speaks'), findsOneWidget);
    expect(find.text('Service'), findsOneWidget);
  });

  testWidgets('previous and next appear only when the server supplies them',
      (tester) async {
    useTallPhone(tester);
    await tester.pumpWidget(harness(detail(previous: summary())));
    await tester.pumpAndSettle();
    expect(find.text('Previous'), findsOneWidget);
    expect(find.text('Next'), findsNothing);
    expect(find.text('Back to Home'), findsOneWidget);
  });

  testWidgets('audio appears only when a source exists', (tester) async {
    useTallPhone(tester);
    await tester.pumpWidget(harness(detail()));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);

    await tester.pumpWidget(harness(
      detail(
        audio: const InspirationAudio(
            url: 'https://cdn.example.com/a.mp3',
            title: 'Reflection',
            durationSeconds: 240),
      ),
      identifier: 'with-audio',
    ));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    expect(find.text('4:00'), findsOneWidget);
  });

  testWidgets('French locale localizes the reading UI', (tester) async {
    useTallPhone(tester);
    await tester.pumpWidget(harness(
      detail(
        prompt: const ReflectionPrompt(
            question: 'Question ?', guidance: '', status: 'open'),
      ),
      locale: const Locale('fr'),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Pause et réflexion'), findsOneWidget);
    expect(find.text('Marquer comme médité'), findsOneWidget);
  });

  testWidgets('renders at large text scale without overflow', (tester) async {
    useTallPhone(tester);
    await tester.pumpWidget(harness(
      detail(
        blocks: [block(BlockType.paragraph, text: 'Awareness is a practice.')],
        prompt: const ReflectionPrompt(
            question: 'Where are you reacting automatically today?',
            guidance: 'Sit with it.',
            status: 'open'),
        related: [summary()],
        previous: summary(),
        next: summary(slug: 'next-one', title: 'Next one'),
      ),
      textScale: 1.6,
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders right-to-left without overflow', (tester) async {
    useTallPhone(tester);
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.rtl,
      child: harness(detail(
        blocks: [block(BlockType.paragraph, text: 'Awareness is a practice.')],
        related: [summary()],
      )),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
