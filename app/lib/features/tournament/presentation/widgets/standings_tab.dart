import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/tournament/presentation/providers/tournament_providers.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

/// Task 13 — Standings tab (Phần 6). A table of wins, losses, rack differential
/// and points, sorted by the standing calculator. Shows an empty state until at
/// least one fixture is resolved — no fabricated ranking.
class StandingsTab extends ConsumerWidget {
  final int tournamentId;
  const StandingsTab({super.key, required this.tournamentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final standingsAsync = ref.watch(standingsProvider(tournamentId));

    return standingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(l10n.get('tnmt_load_error'))),
      data: (rows) {
        if (rows.isEmpty || rows.every((r) => r.matchesPlayed == 0)) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                l10n.get('tnmt_no_standings'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          );
        }
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(label: Text(l10n.get('tnmt_col_rank'))),
                DataColumn(label: Text(l10n.get('tnmt_col_player'))),
                DataColumn(label: Text(l10n.get('tnmt_col_w')), numeric: true),
                DataColumn(label: Text(l10n.get('tnmt_col_l')), numeric: true),
                DataColumn(
                    label: Text(l10n.get('tnmt_col_rackdiff')), numeric: true),
                DataColumn(label: Text(l10n.get('tnmt_col_pts')), numeric: true),
              ],
              rows: [
                for (var i = 0; i < rows.length; i++)
                  DataRow(cells: [
                    DataCell(Text('${i + 1}')),
                    DataCell(Text(rows[i].participantName)),
                    DataCell(Text('${rows[i].wins}')),
                    DataCell(Text('${rows[i].losses}')),
                    DataCell(Text(rows[i].rackDiff >= 0
                        ? '+${rows[i].rackDiff}'
                        : '${rows[i].rackDiff}')),
                    DataCell(Text('${rows[i].points}',
                        style: const TextStyle(fontWeight: FontWeight.bold))),
                  ]),
              ],
            ),
          ),
        );
      },
    );
  }
}
