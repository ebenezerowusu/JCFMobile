import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/signin_identifier_screen.dart';
import '../features/auth/signin_options_screen.dart';
import '../features/donations/causes_screen.dart';
import '../features/engagement/appointments_screen.dart';
import '../features/engagement/notifications_screen.dart';
import '../features/home/home_screen.dart';
import '../features/lessons/lesson_detail_screen.dart';
import '../features/lessons/lessons_screen.dart';
import '../features/onboarding/language_screen.dart';
import '../features/onboarding/path_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/onboarding/splash_screen.dart';
import '../features/onboarding/stay_connected_screen.dart';
import '../features/onboarding/welcome_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/programs/program_detail_screen.dart';
import '../features/programs/programs_screen.dart';
import 'shell.dart';

final _homeNav = GlobalKey<NavigatorState>();
final _lessonsNav = GlobalKey<NavigatorState>();
final _giveNav = GlobalKey<NavigatorState>();
final _programsNav = GlobalKey<NavigatorState>();
final _profileNav = GlobalKey<NavigatorState>();

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
      GoRoute(path: '/login', builder: (_, _) => const SignInOptionsScreen()),
      GoRoute(path: '/login/phone', builder: (_, _) => const SignInIdentifierScreen(isPhone: true)),
      GoRoute(path: '/login/email', builder: (_, _) => const SignInIdentifierScreen(isPhone: false)),
      GoRoute(path: '/notifications', builder: (_, _) => const NotificationsScreen()),
      GoRoute(path: '/appointments', builder: (_, _) => const AppointmentsScreen()),
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
            navigatorKey: _giveNav,
            routes: [GoRoute(path: '/give', builder: (_, _) => const CausesScreen())],
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
            navigatorKey: _profileNav,
            routes: [GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen())],
          ),
        ],
      ),
    ],
  );
}
