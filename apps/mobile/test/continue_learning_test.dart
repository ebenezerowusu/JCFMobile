import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:jcf_mobile/features/auth/auth_controller.dart';
import 'package:jcf_mobile/features/learning/continue_learning_screen.dart';
import 'package:jcf_mobile/features/learning/learning_controller.dart';
import 'package:jcf_mobile/features/learning/learning_models.dart';
import 'package:jcf_mobile/features/learning/learning_repository.dart';
import 'package:jcf_mobile/features/learning/learning_widgets.dart';
import 'package:jcf_mobile/l10n/app_localizations.dart';

// --------------------------------------------------------------------------
// fixtures
// --------------------------------------------------------------------------

Map<String, dynamic> accessJson({
  bool allowed = true,
  String reason = '',
  String? expiresAt,
}) =>
    {
      'allowed': allowed,
      'required_tier': 'general',
      'enrolment_required': false,
      'expires_at': expiresAt,
      'restriction_reason': reason,
    };

Map<String, dynamic> lessonJson({
  int lessonId = 1,
  String title = 'The Practice of Awareness',
  String type = 'video',
  String status = 'not_started',
  int progress = 0,
  String courseTitle = 'Foundations of Conscious Living',
  String moduleTitle = 'Beginning',
  int? durationSeconds = 1080,
  Map<String, dynamic>? access,
  Map<String, dynamic>? prerequisite,
  Map<String, dynamic>? download,
  Map<String, dynamic>? destination,
  String imageUrl = '',
}) =>
    {
      'lesson_id': lessonId,
      'course_id': 10,
      'course_title': courseTitle,
      'module_id': 5,
      'module_title': moduleTitle,
      'title': title,
      'type': type,
      'image_url': imageUrl,
      'course_category': 'awareness',
      'duration_seconds': durationSeconds,
      'progress_percentage': progress,
      'position_seconds': 0,
      'status': status,
      'prerequisite': prerequisite ??
          {
            'required': false,
            'satisfied': true,
            'prerequisite_lesson_id': null,
            'prerequisite_title': '',
            'reason': '',
          },
      'access': access ?? accessJson(),
      'download': download ??
          {'downloadable': false, 'state': 'unavailable',
           'progress_percentage': 0},
      'destination': destination ?? {'type': type, 'lesson_id': lessonId},
    };

Map<String, dynamic> resumeJson({
  int progress = 42,
  int? remainingSeconds = 1080,
  String status = 'in_progress',
  String type = 'video',
  Map<String, dynamic>? access,
  Map<String, dynamic>? download,
}) =>
    {
      ...lessonJson(
          progress: progress, status: status, type: type, access: access,
          download: download),
      'enrolment_id': 3,
      'course_image_url': '',
      'remaining_seconds': remainingSeconds,
      'last_accessed_at': DateTime.now().toIso8601String(),
    };

Map<String, dynamic> courseJson({
  int courseId = 10,
  String title = 'Foundations of Conscious Living',
  String status = 'in_progress',
  int progress = 42,
  int totalModules = 4,
  int totalLessons = 12,
  Map<String, dynamic>? access,
}) =>
    {
      'enrolment_id': 3,
      'course_id': courseId,
      'title': title,
      'description': '',
      'image_url': '',
      'category': 'awareness',
      'facilitator': 'Dr. Baffour Jan',
      'total_modules': totalModules,
      'completed_modules': 1,
      'total_lessons': totalLessons,
      'completed_lessons': 5,
      'progress_percentage': progress,
      'current_module_id': 5,
      'current_lesson_id': 1,
      'status': status,
      'access': access ?? accessJson(),
      'last_accessed_at': DateTime.now().toIso8601String(),
      'destination': {'type': 'course', 'course_id': courseId},
    };

Map<String, dynamic> recommendationJson({
  int courseId = 90,
  String title = 'Listening Deeply',
  String reason = 'Continue your learning path',
}) =>
    {
      'course_id': courseId,
      'title': title,
      'image_url': '',
      'category': 'communication',
      'facilitator': 'Ama Serwaa',
      'module_count': 3,
      'lesson_count': 9,
      'access_level': 'general',
      'recommendation_reason': reason,
      'destination': {'type': 'course', 'course_id': courseId},
    };

Map<String, dynamic> hubJson({
  Map<String, dynamic>? resume,
  List<Map<String, dynamic>>? courses,
  List<Map<String, dynamic>>? lessons,
  List<Map<String, dynamic>>? recommendations,
  String? courseCursor,
  String? lessonCursor,
  Map<String, dynamic>? summary,
}) =>
    {
      'resume_item': resume,
      'learning_summary': summary ??
          {
            'completed_lessons': 12,
            'completed_courses': 1,
            'current_streak_days': 4,
            'downloaded_items': 0,
            'total_learning_seconds': 7200,
          },
      'active_courses': {
        'results': courses ?? [courseJson()],
        'next_cursor': courseCursor,
        'has_more': courseCursor != null,
      },
      'up_next_lessons': {
        'results': lessons ?? [lessonJson()],
        'next_cursor': lessonCursor,
        'has_more': lessonCursor != null,
      },
      'recommendations': recommendations ?? const [],
      'fetched_at': DateTime.now().toIso8601String(),
    };

class FakeLearningRepository implements LearningRepository {
  FakeLearningRepository({
    this.pages = const [],
    this.failWith,
    this.cached_,
    this.hubDelay,
  });

  final List<Map<String, dynamic>> pages;
  final Object? failWith;
  final CachedLearningPayload? cached_;
  final Duration? hubDelay;

  final List<LearningFilter> filters = [];
  final List<String?> courseCursors = [];
  final List<String?> lessonCursors = [];
  int clearCacheCalls = 0;

  @override
  Future<ContinueLearningPayload> hub({
    LearningFilter filter = const LearningFilter(),
    String? courseCursor,
    String? lessonCursor,
    int limit = 20,
  }) async {
    filters.add(filter);
    courseCursors.add(courseCursor);
    lessonCursors.add(lessonCursor);
    if (hubDelay != null) await Future<void>.delayed(hubDelay!);
    if (failWith != null) throw failWith!;
    final index = filters.length - 1;
    final body = pages.isEmpty
        ? hubJson()
        : pages[index < pages.length ? index : pages.length - 1];
    return ContinueLearningPayload.fromJson(body);
  }

  @override
  Future<LessonSummary?> reportProgress(int lessonId,
          {required int percent, int? positionSeconds}) async =>
      null;

  @override
  Future<CachedLearningPayload?> cached() async => cached_;

  @override
  Future<void> clearCache() async => clearCacheCalls++;
}

Widget harness(
  FakeLearningRepository repository, {
  Locale locale = const Locale('en'),
  bool loggedIn = true,
  double textScale = 1.0,
  TextDirection direction = TextDirection.ltr,
}) =>
    ProviderScope(
      overrides: [
        learningRepositoryProvider.overrideWithValue(repository),
        isLoggedInProvider.overrideWith((ref) => loggedIn),
      ],
      child: MaterialApp.router(
        locale: locale,
        routerConfig: GoRouter(
          initialLocation: '/learning/continue',
          routes: [
            GoRoute(
                path: '/learning/continue',
                builder: (_, _) => const ContinueLearningScreen()),
            for (final path in ['/login', '/home', '/lessons', '/search',
                                '/practice', '/more'])
              GoRoute(path: path, builder: (_, _) => const Placeholder()),
            GoRoute(
                path: '/lessons/:id',
                builder: (_, _) => const Placeholder()),
            GoRoute(
                path: '/live/:id', builder: (_, _) => const Placeholder()),
          ],
        ),
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

/// Scrolls until [finder] is built and on screen.
///
/// The screen is a sliver list, so anything below the fold is not in the
/// element tree at all — asserting on it without scrolling tests nothing.
Future<void> scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(finder, 300,
      scrollable: find.byType(Scrollable).first);
  await tester.pumpAndSettle();
}

Future<void> settle(WidgetTester tester,
    [Duration step = const Duration(milliseconds: 50)]) async {
  for (var i = 0; i < 4; i++) {
    await tester.pump(step);
  }
}

void main() {
  // --- parsing ---------------------------------------------------------

  group('parsing', () {
    test('percentages are clamped on the way in', () {
      expect(clampPercent(-20), 0);
      expect(clampPercent(140), 100);
      expect(clampPercent(42), 42);
      expect(clampPercent(null), 0);
      expect(clampPercent('nonsense'), 0);
    });

    test('an unknown lesson type falls back to written', () {
      final lesson =
          LessonSummary.fromJson(lessonJson(type: 'hologram'));
      expect(lesson.type, LessonType.written);
    });

    test('an unknown status falls back to not started', () {
      final lesson =
          LessonSummary.fromJson(lessonJson(status: 'quantum'));
      expect(lesson.status, LessonStatus.notStarted);
    });

    test('an unknown download state reads as unavailable', () {
      final lesson = LessonSummary.fromJson(lessonJson(
          download: {'downloadable': true, 'state': 'teleporting'}));
      expect(lesson.download.state, DownloadState.unavailable);
    });

    test('a prerequisite only blocks when required and unsatisfied', () {
      LessonPrerequisite make(bool required, bool satisfied) =>
          LessonPrerequisite.fromJson(
              {'required': required, 'satisfied': satisfied});
      expect(make(true, false).blocks, isTrue);
      expect(make(true, true).blocks, isFalse);
      expect(make(false, false).blocks, isFalse);
    });

    test('the context line skips whichever part is missing', () {
      expect(
        LessonSummary.fromJson(lessonJson(moduleTitle: '')).contextLine,
        'Foundations of Conscious Living',
      );
      expect(
        LessonSummary.fromJson(
                lessonJson(courseTitle: '', moduleTitle: '')).contextLine,
        '',
      );
    });

    test('has_more is never trusted without a cursor to act on', () {
      final page = LearningPage.parse<LessonSummary>({
        'results': [lessonJson()],
        'next_cursor': null,
        'has_more': true,
      }, LessonSummary.fromJson);
      expect(page.hasMore, isFalse);
    });

    test('an expired access reports itself', () {
      final lesson = LessonSummary.fromJson(lessonJson(
          access: accessJson(allowed: false, reason: 'expired')));
      expect(lesson.access.isExpired, isTrue);
    });

    test('a payload with nothing in it is empty', () {
      final payload = ContinueLearningPayload.fromJson(hubJson(
          courses: [], lessons: [], recommendations: []));
      expect(payload.isEmpty, isTrue);
    });
  });

  // --- filters ---------------------------------------------------------

  group('LearningFilter', () {
    test('an empty filter sends nothing', () {
      expect(const LearningFilter().toParams(), isEmpty);
      expect(const LearningFilter().isEmpty, isTrue);
    });

    test('each group counts once', () {
      const filter = LearningFilter(
          status: 'in_progress', contentType: 'video', downloadedOnly: true);
      expect(filter.activeCount, 3);
      expect(filter.toParams(), {
        'status': 'in_progress',
        'content_type': 'video',
        'downloaded': 'true',
      });
    });

    test('filters with the same contents are equal', () {
      expect(const LearningFilter(status: 'completed'),
          const LearningFilter(status: 'completed'));
    });
  });

  // --- artwork ---------------------------------------------------------

  group('artwork', () {
    test('each known category picks its own art', () {
      expect(learningAsset('awareness'), contains('awareness_course'));
      expect(learningAsset('practice'), contains('mindful_practice_course'));
      expect(
          learningAsset('communication'), contains('communication_course'));
    });

    test('an unknown category falls back rather than breaking', () {
      expect(learningAsset('astrophysics'),
          contains('recommended_course'));
      expect(learningAsset('astrophysics'), endsWith('.webp'));
    });
  });

  // --- resume CTA ------------------------------------------------------

  group('the resume CTA', () {
    testWidgets('changes with the lesson state', (tester) async {
      late AppLocalizations t;
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(builder: (context) {
          t = AppLocalizations.of(context)!;
          return const SizedBox.shrink();
        }),
      ));

      String cta(Map<String, dynamic> json) =>
          resumeCtaLabel(t, LessonSummary.fromJson(json));

      expect(cta(lessonJson(status: 'not_started')), t.learnStartLesson);
      expect(cta(lessonJson(status: 'in_progress')), t.learnContinue);
      expect(cta(lessonJson(status: 'completed')), t.learnReviewLesson);
      expect(cta(lessonJson(type: 'live')), t.learnJoinLive);
      expect(
        cta(lessonJson(
            access: accessJson(allowed: false, reason: 'expired'))),
        t.learnViewAccess,
      );
      expect(
        cta(lessonJson(
            download: {'downloadable': true, 'state': 'failed'})),
        t.learnRetryDownload,
      );
    });
  });

  // --- screen ----------------------------------------------------------

  group('authentication', () {
    testWidgets('a guest is asked to sign in and nothing is fetched',
        (tester) async {
      final repository = FakeLearningRepository();
      await tester.pumpWidget(harness(repository, loggedIn: false));
      await tester.pumpAndSettle();
      expect(find.text('Sign In'), findsOneWidget);
      // Private progress must not be requested before authentication.
      expect(repository.filters, isEmpty);
    });

    testWidgets('a member gets the hub', (tester) async {
      await tester.pumpWidget(harness(FakeLearningRepository()));
      await tester.pumpAndSettle();
      expect(find.text('Continue Learning'), findsOneWidget);
    });
  });

  group('loading and failure', () {
    testWidgets('skeletons show before the first payload', (tester) async {
      await tester.pumpWidget(harness(FakeLearningRepository(
          hubDelay: const Duration(milliseconds: 400))));
      await tester.pump();
      expect(find.byType(LearningSkeleton), findsOneWidget);
      await settle(tester, const Duration(milliseconds: 200));
      expect(find.byType(LearningSkeleton), findsNothing);
    });

    testWidgets('a failed first load offers a retry', (tester) async {
      await tester.pumpWidget(harness(
          FakeLearningRepository(failWith: Exception('offline'))));
      await tester.pumpAndSettle();
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('a cached payload is labelled as a saved copy',
        (tester) async {
      final repository = FakeLearningRepository(
        hubDelay: const Duration(milliseconds: 400),
        cached_: CachedLearningPayload(
          ContinueLearningPayload.fromJson(hubJson(resume: resumeJson())),
          DateTime.now(),
        ),
      );
      await tester.pumpWidget(harness(repository));
      await settle(tester, const Duration(milliseconds: 10));
      expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
      await settle(tester, const Duration(milliseconds: 200));
      expect(find.byIcon(Icons.cloud_off_rounded), findsNothing);
    });
  });

  group('the resume hero', () {
    testWidgets('shows the lesson, progress and remaining time',
        (tester) async {
      await tester.pumpWidget(harness(FakeLearningRepository(
          pages: [hubJson(resume: resumeJson())])));
      await tester.pumpAndSettle();
      expect(find.byType(ResumeLearningHero), findsOneWidget);
      expect(find.text('RESUME WHERE YOU LEFT OFF'), findsOneWidget);
      expect(find.text('42% complete'), findsOneWidget);
      expect(find.text('18 min left'), findsOneWidget);
      expect(find.text('Continue'), findsWidgets);
    });

    testWidgets('is replaced by a prompt when there is nothing to resume',
        (tester) async {
      await tester.pumpWidget(
          harness(FakeLearningRepository(pages: [hubJson(resume: null)])));
      await tester.pumpAndSettle();
      expect(find.byType(ResumeLearningHero), findsNothing);
      expect(find.text('Nothing to resume yet'), findsOneWidget);
      expect(find.text('Start a Course'), findsOneWidget);
    });
  });

  group('the summary', () {
    testWidgets('reports the server totals', (tester) async {
      await tester.pumpWidget(harness(FakeLearningRepository()));
      await tester.pumpAndSettle();
      expect(find.text('12'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('Lessons completed'), findsOneWidget);
    });

    testWidgets('a zero streak is shown plainly', (tester) async {
      await tester.pumpWidget(harness(FakeLearningRepository(pages: [
        hubJson(summary: {
          'completed_lessons': 0,
          'completed_courses': 0,
          'current_streak_days': 0,
          'downloaded_items': 0,
          'total_learning_seconds': 0,
        }),
      ])));
      await tester.pumpAndSettle();
      expect(find.text('Day streak'), findsOneWidget);
    });
  });

  group('active courses', () {
    testWidgets('a course card shows counts and progress', (tester) async {
      await tester.pumpWidget(harness(FakeLearningRepository()));
      await tester.pumpAndSettle();
      expect(find.text('Foundations of Conscious Living'), findsWidgets);
      expect(find.text('42%'), findsOneWidget);
      expect(find.text('4 modules'), findsOneWidget);
    });

    testWidgets('an expired course is marked and cannot be opened',
        (tester) async {
      await tester.pumpWidget(harness(FakeLearningRepository(pages: [
        hubJson(courses: [
          courseJson(
              status: 'expired',
              access: accessJson(allowed: false, reason: 'expired')),
        ]),
      ])));
      await tester.pumpAndSettle();
      expect(find.text('Access expired'), findsWidgets);

      await tester.tap(find.byType(ActiveCourseCard));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('a completed course offers a review', (tester) async {
      await tester.pumpWidget(harness(FakeLearningRepository(pages: [
        hubJson(courses: [courseJson(status: 'completed', progress: 100)]),
      ])));
      await tester.pumpAndSettle();
      expect(find.text('Review Course'), findsOneWidget);
      expect(find.text('Completed'), findsWidgets);
    });

    testWidgets('no active courses shows a prompt, not a blank rail',
        (tester) async {
      await tester.pumpWidget(
          harness(FakeLearningRepository(pages: [hubJson(courses: [])])));
      await tester.pumpAndSettle();
      expect(find.text('You have no active courses'), findsOneWidget);
    });
  });

  group('up next', () {
    testWidgets('a lesson row shows type and duration', (tester) async {
      await tester.pumpWidget(harness(FakeLearningRepository()));
      await tester.pumpAndSettle();
      await scrollTo(tester, find.byType(UpNextLessonTile));
      expect(find.byType(UpNextLessonTile), findsOneWidget);
      expect(find.text('Video'), findsOneWidget);
      expect(find.text('18 min'), findsOneWidget);
    });

    testWidgets('a completed lesson carries a check and the word',
        (tester) async {
      await tester.pumpWidget(harness(FakeLearningRepository(pages: [
        hubJson(lessons: [lessonJson(status: 'completed', progress: 100)]),
      ])));
      await tester.pumpAndSettle();
      await scrollTo(tester, find.byType(UpNextLessonTile));
      // Never colour alone: the icon and the word both appear.
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
      expect(find.text('Completed'), findsWidgets);
    });

    testWidgets('a locked lesson opens its prerequisite instead',
        (tester) async {
      await tester.pumpWidget(harness(FakeLearningRepository(pages: [
        hubJson(lessons: [
          lessonJson(status: 'locked', prerequisite: {
            'required': true,
            'satisfied': false,
            'prerequisite_lesson_id': 7,
            'prerequisite_title': 'Opening the Practice',
            'reason': 'incomplete_prerequisite',
          }),
        ]),
      ])));
      await tester.pumpAndSettle();
      await scrollTo(tester, find.byType(UpNextLessonTile));
      expect(find.text('Locked'), findsOneWidget);

      await tester.tap(find.byType(UpNextLessonTile));
      await tester.pumpAndSettle();
      expect(find.text('Finish this first'), findsOneWidget);
      expect(find.textContaining('Opening the Practice'), findsWidgets);
    });

    testWidgets('a downloaded lesson says it is available offline',
        (tester) async {
      await tester.pumpWidget(harness(FakeLearningRepository(pages: [
        hubJson(lessons: [
          lessonJson(download: {
            'downloadable': true,
            'state': 'downloaded',
            'progress_percentage': 100,
          }),
        ]),
      ])));
      await tester.pumpAndSettle();
      await scrollTo(tester, find.byType(UpNextLessonTile));
      expect(find.text('Available offline'), findsOneWidget);
    });

    testWidgets('a failed download says so', (tester) async {
      await tester.pumpWidget(harness(FakeLearningRepository(pages: [
        hubJson(lessons: [
          lessonJson(download: {
            'downloadable': true,
            'state': 'failed',
            'failure_code': 'network',
          }),
        ]),
      ])));
      await tester.pumpAndSettle();
      await scrollTo(tester, find.byType(UpNextLessonTile));
      expect(find.text('Download failed'), findsOneWidget);
    });

    testWidgets('an empty up-next says you are caught up', (tester) async {
      await tester.pumpWidget(
          harness(FakeLearningRepository(pages: [hubJson(lessons: [])])));
      await tester.pumpAndSettle();
      await scrollTo(tester, find.text("You're all caught up"));
      expect(find.text("You're all caught up"), findsOneWidget);
    });
  });

  group('recommendations', () {
    testWidgets('are shown with their reason', (tester) async {
      await tester.pumpWidget(harness(FakeLearningRepository(pages: [
        hubJson(recommendations: [recommendationJson()]),
      ])));
      await tester.pumpAndSettle();
      await scrollTo(tester, find.byType(RecommendationCard));
      expect(find.byType(RecommendationCard), findsOneWidget);
      expect(find.text('Continue your learning path'), findsOneWidget);
    });

    testWidgets('the section is hidden entirely when there are none',
        (tester) async {
      await tester.pumpWidget(harness(FakeLearningRepository()));
      await tester.pumpAndSettle();
      expect(find.text('Recommended for You'), findsNothing);
    });
  });

  group('pagination', () {
    testWidgets('a lesson page is appended without duplicates',
        (tester) async {
      final repository = FakeLearningRepository(pages: [
        hubJson(lessons: [lessonJson(lessonId: 1, title: 'First')],
            lessonCursor: 'page-2'),
        hubJson(lessons: [
          lessonJson(lessonId: 1, title: 'First'),
          lessonJson(lessonId: 2, title: 'Second'),
        ]),
      ]);
      await tester.pumpWidget(harness(repository));
      await settle(tester);

      final container = ProviderScope.containerOf(
          tester.element(find.byType(ContinueLearningScreen)));
      await container.read(learningHubProvider.notifier).loadMoreLessons();
      await settle(tester);

      final lessons = container.read(learningHubProvider).upNextLessons;
      expect(lessons.map((l) => l.lessonId).toList(), [1, 2]);
    });

    testWidgets('a filter change drops the cursor', (tester) async {
      final repository = FakeLearningRepository(pages: [
        hubJson(lessonCursor: 'page-2'),
        hubJson(),
      ]);
      await tester.pumpWidget(harness(repository));
      await settle(tester);

      final container = ProviderScope.containerOf(
          tester.element(find.byType(ContinueLearningScreen)));
      container
          .read(learningHubProvider.notifier)
          .applyFilter(const LearningFilter(contentType: 'audio'));
      await settle(tester);

      expect(repository.filters.last.contentType, 'audio');
      // The refetch after a filter change must not carry the old cursor.
      expect(repository.lessonCursors.last, isNull);
    });
  });

  group('localization and layout', () {
    testWidgets('the screen speaks French', (tester) async {
      await tester.pumpWidget(harness(FakeLearningRepository(),
          locale: const Locale('fr')));
      await tester.pumpAndSettle();
      expect(find.text("Poursuivre l'apprentissage"), findsOneWidget);
      expect(find.text('Vos cours en cours'), findsOneWidget);
    });

    testWidgets('German renders without overflow at large text',
        (tester) async {
      await tester.pumpWidget(harness(
        FakeLearningRepository(pages: [hubJson(resume: resumeJson())]),
        locale: const Locale('de'),
        textScale: 1.6,
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders right-to-left without overflow', (tester) async {
      await tester.pumpWidget(harness(
        FakeLearningRepository(pages: [hubJson(resume: resumeJson())]),
        direction: TextDirection.rtl,
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
