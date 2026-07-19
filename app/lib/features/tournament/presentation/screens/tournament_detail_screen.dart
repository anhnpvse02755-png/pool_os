import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/tournament/domain/models/tournament_models.dart';
import 'package:pool_os/features/tournament/presentation/providers/tournament_providers.dart';
import 'package:pool_os/features/tournament/presentation/widgets/bracket_view.dart';
import 'package:pool_os/features/tournament/presentation/widgets/participants_tab.dart';
import 'package:pool_os/features/tournament/presentation/widgets/standings_tab.dart';
import 'package:pool_os/features/tournament/presentation/widgets/tournament_stats_tab.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

/// Task 13 — tournament detail (Phần 9 UI). Tabs: Participants, Bracket,
/// Standings, Statistics. History is shown on the list side. The app bar action
/// starts/completes the tournament and re-seeds the bracket.
class TournamentDetailScreen extends ConsumerWidget {
  final int tournamentId;
  const TournamentDetailScreen({super.key, required this.tournamentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tournamentAsync = ref.watch(tournamentProvider(tournamentId));

    return tournamentAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.get('tnmt_load_error'))),
      ),
      data: (tournament) {
        if (tournament == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(l10n.get('tnmt_not_found'))),
          );
        }
        return DefaultTabController(
          length: 4,
          child: Scaffold(
            appBar: AppBar(
              title: Text(tournament.name),
              actions: [
                if (tournament.status == TournamentStatus.active)
                  TextButton.icon(
                    onPressed: () => ref
                        .read(tournamentControllerProvider)
                        .setStatus(tournament.id!, TournamentStatus.completed),
                    icon: const Icon(Icons.flag_outlined),
                    label: Text(l10n.get('tnmt_status_completed')),
                  ),
                _statusButton(context, ref, l10n, tournament),
              ],
              bottom: TabBar(
                isScrollable: true,
                tabs: [
                  Tab(text: l10n.get('tnmt_tab_participants')),
                  Tab(text: l10n.get('tnmt_tab_bracket')),
                  Tab(text: l10n.get('tnmt_tab_standings')),
                  Tab(text: l10n.get('tnmt_tab_stats')),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                ParticipantsTab(
                  tournamentId: tournamentId,
                  competitionMode: tournament.competitionMode,
                ),
                BracketView(tournamentId: tournamentId, type: tournament.type),
                StandingsTab(tournamentId: tournamentId),
                TournamentStatsTab(
                  tournamentId: tournamentId,
                  type: tournament.type,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statusButton(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    Tournament t,
  ) {
    return PopupMenuButton<TournamentStatus>(
      icon: const Icon(Icons.more_vert),
      onSelected: (status) =>
          ref.read(tournamentControllerProvider).setStatus(t.id!, status),
      itemBuilder: (ctx) => [
        for (final s in TournamentStatus.values)
          PopupMenuItem(
            value: s,
            child: Row(
              children: [
                Icon(
                  t.status == s
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(l10n.get(s.labelKey)),
              ],
            ),
          ),
      ],
    );
  }
}
