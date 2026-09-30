import 'package:flutter/material.dart';
import 'package:jcf_ui/jcf_ui.dart';

import '../../l10n/app_localizations.dart';
import 'splash_state.dart';

const _warmWhite = Color(0xFFF8F7F2);
const _softGold = Color(0xFFD5A62E);

/// Whether the platform has been asked to keep motion to a minimum.
bool reducedMotion(BuildContext context) =>
    MediaQuery.disableAnimationsOf(context);

/// The cosmic artwork behind everything, with a restrained navy scrim so
/// text meets contrast wherever the image happens to be bright.
class SplashBackground extends StatelessWidget {
  const SplashBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
        fit: StackFit.expand,
        children: [
          // Decorative: excluded from semantics so a screen reader does
          // not announce the wallpaper.
          Image.asset(
            SplashAssets.cosmicBackground,
            fit: BoxFit.cover,
            excludeFromSemantics: true,
            errorBuilder: (_, _, _) =>
                const ColoredBox(color: JcfColors.cosmicDeep),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x1A102454),
                  Color(0x66102454),
                  Color(0xD9102454),
                ],
                stops: [0, 0.55, 1],
              ),
            ),
          ),
          child,
        ],
      );
}

/// Logo, foundation name and tagline. All three are native text and a
/// native image — nothing here is baked into the artwork.
class SplashBrandContent extends StatefulWidget {
  const SplashBrandContent({super.key, this.compact = false});

  final bool compact;

  @override
  State<SplashBrandContent> createState() => _SplashBrandContentState();
}

class _SplashBrandContentState extends State<SplashBrandContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    // Constructed here, not lazily: a `late final` initializer only runs
    // on first access, and dispose() touching it would then build a
    // controller against a deactivated element.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (reducedMotion(context)) {
      // Straight to the end: no scale, no fade, nothing to sit through.
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final width = MediaQuery.sizeOf(context).width;
    // 190–220 logical pixels on a phone, capped on a tablet so the logo
    // never grows to fill the screen.
    final logoWidth = widget.compact
        ? 150.0
        : (width * 0.54).clamp(170.0, 220.0);

    final logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.6, curve: Curves.easeOut),
    );
    final textFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 1, curve: Curves.easeOut),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FadeTransition(
          opacity: logoFade,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1).animate(logoFade),
            child: Image.asset(
              SplashAssets.brandLogo,
              width: logoWidth,
              // Contain, always: the mark must never be cropped or
              // stretched, whatever the box it lands in.
              fit: BoxFit.contain,
              semanticLabel: t.splashLogoLabel,
              errorBuilder: (_, _, _) => SizedBox(height: logoWidth * 0.8),
            ),
          ),
        ),
        SizedBox(height: widget.compact ? 16 : 24),
        FadeTransition(
          opacity: textFade,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t.splashFoundationName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: widget.compact ? 16 : 18,
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.2,
                  color: _warmWhite,
                ),
              ),
              SizedBox(height: widget.compact ? 8 : 12),
              Text(
                t.splashTagline,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: widget.compact ? 13 : 14.5,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                  color: _softGold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Three dots and a message.
///
/// The message carries the status in words, so the state is never
/// communicated by motion alone — and the dots themselves are hidden from
/// screen readers, which would otherwise announce them endlessly.
class SplashLoadingIndicator extends StatefulWidget {
  const SplashLoadingIndicator({super.key, required this.message});

  final String message;

  @override
  State<SplashLoadingIndicator> createState() =>
      _SplashLoadingIndicatorState();
}

class _SplashLoadingIndicatorState extends State<SplashLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (!reducedMotion(context)) _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final still = reducedMotion(context);

    return Semantics(
      liveRegion: true,
      label: '${t.splashLoadingLabel}. ${widget.message}',
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 10,
            child: still
                // Without motion the dots are simply present, which still
                // reads as "working" beside the message.
                ? const _Dots(opacities: [0.9, 0.6, 0.35])
                : AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      final v = _controller.value;
                      double opacity(int i) {
                        final phase = (v - i * 0.18) % 1.0;
                        return 0.3 + 0.7 * (1 - (phase * 2 - 1).abs())
                            .clamp(0.0, 1.0);
                      }

                      return _Dots(
                        opacities: [opacity(0), opacity(1), opacity(2)],
                      );
                    },
                  ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xCCF8F7F2),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.opacities});

  final List<double> opacities;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final opacity in opacities)
            Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _warmWhite.withValues(alpha: opacity),
              ),
            ),
        ],
      );
}

/// The error, update-required and maintenance panels: one shape, because
/// they differ only in words and in which actions they offer.
class SplashMessagePanel extends StatelessWidget {
  const SplashMessagePanel({
    super.key,
    required this.title,
    required this.message,
    this.primaryLabel,
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.busy = false,
  });

  final String title;
  final String message;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final bool busy;

  @override
  Widget build(BuildContext context) => Semantics(
        liveRegion: true,
        container: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                height: 1.3,
                fontWeight: FontWeight.w600,
                color: _warmWhite,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.45,
                color: Color(0xCCF8F7F2),
              ),
            ),
            if (primaryLabel != null) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: busy ? null : onPrimary,
                  style: FilledButton.styleFrom(
                    backgroundColor: _warmWhite,
                    foregroundColor: JcfColors.cosmicDeep,
                    // At least 48 logical pixels high.
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999)),
                    textStyle: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  child: busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: JcfColors.cosmicDeep),
                        )
                      : Text(primaryLabel!),
                ),
              ),
            ],
            if (secondaryLabel != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: onSecondary,
                  style: TextButton.styleFrom(
                    foregroundColor: _warmWhite,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                        side: const BorderSide(color: Color(0x66F8F7F2))),
                    textStyle: const TextStyle(
                        fontSize: 14.5, fontWeight: FontWeight.w600),
                  ),
                  child: Text(secondaryLabel!),
                ),
              ),
            ],
          ],
        ),
      );
}
