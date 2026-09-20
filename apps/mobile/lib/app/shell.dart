import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jcf_ui/jcf_ui.dart';

import '../l10n/app_localizations.dart';

/// Bottom-nav shell (designs 19-31): Home · Learn · Practice · Programs ·
/// More. Give and Profile live under More (Quick Actions, design 29).
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFE3EEFF),
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (i) => navigationShell.goBranch(
          i,
          initialLocation: i == navigationShell.currentIndex,
        ),
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon:
                  const Icon(Icons.home, color: JcfColors.skyPrimary),
              label: t.tabHome),
          NavigationDestination(
              icon: const Icon(Icons.menu_book_outlined),
              selectedIcon:
                  const Icon(Icons.menu_book, color: JcfColors.skyPrimary),
              label: t.tabLearn),
          NavigationDestination(
              icon: const Icon(Icons.spa_outlined),
              selectedIcon: const Icon(Icons.spa, color: JcfColors.skyPrimary),
              label: t.tabPractice),
          NavigationDestination(
              icon: const Icon(Icons.grid_view_outlined),
              selectedIcon: const Icon(Icons.grid_view_rounded,
                  color: JcfColors.skyPrimary),
              label: t.tabPrograms),
          NavigationDestination(
              icon: const Icon(Icons.more_horiz),
              selectedIcon:
                  const Icon(Icons.more_horiz, color: JcfColors.skyPrimary),
              label: t.tabMore),
        ],
      ),
    );
  }
}
