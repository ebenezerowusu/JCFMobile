import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jcf_ui/jcf_ui.dart';

import '../../l10n/app_localizations.dart';
import '../../core/brand.dart';
import 'auth_widgets.dart';

/// "Your session has expired" (design/17) — shown when the refresh token can
/// no longer be renewed.
class SessionExpiredScreen extends StatelessWidget {
  const SessionExpiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: JcfColors.skySurface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const JcfLogo(size: 130),
              const SizedBox(height: 8),
              const Text(
                'JAN COSMIC\nFOUNDATION',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: JcfColors.inkOnLight,
                  fontFamily: JcfTypography.bodyFamily,
                  fontSize: 18,
                  height: 1.2,
                  letterSpacing: 2.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 30),
              // Clock + shield illustration.
              SizedBox(
                height: 160,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                            color: JcfColors.skyPrimary, width: 10),
                      ),
                      child: const Icon(Icons.access_time_rounded,
                          size: 84, color: JcfColors.skyPrimary),
                    ),
                    Positioned(
                      right: 86,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: JcfColors.skyPrimary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lock_rounded,
                            size: 24, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Text(
                t.sessionExpiredTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: JcfColors.inkOnLight,
                  fontFamily: JcfTypography.bodyFamily,
                  fontSize: 32,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                t.sessionExpiredSub,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF54689B),
                  fontFamily: JcfTypography.bodyFamily,
                  fontSize: 16,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 26),
              AuthPrimaryButton(
                label: t.signInAgain,
                onPressed: () {
                  // Land on Home, then open the sign-in flow above it so a
                  // successful verify unwinds cleanly back to Home.
                  context.go('/home');
                  context.push('/login');
                },
              ),
              const SizedBox(height: 12),
              AuthOutlinedButton(
                label: t.continueAsGuest,
                onPressed: () => context.go('/home'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
