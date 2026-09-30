import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:jcf_mobile/features/auth/auth_controller.dart';
import 'package:jcf_mobile/features/live/live_models.dart';
import 'package:jcf_mobile/features/live/live_playback_controller.dart';
import 'package:jcf_mobile/features/live/live_player_screen.dart';
import 'package:jcf_mobile/l10n/app_localizations.dart';

const _chat = LiveChatConfig(
  enabled: true,
  visibleToGuests: true,
  authRequiredToPost: true,
  slowModeSeconds: 0,
  maxMessageLength: 300,
  readOnly: false,
);

LiveEventDetail event({
  LiveStatus status = LiveStatus.live,
  LiveStream? stream = const LiveStream(
    playbackUrl: 'https://stream.example.com/live.m3u8',
    playbackType: 'hls',
    dvrEnabled: false,
    lowLatency: false,
    captionsUrl: '',
    pipAllowed: true,
  ),
  ReplayMedia? replay,
  LiveAccess access = const LiveAccess(
      allowed: true, requiredTier: 'public', signInRequired: false),
  LiveChatConfig chat = _chat,
  LiveFacilitator? facilitator = const LiveFacilitator(
      displayName: 'Dr. Baffour Jan',
      role: 'Founder',
      avatarUrl: '',
      verified: false),
  int viewerCount = 324,
  bool viewerCountVisible = true,
  bool saved = false,
  DateTime? startsAt,
  String cancellationNote = '',
}) =>
    LiveEventDetail(
      id: 7,
      title: 'Sunday Satsang: Living with Awareness',
      shortDescription: 'A live teaching on conscious living.',
      fullDescription: 'The full description of this session.',
      posterUrl: '',
      status: status,
      startsAt: startsAt ?? DateTime.now().subtract(const Duration(minutes: 5)),
      endsAt: DateTime.now().add(const Duration(minutes: 85)),
      language: 'English',
      category: 'Live session',
      venue: '',
      viewerCount: viewerCount,
      viewerCountVisible: viewerCountVisible,
      chat: chat,
      access: access,
      reminderEnabled: false,
      saved: saved,
      sharingAllowed: true,
      canonicalUrl: 'https://www.jancosmicfoundation.org/live/7',
      facilitator: facilitator,
      stream: stream,
      replay: replay,
      cancellationNote: cancellationNote,
    );

/// A repository that never touches the network, so the chat panel's poll
/// cannot leave pending work behind.
class FakeLiveRepository extends LiveRepository {
  FakeLiveRepository() : super(Dio());

  final sent = <String>[];

  @override
  Future<LiveChatPage> chat(int eventId, {int? after}) async =>
      const LiveChatPage(enabled: true, messages: []);

  @override
  Future<LiveChatMessage> send(int eventId, String text) async {
    sent.add(text);
    return LiveChatMessage(
      id: sent.length,
      displayName: 'Ama',
      role: 'participant',
      text: text,
      deleted: false,
      pinned: false,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<int> heartbeat(int eventId, String key) async => 1;

  @override
  Future<void> endViewerSession(int eventId, String key) async {}

  @override
  Future<bool> setSaved(int eventId, {required bool saved}) async => saved;

  @override
  Future<Map<String, int>> react(int eventId, String kind) async => const {};

  @override
  Future<void> report(int eventId, int messageId) async {}

  @override
  Future<void> block(int eventId, int contactId) async {}
}

void usePhone(WidgetTester tester, {double height = 1400}) {
  tester.view.physicalSize = Size(390 * 3, height * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Widget harness(
  LiveEventDetail? value, {
  Object? error,
  bool loggedIn = false,
  Locale locale = const Locale('en'),
  double textScale = 1,
  TextDirection direction = TextDirection.ltr,
}) {
  final router = GoRouter(
    initialLocation: '/live/7',
    routes: [
      GoRoute(
        path: '/live/:eventId',
        builder: (_, state) => LivePlayerScreen(
            eventId: int.parse(state.pathParameters['eventId']!)),
      ),
      for (final path in ['/home', '/login'])
        GoRoute(path: path, builder: (_, _) => const Placeholder()),
    ],
  );

  return ProviderScope(
    overrides: [
      isLoggedInProvider.overrideWith((ref) => loggedIn),
      liveRepositoryProvider.overrideWith((ref) => FakeLiveRepository()),
      // An inert engine: the tests are about the screen, not the codec.
      livePlaybackControllerFactoryProvider
          .overrideWithValue(InertPlaybackController.new),
      liveEventProvider.overrideWith((ref, arg) async {
        if (error != null) throw error;
        if (value == null) return Completer<LiveEventDetail>().future;
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
  group('model rules', () {
    test('only a running session or a ready replay is playable', () {
      expect(event().playableUrl, isNotNull);
      expect(event(status: LiveStatus.scheduled).playableUrl, isNull);
      expect(event(status: LiveStatus.ended).playableUrl, isNull);
      expect(
        event(
          status: LiveStatus.replayProcessing,
          replay: const ReplayMedia(
              playbackUrl: '',
              processingStatus: 'processing',
              thumbnailUrl: ''),
        ).playableUrl,
        isNull,
      );
      expect(
        event(
          status: LiveStatus.replayAvailable,
          replay: const ReplayMedia(
              playbackUrl: 'https://cdn.example.com/replay.m3u8',
              processingStatus: 'available',
              thumbnailUrl: ''),
        ).playableUrl,
        'https://cdn.example.com/replay.m3u8',
      );
    });

    test('initials stand in for a facilitator without a portrait', () {
      const one = LiveFacilitator(
          displayName: 'Ama', role: '', avatarUrl: '', verified: false);
      const two = LiveFacilitator(
          displayName: 'Dr. Baffour Jan',
          role: '',
          avatarUrl: '',
          verified: false);
      expect(one.initials, 'A');
      expect(two.initials, 'DJ');
    });

    test('unknown server states degrade to unavailable', () {
      expect(LiveStatus.parse('some_new_state'), LiveStatus.unavailable);
      expect(LiveStatus.parse(null), LiveStatus.unavailable);
    });
  });

  group('player screen', () {
    testWidgets('a live session shows the badge, viewers and chat',
        (tester) async {
      usePhone(tester);
      await tester.pumpWidget(harness(event()));
      await tester.pumpAndSettle();

      expect(find.text('Live Now'), findsOneWidget);
      expect(find.text('LIVE'), findsOneWidget);
      expect(find.text('324 watching'), findsOneWidget);
      expect(find.text('Sunday Satsang: Living with Awareness'),
          findsOneWidget);
      expect(find.text('Chat'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
    });

    testWidgets('the viewer count can be hidden', (tester) async {
      usePhone(tester);
      await tester.pumpWidget(harness(event(viewerCountVisible: false)));
      await tester.pumpAndSettle();
      expect(find.text('324 watching'), findsNothing);
    });

    testWidgets('a scheduled session shows the waiting room, not a player',
        (tester) async {
      usePhone(tester);
      await tester.pumpWidget(harness(event(
        status: LiveStatus.scheduled,
        stream: null,
        startsAt: DateTime.now().add(const Duration(hours: 3)),
      )));
      await tester.pump();
      expect(find.text('The stream will begin here'), findsOneWidget);
      expect(find.text('SCHEDULED'), findsOneWidget);
      expect(find.text('LIVE'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('the countdown never shows a negative value', (tester) async {
      usePhone(tester);
      await tester.pumpWidget(harness(event(
        status: LiveStatus.startingSoon,
        stream: null,
        // Already past: a naive countdown would go negative here.
        startsAt: DateTime.now().subtract(const Duration(minutes: 5)),
      )));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.textContaining('-'), findsNothing);
      expect(find.text('STARTING SOON'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('a cancelled session explains itself', (tester) async {
      usePhone(tester);
      await tester.pumpWidget(harness(event(
        status: LiveStatus.cancelled,
        stream: null,
        cancellationNote: 'Cancelled due to travel.',
      )));
      await tester.pumpAndSettle();
      expect(find.text('Cancelled due to travel.'), findsOneWidget);
    });

    testWidgets('replay processing shows its own state', (tester) async {
      usePhone(tester);
      await tester.pumpWidget(harness(event(
        status: LiveStatus.replayProcessing,
        stream: null,
        replay: const ReplayMedia(
            playbackUrl: '',
            processingStatus: 'processing',
            thumbnailUrl: ''),
      )));
      await tester.pumpAndSettle();
      expect(find.text('Replay Processing'), findsWidgets);
    });

    testWidgets('a replay shows the Replay title', (tester) async {
      usePhone(tester);
      await tester.pumpWidget(harness(event(
        status: LiveStatus.replayAvailable,
        stream: null,
        replay: const ReplayMedia(
            playbackUrl: 'https://cdn.example.com/replay.m3u8',
            processingStatus: 'available',
            thumbnailUrl: ''),
      )));
      await tester.pumpAndSettle();
      expect(find.text('Replay'), findsWidgets);
      expect(find.text('LIVE'), findsNothing);
    });

    testWidgets('a members-only session gates a guest', (tester) async {
      usePhone(tester);
      await tester.pumpWidget(harness(event(
        access: const LiveAccess(
            allowed: false, requiredTier: 'members', signInRequired: true),
        // The server sends no stream when access is refused.
        stream: null,
      )));
      await tester.pumpAndSettle();
      expect(find.text('This session is for members and students.'),
          findsOneWidget);
      expect(find.text('Sign In'), findsWidgets);
      expect(find.text('LIVE'), findsNothing);
    });

    testWidgets('a students-only session names the right tier',
        (tester) async {
      usePhone(tester);
      await tester.pumpWidget(harness(event(
        access: const LiveAccess(
            allowed: false, requiredTier: 'students', signInRequired: false),
        stream: null,
      )));
      await tester.pumpAndSettle();
      expect(find.text('This session is for enrolled students.'),
          findsOneWidget);
    });

    testWidgets('a facilitator without a portrait shows initials',
        (tester) async {
      usePhone(tester);
      await tester.pumpWidget(harness(event()));
      await tester.pumpAndSettle();
      expect(find.text('DJ'), findsOneWidget);
      expect(find.text('Dr. Baffour Jan'), findsWidgets);
    });

    testWidgets('a missing event offers a way home', (tester) async {
      usePhone(tester);
      await tester.pumpWidget(harness(null, error: const LiveEventNotFound()));
      await tester.pumpAndSettle();
      expect(find.text('This stream is unavailable right now.'),
          findsOneWidget);
      expect(find.text('Back to Home'), findsOneWidget);
    });

    testWidgets('a network error offers retry', (tester) async {
      usePhone(tester);
      await tester.pumpWidget(harness(null, error: Exception('offline')));
      await tester.pumpAndSettle();
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('a guest asked to save is prompted to sign in',
        (tester) async {
      usePhone(tester);
      await tester.pumpWidget(harness(event()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save for Later'));
      await tester.pumpAndSettle();
      expect(find.text('Sign in to save this inspiration.'), findsOneWidget);
    });

    testWidgets('the About tab lists the event facts', (tester) async {
      usePhone(tester);
      await tester.pumpWidget(harness(event()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('About'));
      await tester.pumpAndSettle();
      expect(find.text('The full description of this session.'),
          findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Schedule'), findsOneWidget);
    });

    testWidgets('chat closed by the server shows a closed notice',
        (tester) async {
      usePhone(tester);
      await tester.pumpWidget(harness(event(
        chat: const LiveChatConfig(
          enabled: false,
          visibleToGuests: false,
          authRequiredToPost: true,
          slowModeSeconds: 0,
          maxMessageLength: 300,
          readOnly: false,
        ),
      )));
      await tester.pumpAndSettle();
      expect(find.text('Chat is closed'), findsOneWidget);
    });

    testWidgets('a muted member sees a read-only chat', (tester) async {
      usePhone(tester);
      await tester.pumpWidget(harness(
        event(
          chat: const LiveChatConfig(
            enabled: true,
            visibleToGuests: true,
            authRequiredToPost: true,
            slowModeSeconds: 0,
            maxMessageLength: 300,
            readOnly: true,
          ),
        ),
        loggedIn: true,
      ));
      await tester.pumpAndSettle();
      expect(find.text('Chat is read-only'), findsOneWidget);
      // No input is offered at all.
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('guests are shut out when chat is not public', (tester) async {
      usePhone(tester);
      await tester.pumpWidget(harness(event(
        chat: const LiveChatConfig(
          enabled: true,
          visibleToGuests: false,
          authRequiredToPost: true,
          slowModeSeconds: 0,
          maxMessageLength: 300,
          readOnly: false,
        ),
      )));
      await tester.pumpAndSettle();
      expect(find.text('Sign in to participate'), findsWidgets);
    });

    testWidgets('French locale localizes the player', (tester) async {
      usePhone(tester);
      await tester.pumpWidget(harness(event(), locale: const Locale('fr')));
      await tester.pumpAndSettle();
      expect(find.text('En direct'), findsWidgets);
      expect(find.text('Discussion'), findsOneWidget);
    });

    testWidgets('renders at large text scale without overflow',
        (tester) async {
      usePhone(tester, height: 2000);
      await tester.pumpWidget(harness(event(), textScale: 1.6));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders right-to-left without overflow', (tester) async {
      usePhone(tester);
      await tester
          .pumpWidget(harness(event(), direction: TextDirection.rtl));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('leaving the screen disposes its resources', (tester) async {
      usePhone(tester);
      await tester.pumpWidget(harness(event()));
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      // No pending timers or controllers left behind.
      expect(tester.takeException(), isNull);
    });
  });
}
