import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jcf_ui/jcf_ui.dart';

import '../../l10n/app_localizations.dart';

import '../../core/brand.dart';
import 'notification_prefs.dart';

/// Stay connected (design/8): notification opt-in with the three reasons.
class StayConnectedScreen extends ConsumerWidget {
  const StayConnectedScreen({super.key});

  Future<void> _choose(
      BuildContext context, WidgetRef ref, {required bool optedIn}) async {
    await ref.read(notificationPrefsProvider).choose(optedIn: optedIn);
    if (context.mounted) context.go('/home');
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
              const SizedBox(height: 16),
              const JcfLogo(size: 88),
              const SizedBox(height: 8),
              const Text(
                'JAN COSMIC FOUNDATION',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: JcfColors.inkOnLight,
                  fontFamily: JcfTypography.bodyFamily,
                  fontSize: 17,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'assets/images/notify_bell.jpg',
                  height: 210,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                t.stayConnected,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: JcfColors.inkOnLight,
                  fontFamily: JcfTypography.bodyFamily,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                t.stayConnectedSub,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF54689B),
                  fontFamily: JcfTypography.bodyFamily,
                  fontSize: 16,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 20),
              _ReasonRow(
                icon: Icons.format_quote_rounded,
                tint: const Color(0xFFF08A24),
                bg: const Color(0xFFFDEED9),
                label: t.dailyInspiration,
              ),
              const SizedBox(height: 10),
              _ReasonRow(
                icon: Icons.self_improvement_rounded,
                tint: const Color(0xFF2E9E5B),
                bg: const Color(0xFFDDF3E4),
                label: t.practiceReminders,
              ),
              const SizedBox(height: 10),
              _ReasonRow(
                icon: Icons.calendar_month_rounded,
                tint: const Color(0xFF7B5BD6),
                bg: const Color(0xFFEAE3FA),
                label: t.programmeUpdates,
              ),
              const SizedBox(height: 22),
              FilledButton(
                onPressed: () => _choose(context, ref, optedIn: true),
                style: FilledButton.styleFrom(
                  backgroundColor: JcfColors.skyPrimary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: JcfTypography.bodyFamily,
                  ),
                ),
                child: Text(t.enableNotifications),
              ),
              TextButton(
                onPressed: () => _choose(context, ref, optedIn: false),
                child: Text(
                  t.notNow,
                  style: TextStyle(
                    color: JcfColors.skyPrimary,
                    fontFamily: JcfTypography.bodyFamily,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReasonRow extends StatelessWidget {
  const _ReasonRow({
    required this.icon,
    required this.tint,
    required this.bg,
    required this.label,
  });

  final IconData icon;
  final Color tint;
  final Color bg;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 22, backgroundColor: bg,
              child: Icon(icon, color: tint, size: 24)),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: JcfColors.inkOnLight,
                fontFamily: JcfTypography.bodyFamily,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF9AA7C7)),
        ],
      ),
    );
  }
}
