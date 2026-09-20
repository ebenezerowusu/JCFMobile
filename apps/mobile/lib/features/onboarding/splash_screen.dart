import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jcf_ui/jcf_ui.dart';

import 'onboarding_prefs.dart';

/// Cosmic splash (design/1). The same comp is used as the NATIVE splash
/// (flutter_native_splash background_image), so the OS launch frame and this
/// screen are pixel-identical — one splash, no visible hand-off.
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
      Future<void>.delayed(const Duration(milliseconds: 2000)),
    ]);
    if (!mounted) return;
    final seen = results.first as bool;
    context.go(seen ? '/home' : '/welcome');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: JcfColors.cosmicDeep,
      body: SizedBox.expand(
        child: Image(
          image: AssetImage('assets/images/splash_bg.jpg'),
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
      ),
    );
  }
}
