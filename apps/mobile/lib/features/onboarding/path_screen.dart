import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jcf_ui/jcf_ui.dart';

import '../../l10n/app_localizations.dart';

import '../../core/brand.dart';
import '../auth/auth_controller.dart';

/// Path chooser (design/7): continue as a signed-in member/student or a guest.
class PathScreen extends ConsumerWidget {
  const PathScreen({super.key});

  Future<void> _signIn(BuildContext context, WidgetRef ref) async {
    await context.push('/login');
    // Back from the login flow: if the code was verified, continue the
    // designed flow into the notification opt-in.
    if (context.mounted && ref.read(isLoggedInProvider)) {
      context.go('/stay-connected');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              const JcfLogo(size: 120),
              const SizedBox(height: 12),
              const Text(
                'Jan Cosmic Foundation',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: JcfColors.inkOnLight,
                  fontFamily: JcfTypography.bodyFamily,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                t.brandTagline,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF54689B),
                  fontFamily: JcfTypography.bodyFamily,
                  fontSize: 11.5,
                  letterSpacing: 1.6,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 26),
              Text(
                t.howToContinue,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: JcfColors.inkOnLight,
                  fontFamily: JcfTypography.bodyFamily,
                  fontSize: 30,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                t.pathSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF54689B),
                  fontFamily: JcfTypography.bodyFamily,
                  fontSize: 16,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 24),
              _PathCard(
                icon: Icons.badge_rounded,
                iconTint: JcfColors.skyPrimary,
                title: t.memberOrStudent,
                body: t.memberCardBody,
                button: FilledButton.icon(
                  onPressed: () => _signIn(context, ref),
                  icon: const Icon(Icons.arrow_forward, size: 20),
                  iconAlignment: IconAlignment.end,
                  label: Text(t.signIn, overflow: TextOverflow.ellipsis),
                  style: FilledButton.styleFrom(
                    backgroundColor: JcfColors.skyPrimary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      fontFamily: JcfTypography.bodyFamily,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _PathCard(
                icon: Icons.meeting_room_rounded,
                iconTint: const Color(0xFF3F7BFF),
                title: t.guest,
                body: t.guestCardBody,
                button: OutlinedButton.icon(
                  onPressed: () => context.go('/stay-connected'),
                  icon: const Icon(Icons.arrow_forward, size: 20),
                  iconAlignment: IconAlignment.end,
                  label: Text(t.continueAsGuest,
                      overflow: TextOverflow.ellipsis),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: JcfColors.skyPrimary,
                    minimumSize: const Size.fromHeight(54),
                    side: const BorderSide(
                        color: JcfColors.skyPrimary, width: 1.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      fontFamily: JcfTypography.bodyFamily,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                t.otpNote,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF7C8DB5),
                  fontFamily: JcfTypography.bodyFamily,
                  fontSize: 14.5,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _PathCard extends StatelessWidget {
  const _PathCard({
    required this.icon,
    required this.iconTint,
    required this.title,
    required this.body,
    required this.button,
  });

  final IconData icon;
  final Color iconTint;
  final String title;
  final String body;
  final Widget button;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E6BF0).withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3EEFF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, size: 34, color: iconTint),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: JcfColors.inkOnLight,
                        fontFamily: JcfTypography.bodyFamily,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      body,
                      style: const TextStyle(
                        color: Color(0xFF54689B),
                        fontFamily: JcfTypography.bodyFamily,
                        fontSize: 15,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          button,
        ],
      ),
    );
  }
}
