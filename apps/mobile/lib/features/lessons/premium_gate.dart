import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jcf_ui/jcf_ui.dart';

import '../../l10n/app_localizations.dart';
import '../auth/auth_controller.dart';
import '../auth/auth_widgets.dart';

/// Premium-content gate (design/14): the modal card shown when a guest opens
/// a member/student-only teaching. [onSignedIn] runs after a successful
/// sign-in so the caller can refetch the now-unlocked content.
class PremiumGate extends ConsumerWidget {
  const PremiumGate({super.key, required this.onSignedIn});

  final VoidCallback onSignedIn;

  Future<void> _signIn(BuildContext context, WidgetRef ref) async {
    await context.push('/login');
    if (context.mounted && ref.read(isLoggedInProvider)) {
      onSignedIn();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF122B63).withValues(alpha: 0.12),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.close, color: Color(0xFF54689B)),
                ),
              ),
              const CircleAvatar(
                radius: 44,
                backgroundColor: Color(0xFFE3EEFF),
                child: Icon(Icons.lock_rounded,
                    size: 40, color: JcfColors.skyPrimary),
              ),
              const SizedBox(height: 18),
              Text(
                t.memberStudentContent,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: JcfColors.skyPrimary,
                  fontFamily: JcfTypography.bodyFamily,
                  fontSize: 13,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                t.signInToContinue,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: JcfColors.inkOnLight,
                  fontFamily: JcfTypography.bodyFamily,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                t.premiumTeachingSub,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF54689B),
                  fontFamily: JcfTypography.bodyFamily,
                  fontSize: 16,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: () => _signIn(context, ref),
                icon: const Icon(Icons.arrow_forward, size: 20),
                iconAlignment: IconAlignment.end,
                label: Text(t.signIn, overflow: TextOverflow.ellipsis),
                style: FilledButton.styleFrom(
                  backgroundColor: JcfColors.skyPrimary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: JcfTypography.bodyFamily,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              AuthOutlinedButton(
                label: t.returnToPublicTeachings,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
