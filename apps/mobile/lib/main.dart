import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jcf_ui/jcf_ui.dart';

void main() {
  runApp(const ProviderScope(child: JcfApp()));
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);

class JcfApp extends StatelessWidget {
  const JcfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'JCF App',
      debugShowCheckedModeBanner: false,
      theme: JcfTheme.light(),
      routerConfig: _router,
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'JCF App',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 8),
            const Text('Jan Cosmic Foundation'),
          ],
        ),
      ),
    );
  }
}
