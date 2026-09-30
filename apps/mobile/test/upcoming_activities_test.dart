import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:jcf_mobile/features/auth/auth_controller.dart';

import 'package:jcf_mobile/features/activities/activities_repository.dart';
import 'package:jcf_mobile/features/activities/activities_screen.dart';
import 'package:jcf_mobile/features/activities/activity_models.dart';
import 'package:jcf_mobile/features/activities/activity_widgets.dart';
import 'package:jcf_mobile/l10n/app_localizations.dart';

// --------------------------------------------------------------------------
// fixtures
// --------------------------------------------------------------------------

Map<String, dynamic> activityJson({
  int id = 1,
  String title = 'Lakeside Guided Meditation',
  String kind = 'practice',
  String activityType = 'meditation',
  String format = 'in_person',
  DateTime? startsAt,
  int durationMinutes = 60,
  bool allDay = false,
  bool cancelled = false,
  String rescheduledNote = '',
  bool isLiveNow = false,
  bool startingSoon = false,
  bool reminderSet = false,
  bool saved = false,
  Map<String, dynamic>? access,
  Map<String, dynamic>? registration,
  Map<String, dynamic>? fee,
  Map<String, dynamic>? destination,
  Map<String, dynamic>? facilitator,
  String locationLine = 'Lakeside Grounds, Akosombo',
  String featuredBlurb = '',
}) {
  final start = startsAt ?? DateTime.now().add(const Duration(days: 1));
  return {
    'id': id,
    'kind': kind,
    'activity_type': activityType,
    'activity_type_label': 'Guided meditation',
    'title': title,
    'summary': 'A slow sitting by the water.',
    'starts_at': start.toIso8601String(),
    'ends_at':
        start.add(Duration(minutes: durationMinutes)).toIso8601String(),
    'all_day': allDay,
    'duration_minutes': durationMinutes,
    'format': format,
    'format_label': 'In person',
    'location_line': locationLine,
    'language': 'English',
    'image_url': '',
    'image_key': 'guided_meditation',
    'access': access ??
        {
          'allowed': true,
          'required_audience': 'public',
          'sign_in_required': false,
          'reason': '',
        },
    'registration': registration ??
        {
          'required': false,
          'state': 'not_required',
          'capacity': null,
          'seats_left': null,
          'opens_at': null,
          'closes_at': null,
          'waitlist_enabled': false,
          'external_url': '',
          'my_status': null,
        },
    'fee': fee ??
        {'free': true, 'amount': null, 'currency': '', 'display': ''},
    'destination':
        destination ?? {'type': 'activity', 'event_id': id},
    'facilitator': facilitator,
    'reminder_set': reminderSet,
    'saved': saved,
    'cancelled': cancelled,
    'rescheduled_note': rescheduledNote,
    'is_live_now': isLiveNow,
    'starting_soon': startingSoon,
    if (featuredBlurb.isNotEmpty) 'featured_blurb': featuredBlurb,
  };
}

Map<String, dynamic> pageJson({
  List<Map<String, dynamic>>? results,
  Map<String, dynamic>? featured,
  String? nextCursor,
}) =>
    {
      'server_time': DateTime.now().toIso8601String(),
      'timezone': 'Africa/Accra',
      'applied_filter': 'all',
      'results': results ?? [activityJson()],
      'next_cursor': nextCursor,
      'featured_activity': featured,
      'available_filters': {
        'types': [
          {'value': 'meditation', 'label': 'Guided meditation', 'count': 3},
          {'value': 'workshop', 'label': 'Workshop', 'count': 1},
        ],
        'languages': [
          {'value': 'English', 'label': 'English', 'count': 4},
        ],
        'formats': [
          {'value': 'in_person', 'label': 'In person', 'count': 4},
        ],
      },
    };

/// A repository that answers from memory and records what it was asked.
class FakeActivitiesRepository implements ActivitiesRepository {
  FakeActivitiesRepository({
    this.pages = const [],
    this.calendarDays = const [],
    this.failWith,
    this.cached,
    this.browseDelay,
  });

  /// One entry per call, in order; the last is reused once exhausted.
  final List<Map<String, dynamic>> pages;
  final List<CalendarDay> calendarDays;
  final Object? failWith;
  final CachedActivityPage? cached;

  /// Holds each page back, so a test can look at the screen while the
  /// first request is still in flight.
  final Duration? browseDelay;

  final List<ActivityQuery> queries = [];
  final List<String?> cursors = [];
  final List<int> remindedIds = [];
  final List<int> savedIds = [];
  int registerCalls = 0;
  bool lastRegisterWasCancel = false;

  @override
  Future<ActivityPage> browse({
    ActivityQuery query = const ActivityQuery(),
    String? cursor,
    int limit = 20,
  }) async {
    queries.add(query);
    cursors.add(cursor);
    if (browseDelay != null) await Future<void>.delayed(browseDelay!);
    if (failWith != null) throw failWith!;
    final index = queries.length - 1;
    final body = pages.isEmpty
        ? pageJson()
        : pages[index < pages.length ? index : pages.length - 1];
    return ActivityPage.fromJson(body);
  }

  @override
  Future<List<CalendarDay>> calendar({
    required DateTime month,
    ActivityQuery query = const ActivityQuery(),
  }) async =>
      calendarDays;

  @override
  Future<bool> toggleReminder({int? activityId, String? programSlug}) async {
    if (activityId != null) remindedIds.add(activityId);
    return true;
  }

  @override
  Future<bool> toggleSave(int activityId) async {
    savedIds.add(activityId);
    return true;
  }

  @override
  Future<ActivityRegistrationInfo> register(int activityId,
      {bool cancel = false}) async {
    registerCalls++;
    lastRegisterWasCancel = cancel;
    return ActivityRegistrationInfo.fromJson({
      'required': true,
      'state': cancel ? 'open' : 'open',
      'my_status': cancel ? null : 'registered',
      'seats_left': cancel ? 5 : 4,
    });
  }

  @override
  Future<CachedActivityPage?> cachedFirstPage() async => cached;
}

Widget harness(
  FakeActivitiesRepository repository, {
  Locale locale = const Locale('en'),
  bool loggedIn = true,
}) =>
    ProviderScope(
      overrides: [
        activitiesRepositoryProvider.overrideWithValue(repository),
        isLoggedInProvider.overrideWith((ref) => loggedIn),
      ],
      child: MaterialApp.router(
        locale: locale,
        routerConfig: GoRouter(
          initialLocation: '/activities',
          routes: [
            GoRoute(
                path: '/activities',
                builder: (_, _) => const ActivitiesScreen()),
            for (final path in ['/login', '/home'])
              GoRoute(path: path, builder: (_, _) => const Placeholder()),
            GoRoute(
                path: '/live/:eventId',
                builder: (_, _) => const Placeholder()),
          ],
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

/// Runs the microtask that kicks off the first load, plus any delay, then
/// lets the tree rebuild — without pumpAndSettle, which never returns while
/// a "loading more" spinner is turning.
Future<void> settle(WidgetTester tester,
    [Duration step = const Duration(milliseconds: 50)]) async {
  for (var i = 0; i < 4; i++) {
    await tester.pump(step);
  }
}

void main() {
  // --- query ------------------------------------------------------------

  group('ActivityQuery', () {
    test('the default query sends nothing', () {
      expect(const ActivityQuery().toParams(), isEmpty);
    });

    test('the All chip is never sent as a filter', () {
      expect(
        const ActivityQuery(primary: PrimaryFilter.all).toParams(),
        isNot(contains('filter')),
      );
    });

    test('in person is sent in the wire spelling', () {
      expect(
        const ActivityQuery(primary: PrimaryFilter.inPerson)
            .toParams()['filter'],
        'in_person',
      );
    });

    test('dates are sent as plain local days, not timestamps', () {
      final params = ActivityQuery(
        from: DateTime(2026, 3, 7, 23, 30),
        to: DateTime(2026, 3, 7, 23, 30),
      ).toParams();
      expect(params['from'], '2026-03-07');
      expect(params['to'], '2026-03-07');
    });

    test('a blank search is not sent', () {
      expect(const ActivityQuery(search: '   ').toParams(),
          isNot(contains('q')));
    });

    test('advancedCount counts each group once', () {
      const query = ActivityQuery(
        types: {'workshop', 'retreat'},
        languages: {'English'},
        fee: FeeFilter.free,
        openToMeOnly: true,
      );
      expect(query.advancedCount, 5);
    });

    test('the primary chip and the search do not count as advanced', () {
      const query = ActivityQuery(
          primary: PrimaryFilter.live, search: 'stillness');
      expect(query.advancedCount, 0);
      expect(query.hasAnyFilter, isTrue);
    });

    test('clearedAdvanced keeps the chip and the search', () {
      const query = ActivityQuery(
        primary: PrimaryFilter.live,
        search: 'stillness',
        types: {'workshop'},
        fee: FeeFilter.paid,
      );
      final cleared = query.clearedAdvanced();
      expect(cleared.primary, PrimaryFilter.live);
      expect(cleared.search, 'stillness');
      expect(cleared.advancedCount, 0);
    });

    test('queries with the same contents are equal', () {
      expect(
        const ActivityQuery(types: {'a', 'b'}),
        const ActivityQuery(types: {'b', 'a'}),
      );
    });
  });

  // --- parsing ----------------------------------------------------------

  group('Activity parsing', () {
    test('hybrid answers to both online and in person', () {
      final activity =
          Activity.fromJson(activityJson(format: 'hybrid'));
      expect(activity.isOnline, isTrue);
      expect(activity.isInPerson, isTrue);
    });

    test('an unknown format falls back to in person', () {
      final activity =
          Activity.fromJson(activityJson(format: 'teleport'));
      expect(activity.format, ActivityFormat.inPerson);
    });

    test('an unknown registration state shows no button', () {
      final activity = Activity.fromJson(activityJson(registration: {
        'required': true,
        'state': 'quantum',
      }));
      expect(activity.registration.state, RegistrationState.notRequired);
    });

    test('localDay drops the clock time', () {
      final activity = Activity.fromJson(activityJson(
          startsAt: DateTime(2026, 5, 4, 23, 45)));
      expect(activity.localDay, DateTime(2026, 5, 4));
    });

    test('a facilitator without a name is no facilitator', () {
      final activity = Activity.fromJson(activityJson(
          facilitator: {'display_name': '', 'role': 'Guide'}));
      expect(activity.facilitator, isNull);
    });

    test('initials come from the first and last names', () {
      final activity = Activity.fromJson(activityJson(facilitator: {
        'display_name': 'Ama Serwaa Mensah',
        'role': 'Guide',
        'avatar_url': '',
      }));
      expect(activity.facilitator!.initials, 'AM');
    });

    test('nearlyFull is about a handful, not an empty room', () {
      ActivityRegistrationInfo info(int? left) =>
          ActivityRegistrationInfo.fromJson(
              {'required': true, 'state': 'open', 'seats_left': left});
      expect(info(3).nearlyFull, isTrue);
      expect(info(0).nearlyFull, isFalse);
      expect(info(40).nearlyFull, isFalse);
      expect(info(null).nearlyFull, isFalse);
    });

    test('a page with no featured activity parses to null', () {
      expect(ActivityPage.fromJson(pageJson()).featured, isNull);
    });

    test('facets carry their counts', () {
      final page = ActivityPage.fromJson(pageJson());
      expect(page.availableFilters.types.first.count, 3);
    });
  });

  // --- artwork ----------------------------------------------------------

  group('artwork', () {
    test('a known key picks its own art', () {
      expect(activityAsset('retreat', 'other'), contains('retreat'));
    });

    test('an empty key falls back to the activity type', () {
      expect(activityAsset('', 'workshop'), contains('workshop'));
    });

    test('an unknown key and type still resolve to a real asset', () {
      expect(activityAsset('nope', 'nope'), endsWith('.webp'));
    });
  });

  // --- week selector ----------------------------------------------------

  group('week selector', () {
    testWidgets('the week starts on the locale\'s own first day',
        (tester) async {
      late DateTime monday;
      late DateTime sunday;
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('fr'),
        home: Builder(builder: (context) {
          // 5 March 2026 is a Thursday.
          monday = WeekSelector.startOfWeek(
              context, DateTime(2026, 3, 5));
          return const SizedBox.shrink();
        }),
      ));
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en', 'US'),
        home: Builder(builder: (context) {
          sunday = WeekSelector.startOfWeek(
              context, DateTime(2026, 3, 5));
          return const SizedBox.shrink();
        }),
      ));
      expect(monday.weekday, DateTime.monday);
      expect(sunday.weekday, DateTime.sunday);
    });
  });

  // --- screen -----------------------------------------------------------

  group('the list', () {
    testWidgets('shows skeletons before the first page lands',
        (tester) async {
      await tester.pumpWidget(harness(FakeActivitiesRepository(
          browseDelay: const Duration(milliseconds: 400))));
      await tester.pump();
      expect(find.byType(ActivitySkeleton), findsWidgets);
      await settle(tester, const Duration(milliseconds: 200));
      expect(find.byType(ActivitySkeleton), findsNothing);
    });

    testWidgets('renders a card once the page lands', (tester) async {
      await tester.pumpWidget(harness(FakeActivitiesRepository()));
      await tester.pumpAndSettle();
      expect(find.text('Lakeside Guided Meditation'), findsOneWidget);
    });

    testWidgets('groups the first card of a day under a heading',
        (tester) async {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      await tester.pumpWidget(harness(FakeActivitiesRepository(pages: [
        pageJson(results: [
          activityJson(id: 1, startsAt: tomorrow),
          activityJson(
              id: 2, title: 'Second', startsAt: tomorrow.add(
                  const Duration(hours: 2))),
        ]),
      ])));
      await tester.pumpAndSettle();
      expect(find.text('Tomorrow'), findsOneWidget);
      expect(find.byType(ActivityCard), findsNWidgets(2));
    });

    testWidgets('a failed first load offers a retry', (tester) async {
      await tester.pumpWidget(
          harness(FakeActivitiesRepository(failWith: Exception('offline'))));
      await tester.pumpAndSettle();
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('an empty schedule says so rather than showing nothing',
        (tester) async {
      await tester.pumpWidget(harness(
          FakeActivitiesRepository(pages: [pageJson(results: [])])));
      await tester.pumpAndSettle();
      expect(find.text('Nothing scheduled'), findsOneWidget);
    });

    testWidgets('a cached page is labelled as a saved copy', (tester) async {
      final repository = FakeActivitiesRepository(
        // The network is slow; the disk is not. That is the whole point of
        // the cache, and the only way to observe it.
        browseDelay: const Duration(milliseconds: 400),
        cached: CachedActivityPage(
          ActivityPage.fromJson(pageJson()),
          DateTime.now(),
        ),
      );
      await tester.pumpWidget(harness(repository));
      await settle(tester, const Duration(milliseconds: 10));
      expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
      expect(find.text('Lakeside Guided Meditation'), findsOneWidget);

      await settle(tester, const Duration(milliseconds: 200));
      // Once the network answers, the notice goes away.
      expect(find.byIcon(Icons.cloud_off_rounded), findsNothing);
    });
  });

  group('the featured banner', () {
    testWidgets('is drawn above the list when the server sends one',
        (tester) async {
      await tester.pumpWidget(harness(FakeActivitiesRepository(pages: [
        pageJson(
          featured: activityJson(
              id: 9,
              title: 'Sunset Community Gathering',
              featuredBlurb: 'Our largest gathering of the season'),
        ),
      ])));
      await tester.pumpAndSettle();
      expect(find.byType(FeaturedActivityCard), findsOneWidget);
      expect(find.text('Our largest gathering of the season'),
          findsOneWidget);
    });

    testWidgets('is absent when the server sends none', (tester) async {
      await tester.pumpWidget(harness(FakeActivitiesRepository()));
      await tester.pumpAndSettle();
      expect(find.byType(FeaturedActivityCard), findsNothing);
    });
  });

  group('card states', () {
    testWidgets('a cancelled activity stays visible and says so',
        (tester) async {
      await tester.pumpWidget(harness(FakeActivitiesRepository(pages: [
        pageJson(results: [
          activityJson(
              cancelled: true, rescheduledNote: 'Moved to Friday'),
        ]),
      ])));
      await tester.pumpAndSettle();
      expect(find.text('Lakeside Guided Meditation'), findsOneWidget);
      expect(find.text('Cancelled'), findsOneWidget);
      expect(find.textContaining('Moved to Friday'), findsOneWidget);
    });

    testWidgets('a locked activity carries a lock, not a hidden row',
        (tester) async {
      await tester.pumpWidget(harness(FakeActivitiesRepository(pages: [
        pageJson(results: [
          activityJson(access: {
            'allowed': false,
            'required_audience': 'members',
            'sign_in_required': false,
            'reason': 'members_only',
          }),
        ]),
      ])));
      await tester.pumpAndSettle();
      expect(find.text('Members only'), findsOneWidget);
      expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
    });

    testWidgets('a live activity is badged live', (tester) async {
      await tester.pumpWidget(harness(FakeActivitiesRepository(pages: [
        pageJson(results: [
          activityJson(kind: 'live', isLiveNow: true, destination: {
            'type': 'live',
            'event_id': 1,
          }),
        ]),
      ])));
      await tester.pumpAndSettle();
      expect(find.text('Live'), findsWidgets);
    });

    testWidgets('a paid activity shows its fee', (tester) async {
      await tester.pumpWidget(harness(FakeActivitiesRepository(pages: [
        pageJson(results: [
          activityJson(fee: {
            'free': false,
            'amount': '50.00',
            'currency': 'GHS',
            'display': 'GHS 50',
          }),
        ]),
      ])));
      await tester.pumpAndSettle();
      expect(find.text('GHS 50'), findsOneWidget);
    });

    testWidgets('an almost-full activity counts down its places',
        (tester) async {
      await tester.pumpWidget(harness(FakeActivitiesRepository(pages: [
        pageJson(results: [
          activityJson(registration: {
            'required': true,
            'state': 'open',
            'capacity': 20,
            'seats_left': 3,
            'my_status': null,
            'external_url': '',
            'waitlist_enabled': false,
          }),
        ]),
      ])));
      await tester.pumpAndSettle();
      expect(find.text('3 places left'), findsOneWidget);
      expect(find.text('Register'), findsOneWidget);
    });

    testWidgets('a full activity without a waitlist cannot be pressed',
        (tester) async {
      await tester.pumpWidget(harness(FakeActivitiesRepository(pages: [
        pageJson(results: [
          activityJson(registration: {
            'required': true,
            'state': 'full',
            'capacity': 20,
            'seats_left': 0,
            'my_status': null,
            'external_url': '',
            'waitlist_enabled': false,
          }),
        ]),
      ])));
      await tester.pumpAndSettle();
      final button = tester.widget<TextButton>(
          find.widgetWithText(TextButton, 'Fully booked'));
      expect(button.onPressed, isNull);
    });

    testWidgets('an activity I am registered for offers to release my place',
        (tester) async {
      await tester.pumpWidget(harness(FakeActivitiesRepository(pages: [
        pageJson(results: [
          activityJson(registration: {
            'required': true,
            'state': 'open',
            'my_status': 'registered',
            'seats_left': 4,
            'external_url': '',
            'waitlist_enabled': false,
          }),
        ]),
      ])));
      await tester.pumpAndSettle();
      expect(find.text("You're registered"), findsOneWidget);
      expect(find.text('Cancel my place'), findsOneWidget);
    });

    testWidgets('an activity with no registration shows no button',
        (tester) async {
      await tester.pumpWidget(harness(FakeActivitiesRepository()));
      await tester.pumpAndSettle();
      expect(find.byType(TextButton), findsNothing);
    });
  });

  group('actions', () {
    testWidgets('the bell flips before the network answers', (tester) async {
      final repository = FakeActivitiesRepository();
      await tester.pumpWidget(harness(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.notifications_none_rounded));
      await tester.pump();
      expect(find.byIcon(Icons.notifications_active_rounded),
          findsOneWidget);
      await tester.pumpAndSettle();
      expect(repository.remindedIds, [1]);
    });

    testWidgets('saving is a separate action from registering',
        (tester) async {
      final repository = FakeActivitiesRepository();
      await tester.pumpWidget(harness(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.bookmark_border_rounded));
      await tester.pumpAndSettle();
      expect(repository.savedIds, [1]);
      expect(repository.registerCalls, 0);
    });

    testWidgets('registering asks the server rather than guessing',
        (tester) async {
      final repository = FakeActivitiesRepository(pages: [
        pageJson(results: [
          activityJson(registration: {
            'required': true,
            'state': 'open',
            'my_status': null,
            'seats_left': 4,
            'external_url': '',
            'waitlist_enabled': false,
          }),
        ]),
      ]);
      await tester.pumpWidget(harness(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();
      expect(repository.registerCalls, 1);
      expect(repository.lastRegisterWasCancel, isFalse);
      expect(find.text("You're registered"), findsOneWidget);
    });

    testWidgets('cancelling a place sends the cancel flag', (tester) async {
      final repository = FakeActivitiesRepository(pages: [
        pageJson(results: [
          activityJson(registration: {
            'required': true,
            'state': 'open',
            'my_status': 'registered',
            'seats_left': 4,
            'external_url': '',
            'waitlist_enabled': false,
          }),
        ]),
      ]);
      await tester.pumpWidget(harness(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel my place'));
      await tester.pumpAndSettle();
      expect(repository.lastRegisterWasCancel, isTrue);
    });
  });

  group('filters', () {
    testWidgets('a chip reloads with the filter and no stale cursor',
        (tester) async {
      final repository = FakeActivitiesRepository(pages: [
        pageJson(nextCursor: 'page-two'),
        pageJson(results: [activityJson(id: 2, title: 'Live one')]),
      ]);
      await tester.pumpWidget(harness(repository));
      // No pumpAndSettle here: page one advertises a next cursor, so the
      // list keeps a spinner turning and settling would never return.
      await settle(tester);

      await tester.tap(find.text('Live'));
      await settle(tester);

      expect(repository.queries.last.primary, PrimaryFilter.live);
      // The reload after a filter change must not carry the old cursor.
      expect(repository.cursors.last, isNull);
      expect(find.text('Live one'), findsOneWidget);
    });

    testWidgets('the filter button stays reachable and counts what is on',
        (tester) async {
      final repository = FakeActivitiesRepository();
      await tester.pumpWidget(harness(repository));
      await tester.pumpAndSettle();
      // Pinned beside the scrolling chips, so it is on screen without a
      // gesture: hitTestable finds only what is actually visible.
      expect(find.byIcon(Icons.tune_rounded).hitTestable(),
          findsOneWidget);
      final badge = find.descendant(
        of: find.byKey(const ValueKey('activities-filter-button')),
        matching: find.text('1'),
      );
      expect(badge, findsNothing);

      await tester.tap(find.byIcon(Icons.tune_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Guided meditation (3)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show results'));
      await tester.pumpAndSettle();
      expect(badge, findsOneWidget);
    });

    testWidgets('the filter sheet only applies when confirmed',
        (tester) async {
      final repository = FakeActivitiesRepository();
      await tester.pumpWidget(harness(repository));
      await tester.pumpAndSettle();
      final before = repository.queries.length;

      await tester.tap(find.byIcon(Icons.tune_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Guided meditation (3)'));
      await tester.pumpAndSettle();
      // Still nothing asked of the server: the sheet edits a draft.
      expect(repository.queries.length, before);

      await tester.tap(find.text('Show results'));
      await tester.pumpAndSettle();
      expect(repository.queries.last.types, {'meditation'});
    });

    testWidgets('dismissing the filter sheet changes nothing',
        (tester) async {
      final repository = FakeActivitiesRepository();
      await tester.pumpWidget(harness(repository));
      await tester.pumpAndSettle();
      final before = repository.queries.length;

      await tester.tap(find.byIcon(Icons.tune_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Guided meditation (3)'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(200, 40));
      await tester.pumpAndSettle();

      expect(repository.queries.length, before);
    });

    testWidgets('an empty filtered list offers to clear the filters',
        (tester) async {
      final repository = FakeActivitiesRepository(pages: [
        pageJson(),
        pageJson(results: []),
      ]);
      await tester.pumpWidget(harness(repository));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Live'));
      await tester.pumpAndSettle();

      expect(find.text('No activities match'), findsOneWidget);
      expect(find.text('Clear all'), findsOneWidget);
    });
  });

  group('the week selector on screen', () {
    testWidgets('choosing a day narrows the request to that day',
        (tester) async {
      final repository = FakeActivitiesRepository();
      await tester.pumpWidget(harness(repository));
      await tester.pumpAndSettle();

      final today = DateTime.now();
      await tester.tap(find.text('${today.day}').first);
      await tester.pumpAndSettle();

      final query = repository.queries.last;
      expect(query.from, isNotNull);
      expect(query.from, query.to);
    });

    testWidgets('tapping the chosen day again shows the whole schedule',
        (tester) async {
      final repository = FakeActivitiesRepository();
      await tester.pumpWidget(harness(repository));
      await tester.pumpAndSettle();

      final today = DateTime.now();
      await tester.tap(find.text('${today.day}').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('${today.day}').first);
      await tester.pumpAndSettle();

      expect(repository.queries.last.from, isNull);
    });
  });

  group('the calendar view', () {
    testWidgets('the toggle swaps the list for a month grid',
        (tester) async {
      await tester.pumpWidget(harness(FakeActivitiesRepository()));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.calendar_month_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(ActivityCalendarGrid), findsOneWidget);
    });
  });

  group('localization', () {
    testWidgets('the chips speak French', (tester) async {
      await tester.pumpWidget(harness(FakeActivitiesRepository(),
          locale: const Locale('fr')));
      await tester.pumpAndSettle();
      expect(find.text('Tout'), findsOneWidget);
      expect(find.text('En direct'), findsOneWidget);
    });

    testWidgets('no user-facing string is hardcoded English in Portuguese',
        (tester) async {
      await tester.pumpWidget(harness(
          FakeActivitiesRepository(pages: [pageJson(results: [])]),
          locale: const Locale('pt')));
      await tester.pumpAndSettle();
      expect(find.text('Nada agendado'), findsOneWidget);
    });
  });
}
