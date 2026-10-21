import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:jcf_ui/jcf_ui.dart';

import '../../l10n/app_localizations.dart';
import 'splash_state.dart';

const _warmWhite = Color(0xFFF8F7F2);
const _softGold = Color(0xFFD5A62E);

/// Whether the platform has been asked to keep motion to a minimum.
bool reducedMotion(BuildContext context) =>
    MediaQuery.disableAnimationsOf(context);

/// The navy the native launch screen is painted in (`color` under
/// `flutter_native_splash` in pubspec.yaml). Stage two starts on exactly
/// this colour so the handover from the OS is invisible.
const splashNativeNavy = Color(0xFF102454);

/// The logo's width on the native launch screen: the mdpi drawable is
/// 190x154 px, i.e. 190 logical pixels, centred in the window.
const splashNativeLogoWidth = 190.0;

/// Width over height of [SplashAssets.brandLogo] (760x616).
const splashLogoAspect = 760 / 616;

/// The mark's own orbit ring, measured off the artwork: tilted -30.2 and
/// centred slightly below the middle of the box. [SplashOrbitTrack] draws
/// a second, wider ring concentric with it.
///
/// The radii are deliberately sized so the outer ring fits *inside* the
/// existing logo box on all four sides, which is what lets it be painted
/// without touching the layout or the handover's measured target. The
/// margin is 12-17 logical pixels at every logo width the app uses;
/// `splashOrbitBounds` and its test hold that line.
const splashOrbitTilt = -0.5271; // radians, -30.2 degrees
const splashOrbitCentre = Offset(0.505, 0.528); // fractions of the box
const splashOrbitRadiusX = 0.475; // fraction of the box WIDTH
const splashOrbitRadiusY = 0.1425; // fraction of the box WIDTH

/// The axis-aligned area the orbit paints into, for a logo box of [box].
///
/// Must stay within `Offset.zero & box`: the track is painted inside a
/// RepaintBoundary the size of that box, so anything outside would be
/// clipped away rather than drawn.
Rect splashOrbitBounds(Size box) {
  final a = splashOrbitRadiusX * box.width;
  final b = splashOrbitRadiusY * box.width;
  final halfWidth = math.sqrt(math.pow(a * math.cos(splashOrbitTilt), 2) +
      math.pow(b * math.sin(splashOrbitTilt), 2));
  final halfHeight = math.sqrt(math.pow(a * math.sin(splashOrbitTilt), 2) +
      math.pow(b * math.cos(splashOrbitTilt), 2));
  return Rect.fromCenter(
    center: Offset(splashOrbitCentre.dx * box.width,
        splashOrbitCentre.dy * box.height),
    width: halfWidth * 2,
    height: halfHeight * 2,
  );
}

/// The cosmic artwork behind everything, with a restrained navy scrim so
/// text meets contrast wherever the image happens to be bright.
///
/// Sits on [splashNativeNavy]; [reveal] fades the artwork in over it, so
/// the screen reads as the native launch frame gaining its background.
class SplashBackground extends StatelessWidget {
  const SplashBackground({super.key, required this.child, this.reveal});

  final Widget child;

  /// Opacity of the artwork and scrim. Null shows them at full strength.
  final Animation<double>? reveal;

  @override
  Widget build(BuildContext context) => Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: splashNativeNavy),
          FadeTransition(
            opacity: reveal ?? kAlwaysCompleteAnimation,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Decorative: excluded from semantics so a screen reader
                // does not announce the wallpaper.
                Image.asset(
                  SplashAssets.cosmicBackground,
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
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
              ],
            ),
          ),
          child,
        ],
      );
}

/// The brand mark. Contain, always: it must never be cropped or
/// stretched, whatever the box it lands in.
class SplashLogoImage extends StatelessWidget {
  const SplashLogoImage({super.key, this.width, this.semanticLabel});

  final double? width;

  /// Null marks the image decorative.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => Image.asset(
        SplashAssets.brandLogo,
        width: width,
        fit: BoxFit.contain,
        semanticLabel: semanticLabel,
        excludeFromSemantics: semanticLabel == null,
        errorBuilder: (_, _, _) => SizedBox(
            width: width,
            height: width == null ? null : width! / splashLogoAspect),
      );
}

/// Logo, foundation name and tagline. All three are native text and a
/// native image — nothing here is baked into the artwork.
///
/// Animation belongs to the splash screen's handover: [showLogo] is false
/// while a stand-in logo travels from the native launch position into
/// [logoKey]'s box, and [textOpacity] brings the words in after it.
class SplashBrandContent extends StatelessWidget {
  const SplashBrandContent({
    super.key,
    this.compact = false,
    this.logoKey,
    this.showLogo = true,
    this.textOpacity,
    this.orbitDraw,
    this.orbitAmbient = true,
  });

  final bool compact;
  final Key? logoKey;
  final bool showLogo;
  final Animation<double>? textOpacity;

  /// How much of the outer orbit is drawn. See [SplashOrbitTrack].
  final Animation<double>? orbitDraw;

  /// Whether the orbit may drift. False until the handover is done, so
  /// no frames are spent on it while startup is still working.
  final bool orbitAmbient;

  /// 190–220 logical pixels on a phone, capped on a tablet so the logo
  /// never grows to fill the screen.
  static double logoWidthFor(BuildContext context, {bool compact = false}) =>
      compact
          ? 150.0
          : (MediaQuery.sizeOf(context).width * 0.54).clamp(170.0, 220.0);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final logoWidth = logoWidthFor(context, compact: compact);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // A fixed box, so the layout — and the handover's target — does
        // not depend on whether the image has decoded yet.
        SizedBox(
          key: logoKey,
          width: logoWidth,
          height: logoWidth / splashLogoAspect,
          // The orbit paints inside this same box - see
          // splashOrbitBounds - so neither the layout nor the handover's
          // measured target moves by a pixel.
          child: SplashOrbitTrack(
            draw: orbitDraw,
            ambient: orbitAmbient,
            child: Opacity(
              opacity: showLogo ? 1 : 0,
              child: SplashLogoImage(
                  width: logoWidth, semanticLabel: t.splashLogoLabel),
            ),
          ),
        ),
        SizedBox(height: compact ? 16 : 24),
        FadeTransition(
          opacity: textOpacity ?? kAlwaysCompleteAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t.splashFoundationName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: compact ? 16 : 18,
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.2,
                  color: _warmWhite,
                ),
              ),
              SizedBox(height: compact ? 8 : 12),
              Text(
                t.splashTagline,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: compact ? 13 : 14.5,
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

/// A second, outer orbit around the mark: a point of light traces the
/// ring as the logo lands, then drifts round it while startup finishes.
///
/// It costs no startup time, which is the whole point. [draw] rides the
/// handover's own controller in the window the logo has already finished
/// travelling in, and the drift loop does not start until [ambient] — so
/// it only ever turns while the app is already waiting for bootstrap. On
/// a fast launch nobody sees it; on a slow one it is what makes the wait
/// look alive.
class SplashOrbitTrack extends StatefulWidget {
  const SplashOrbitTrack({
    super.key,
    required this.child,
    this.draw,
    this.ambient = true,
  });

  /// The mark. Painted between the ring's far and near halves, so the
  /// planet occludes the travelling point as it passes behind.
  final Widget child;

  /// How much of the ring is drawn. 0 paints nothing at all, which keeps
  /// the first frame an exact match for the native launch screen. Null
  /// means fully drawn.
  final Animation<double>? draw;

  /// Whether the slow drift may run.
  final bool ambient;

  @override
  State<SplashOrbitTrack> createState() => SplashOrbitTrackState();
}

class SplashOrbitTrackState extends State<SplashOrbitTrack>
    with SingleTickerProviderStateMixin {
  /// One revolution. Slow enough to read as drift rather than as a
  /// spinner, which would imply the wait is measurable.
  static const _revolution = Duration(milliseconds: 5200);

  late final AnimationController _orbit;
  late final Listenable _repaint;
  bool _latched = false;

  /// Whether the drift is actually turning. Exposed so a test can hold
  /// the line that it never runs during the handover, or under reduced
  /// motion — neither of which is visible from the widget tree.
  @visibleForTesting
  bool get isOrbiting => _orbit.isAnimating;

  @override
  void initState() {
    super.initState();
    _orbit = AnimationController(vsync: this, duration: _revolution);
    // Built once: rebuilding it per frame would churn listeners on the
    // render object for no reason.
    _repaint = Listenable.merge([widget.draw, _orbit]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // MediaQuery is not available in initState, so the reduced-motion
    // decision is latched here — the same shape SplashLoadingIndicator
    // uses, including not restarting if the setting changes later.
    if (_latched) return;
    _latched = true;
    _startDrift();
  }

  @override
  void didUpdateWidget(SplashOrbitTrack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.ambient != oldWidget.ambient) _startDrift();
  }

  void _startDrift() {
    if (!_latched || !widget.ambient || _orbit.isAnimating) return;
    if (reducedMotion(context)) return;
    _orbit.repeat();
  }

  @override
  void dispose() {
    _orbit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Two boundaries with the mark between them, rather than one around
    // the lot: a boundary enclosing the image would drag it into the
    // repainting layer and have it re-rasterised every frame.
    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: CustomPaint(
            painter: _OrbitPainter(
                half: _OrbitHalf.far,
                draw: widget.draw,
                spin: _orbit,
                repaint: _repaint),
            isComplex: false,
            willChange: true,
          ),
        ),
        widget.child,
        RepaintBoundary(
          child: CustomPaint(
            painter: _OrbitPainter(
                half: _OrbitHalf.near,
                draw: widget.draw,
                spin: _orbit,
                repaint: _repaint),
            isComplex: false,
            willChange: true,
          ),
        ),
      ],
    );
  }
}

/// Which half of the ring a painter owns. The near half passes in front
/// of the planet, the far half behind it.
enum _OrbitHalf { near, far }

class _OrbitPainter extends CustomPainter {
  _OrbitPainter({
    required this.half,
    required this.draw,
    required this.spin,
    required Listenable repaint,
  }) : super(repaint: repaint);

  final _OrbitHalf half;
  final Animation<double>? draw;
  final Animation<double> spin;

  @override
  void paint(Canvas canvas, Size size) {
    final drawn = draw?.value ?? 1.0;
    if (drawn <= 0) return; // the native first frame: nothing at all

    final a = splashOrbitRadiusX * size.width;
    final b = splashOrbitRadiusY * size.width;
    final oval = Rect.fromCenter(
        center: Offset.zero, width: a * 2, height: b * 2);

    // Two separate things, which is the whole trick: how much of the
    // ring exists, and where the point of light currently is. The pen
    // draws the ring once and the ring stays; the point then keeps
    // going round it. Both start at angle 0, the right-hand tip, so the
    // changeover has no jump in it.
    final penAngle = drawn * 2 * math.pi;
    final moteAngle = (drawn < 1 ? drawn : spin.value) * 2 * math.pi;

    // The near half is the lower one at this tilt, which is where the
    // mark's own ring crosses in front of its globe.
    final start = half == _OrbitHalf.near ? 0.0 : math.pi;
    final sweep = (penAngle - start).clamp(0.0, math.pi);

    // A faint breath, so the ring stays alive through the half
    // revolution the point spends hidden behind the planet.
    final breath = 0.86 + 0.14 * math.sin(spin.value * 2 * math.pi);

    canvas.save();
    canvas.translate(splashOrbitCentre.dx * size.width,
        splashOrbitCentre.dy * size.height);
    canvas.rotate(splashOrbitTilt);

    if (sweep > 0) {
      canvas.drawArc(
        oval,
        start,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..strokeCap = StrokeCap.round
          ..isAntiAlias = true
          // Warm white, echoing the mark's own ring, rather than gold:
          // gold at any readable alpha vanishes into the nebula, which
          // is itself gold and blue.
          ..color = _warmWhite.withValues(alpha: 0.42 * breath * drawn),
      );
    }

    if (moteAngle >= start && moteAngle <= start + math.pi) {
      final point = Offset(a * math.cos(moteAngle), b * math.sin(moteAngle));
      // Two filled circles rather than a blur: a MaskFilter would force
      // an offscreen pass on the frames bootstrap is competing for.
      canvas.drawCircle(point, 4.2,
          Paint()..color = _softGold.withValues(alpha: 0.22 * drawn));
      canvas.drawCircle(point, 1.6,
          Paint()..color = _softGold.withValues(alpha: 0.95 * drawn));
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_OrbitPainter old) =>
      old.half != half ||
      old.draw?.value != draw?.value ||
      old.spin.value != spin.value;
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
