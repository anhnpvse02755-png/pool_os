// EPIC 04 Phase 2.2 — Ranking screen (read-only).
//
// Skeleton: aggregates all resolved tournament fixtures into a single ranking
// table. No mutation, no ELO, no AI. Reads the [rankingProvider] which itself
// reads only existing tournament / match / participant tables.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/tournament/domain/ranking.dart';
import 'package:pool_os/features/tournament/presentation/providers/tournament_providers.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

class RankingScreen extends ConsumerWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final rankingAsync = ref.watch(tournamentRankingProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.get('tnmt_tab_ranking'))),
      body: rankingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.get('tnmt_load_error'))),
        data: (rows) {
          if (rows.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.get('tnmt_no_ranking'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            );
          }
          return ListView.separated(
            itemCount: rows.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final r = rows[i];
              return _RankingRow(rank: i + 1, entry: r);
            },
          );
        },
      ),
    );
  }
}

class _RankingRow extends StatelessWidget {
  final int rank;
  final TournamentRankingEntry entry;
  const _RankingRow({required this.rank, required this.entry});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Text('$rank')),
      title: Text(entry.participantName),
      subtitle: Text('W ${entry.wins}  ·  L ${entry.losses}'
          '  ·  MP ${entry.matchesPlayed}'
          '  ·  ${(entry.winRate * 100).toStringAsFixed(0)}%'),
      trailing: const Icon(Icons.lock_outline, size: 16, color: Colors.grey),
    );
  }
}