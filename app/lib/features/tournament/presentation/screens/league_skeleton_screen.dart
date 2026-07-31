// EPIC 04 Phase 2.5 — League skeleton.
//
// PO 2026-07-31: skeleton only. NO Fixture Generator, NO League Scheduler.
// This screen filters the existing tournament list by [TournamentType.league]
// and shows them. Tapping opens the existing detail screen; the engine will
// return NotAvailable for any action that requires Round Robin generation
// (capability-driven UI per Phase 1.10).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/tournament/domain/formats/tournament_format.dart';
import 'package:pool_os/features/tournament/domain/models/tournament_models.dart';
import 'package:pool_os/features/tournament/presentation/providers/tournament_providers.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

class LeagueSkeletonScreen extends ConsumerWidget {
  const LeagueSkeletonScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final all = ref.watch(tournamentListProvider);
    final cap = tournamentFormatFor(TournamentType.league).capability;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.get('tnmt_league_title'))),
      body: Column(
        children: [
          if (!cap.implemented) _plannedBanner(context, l10n, cap.code),
          Expanded(
            child: all.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text(l10n.get('tnmt_load_error'))),
              data: (tournaments) {
                final leagues = tournaments
                    .where((t) => t.type == TournamentType.league)
                    .toList();
                if (leagues.isEmpty) {
                  return Center(
                    child: Text(l10n.get('tnmt_league_empty')),
                  );
                }
                return ListView.separated(
                  itemCount: leagues.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final t = leagues[i];
                    return ListTile(
                      title: Text(t.name),
                      subtitle: Text(t.status.labelKey),
                      trailing: const Icon(Icons.lock_outline),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _plannedBanner(
      BuildContext context, AppLocalizations l10n, String code) {
    return Material(
      color: Colors.amber.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.handshake_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${l10n.get('tnmt_league_skeleton_hint')} — code: $code',
              ),
            ),
          ],
        ),
      ),
    );
  }
}