import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/club/presentation/providers/club_providers.dart';
import 'package:pool_os/features/club/presentation/widgets/club_members_tab.dart';
import 'package:pool_os/features/club/presentation/widgets/club_ranking_tab.dart';
import 'package:pool_os/features/club/presentation/widgets/club_leaderboard_tab.dart';
import 'package:pool_os/features/club/presentation/widgets/club_stats_tab.dart';
import 'package:pool_os/features/club/presentation/widgets/club_history_tab.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

/// Task 14 — club detail (Phần 9 UI). Tabs follow the doc flow: Members →
/// Ranking → Leaderboard → Statistics → History. Ranking (Phần 3) and
/// Leaderboard (Phần 8) are split into two tabs since the leaderboard is
/// period-scoped. No AI, no chat.
class ClubDetailScreen extends ConsumerWidget {
  final int clubId;
  const ClubDetailScreen({super.key, required this.clubId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final clubAsync = ref.watch(clubProvider(clubId));

    return clubAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.get('club_load_error'))),
      ),
      data: (club) {
        if (club == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(l10n.get('club_not_found'))),
          );
        }
        return DefaultTabController(
          length: 5,
          child: Scaffold(
            appBar: AppBar(
              title: Text(club.name),
              bottom: TabBar(
                isScrollable: true,
                tabs: [
                  Tab(text: l10n.get('club_tab_members')),
                  Tab(text: l10n.get('club_tab_ranking')),
                  Tab(text: l10n.get('club_tab_leaderboard')),
                  Tab(text: l10n.get('club_tab_stats')),
                  Tab(text: l10n.get('club_tab_history')),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                ClubMembersTab(clubId: clubId),
                ClubRankingTab(clubId: clubId),
                ClubLeaderboardTab(clubId: clubId),
                ClubStatsTab(clubId: clubId),
                ClubHistoryTab(clubId: clubId),
              ],
            ),
          ),
        );
      },
    );
  }
}
