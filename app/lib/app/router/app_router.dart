import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pool_os/features/dashboard/presentation/dashboard_screen.dart';
import 'package:pool_os/features/equipment/presentation/equipment_screen.dart';
import 'package:pool_os/features/session/presentation/session_screen.dart';
import 'package:pool_os/features/statistics/presentation/statistics_screen.dart';
import 'package:pool_os/features/coach/presentation/coach_screen.dart';
import 'package:pool_os/features/settings/presentation/settings_screen.dart';
import 'package:pool_os/features/daily_readiness/presentation/daily_readiness_screen.dart';
import 'package:pool_os/features/match/presentation/match_detail_screen.dart';
import 'package:pool_os/features/player/presentation/player_profile_screen.dart';
import 'package:pool_os/features/endurance/presentation/endurance_screen.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/session',
              builder: (context, state) => const SessionScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/equipment',
              builder: (context, state) => const EquipmentScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/coach',
              builder: (context, state) => const CoachScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/statistics',
              builder: (context, state) => const StatisticsScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    // Task 05: the career profile (player identity, equipment in use,
    // achievements, timeline). Reached from Settings / Dashboard.
    GoRoute(
      path: '/profile',
      builder: (context, state) => const PlayerProfileScreen(),
    ),
    GoRoute(
      path: '/readiness',
      builder: (context, state) => const DailyReadinessScreen(),
    ),
    // Task 08: Player Endurance Intelligence — the learned stamina profile
    // (endurance score, decline onset, cause, race recommendation, curve).
    // Reached from the Player screen's insight card.
    GoRoute(
      path: '/endurance',
      builder: (context, state) => const EnduranceScreen(),
    ),
    // RFC-302 Task 7: Dashboard's recent-match tap navigates here
    // (context.go('/match/:id')). Route was missing -> GoException "no routes
    // for location". matchId is parsed with a safe fallback so a malformed id
    // cannot crash navigation.
    GoRoute(
      path: '/match/:id',
      builder: (context, state) {
        final matchId = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        return MatchDetailScreen(matchId: matchId);
      },
    ),
  ],
);

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  static const _icons = [
    (Icons.dashboard_outlined, Icons.dashboard),
    (Icons.sports_bar_outlined, Icons.sports_bar),
    (Icons.sports_esports_outlined, Icons.sports_esports),
    (Icons.psychology_outlined, Icons.psychology),
    (Icons.bar_chart_outlined, Icons.bar_chart),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _goBranch,
        destinations: [
          NavigationDestination(
            icon: Icon(_icons[0].$1),
            selectedIcon: Icon(_icons[0].$2),
            label: l10n.get('dashboard'),
          ),
          NavigationDestination(
            icon: Icon(_icons[1].$1),
            selectedIcon: Icon(_icons[1].$2),
            label: l10n.get('session'),
          ),
          NavigationDestination(
            icon: Icon(_icons[2].$1),
            selectedIcon: Icon(_icons[2].$2),
            label: l10n.get('equipment'),
          ),
          NavigationDestination(
            icon: Icon(_icons[3].$1),
            selectedIcon: Icon(_icons[3].$2),
            label: l10n.get('coach'),
          ),
          NavigationDestination(
            icon: Icon(_icons[4].$1),
            selectedIcon: Icon(_icons[4].$2),
            label: l10n.get('statistics'),
          ),
        ],
      ),
    );
  }
}
