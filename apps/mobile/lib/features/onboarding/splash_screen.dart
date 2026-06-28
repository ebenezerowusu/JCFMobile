import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jcf_ui/jcf_ui.dart';

import '../../core/brand.dart';
import 'onboarding_prefs.dart';

/// Branded splash shown on launch; routes to onboarding (first run) or home.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final results = await Future.wait([
      ref.read(onboardingPrefsProvider).isSeen(),
      Future<void>.delayed(const Duration(milliseconds: 1400)),
    ]);
    if (!mounted) return;
    final seen = results.first as bool;
    context.go(seen ? '/home' : '/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JcfColors.heroNavy,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const JcfLogo(size: 120, onDark: true),
            const SizedBox(height: 24),
            Text(
              'Jan Cosmic Foundation',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontFamily: JcfTypography.headingFamily,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
