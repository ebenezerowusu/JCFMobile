import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jcf_ui/jcf_ui.dart';

import '../../core/brand.dart';
import 'onboarding_prefs.dart';

class _Page {
  const _Page(this.asset, this.title, this.body);
  final String asset;
  final String title;
  final String body;
}

/// Onboarding carousel (designs/3-5): hero comp, headline, dots, Next/Skip.
const _pages = <_Page>[
  _Page(
    'assets/images/onboard_wisdom.jpg',
    'Wisdom for the journey',
    'Watch, listen and read teachings that\nsupport awareness and conscious living.',
  ),
  _Page(
    'assets/images/onboard_innerspace.jpg',
    'Go deeper with InnerSpace',
    'Build a steady practice. Follow your progress\nand move through a guided path of inner study.',
  ),
  _Page(
    'assets/images/onboard_serve.jpg',
    'Learn, gather and serve',
    'Join programmes, connect with centres\nand help carry the work forward.',
  ),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(onboardingPrefsProvider).markSeen();
    if (mounted) context.go('/home');
  }

  void _next() {
    if (_index == _pages.length - 1) {
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _back() {
    _controller.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == _pages.length - 1;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar: brand mark left, page counter right.
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  const JcfLogo(size: 44),
                  const SizedBox(width: 10),
                  const Text(
                    'Jan Cosmic\nFoundation',
                    style: TextStyle(
                      color: JcfColors.inkOnLight,
                      fontFamily: JcfTypography.bodyFamily,
                      fontSize: 15,
                      height: 1.15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_index + 1} of ${_pages.length}',
                    style: const TextStyle(
                      color: JcfColors.inkOnLight,
                      fontFamily: JcfTypography.bodyFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _index = i),
                itemCount: _pages.length,
                itemBuilder: (context, i) {
                  final p = _pages[i];
                  return Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          child: Image.asset(p.asset, fit: BoxFit.contain),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          children: [
                            Text(
                              p.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: JcfColors.inkOnLight,
                                fontFamily: JcfTypography.bodyFamily,
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              p.body,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF54689B),
                                fontFamily: JcfTypography.bodyFamily,
                                fontSize: 16,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
            ),
            // Dots.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _pages.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 9,
                    width: i == _index ? 9 : 9,
                    decoration: BoxDecoration(
                      color: i == _index
                          ? JcfColors.skyPrimary
                          : const Color(0xFFC6D6F2),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
              ],
            ),
            // CTA + secondary action.
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton(
                    onPressed: _next,
                    style: FilledButton.styleFrom(
                      backgroundColor: JcfColors.skyPrimary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: JcfTypography.bodyFamily,
                      ),
                    ),
                    child: Text(isLast ? 'Continue' : 'Next'),
                  ),
                  TextButton(
                    onPressed: isLast ? _back : _finish,
                    child: Text(
                      isLast ? 'Back' : 'Skip',
                      style: const TextStyle(
                        color: JcfColors.skyPrimary,
                        fontFamily: JcfTypography.bodyFamily,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
