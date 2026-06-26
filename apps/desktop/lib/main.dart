import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jcf_ui/jcf_ui.dart';

void main() {
  runApp(const ProviderScope(child: JcfDesktopApp()));
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const AdminHomeScreen(),
    ),
  ],
);

class JcfDesktopApp extends StatelessWidget {
  const JcfDesktopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'JCF Admin',
      debugShowCheckedModeBanner: false,
      theme: JcfTheme.light(),
      routerConfig: _router,
    );
  }
}

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'JCF Admin',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 8),
            const Text('Foundation management desktop'),
          ],
        ),
      ),
    );
  }
}
