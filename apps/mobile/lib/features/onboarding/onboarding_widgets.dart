import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../welcome/welcome_widgets.dart'
    show royalBlue, deepNavy, warmWhite, softGold, supportingText;
import 'onboarding_pages.dart';

const inactiveIndicator = Color(0xFFCBD3E1);

/// The page artwork, with a navy gradient so the panel below it does not
/// begin at a hard line.
class OnboardingHero extends StatelessWidget {
  const OnboardingHero({
    super.key,
    required this.asset,
    required this.height,
  });

  final String asset;
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Decorative: kept out of the semantics tree so a screen
            // reader reaches the heading rather than describing a photo.
            Image.asset(
              asset,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              excludeFromSemantics: true,
              errorBuilder: (_, _, _) =>
                  const ColoredBox(color: deepNavy),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x4D102454), Color(0x00102454)],
                  stops: [0, 0.3],
                ),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xCC102454), Color(0x00102454)],
                  stops: [0, 0.3],
                ),
              ),
            ),
          ],
        ),
      );
}

/// Three indicators. The active one is wider as well as bluer, so the
/// position is not carried by colour alone, and the whole row announces
/// "Page 2 of 3" rather than three anonymous dots.
class OnboardingPageIndicator extends StatelessWidget {
  const OnboardingPageIndicator({
    super.key,
    required this.current,
    required this.total,
  });

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Semantics(
      label: t.onboardingPagePosition(current + 1, total),
      excludeSemantics: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < total; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              width: i == current ? 22 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: i == current ? royalBlue : inactiveIndicator,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
        ],
      ),
    );
  }
}

/// The circular Back control. Hidden on the first page rather than shown
/// dead, so nothing invites a tap that cannot do anything.
class OnboardingBackButton extends StatelessWidget {
  const OnboardingBackButton({super.key, required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: t.onboardingBack,
      excludeSemantics: true,
      child: SizedBox(
        width: 54,
        height: 54,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            shape: const CircleBorder(),
            padding: EdgeInsets.zero,
            side: const BorderSide(color: inactiveIndicator, width: 1.5),
            foregroundColor: deepNavy,
          ),
          // Mirrors in RTL, where "back" is the other way.
          child: const Icon(Icons.arrow_back_rounded, size: 21),
        ),
      ),
    );
  }
}

/// Next, or Get started on the last page.
class OnboardingPrimaryButton extends StatelessWidget {
  const OnboardingPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        enabled: !loading,
        // Announced in words: the spinner alone says nothing aloud.
        label: loading ? '$label…' : label,
        excludeSemantics: true,
        child: FilledButton(
          onPressed: loading ? null : onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: royalBlue,
            disabledBackgroundColor: royalBlue.withValues(alpha: 0.6),
            foregroundColor: Colors.white,
            disabledForegroundColor: Colors.white,
            minimumSize: const Size(0, 56),
            padding: const EdgeInsets.symmetric(horizontal: 26),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)),
            textStyle: const TextStyle(
                fontSize: 15.5, fontWeight: FontWeight.w600),
          ),
          child: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.4, color: Colors.white),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_rounded, size: 19),
                  ],
                ),
        ),
      );
}

/// The words for one page. A separate widget so changing page rebuilds
/// this rather than the whole PageView.
class OnboardingPageContent extends StatelessWidget {
  const OnboardingPageContent({
    super.key,
    required this.page,
    required this.compact,
  });

  final OnboardingPageData page;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          page.eyebrow(t),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: softGold,
          ),
        ),
        SizedBox(height: compact ? 8 : 10),
        Semantics(
          header: true,
          child: Text(
            page.title(t),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: compact ? 23 : 26,
              height: 1.2,
              fontWeight: FontWeight.w700,
              color: deepNavy,
            ),
          ),
        ),
        SizedBox(height: compact ? 8 : 12),
        Text(
          page.description(t),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            height: 1.55,
            color: supportingText,
          ),
        ),
      ],
    );
  }
}

/// The logo and Skip row over the hero.
class OnboardingTopBar extends StatelessWidget {
  const OnboardingTopBar({
    super.key,
    required this.showSkip,
    required this.onSkip,
  });

  final bool showSkip;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 12, 0),
      child: Row(
        children: [
          Semantics(
            label: t.splashLogoLabel,
            image: true,
            child: Image.asset(
              OnboardingAssets.brandLogo,
              width: 72,
              // Contain, never cropped, and never mirrored in RTL: a
              // reversed wordmark is not the brand.
              fit: BoxFit.contain,
              excludeFromSemantics: true,
              errorBuilder: (_, _, _) => const SizedBox(width: 72),
            ),
          ),
          const Spacer(),
          if (showSkip)
            Semantics(
              button: true,
              label: t.onboardingSkip,
              excludeSemantics: true,
              child: TextButton(
                onPressed: onSkip,
                style: TextButton.styleFrom(
                  foregroundColor: warmWhite,
                  // At least 48 logical pixels of target.
                  minimumSize: const Size(64, 48),
                  textStyle: const TextStyle(
                      fontSize: 14.5, fontWeight: FontWeight.w600),
                ),
                child: Text(
                  t.onboardingSkip,
                  style: const TextStyle(
                    shadows: [
                      Shadow(color: Color(0x99102454), blurRadius: 8),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
