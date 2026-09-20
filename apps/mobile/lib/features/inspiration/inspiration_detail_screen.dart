import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:jcf_ui/jcf_ui.dart';

import '../../l10n/app_localizations.dart';
import '../../core/brand.dart';
import '../auth/auth_widgets.dart';
import 'inspiration_repository.dart';
import 'share_inspiration_screen.dart';

/// Daily Inspiration page (design/22): dated quote card with reflection,
/// share action and the related-teaching link.
class InspirationDetailScreen extends StatelessWidget {
  const InspirationDetailScreen({super.key, required this.inspiration});

  final Inspiration inspiration;

  void _share(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ShareInspirationScreen(inspiration: inspiration),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final date = DateFormat.yMMMMd(locale).format(inspiration.date);

    return Scaffold(
      backgroundColor: JcfColors.skySurface,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFBBD4FF), Color(0xFFEAF2FD)],
            stops: [0.0, 0.45],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back,
                          color: JcfColors.inkOnLight),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            t.dailyInspiration,
                            style: const TextStyle(
                              color: JcfColors.inkOnLight,
                              fontFamily: JcfTypography.bodyFamily,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            date,
                            style: const TextStyle(
                              color: Color(0xFF54689B),
                              fontFamily: JcfTypography.bodyFamily,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _share(context),
                      icon: const Icon(Icons.share_rounded,
                          color: JcfColors.skyPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const JcfLogo(size: 170),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF122B63).withValues(alpha: 0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(Icons.format_quote_rounded,
                            size: 40, color: JcfColors.skyPrimary),
                      ),
                      Text(
                        '“${inspiration.quote}”',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: JcfColors.inkOnLight,
                          fontFamily: JcfTypography.bodyFamily,
                          fontSize: 24,
                          height: 1.3,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '— ${inspiration.author}',
                        style: const TextStyle(
                          color: JcfColors.skyPrimary,
                          fontFamily: JcfTypography.bodyFamily,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (inspiration.reflection.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Divider(color: Color(0xFFD3DDF0)),
                        ),
                        Text(
                          inspiration.reflection,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF54689B),
                            fontFamily: JcfTypography.bodyFamily,
                            fontSize: 16.5,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                AuthPrimaryButton(
                  label: t.shareLabel,
                  onPressed: () => _share(context),
                ),
                if (inspiration.relatedTeachingSlug != null) ...[
                  const SizedBox(height: 12),
                  AuthOutlinedButton(
                    label: t.exploreRelated,
                    onPressed: () => context
                        .push('/lessons/${inspiration.relatedTeachingSlug}'),
                  ),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
