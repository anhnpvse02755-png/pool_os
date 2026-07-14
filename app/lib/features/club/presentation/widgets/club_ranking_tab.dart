import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/club/presentation/providers/club_providers.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

/// Task 14 — Internal ranking tab (Phần 3). A table of matches / wins / win-rate
/// / streak / club points, derived from the club's linked matches. Shows an
/// empty state until at least one linked match has a result — no fabricated
/// ranking.
class ClubRankingTab extends ConsumerWidget {
  final int clubId;
  const ClubRankingTab({super.key, required this.clubId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final rankingAsync = ref.watch(clubRankingProvider(clubId));

    return rankingAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(l10n.get('club_load_error'))),
      data: (rows) {
        if (rows.isEmpty || rows.every((r) => r.matchesPlayed == 0)) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                l10n.get('club_no_ranking'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          );
        }
        return SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(label: Text(l10n.get('club_col_rank'))),
                DataColumn(label: Text(l10n.get('club_col_member'))),
                DataColumn(label: Text(l10n.get('club_col_played')), numeric: true),
                DataColumn(label: Text(l10n.get('club_col_w')), numeric: true),
                DataColumn(label: Text(l10n.get('club_col_winrate')), numeric: true),
                DataColumn(label: Text(l10n.get('club_col_streak')), numeric: true),
                DataColumn(label: Text(l10n.get('club_col_pts')), numeric: true),
              ],
              rows: [
                for (var i = 0; i < rows.length; i++)
                  DataRow(cells: [
                    DataCell(Text('${i + 1}')),
                    DataCell(Text(rows[i].memberName)),
                    DataCell(Text('${rows[i].matchesPlayed}')),
                    DataCell(Text('${rows[i].wins}')),
                    DataCell(Text('${(rows[i].winRate * 100).toStringAsFixed(0)}%')),
                    DataCell(_streakChip(rows[i].currentStreak)),
                    DataCell(Text('${rows[i].clubPoints}',
                        style: const TextStyle(fontWeight: FontWeight.bold))),
                  ]),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _streakChip(int streak) {
    if (streak == 0) return const Text('—');
    final win = streak > 0;
    return Text(
      '${win ? 'W' : 'L'}${streak.abs()}',
      style: TextStyle(
        color: win ? Colors.green : Colors.red,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
