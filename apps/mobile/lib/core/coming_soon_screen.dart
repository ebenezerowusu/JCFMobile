import 'package:flutter/material.dart';
import 'package:jcf_ui/jcf_ui.dart';

import '../l10n/app_localizations.dart';

/// Temporary destination for designed-but-not-yet-built features.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen(
      {super.key, required this.title, this.icon = Icons.auto_awesome});

  final String title;
  final IconData icon;

  static Route<void> route(String title, {IconData icon = Icons.auto_awesome}) {
    return MaterialPageRoute(
        builder: (_) => ComingSoonScreen(title: title, icon: icon));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: JcfColors.skySurface,
      appBar: AppBar(
        backgroundColor: JcfColors.skySurface,
        elevation: 0,
        foregroundColor: JcfColors.inkOnLight,
        title: Text(title,
            style: const TextStyle(
              color: JcfColors.inkOnLight,
              fontFamily: JcfTypography.bodyFamily,
              fontWeight: FontWeight.w800,
            )),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: const Color(0xFFE3EEFF),
                child: Icon(icon, size: 40, color: JcfColors.skyPrimary),
              ),
              const SizedBox(height: 18),
              Text(
                t.comingSoonTitle,
                style: const TextStyle(
                  color: JcfColors.inkOnLight,
                  fontFamily: JcfTypography.bodyFamily,
                  fontSize: 24,
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
    );
  }
}
