import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import 'splash_controller.dart';
import 'splash_state.dart';
import 'splash_widgets.dart';

/// The branded Flutter startup screen (owner spec, designs 48–49).
///
/// Stage two of a two-stage splash: the native launch screen appears the
/// instant the process starts, and this takes over once Flutter has a
/// frame, while bootstrap runs. It observes state; it owns no startup
/// logic of its own.
class StartupSplashScreen extends ConsumerStatefulWidget {
  const StartupSplashScreen({super.key});

  @override
  ConsumerState<StartupSplashScreen> createState() =>
      _StartupSplashScreenState();
}

/// The whole handover: logo travel, artwork fade, then the words.
const _handoffDuration = Duration(milliseconds: 800);

/// How long the handover waits for the artwork to decode before starting
/// anyway. Decoding normally takes well under this; the cap only stops a
/// stuck decode from holding the splash on plain navy.
const _photoWaitCap = Duration(milliseconds: 300);

class _StartupSplashScreenState extends ConsumerState<StartupSplashScreen>
    with SingleTickerProviderStateMixin {
  bool _navigated = false;

  // The first Flutter frame must look exactly like the native launch
  // screen — navy, logo centred at its native size — or the switch from
  // OS to Flutter shows as a jump. From there one controller moves the
  // logo into the layout, fades the artwork in behind it, then the words.
  late final AnimationController _handoff;
  late final Animation<double> _photoFade;
  late final Animation<double> _logoTravel;
  late final Animation<double> _textFade;
  final _stackKey = GlobalKey();
  final _logoKey = GlobalKey();
  Timer? _photoWait;
  Rect? _logoTarget;
  bool _photoReady = false;
  bool _prepared = false;
  bool _handoffStarted = false;
  bool _handoffDone = false;

  @override
  void initState() {
    super.initState();
    _handoff = AnimationController(vsync: this, duration: _handoffDuration);
    _logoTravel = CurvedAnimation(
      parent: _handoff,
      curve: const Interval(0, 0.7, curve: Curves.easeInOutCubic),
    );
    _photoFade = CurvedAnimation(
      parent: _handoff,
      curve: const Interval(0.1, 0.8, curve: Curves.easeOut),
    );
    _textFade = CurvedAnimation(
      parent: _handoff,
      curve: const Interval(0.55, 1, curve: Curves.easeOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prepared) return;
    _prepared = true;
    if (reducedMotion(context)) {
      // Straight to the end: no travel, no fade, nothing to sit through.
      _finishHandoff();
      return;
    }
    precacheImage(const AssetImage(SplashAssets.cosmicBackground), context)
        .whenComplete(_onPhotoReady);
    _photoWait = Timer(_photoWaitCap, _onPhotoReady);
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureLogo());
  }

  @override
  void dispose() {
    _photoWait?.cancel();
    _handoff.dispose();
    super.dispose();
  }

  void _onPhotoReady() {
    if (!mounted || _photoReady) return;
    _photoReady = true;
    _startHandoff();
  }

  /// Where the logo sits in the laid-out screen, in the stack's
  /// coordinates — the stand-in's destination.
  void _measureLogo() {
    if (!mounted) return;
    final stack = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    final logo = _logoKey.currentContext?.findRenderObject() as RenderBox?;
    if (stack == null || logo == null || !stack.hasSize || !logo.hasSize) {
      // Nothing to travel to; show the finished screen rather than hang.
      setState(_finishHandoff);
      return;
    }
    final origin = logo.localToGlobal(Offset.zero, ancestor: stack);
    setState(() => _logoTarget = origin & logo.size);
    _startHandoff();
  }

  void _startHandoff() {
    if (_handoffStarted || !_photoReady || _logoTarget == null) return;
    _handoffStarted = true;
    _handoff.forward().whenComplete(() {
      if (mounted) setState(_finishHandoff);
    });
  }

  void _finishHandoff() {
    _photoWait?.cancel();
    _handoffStarted = true;
    _handoffDone = true;
    _handoff.value = 1;
  }

  void _maybeNavigate(SplashScreenState state) {
    final result = state.result;
    // Waits for the handover too, so a fast bootstrap never cuts the logo
    // off mid-flight. The handover runs alongside bootstrap, so this only
    // adds time when bootstrap beats it.
    if (_navigated || !_handoffDone || result == null || !result.canProceed) {
      return;
    }
    _navigated = true;
    // After the frame, and by replacement, so the splash cannot be
    // reached again with the back button.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.go(result.destination);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final state = ref.watch(splashControllerProvider);

    // Checked on every build rather than only on a change. A listener
    // alone misses a bootstrap that finished before the first frame —
    // which is exactly what a warm launch does — and the splash then sits
    // there forever waiting for a transition that already happened.
    _maybeNavigate(state);

    return Scaffold(
      backgroundColor: splashNativeNavy,
      body: Stack(
        key: _stackKey,
        fit: StackFit.expand,
        children: [
          SplashBackground(
            reveal: _photoFade,
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  // Scrollable so the largest text setting on the shortest
                  // phone cannot clip the message or the buttons.
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: _content(t, state, constraints),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (!_handoffDone) _travellingLogo(),
        ],
      ),
    );
  }

  /// The stand-in logo: on the first frame it is exactly where the native
  /// launch screen drew it (centred in the window, native size), then it
  /// flies to the laid-out logo's box and hands over to it.
  Widget _travellingLogo() => Positioned.fill(
        child: IgnorePointer(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final native = Rect.fromCenter(
                center: constraints.biggest.center(Offset.zero),
                width: splashNativeLogoWidth,
                height: splashNativeLogoWidth / splashLogoAspect,
              );
              return AnimatedBuilder(
                animation: _logoTravel,
                builder: (context, child) {
                  final target = _logoTarget;
                  final rect = target == null
                      ? native
                      : Rect.lerp(native, target, _logoTravel.value)!;
                  return Stack(children: [
                    Positioned.fromRect(rect: rect, child: child!),
                  ]);
                },
                child: const SplashLogoImage(),
              );
            },
          ),
        ),
      );

  Widget _content(AppLocalizations t, SplashScreenState state,
      BoxConstraints constraints) {
    final short = constraints.maxHeight < 640;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28, vertical: short ? 16 : 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Flexible spacers rather than fixed offsets, so the logo sits
          // around 38% of the usable height on any screen.
          Spacer(flex: short ? 2 : 3),
          SplashBrandContent(
            compact: short,
            logoKey: _logoKey,
            showLogo: _handoffDone,
            textOpacity: _textFade,
          ),
          const Spacer(flex: 3),
          FadeTransition(opacity: _textFade, child: _statusPanel(t, state)),
          SizedBox(height: short ? 8 : 20),
        ],
      ),
    );
  }

  Widget _statusPanel(AppLocalizations t, SplashScreenState state) {
    switch (state.stage) {
      case SplashStage.updateRequired:
        final url = state.result?.version.safeStoreUrl;
        return SplashMessagePanel(
          title: t.splashUpdateRequiredTitle,
          message: t.splashUpdateRequiredMessage,
          primaryLabel: url == null ? null : t.splashUpdateApp,
          onPrimary: url == null ? null : () => _openStore(t, url),
        );

      case SplashStage.maintenance:
        final maintenance = state.result?.maintenance;
        return SplashMessagePanel(
          // The server's own words when it has them, the app's localized
          // fallback when it does not.
          title: maintenance?.title ?? t.splashMaintenanceTitle,
          message: maintenance?.message ?? t.splashMaintenanceMessage,
          primaryLabel: t.splashTryAgain,
          onPrimary: () =>
              ref.read(splashControllerProvider.notifier).retry(),
          secondaryLabel: (state.result?.offlineEligible ?? false)
              ? t.splashContinueOffline
              : null,
          onSecondary: () => ref
              .read(splashControllerProvider.notifier)
              .continueOffline(),
        );

      case SplashStage.recoverableError:
      case SplashStage.fatalError:
        return SplashMessagePanel(
          title: t.splashStartupFailed,
          message: t.splashCheckConnection,
          primaryLabel: t.splashTryAgain,
          busy: state.retrying,
          onPrimary: () =>
              ref.read(splashControllerProvider.notifier).retry(),
          // Offered only when bootstrap said there is genuinely something
          // cached to go back to.
          secondaryLabel: (state.result?.offlineEligible ?? false)
              ? t.splashContinueOffline
              : null,
          onSecondary: () => ref
              .read(splashControllerProvider.notifier)
              .continueOffline(),
        );

      default:
        return SplashLoadingIndicator(
          message: state.slow ? t.splashStillPreparing : t.splashPreparing,
        );
    }
  }

  Future<void> _openStore(AppLocalizations t, String url) async {
    final uri = Uri.tryParse(url);
    var opened = false;
    if (uri != null) {
      try {
        opened =
            await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        opened = false;
      }
    }
    if (!opened && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.splashGenericError)));
    }
  }
}
