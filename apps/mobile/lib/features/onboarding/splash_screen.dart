import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jcf_ui/jcf_ui.dart';

import '../../core/brand.dart';
import 'onboarding_prefs.dart';

/// Cosmic splash (design/1): starfield + orbit rings over deep blue, the JCF
/// globe centred in a glow, wordmark below, planet horizon rising at the foot.
/// Routes to onboarding (first run) or home.
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
    context.go(seen ? '/home' : '/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JcfColors.cosmicDeep,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Deep-space gradient, brightest behind the logo.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.25),
                radius: 1.3,
                colors: [
                  JcfColors.cosmicBlue,
                  Color(0xFF0B1B85),
                  JcfColors.cosmicDeep,
                ],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
          ),
          // Stars + orbit rings around the logo.
          const CustomPaint(painter: _CosmosPainter()),
          // Planet horizon rising from the bottom edge.
          Positioned(
            left: -120,
            right: -120,
            bottom: -260,
            height: 360,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.0,
                  colors: [Color(0xFF3F7BFF), Color(0xFF0A1770)],
                  stops: [0.0, 0.6],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6EA8FF).withValues(alpha: 0.55),
                    blurRadius: 90,
                    spreadRadius: 8,
                  ),
                ],
              ),
            ),
          ),
          // Logo + wordmark, fading and settling in.
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, t, child) => Opacity(
              opacity: t,
              child: Transform.scale(scale: 0.92 + 0.08 * t, child: child),
            ),
            child: Column(
              children: [
                const Spacer(flex: 3),
                // Soft glow behind the globe.
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4D8DFF).withValues(alpha: 0.45),
                        blurRadius: 110,
                        spreadRadius: 24,
                      ),
                    ],
                  ),
                  child: const JcfLogo(size: 220, onDark: true),
                ),
                const Spacer(flex: 2),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'JAN COSMIC FOUNDATION',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: JcfTypography.bodyFamily,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Freedom. Awake and aware.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFD7E4FF),
                    fontFamily: JcfTypography.bodyFamily,
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Orbit rings + a fixed starfield. Positions are seeded so the sky is stable
/// between builds (no twinkle-jitter on rebuild).
class _CosmosPainter extends CustomPainter {
  const _CosmosPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height * 0.38);

    // Orbit rings.
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: 0.28);
    canvas.drawCircle(centre, size.width * 0.44, ring);
    ring.color = Colors.white.withValues(alpha: 0.16);
    canvas.drawCircle(centre, size.width * 0.62, ring);

    // Bright nodes sitting on the rings.
    final node = Paint()..color = Colors.white;
    for (final (radius, angle) in [
      (0.44, -2.35),
      (0.44, 0.55),
      (0.62, -0.85),
      (0.62, 2.65),
      (0.62, -2.9),
    ]) {
      final r = size.width * radius;
      final p = centre + Offset(math.cos(angle) * r, math.sin(angle) * r);
      canvas.drawCircle(p, 3.2, node);
      canvas.drawCircle(
        p,
        7,
        Paint()..color = Colors.white.withValues(alpha: 0.25),
      );
    }

    // Starfield — seeded random keeps it identical every frame.
    final rand = math.Random(7);
    for (var i = 0; i < 90; i++) {
      final p = Offset(
        rand.nextDouble() * size.width,
        rand.nextDouble() * size.height,
      );
      final twinkle = 0.15 + rand.nextDouble() * 0.55;
      canvas.drawCircle(
        p,
        rand.nextDouble() * 1.6 + 0.4,
        Paint()..color = Colors.white.withValues(alpha: twinkle),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CosmosPainter oldDelegate) => false;
}
