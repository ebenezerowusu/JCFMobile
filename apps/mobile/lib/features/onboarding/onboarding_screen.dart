import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../welcome/welcome_widgets.dart'
    show WelcomeErrorMessage, warmWhite;
import 'onboarding_pages.dart';
import 'onboarding_prefs.dart';
import 'onboarding_widgets.dart';

/// The three-page onboarding sequence (owner spec + designs 51–53).
///
/// One PageView, not three routes: the pages are a single experience, and
/// the reader must be able to swipe between them.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;
  bool _completing = false;
  bool _failed = false;

  static const _pageDuration = Duration(milliseconds: 300);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isLast => _index == onboardingPages.length - 1;

  bool get _reduceMotion => MediaQuery.disableAnimationsOf(context);

  void _goTo(int page) {
    if (_reduceMotion) {
      _controller.jumpToPage(page);
    } else {
      _controller.animateToPage(page,
          duration: _pageDuration, curve: Curves.easeOut);
    }
  }

  Future<void> _finish({required String method}) async {
    // One completion only: a second tap must not write again or start a
    // second navigation.
    if (_completing) return;
    setState(() {
      _completing = true;
      _failed = false;
    });
    try {
      await ref.read(onboardingPrefsProvider).markSeen(method: method);
      if (!mounted) return;
      // Replace, so neither the system Back button nor the router can
      // return to onboarding — or, behind it, to the splash.
      context.go('/welcome');
    } catch (_) {
      if (!mounted) return;
      // Nothing is persisted, so navigating would show onboarding again
      // on the next launch. Better to stay and say so.
      setState(() {
        _completing = false;
        _failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return PopScope(
      // Back walks the pages; only on the first does it leave, which the
      // platform handles as it would from any entry screen.
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _index > 0) _goTo(_index - 1);
      },
      child: Scaffold(
        backgroundColor: warmWhite,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final height = constraints.maxHeight;
            final short = height < 680;
            final heroHeight = height * (short ? 0.48 : 0.56);

            return Stack(
              fit: StackFit.expand,
              children: [
                // The hero belongs to the page, so it swipes with it.
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: heroHeight + 40,
                  child: PageView.builder(
                    controller: _controller,
                    // Swiping is disabled while completing, so the reader
                    // cannot leave the page whose button is working.
                    physics: _completing
                        ? const NeverScrollableScrollPhysics()
                        : const PageScrollPhysics(),
                    onPageChanged: (index) =>
                        setState(() => _index = index),
                    itemCount: onboardingPages.length,
                    itemBuilder: (context, index) => OnboardingHero(
                      asset: onboardingPages[index].imageAsset,
                      height: heroHeight + 40,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: SafeArea(
                    child: Column(
                      children: [
                        OnboardingTopBar(
                          // Gone on the last page: there is nothing left
                          // to skip past.
                          showSkip: !_isLast && !_completing,
                          onSkip: () => _finish(method: 'skipped'),
                        ),
                        const Spacer(),
                        _panel(t, constraints, short),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _panel(
      AppLocalizations t, BoxConstraints constraints, bool short) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: warmWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
              color: Color(0x1A102454),
              blurRadius: 24,
              offset: Offset(0, -6)),
        ],
      ),
      // Bounded and scrollable, so large text or a long translation
      // cannot push the navigation off the bottom.
      constraints: BoxConstraints(
          maxHeight: constraints.maxHeight * (short ? 0.74 : 0.62)),
      child: SingleChildScrollView(
        padding:
            EdgeInsets.fromLTRB(24, short ? 20 : 26, 24, short ? 16 : 22),
        child: Center(
          child: ConstrainedBox(
            // A readable measure on a tablet rather than one wide line.
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Keyed by page id so a page change swaps the words
                // rather than mutating one widget in place.
                OnboardingPageContent(
                  key: ValueKey(onboardingPages[_index].id),
                  page: onboardingPages[_index],
                  compact: short,
                ),
                SizedBox(height: short ? 18 : 24),
                OnboardingPageIndicator(
                    current: _index, total: onboardingPages.length),
                SizedBox(height: short ? 16 : 22),
                if (_failed) ...[
                  WelcomeErrorMessage(
                    message: t.onboardingCompletionFailed,
                    onRetry: () => _finish(
                        method: _isLast ? 'completed' : 'skipped'),
                  ),
                  const SizedBox(height: 14),
                ],
                Row(
                  children: [
                    // Hidden, not disabled, on the first page: nothing
                    // should invite a tap that cannot do anything.
                    if (_index > 0) ...[
                      OnboardingBackButton(
                        onPressed: _completing
                            ? null
                            : () => _goTo(_index - 1),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: OnboardingPrimaryButton(
                        label: _isLast
                            ? t.onboardingGetStarted
                            : t.onboardingNext,
                        loading: _completing,
                        onPressed: () {
                          if (_isLast) {
                            _finish(method: 'completed');
                          } else {
                            _goTo(_index + 1);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
