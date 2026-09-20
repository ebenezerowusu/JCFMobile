import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jcf_ui/jcf_ui.dart';

import '../../l10n/app_localizations.dart';
import '../../core/brand.dart';
import '../../core/coming_soon_screen.dart';
import '../auth/auth_controller.dart';

/// The "More" tab — Quick Actions (design/29).
class QuickActionsScreen extends ConsumerWidget {
  const QuickActionsScreen({super.key});

  void _soon(BuildContext context, String title, IconData icon) {
    Navigator.of(context).push(ComingSoonScreen.route(title, icon: icon));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final loggedIn = ref.watch(isLoggedInProvider);
    final tiles = <_Tile>[
      _Tile(Icons.badge_rounded, const Color(0xFF2E6BF0), t.membershipCardTitle,
          t.membershipCardSub,
          () => _soon(context, t.membershipCardTitle, Icons.badge_rounded)),
      _Tile(Icons.calendar_month_rounded, const Color(0xFFF08A24),
          t.bookConsultation, t.bookConsultationSub,
          () => context.push('/appointments')),
      _Tile(Icons.favorite_rounded, const Color(0xFF2E9E5B), t.giveAction,
          t.giveTileSub, () => context.push('/give')),
      _Tile(Icons.groups_rounded, const Color(0xFF7B5BD6), t.myGroups,
          t.myGroupsTileSub,
          () => _soon(context, t.myGroups, Icons.groups_rounded)),
      _Tile(Icons.explore_rounded, const Color(0xFF122B63), t.guidanceRequest,
          t.guidanceRequestSub,
          () => _soon(context, t.guidanceRequest, Icons.explore_rounded)),
      _Tile(Icons.location_on_rounded, const Color(0xFF19A7CE), t.findCentre,
          t.findCentreSub,
          () => _soon(context, t.findCentre, Icons.location_on_rounded)),
      _Tile(Icons.description_rounded, const Color(0xFFE8B33B),
          t.myRegistrations, t.myRegistrationsSub,
          () => _soon(context, t.myRegistrations, Icons.description_rounded)),
      _Tile(Icons.shopping_cart_rounded, const Color(0xFFE25563), t.shopTitle,
          t.shopSub, () => _soon(context, t.shopTitle,
              Icons.shopping_cart_rounded)),
      _Tile(Icons.download_rounded, const Color(0xFF8A63E8), t.downloadsTitle,
          t.downloadsSub,
          () => _soon(context, t.downloadsTitle, Icons.download_rounded)),
      _Tile(Icons.settings_rounded, const Color(0xFF2EBFA5), t.settingsTitle,
          t.settingsSub,
          () => _soon(context, t.settingsTitle, Icons.settings_rounded)),
    ];

    return Scaffold(
      backgroundColor: JcfColors.skySurface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const JcfLogo(size: 110),
              const SizedBox(height: 14),
              Text(
                t.quickActions,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: JcfColors.inkOnLight,
                  fontFamily: JcfTypography.bodyFamily,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                t.quickActionsSub,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF54689B),
                  fontFamily: JcfTypography.bodyFamily,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.55,
                children: [for (final tile in tiles) _TileCard(tile: tile)],
              ),
              const SizedBox(height: 12),
              if (loggedIn)
                TextButton.icon(
                  onPressed: () => context.push('/profile'),
                  icon: const Icon(Icons.person_rounded,
                      color: JcfColors.skyPrimary),
                  label: Text(
                    AppLocalizations.of(context)!.memberChip,
                    style: const TextStyle(
                      color: JcfColors.skyPrimary,
                      fontFamily: JcfTypography.bodyFamily,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
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

class _Tile {
  const _Tile(this.icon, this.tint, this.title, this.sub, this.onTap);
  final IconData icon;
  final Color tint;
  final String title;
  final String sub;
  final VoidCallback onTap;
}

class _TileCard extends StatelessWidget {
  const _TileCard({required this.tile});
  final _Tile tile;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: tile.onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: tile.tint,
                child: Icon(tile.icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tile.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: JcfColors.inkOnLight,
                        fontFamily: JcfTypography.bodyFamily,
                        fontSize: 15.5,
                        height: 1.15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      tile.sub,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF54689B),
                        fontFamily: JcfTypography.bodyFamily,
                        fontSize: 12.5,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: Color(0xFF9AA7C7), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
