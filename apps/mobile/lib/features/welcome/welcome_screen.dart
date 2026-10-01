import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/locale_prefs.dart';
import '../../l10n/app_localizations.dart';
import '../notifications/notification_primer_prefs.dart';
import 'welcome_controller.dart';
import 'welcome_state.dart';
import 'welcome_widgets.dart';

/// Welcome (owner spec + design 50).
///
/// Shown once, after onboarding and before authentication, to offer two
/// ways in. It is not a gate: choosing guest grants nothing, because
/// every protected surface still asks the server.
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Once only: the entrance must not replay every time an action
    // changes the state.
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _entrance.value = 1;
    } else {
      _entrance.forward();
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final state = ref.watch(welcomeControllerProvider);
    final language = languageFor(ref.watch(appLocaleProvider));

    return Scaffold(
      backgroundColor: warmWhite,
      // No back button and no bottom navigation: this is an entry point,
      // and there is nothing behind it worth returning to.
      body: LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxHeight;
          final short = height < 680;
          // The panel takes what it needs; the hero takes the rest, within
          // the range the design allows.
          final heroHeight = height * (short ? 0.5 : 0.58);

          return Stack(
            // Expand explicitly: with the hero as a non-positioned child
            // the Stack sized itself to the hero, so Positioned.fill
            // filled only the top half and the panel overflowed the rest.
            fit: StackFit.expand,
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _entrance,
                  child: WelcomeHero(height: heroHeight + 40),
                ),
              ),
              Positioned.fill(
                child: SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const WelcomeBrandLogo(),
                            const Spacer(),
                            // Flexible: at large text sizes the pill grows
                            // and would otherwise overflow the row.
                            Flexible(
                              child: WelcomeLanguageButton(
                                language: language,
                                onPressed: () => _chooseLanguage(language),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      _panel(t, state, constraints, short),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _panel(
    AppLocalizations t,
    WelcomeState state,
    BoxConstraints constraints,
    bool short,
  ) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final slide = Tween<Offset>(
      begin: reduceMotion ? Offset.zero : const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic));

    return SlideTransition(
      position: slide,
      child: FadeTransition(
        opacity: _entrance,
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: warmWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Color(0x1A102454),
                blurRadius: 24,
                offset: Offset(0, -6),
              ),
            ],
          ),
          // Bounded and scrollable: large text, a long translation or a
          // short device must never push the buttons out of reach.
          constraints: BoxConstraints(
            maxHeight: constraints.maxHeight * (short ? 0.72 : 0.62),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              24,
              short ? 20 : 28,
              24,
              short ? 16 : 24,
            ),
            child: Center(
              child: ConstrainedBox(
                // Kept to a readable measure on a tablet rather than
                // stretching the buttons across the whole width.
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      t.welcomeEyebrow,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        color: softGold,
                      ),
                    ),
                    SizedBox(height: short ? 8 : 10),
                    Text(
                      t.welcomeTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: short ? 24 : 27,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                        color: deepNavy,
                      ),
                    ),
                    SizedBox(height: short ? 8 : 12),
                    Text(
                      t.welcomeDescription,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.55,
                        color: supportingText,
                      ),
                    ),
                    SizedBox(height: short ? 18 : 26),
                    if (state.errorMessage != null) ...[
                      WelcomeErrorMessage(
                        message: state.errorMessage == 'language_failed'
                            ? t.welcomeLanguageFailure
                            : t.welcomeGuestFailure,
                        onRetry: _continueAsGuest,
                      ),
                      const SizedBox(height: 14),
                    ],
                    WelcomeActionButton(
                      label: t.welcomeAccountAction,
                      loading:
                          state.accountAction == WelcomeActionStatus.loading,
                      enabled: !state.busy,
                      onPressed: _beginAccountJourney,
                    ),
                    const SizedBox(height: 12),
                    WelcomeActionButton(
                      label: t.welcomeGuestAction,
                      outlined: true,
                      loading: state.guestAction == WelcomeActionStatus.loading,
                      enabled: !state.busy,
                      onPressed: _continueAsGuest,
                    ),
                    SizedBox(height: short ? 14 : 18),
                    WelcomeLegalAgreement(
                      onTerms: () => context.push('/legal/terms'),
                      onPrivacy: () => context.push('/legal/privacy'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- actions --------------------------------------------------------

  Future<void> _beginAccountJourney() async {
    final controller = ref.read(welcomeControllerProvider.notifier);
    if (!controller.beginAccountJourney()) return;
    // Push, not replace: authentication can be abandoned, and the reader
    // should come back here rather than into a half-chosen state.
    await context.push('/login');
    if (mounted) controller.finishAccountJourney();
  }

  Future<void> _continueAsGuest() async {
    final controller = ref.read(welcomeControllerProvider.notifier);
    final ok = await controller.continueAsGuest();
    if (!mounted || !ok) return;
    // The notification primer sits here, at the end of the first run —
    // after the reader has seen what the app is for, and only if they
    // have not already answered it.
    final askAboutNotifications =
        await ref.read(notificationPrimerPrefsProvider).shouldShow();
    if (!mounted) return;
    // Replace, so the welcome cannot be reached again with back.
    context.go(askAboutNotifications ? '/notification-permission' : '/home');
  }

  Future<void> _chooseLanguage(AppLanguage current) async {
    final chosen = await LanguageSelectionSheet.show(
      context,
      selected: current,
    );
    if (chosen == null || !mounted || chosen == current) return;
    await ref.read(welcomeControllerProvider.notifier).chooseLanguage(chosen);
  }
}
