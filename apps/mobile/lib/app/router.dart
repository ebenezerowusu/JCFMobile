import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/login_screen.dart';
import '../features/lessons/lesson_detail_screen.dart';
import '../features/lessons/lessons_screen.dart';
import '../features/profile/profile_screen.dart';
import 'shell.dart';

final _lessonsNav = GlobalKey<NavigatorState>();
final _profileNav = GlobalKey<NavigatorState>();

GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/lessons',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            HomeShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _lessonsNav,
            routes: [
              GoRoute(
                path: '/lessons',
                builder: (context, state) => const LessonsScreen(),
                routes: [
                  GoRoute(
                    path: ':slug',
                    builder: (context, state) =>
                        LessonDetailScreen(slug: state.pathParameters['slug']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _profileNav,
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
