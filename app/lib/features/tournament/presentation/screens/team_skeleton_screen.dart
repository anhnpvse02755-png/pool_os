// EPIC 04 Phase 2.7 — Team skeleton.
//
// PO 2026-07-31: NO Team Statistics, NO Team Match Engine. This screen is a
// UI shell that lists tournaments whose [TournamentCompetitionMode] is team,
// using the existing schema v19 column (no bump). Tapping a row opens the
// existing tournament detail screen. Engine work (team standings, team match
// pipeline) is post-Beta.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/tournament/domain/models/tournament_models.dart';
import 'package:pool_os/features/tournament/presentation/providers/tournament_providers.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

class TeamSkeletonScreen extends ConsumerWidget {
  const TeamSkeletonScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final all = ref.watch(tournamentListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.get('tnmt_team_title'))),
      body: all.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.get('tnmt_load_error'))),
        data: (tournaments) {
          final teamTournaments = tournaments
              .where((t) =>
                  t.competitionMode == TournamentCompetitionMode.team)
              .toList();
          if (teamTournaments.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  l10n.get('tnmt_team_empty'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            );
          }
          return ListView.separated(
            itemCount: teamTournaments.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final t = teamTournaments[i];
              return ListTile(
                leading: const Icon(Icons.groups_outlined),
                title: Text(t.name),
                subtitle: Text('${t.type.labelKey}'
                    ' · ${t.status.labelKey}'),
                trailing: const Icon(Icons.lock_outline),
              );
            },
          );
        },
      ),
    );
  }
}