import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jcf_ui/jcf_ui.dart';

import '../../l10n/app_localizations.dart';

import 'onboarding_prefs.dart';

/// Welcome (design/2): sunrise hero with the JCF mark, a frosted panel with
/// the invitation, and the three ways in — Begin, Guest, or member Sign In.
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  Future<void> _continueAsGuest(BuildContext context, WidgetRef ref) async {
    await ref.read(onboardingPrefsProvider).markSeen();
    if (context.mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: JcfColors.skySurface,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Sunrise hero (from the design) filling the top two-thirds; the
          // frosted panel overlaps its lower edge like the design comp.
          const Align(
            alignment: Alignment.topCenter,
            child: FractionallySizedBox(
              heightFactor: 0.68,
              widthFactor: 1,
              child: Image(
                image: AssetImage('assets/images/welcome_hero.jpg'),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          // Frosted invitation panel.
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.94),
                        JcfColors.skySurface.withValues(alpha: 0.98),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          t.welcomeHeadline,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: JcfColors.inkOnLight,
                            fontFamily: JcfTypography.bodyFamily,
                            fontSize: 28,
                            height: 1.2,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          t.welcomeSub,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF54689B),
                            fontFamily: JcfTypography.bodyFamily,
                            fontSize: 16,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 22),
                        FilledButton(
                          onPressed: () => context.go('/onboarding'),
                          style: FilledButton.styleFrom(
                            backgroundColor: JcfColors.skyPrimary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              fontFamily: JcfTypography.bodyFamily,
                            ),
                          ),
                          child: Text(t.begin),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () => _continueAsGuest(context, ref),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: JcfColors.skyPrimary,
                            backgroundColor: Colors.white.withValues(alpha: 0.65),
                            minimumSize: const Size.fromHeight(56),
                            side: const BorderSide(
                              color: JcfColors.skyPrimary, width: 1.4,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              fontFamily: JcfTypography.bodyFamily,
                            ),
                          ),
                          child: Text(t.continueAsGuest),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () => context.push('/login'),
                          child: Text.rich(
                            TextSpan(
                              text: '${t.alreadyMemberPrompt}  ',
                              style: const TextStyle(
                                color: Color(0xFF54689B),
                                fontFamily: JcfTypography.bodyFamily,
                                fontSize: 15,
                              ),
                              children: [
                                TextSpan(
                                  text: t.signIn,
                                  style: TextStyle(
                                    color: JcfColors.skyPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
