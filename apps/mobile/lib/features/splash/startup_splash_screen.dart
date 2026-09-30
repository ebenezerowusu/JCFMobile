import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jcf_ui/jcf_ui.dart';
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

class _StartupSplashScreenState
    extends ConsumerState<StartupSplashScreen> {
  bool _navigated = false;

  void _maybeNavigate(SplashScreenState state) {
    final result = state.result;
    if (_navigated || result == null || !result.canProceed) return;
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
      backgroundColor: JcfColors.cosmicDeep,
      body: SplashBackground(
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
    );
  }

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
          SplashBrandContent(compact: short),
          const Spacer(flex: 3),
          _statusPanel(t, state),
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
