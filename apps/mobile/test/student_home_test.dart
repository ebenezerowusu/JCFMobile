import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jcf_ui/jcf_ui.dart';

import 'package:jcf_mobile/features/home/student_home_repository.dart';
import 'package:jcf_mobile/features/home/student_home_screen.dart';
import 'package:jcf_mobile/features/home/student_home_widgets.dart';
import 'package:jcf_mobile/l10n/app_localizations.dart';

StudentHomePayload payload({
  String preferredName = 'Kwame',
  String firstName = 'Kwame',
  String studentStatus = 'active',
  DateTime? accessExpiresAt,
  ProgramEnrolment? primary,
  List<ProgramEnrolment> active = const [],
  CourseProgress? course,
  List<PracticeAssignment> practices = const [],
  LiveClass? liveClass,
  ProgressSummary? progress,
  StudentMilestone? milestone,
  StudentMentor? mentor,
  List<StudentUpdate> updates = const [],
  List<StudentQuickAction> quickActions = const [],
  int unread = 0,
}) =>
    StudentHomePayload(
      summary: StudentSummary(
        preferredName: preferredName,
        firstName: firstName,
        studentStatus: studentStatus,
        accessExpiresAt: accessExpiresAt,
      ),
      activeEnrolments: active,
      assignedPractices: practices,
      progress: progress ??
          const ProgressSummary(
            programPercentage: 40,
            completedLessons: 4,
            totalLessons: 10,
            completedPractices: 3,
            requiredPractices: 8,
            currentStreak: 5,
          ),
      updates: updates,
      quickActions: quickActions,
      unreadNotificationCount: unread,
      fetchedAt: DateTime(2026, 9, 29, 12),
      primaryEnrolment: primary,
      continueCourse: course,
      nextLiveClass: liveClass,
      nextMilestone: milestone,
      mentor: mentor,
    );

ProgramEnrolment enrolment({
  String status = 'active',
  bool isPrimary = true,
  int percent = 40,
  String title = 'InnerSpace Foundations',
}) =>
    ProgramEnrolment(
      enrolmentId: 1,
      programId: 'innerspace-foundations',
      programTitle: title,
      cohort: 'Cohort 3',
      intake: '2026',
      currentModuleTitle: 'Module 2 · The Observing Mind',
      progressPercentage: percent,
      status: status,
      isPrimary: isPrimary,
      destination: StudentDestination.program,
    );

CourseProgress course({bool started = true, bool accessGranted = true}) =>
    CourseProgress(
      courseTitle: 'Foundations Curriculum',
      moduleTitle: 'Module 2',
      lessonTitle: 'The Observing Mind',
      lessonType: 'video',
      progressPercentage: started ? 40 : 0,
      started: started,
      accessGranted: accessGranted,
      destination: StudentDestination.lesson,
      lessonId: 'the-observing-mind',
      remainingSeconds: 1800,
    );

PracticeAssignment assignment({
  String status = 'not_started',
  DateTime? dueAt,
  String title = 'Morning Stillness',
}) =>
    PracticeAssignment(
      assignmentId: 1,
      practiceId: 'morning-stillness',
      title: title,
      practiceType: 'morning',
      status: status,
      required: true,
      destination: StudentDestination.practice,
      durationSeconds: 900,
      dueAt: dueAt,
    );

LiveClass liveClass({
  required DateTime startsAt,
  DateTime? endsAt,
  bool joinAllowed = false,
  String serverStatus = 'upcoming',
  String replayUrl = '',
}) =>
    LiveClass(
      sessionId: 7,
      title: 'Module 3 Live',
      moduleTitle: 'Module 3',
      facilitator: 'Dr. Baffour Jan',
      startsAt: startsAt,
      endsAt: endsAt,
      serverStatus: serverStatus,
      joinAllowed: joinAllowed,
      reminderEnabled: false,
      destination: StudentDestination.liveClass,
      replayUrl: replayUrl,
    );

void useTallPhone(WidgetTester tester, {double width = 390}) {
  tester.view.physicalSize = Size(width * 3, 5200 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Widget harness(StudentHomePayload? data,
    {Object? error, Locale locale = const Locale('en'), double textScale = 1}) {
  final router = GoRouter(routes: [
    GoRoute(
      path: '/',
      builder: (_, _) => const Scaffold(
        backgroundColor: JcfColors.skySurface,
        body: SafeArea(child: StudentHomeBody()),
      ),
    ),
    for (final path in [
      '/lessons', '/practice', '/learning', '/activities', '/announcements',
      '/programs', '/more', '/search', '/profile', '/notifications',
      '/appointments',
    ])
      GoRoute(path: path, builder: (_, _) => const Placeholder()),
  ]);

  return ProviderScope(
    overrides: [
      studentHomeProvider.overrideWith((ref) => error != null
          ? Future<StudentHomePayload>.error(error)
          : data == null
              ? Completer<StudentHomePayload>().future
              : Future.value(data)),
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
  testWidgets('renders every populated section', (tester) async {
    useTallPhone(tester);
    await tester.pumpWidget(harness(payload(
      primary: enrolment(),
      active: [enrolment()],
      course: course(),
      practices: [assignment()],
      liveClass: liveClass(
          startsAt: DateTime.now().add(const Duration(days: 2))),
      milestone: const StudentMilestone(
        id: 1,
        title: 'Complete Level 1',
        description: 'Finish the first six lessons.',
        currentProgress: 40,
        requiredProgress: 50,
        status: 'in_progress',
        destination: StudentDestination.milestone,
      ),
      mentor: const StudentMentor(
        id: 1,
        displayName: 'Kofi Mensah',
        role: 'Programme Guide',
        availability: 'Weekdays 9-5 GMT',
        messagingEnabled: true,
        bookingEnabled: false,
        destination: StudentDestination.mentor,
      ),
      updates: [
        StudentUpdate(
          id: 'assignment-1',
          type: 'assignment',
          title: 'Evening Reflection due',
          summary: 'Complete before Friday.',
          priority: 'urgent',
          read: false,
          destination: StudentDestination.practice,
          dueAt: DateTime.now().add(const Duration(days: 1)),
        ),
      ],
      quickActions: const [
        StudentQuickAction(id: 'courses', sortOrder: 1),
        StudentQuickAction(id: 'schedule', sortOrder: 2),
        StudentQuickAction(id: 'assignments', sortOrder: 3),
      ],
      unread: 2,
    )));
    await tester.pumpAndSettle();

    expect(find.text('JCF Student'), findsOneWidget);
    expect(find.text('MY PROGRAM'), findsOneWidget);
    expect(find.text('InnerSpace Foundations'), findsOneWidget);
    expect(find.text('Cohort 3  ·  2026'), findsOneWidget);
    expect(find.text("Today's Learning"), findsOneWidget);
    expect(find.text('The Observing Mind'), findsOneWidget);
    expect(find.text('Morning Stillness'), findsOneWidget);
    expect(find.text('Module 3 Live'), findsOneWidget);
    expect(find.text('4 of 10 lessons'), findsOneWidget);
    expect(find.text('Complete Level 1'), findsOneWidget);
    expect(find.text('Kofi Mensah'), findsOneWidget);
    expect(find.text('Message Mentor'), findsOneWidget);
    expect(find.text('Urgent'), findsOneWidget);
    expect(find.text('My Courses'), findsOneWidget);
    // Authenticated screens never offer public signup.
    expect(find.textContaining('Sign Up'), findsNothing);
  });

  testWidgets('greeting falls back when no name is available',
      (tester) async {
    useTallPhone(tester);
    await tester.pumpWidget(harness(
        payload(preferredName: '', firstName: '', primary: enrolment())));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsWidgets);
  });

  testWidgets('shows the skeleton while loading', (tester) async {
    await tester.pumpWidget(harness(null));
    await tester.pump();
    expect(find.byType(StudentHomeSkeleton), findsOneWidget);
  });

  testWidgets('full-page error offers retry', (tester) async {
    await tester.pumpWidget(harness(null, error: Exception('boom')));
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('a paused programme explains itself instead of erroring',
      (tester) async {
    useTallPhone(tester);
    await tester.pumpWidget(harness(payload(
      primary: enrolment(status: 'paused'),
      studentStatus: 'paused',
    )));
    await tester.pumpAndSettle();
    expect(find.text('This programme is paused'), findsOneWidget);
    expect(find.byType(StudentProgramHero), findsOneWidget);
  });

  testWidgets('expired access is explained', (tester) async {
    useTallPhone(tester);
    await tester.pumpWidget(harness(payload(
      primary: enrolment(status: 'expired'),
      accessExpiresAt: DateTime.now().subtract(const Duration(days: 1)),
    )));
    await tester.pumpAndSettle();
    expect(find.text('Your access has expired'), findsOneWidget);
  });

  testWidgets('no enrolment shows the support state', (tester) async {
    useTallPhone(tester);
    await tester.pumpWidget(harness(payload()));
    await tester.pumpAndSettle();
    expect(find.text('You are not enrolled in a programme yet.'),
        findsOneWidget);
    expect(find.byType(StudentProgramHero), findsNothing);
  });

  testWidgets('one enrolment does not offer View All Programs',
      (tester) async {
    useTallPhone(tester);
    await tester.pumpWidget(harness(
        payload(primary: enrolment(), active: [enrolment()])));
    await tester.pumpAndSettle();
    expect(find.text('View All Programs'), findsNothing);
  });

  testWidgets('several enrolments offer View All Programs', (tester) async {
    useTallPhone(tester);
    await tester.pumpWidget(harness(payload(
      primary: enrolment(),
      active: [enrolment(), enrolment(title: 'Second Programme')],
    )));
    await tester.pumpAndSettle();
    expect(find.text('View All Programs'), findsOneWidget);
  });

  testWidgets('an unstarted course offers Start Lesson', (tester) async {
    useTallPhone(tester);
    await tester.pumpWidget(harness(
        payload(primary: enrolment(), course: course(started: false))));
    await tester.pumpAndSettle();
    expect(find.text('Start Lesson'), findsOneWidget);
  });

  testWidgets('a started course offers Continue Lesson', (tester) async {
    useTallPhone(tester);
    await tester.pumpWidget(harness(
        payload(primary: enrolment(), course: course())));
    await tester.pumpAndSettle();
    expect(find.text('Continue Lesson'), findsOneWidget);
  });

  testWidgets('an overdue assignment is labelled and gets Complete Now',
      (tester) async {
    useTallPhone(tester);
    await tester.pumpWidget(harness(payload(
      primary: enrolment(),
      practices: [
        assignment(
            status: 'overdue',
            dueAt: DateTime.now().subtract(const Duration(days: 2))),
      ],
    )));
    await tester.pumpAndSettle();
    expect(find.text('Overdue'), findsOneWidget);
    expect(find.text('Complete Now'), findsOneWidget);
  });

  testWidgets('no assignment and no course shows the caught-up state',
      (tester) async {
    useTallPhone(tester);
    await tester.pumpWidget(harness(payload(primary: enrolment())));
    await tester.pumpAndSettle();
    // The section is hidden entirely when there is nothing to do.
    expect(find.text("Today's Learning"), findsNothing);
  });

  testWidgets('a class in progress is live and joinable', (tester) async {
    useTallPhone(tester);
    final now = DateTime.now();
    await tester.pumpWidget(harness(payload(
      primary: enrolment(),
      liveClass: liveClass(
        startsAt: now.subtract(const Duration(minutes: 10)),
        endsAt: now.add(const Duration(minutes: 50)),
        joinAllowed: true,
        serverStatus: 'live',
      ),
    )));
    await tester.pumpAndSettle();
    expect(find.text('LIVE'), findsOneWidget);
    expect(find.text('Join Class'), findsOneWidget);
  });

  testWidgets('an upcoming class does not offer Join', (tester) async {
    useTallPhone(tester);
    await tester.pumpWidget(harness(payload(
      primary: enrolment(),
      liveClass: liveClass(
          startsAt: DateTime.now().add(const Duration(days: 1))),
    )));
    await tester.pumpAndSettle();
    expect(find.text('Join Class'), findsNothing);
    expect(find.text('UPCOMING'), findsOneWidget);
  });

  testWidgets('an ended class never still reads as live', (tester) async {
    useTallPhone(tester);
    final now = DateTime.now();
    await tester.pumpWidget(harness(payload(
      primary: enrolment(),
      // The cached payload still claims "live" — the app must recompute.
      liveClass: liveClass(
        startsAt: now.subtract(const Duration(hours: 3)),
        endsAt: now.subtract(const Duration(hours: 2)),
        joinAllowed: true,
        serverStatus: 'live',
      ),
    )));
    await tester.pumpAndSettle();
    expect(find.text('LIVE'), findsNothing);
    expect(find.text('Join Class'), findsNothing);
    expect(find.text('MISSED'), findsOneWidget);
  });

  testWidgets('an ended class with a replay offers Watch Replay',
      (tester) async {
    useTallPhone(tester);
    final now = DateTime.now();
    await tester.pumpWidget(harness(payload(
      primary: enrolment(),
      liveClass: liveClass(
        startsAt: now.subtract(const Duration(hours: 3)),
        endsAt: now.subtract(const Duration(hours: 2)),
        replayUrl: 'https://example.com/replay',
      ),
    )));
    await tester.pumpAndSettle();
    expect(find.text('Watch Replay'), findsOneWidget);
  });

  testWidgets('a cancelled class shows View Update', (tester) async {
    useTallPhone(tester);
    await tester.pumpWidget(harness(payload(
      primary: enrolment(),
      liveClass: liveClass(
        startsAt: DateTime.now().add(const Duration(days: 1)),
        serverStatus: 'cancelled',
      ),
    )));
    await tester.pumpAndSettle();
    expect(find.text('View Update'), findsOneWidget);
    expect(find.text('CANCELLED'), findsOneWidget);
  });

  testWidgets('no mentor shows programme support, not a fake mentor',
      (tester) async {
    useTallPhone(tester);
    await tester.pumpWidget(harness(payload(primary: enrolment())));
    await tester.pumpAndSettle();
    expect(find.textContaining('No mentor assigned yet'), findsOneWidget);
    expect(find.text('Message Mentor'), findsNothing);
  });

  testWidgets('messaging is hidden when the programme disables it',
      (tester) async {
    useTallPhone(tester);
    await tester.pumpWidget(harness(payload(
      primary: enrolment(),
      mentor: const StudentMentor(
        id: 1,
        displayName: 'Kofi Mensah',
        role: 'Programme Guide',
        availability: '',
        messagingEnabled: false,
        bookingEnabled: false,
        destination: StudentDestination.mentor,
      ),
    )));
    await tester.pumpAndSettle();
    expect(find.text('Kofi Mensah'), findsOneWidget);
    expect(find.text('Message Mentor'), findsNothing);
    expect(find.text('View Mentor'), findsOneWidget);
  });

  testWidgets('milestone states render their own badge', (tester) async {
    useTallPhone(tester);
    await tester.pumpWidget(harness(payload(
      primary: enrolment(),
      milestone: const StudentMilestone(
        id: 1,
        title: 'Complete Level 1',
        description: '',
        currentProgress: 100,
        requiredProgress: 100,
        status: 'achieved',
        destination: StudentDestination.milestone,
      ),
    )));
    await tester.pumpAndSettle();
    expect(find.text('ACHIEVED'), findsOneWidget);
  });

  testWidgets('progress percentages are clamped for display',
      (tester) async {
    useTallPhone(tester);
    await tester.pumpWidget(harness(payload(
      primary: enrolment(),
      progress: const ProgressSummary(
        // A bad server value must not paint an over-full ring.
        programPercentage: 140,
        completedLessons: 12,
        totalLessons: 10,
        completedPractices: 8,
        requiredPractices: 8,
        currentStreak: 3,
      ),
    )));
    await tester.pumpAndSettle();
    expect(find.text('100%'), findsOneWidget);
    expect(find.text('140%'), findsNothing);
  });

  testWidgets('French locale localizes the sections', (tester) async {
    useTallPhone(tester);
    await tester.pumpWidget(harness(
      payload(primary: enrolment(), course: course()),
      locale: const Locale('fr'),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Apprentissage du jour'), findsOneWidget);
    expect(find.text('Continuer le programme'), findsOneWidget);
  });

  testWidgets('renders at large text scale without overflow',
      (tester) async {
    useTallPhone(tester);
    await tester.pumpWidget(harness(
      payload(primary: enrolment(), course: course(),
          practices: [assignment()]),
      textScale: 1.6,
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders right-to-left without overflow', (tester) async {
    useTallPhone(tester);
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.rtl,
      child: harness(payload(
          primary: enrolment(), course: course(),
          practices: [assignment()])),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
