import 'package:flutter/material.dart';
import 'package:jcf_ui/jcf_ui.dart';

import '../../l10n/app_localizations.dart';

/// Practice tab — placeholder until the practice domain (design/27) lands.
class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: JcfColors.skySurface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 48,
                  backgroundColor: Color(0xFFDDF3E4),
                  child: Icon(Icons.spa_rounded,
                      size: 46, color: Color(0xFF2E9E5B)),
                ),
                const SizedBox(height: 18),
                Text(
                  t.tabPractice,
                  style: const TextStyle(
                    color: JcfColors.inkOnLight,
                    fontFamily: JcfTypography.bodyFamily,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  t.comingSoonBody,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF54689B),
                    fontFamily: JcfTypography.bodyFamily,
                    fontSize: 16,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
