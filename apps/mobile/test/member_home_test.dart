import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jcf_ui/jcf_ui.dart';

import 'package:jcf_mobile/features/home/member_home_repository.dart';
import 'package:jcf_mobile/features/home/member_home_screen.dart';
import 'package:jcf_mobile/features/home/member_home_widgets.dart';
import 'package:jcf_mobile/features/inspiration/inspiration_repository.dart';
import 'package:jcf_mobile/l10n/app_localizations.dart';

MemberHomePayload payload({
  String preferredName = 'Ama',
  String firstName = 'Ama',
  List<LearningProgress> learning = const [],
  List<PracticeProgress> practice = const [],
  List<Inspiration> inspirations = const [],
  List<CommunityAnnouncement> announcements = const [],
  List<QuickActionItem> quickActions = const [],
  FeaturedContent? featured,
  MemberEvent? event,
  int unread = 0,
}) =>
    MemberHomePayload(
      summary: MemberSummary(
        preferredName: preferredName,
        firstName: firstName,
        membershipLabel: 'JCF Member',
        membershipStatus: 'member',
      ),
      welcome: const WelcomeContent(
        eyebrow: 'YOUR JOURNEY',
        titleTemplate: 'Welcome back, {name}',
        message: 'Continue growing in awareness, one conscious step at a time.',
        actionLabel: 'Continue Your Journey',
        destination: MemberDestination.journey,
      ),
      continueLearning: learning,
      continuePractice: practice,
      inspirations: inspirations,
      quickActions: quickActions,
      announcements: announcements,
      unreadNotificationCount: unread,
      fetchedAt: DateTime(2026, 9, 29, 12),
      featuredContent: featured,
      featuredEvent: event,
    );

final learningFixture = LearningProgress(
  contentId: 'foundations',
  title: 'InnerSpace Foundations',
  subtitle: 'Dr. Baffour Jan',
  currentUnitTitle: 'Lesson 3 · The Observing Mind',
  completedUnits: 2,
  totalUnits: 6,
  destination: MemberDestination.lesson,
  currentUnitId: 'the-observing-mind',
  progressPercentage: 33,
  remainingSeconds: 2400,
);

final practiceFixture = const PracticeProgress(
  practiceId: 'morning-stillness',
  title: 'Morning Stillness',
  subtitle: 'Morning',
  currentStreak: 4,
  destination: MemberDestination.practice,
  durationSeconds: 900,
);

final featuredFixture = const FeaturedContent(
  id: 'the-consciousness-of-a-new-humanity',
  contentType: 'video',
  title: 'The Consciousness of a New Humanity',
  speaker: 'Dr. Baffour Jan',
  accessGranted: true,
  destination: MemberDestination.teaching,
  durationSeconds: 1800,
);

MemberEvent eventFixture({required DateTime startsAt, DateTime? endsAt}) =>
    MemberEvent(
      title: 'Sunday Satsang',
      facilitator: 'Dr. Baffour Jan',
      startsAt: startsAt,
      endsAt: endsAt,
      allDay: false,
      format: '',
      reminderEnabled: false,
      destination: MemberDestination.event,
    );

Widget harness(MemberHomePayload? data,
    {Object? error, Locale locale = const Locale('en'), double textScale = 1}) {
  final router = GoRouter(routes: [
    GoRoute(
      path: '/',
      builder: (_, _) => Scaffold(
        backgroundColor: JcfColors.skySurface,
        body: SafeArea(child: const MemberHomeBody()),
      ),
    ),
    GoRoute(path: '/lessons', builder: (_, _) => const Placeholder()),
    GoRoute(path: '/practice', builder: (_, _) => const Placeholder()),
    GoRoute(path: '/learning', builder: (_, _) => const Placeholder()),
    GoRoute(path: '/activities', builder: (_, _) => const Placeholder()),
    GoRoute(path: '/announcements', builder: (_, _) => const Placeholder()),
    GoRoute(path: '/programs', builder: (_, _) => const Placeholder()),
    GoRoute(path: '/more', builder: (_, _) => const Placeholder()),
    GoRoute(path: '/search', builder: (_, _) => const Placeholder()),
    GoRoute(path: '/profile', builder: (_, _) => const Placeholder()),
    GoRoute(path: '/notifications', builder: (_, _) => const Placeholder()),
  ]);

  return ProviderScope(
    overrides: [
      memberHomeProvider.overrideWith((ref) => error != null
          ? Future<MemberHomePayload>.error(error)
          : data == null
              // Never completes: the initial loading state (a Completer
              // rather than a delay, so no timer is left pending).
              ? Completer<MemberHomePayload>().future
              : Future.value(data)),
    ],
    // The scaler is applied inside MaterialApp so the ambient MediaQuery
    // (and therefore the surface size) is preserved.
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

/// Gives the test a phone-width but very tall surface so every sliver child
/// is built in a single pass.
void useTallPhone(WidgetTester tester, {double width = 390}) {
  tester.view.physicalSize = Size(width * 3, 4200 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('renders every populated section', (tester) async {
    useTallPhone(tester);
    await tester.pumpWidget(harness(payload(
      learning: [learningFixture],
      practice: [practiceFixture],
      featured: featuredFixture,
      event: eventFixture(startsAt: DateTime.now().add(const Duration(days: 2))),
      quickActions: const [
        QuickActionItem(id: 'my_library', sortOrder: 1),
        QuickActionItem(id: 'my_programs', sortOrder: 2),
        QuickActionItem(id: 'saved', sortOrder: 3),
      ],
      announcements: [
        CommunityAnnouncement(
          id: 1,
          category: 'Members',
          title: 'September Gathering',
          summary: 'Join the JCF community for an evening of reflection.',
          read: false,
          destination: MemberDestination.announcement,
          publishedAt: DateTime(2026, 9, 20),
        ),
      ],
    )));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back, Ama'), findsOneWidget);
    expect(find.text('JCF Member'), findsOneWidget);
    expect(find.text('Continue Your Journey'), findsWidgets);
    expect(find.text('InnerSpace Foundations'), findsOneWidget);
    expect(find.text('2 of 6 lessons'), findsOneWidget);
    expect(find.text('33%'), findsOneWidget);
    expect(find.text('For Members'), findsOneWidget);
    expect(find.text('MEMBER EXCLUSIVE'), findsOneWidget);
    expect(find.text('Sunday Satsang'), findsOneWidget);
    expect(find.text('My Library'), findsOneWidget);
    expect(find.text('September Gathering'), findsOneWidget);
    // No public signup anywhere on an authenticated screen.
    expect(find.textContaining('Sign Up'), findsNothing);
    expect(find.textContaining('Create Account'), findsNothing);
  });

  testWidgets('greeting falls back when no name is available',
      (tester) async {
    await tester.pumpWidget(
        harness(payload(preferredName: '', firstName: '')));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsWidgets);
  });

  testWidgets('shows the skeleton while loading', (tester) async {
    await tester.pumpWidget(harness(null));
    await tester.pump();
    expect(find.byType(MemberHomeSkeleton), findsOneWidget);
  });

  testWidgets('full-page error offers retry', (tester) async {
    await tester.pumpWidget(harness(null, error: Exception('boom')));
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('hides Continue Your Journey when nothing is resumable',
      (tester) async {
    useTallPhone(tester);
    await tester.pumpWidget(harness(payload()));
    await tester.pumpAndSettle();
    expect(find.text('Continue Learning'), findsNothing);
    expect(find.text('Continue Practice'), findsNothing);
    expect(find.text('No upcoming events'), findsOneWidget);
  });

  testWidgets('an in-progress event shows LIVE and Join Live',
      (tester) async {
    useTallPhone(tester);
    final now = DateTime.now();
    await tester.pumpWidget(harness(payload(
      event: eventFixture(
        startsAt: now.subtract(const Duration(minutes: 10)),
        endsAt: now.add(const Duration(minutes: 50)),
      ),
    )));
    await tester.pumpAndSettle();
    expect(find.text('Join Live'), findsOneWidget);
    expect(find.text('LIVE'), findsOneWidget);
  });

  testWidgets('an event past its end time never still reads as live',
      (tester) async {
    useTallPhone(tester);
    final now = DateTime.now();
    await tester.pumpWidget(harness(payload(
      event: eventFixture(
        startsAt: now.subtract(const Duration(hours: 3)),
        endsAt: now.subtract(const Duration(hours: 2)),
      ),
    )));
    await tester.pumpAndSettle();
    expect(find.text('Join Live'), findsNothing);
    expect(find.text('LIVE'), findsNothing);
  });

  testWidgets('indeterminate progress renders no progress bar',
      (tester) async {
    useTallPhone(tester);
    await tester.pumpWidget(harness(payload(practice: [practiceFixture])));
    await tester.pumpAndSettle();
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.text('4 day streak'), findsOneWidget);
  });

  testWidgets('French locale localizes the sections', (tester) async {
    useTallPhone(tester);
    await tester.pumpWidget(harness(
      payload(learning: [learningFixture]),
      locale: const Locale('fr'),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Continuez votre chemin'), findsOneWidget);
    expect(find.text("Continuer l'apprentissage"), findsOneWidget);
  });

  testWidgets('renders at large text scale without overflow',
      (tester) async {
    await tester.pumpWidget(harness(
      payload(learning: [learningFixture], featured: featuredFixture),
      textScale: 1.6,
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders right-to-left without overflow', (tester) async {
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.rtl,
      child: harness(payload(learning: [learningFixture], featured: featuredFixture)),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
