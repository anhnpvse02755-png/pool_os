import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pool_os/features/dashboard/presentation/dashboard_screen.dart';
import 'package:pool_os/features/home/presentation/home_dashboard_screen.dart';
import 'package:pool_os/features/competition/presentation/coach_review_screen.dart';
import 'package:pool_os/features/competition/presentation/competition_history_screen.dart';
import 'package:pool_os/features/competition/presentation/competition_hub_screen.dart';
import 'package:pool_os/features/equipment/presentation/equipment_screen.dart';
import 'package:pool_os/features/session/presentation/session_screen.dart';
import 'package:pool_os/features/session/presentation/session_summary_screen.dart';
import 'package:pool_os/features/performance/presentation/performance_screen.dart';
import 'package:pool_os/features/statistics/presentation/statistics_screen.dart';
import 'package:pool_os/features/coach/presentation/coach_screen.dart';
import 'package:pool_os/features/settings/presentation/settings_screen.dart';
import 'package:pool_os/features/daily_readiness/presentation/daily_readiness_screen.dart';
import 'package:pool_os/features/match/presentation/match_detail_screen.dart';
import 'package:pool_os/features/player/presentation/player_profile_screen.dart';
import 'package:pool_os/features/endurance/presentation/endurance_screen.dart';
import 'package:pool_os/features/training_center/presentation/screens/training_center_screen.dart';
import 'package:pool_os/features/goal_center/presentation/screens/goal_center_screen.dart';
import 'package:pool_os/features/career/presentation/screens/career_screen.dart';
import 'package:pool_os/features/data_center/presentation/screens/data_center_screen.dart';
import 'package:pool_os/features/tournament/presentation/screens/tournament_list_screen.dart';
import 'package:pool_os/features/club/presentation/screens/club_list_screen.dart';
import 'package:pool_os/features/knowledge/presentation/screens/knowledge_detail_screen.dart';
import 'package:pool_os/features/knowledge/presentation/screens/knowledge_library_screen.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeDashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/session',
              builder: (context, state) => const CompetitionHubScreen(),
              routes: [
                GoRoute(
                  path: 'match',
                  builder: (context, state) => const SessionScreen(),
                ),
                GoRoute(
                  path: 'history',
                  builder: (context, state) => const CompetitionHistoryScreen(),
                ),
                GoRoute(
                  path: 'history/:sessionId',
                  builder: (context, state) => SessionSummaryScreen(
                    sessionId: int.tryParse(
                          state.pathParameters['sessionId'] ?? '',
                        ) ??
                        0,
                  ),
                ),
                GoRoute(
                  path: 'performance',
                  builder: (context, state) => const PerformanceScreen(),
                ),
                GoRoute(
                  path: 'review',
                  builder: (context, state) => const CoachReviewScreen(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/training-center',
              builder: (context, state) => TrainingCenterScreen(
                initialCategory: state.uri.queryParameters['category'],
                initialKnowledgeId: state.uri.queryParameters['knowledgeId'],
              ),
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
      ],
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/statistics',
      builder: (context, state) => const StatisticsScreen(),
    ),
    GoRoute(
      path: '/equipment',
      builder: (context, state) => const EquipmentScreen(),
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
    GoRoute(
      path: '/knowledge',
      builder: (context, state) => const KnowledgeLibraryScreen(),
    ),
    GoRoute(
      path: '/knowledge/:id',
      builder: (context, state) => KnowledgeDetailScreen(
        knowledgeId: state.pathParameters['id'] ?? '',
      ),
    ),
    // Task 10: Goal & Progress Center — goals, achievements, streaks,
    // milestones. Top-level route (pushed from the Dashboard quick action),
    // outside the bottom-nav shell. Read-only over the recording pipeline.
    GoRoute(
      path: '/goal-center',
      builder: (context, state) => const GoalCenterScreen(),
    ),
    // Task 11: Player Timeline & Career — read-only development journal that
    // aggregates events (sessions, matches, goals, achievements, equipment,
    // training) from other features. Top-level route, no new data.
    GoRoute(
      path: '/career',
      builder: (context, state) => const CareerScreen(),
    ),
    // Task 12: Data Center — backup, restore, export, import, database info and
    // maintenance. Manages storage of data without changing its meaning; never
    // touches the LOCKED recording pipeline or Statistics engine logic.
    GoRoute(
      path: '/data-center',
      builder: (context, state) => const DataCenterScreen(),
    ),
    // Task 13: Tournament & League — create competitions, seed brackets, record
    // results and view standings/statistics. A tournament only soft-references
    // recorded Matches (matchId); it never modifies the LOCKED recording
    // pipeline or the Statistics engine.
    GoRoute(
      path: '/tournaments',
      builder: (context, state) => const TournamentListScreen(),
    ),
    // Task 14: Club & Community — clubs, members, internal ranking, leaderboard,
    // club statistics and history. A Match / Training / Tournament belongs to a
    // club only through a soft-ref ClubLink; the LOCKED recording pipeline, the
    // Task 09 training tables and the Task 13 tournament tables are untouched.
    GoRoute(
      path: '/clubs',
      builder: (context, state) => const ClubListScreen(),
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
    (Icons.emoji_events_outlined, Icons.emoji_events),
    (Icons.school_outlined, Icons.school),
    (Icons.psychology_outlined, Icons.psychology),
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
            label: l10n.get('competition'),
          ),
          NavigationDestination(
            icon: Icon(_icons[2].$1),
            selectedIcon: Icon(_icons[2].$2),
            label: l10n.get('kb_learning_hub'),
          ),
          NavigationDestination(
            icon: Icon(_icons[3].$1),
            selectedIcon: Icon(_icons[3].$2),
            label: l10n.get('coach'),
          ),
        ],
      ),
    );
  }
}
