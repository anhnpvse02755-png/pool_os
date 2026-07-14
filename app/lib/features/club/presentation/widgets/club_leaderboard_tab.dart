import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/club/domain/models/club_models.dart';
import 'package:pool_os/features/club/presentation/providers/club_providers.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

/// Task 14 — Leaderboard tab (Phần 8). Same ranking, but scoped to a period
/// (week / month / year). A segmented control switches the period; the list
/// re-derives from matches within that window.
class ClubLeaderboardTab extends ConsumerStatefulWidget {
  final int clubId;
  const ClubLeaderboardTab({super.key, required this.clubId});

  @override
  ConsumerState<ClubLeaderboardTab> createState() =>
      _ClubLeaderboardTabState();
}

class _ClubLeaderboardTabState extends ConsumerState<ClubLeaderboardTab> {
  LeaderboardPeriod _period = LeaderboardPeriod.week;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rowsAsync = ref.watch(
      clubLeaderboardProvider(LeaderboardArgs(widget.clubId, _period)),
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: SegmentedButton<LeaderboardPeriod>(
            segments: [
              for (final p in LeaderboardPeriod.values)
                ButtonSegment(value: p, label: Text(l10n.get(p.labelKey))),
            ],
            selected: {_period},
            onSelectionChanged: (s) => setState(() => _period = s.first),
          ),
        ),
        Expanded(
          child: rowsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(l10n.get('club_load_error'))),
            data: (rows) {
              final ranked =
                  rows.where((r) => r.matchesPlayed > 0).toList();
              if (ranked.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      l10n.get('club_no_leaderboard'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: ranked.length,
                itemBuilder: (context, i) => _row(context, l10n, ranked[i], i + 1),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _row(
    BuildContext context,
    AppLocalizations l10n,
    ClubRankingRow r,
    int rank,
  ) {
    final medal = rank == 1
        ? Colors.amber
        : rank == 2
            ? Colors.blueGrey
            : rank == 3
                ? Colors.brown
                : null;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: medal ?? Colors.grey.shade300,
          child: Text('$rank',
              style: TextStyle(
                  color: medal != null ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold)),
        ),
        title: Text(r.memberName),
        subtitle: Text(
          '${r.wins}W · ${r.losses}L · ${(r.winRate * 100).toStringAsFixed(0)}%',
        ),
        trailing: Text('${r.clubPoints} ${l10n.get('club_pts_short')}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
