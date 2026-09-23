import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/activities/activities_screen.dart';
import '../features/auth/session_expired_screen.dart';
import '../features/auth/signin_identifier_screen.dart';
import '../features/auth/signin_options_screen.dart';
import '../features/donations/causes_screen.dart';
import '../features/engagement/announcements_screen.dart';
import '../features/engagement/appointments_screen.dart';
import '../features/engagement/notifications_screen.dart';
import '../features/home/home_screen.dart';
import '../features/lessons/continue_learning_screen.dart';
import '../features/lessons/lesson_detail_screen.dart';
import '../features/lessons/lessons_screen.dart';
import '../features/more/quick_actions_screen.dart';
import '../features/onboarding/language_screen.dart';
import '../features/practice/practice_screen.dart';
import '../features/onboarding/path_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/onboarding/splash_screen.dart';
import '../features/onboarding/stay_connected_screen.dart';
import '../features/onboarding/welcome_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/programs/program_detail_screen.dart';
import '../features/programs/programs_screen.dart';
import '../features/search/search_screen.dart';
import 'shell.dart';

final _homeNav = GlobalKey<NavigatorState>();
final _lessonsNav = GlobalKey<NavigatorState>();
final _practiceNav = GlobalKey<NavigatorState>();
final _programsNav = GlobalKey<NavigatorState>();
final _moreNav = GlobalKey<NavigatorState>();

/// The app's router. Module-level so non-widget code (e.g. the session-
/// expired handler) can navigate; created once — recreating it on rebuild
/// would reset navigation to the splash screen.
final appRouter = createRouter();

GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/welcome', builder: (_, _) => const WelcomeScreen()),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: '/language', builder: (_, _) => const LanguageScreen()),
      GoRoute(path: '/path', builder: (_, _) => const PathScreen()),
      GoRoute(path: '/stay-connected', builder: (_, _) => const StayConnectedScreen()),
      GoRoute(path: '/session-expired', builder: (_, _) => const SessionExpiredScreen()),
      GoRoute(path: '/login', builder: (_, _) => const SignInOptionsScreen()),
      GoRoute(path: '/login/phone', builder: (_, _) => const SignInIdentifierScreen(isPhone: true)),
      GoRoute(path: '/login/email', builder: (_, _) => const SignInIdentifierScreen(isPhone: false)),
      GoRoute(path: '/notifications', builder: (_, _) => const NotificationsScreen()),
      GoRoute(path: '/appointments', builder: (_, _) => const AppointmentsScreen()),
      GoRoute(path: '/give', builder: (_, _) => const CausesScreen()),
      GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
      GoRoute(path: '/learning', builder: (_, _) => const ContinueLearningScreen()),
      GoRoute(path: '/activities', builder: (_, _) => const ActivitiesScreen()),
      GoRoute(path: '/announcements', builder: (_, _) => const AnnouncementsScreen()),
      GoRoute(path: '/search', builder: (_, _) => const SearchScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            HomeShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _homeNav,
            routes: [GoRoute(path: '/home', builder: (_, _) => const HomeScreen())],
          ),
          StatefulShellBranch(
            navigatorKey: _lessonsNav,
            routes: [
              GoRoute(
                path: '/lessons',
                builder: (_, _) => const LessonsScreen(),
                routes: [
                  GoRoute(
                    path: ':slug',
                    builder: (_, state) =>
                        LessonDetailScreen(slug: state.pathParameters['slug']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _practiceNav,
            routes: [GoRoute(path: '/practice', builder: (_, _) => const PracticeScreen())],
          ),
          StatefulShellBranch(
            navigatorKey: _programsNav,
            routes: [
              GoRoute(
                path: '/programs',
                builder: (_, _) => const ProgramsScreen(),
                routes: [
                  GoRoute(
                    path: ':slug',
                    builder: (_, state) =>
                        ProgramDetailScreen(slug: state.pathParameters['slug']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _moreNav,
            routes: [GoRoute(path: '/more', builder: (_, _) => const QuickActionsScreen())],
          ),
        ],
      ),
    ],
  );
}
