import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcf_ui/jcf_ui.dart';

import '../../l10n/app_localizations.dart';
import '../../core/brand.dart';
import '../auth/auth_controller.dart';

/// Sign-out confirmation (design/18): logo, warning that a new verification
/// code will be needed, destructive Sign Out vs filled Stay Signed In.
Future<void> showSignOutDialog(BuildContext context, WidgetRef ref) {
  final t = AppLocalizations.of(context)!;
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const JcfLogo(size: 84),
            const SizedBox(height: 16),
            Text(
              t.signOutQuestion,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: JcfColors.inkOnLight,
                fontFamily: JcfTypography.bodyFamily,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              t.signOutWarning,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF54689B),
                fontFamily: JcfTypography.bodyFamily,
                fontSize: 15.5,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 22),
            OutlinedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await ref.read(authControllerProvider.notifier).logout();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFD64545),
                minimumSize: const Size.fromHeight(54),
                side: const BorderSide(color: Color(0xFFD64545), width: 1.6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27)),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: JcfTypography.bodyFamily,
                ),
              ),
              child: Text(t.signOutConfirm),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: JcfColors.skyPrimary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27)),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: JcfTypography.bodyFamily,
                ),
              ),
              child: Text(t.staySignedIn),
            ),
          ],
        ),
      ),
    ),
  );
}
