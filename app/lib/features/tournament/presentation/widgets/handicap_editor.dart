// EPIC 04 Phase 2.3 — Handicap UI shell.
//
// Skeleton: lets the user view the per-fixture RacePatch table for a
// tournament. Mutations are NOT in scope for Phase 2 (PO 2026-07-31); the
// widget reads via [TournamentService.createMatchRequest] and shows the
// {playerA, playerB} race-to pair the engine would feed into MatchEngine
// (EPIC 01).
//
// Other policies (NoHandicap, FixedRace, ApaHandicap) show their capability
// flags so the UI can disable the action — PO 2026-07-31 capability pattern.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/tournament/application/tournament_service.dart';
import 'package:pool_os/features/tournament/domain/handicap_policy.dart';
import 'package:pool_os/features/tournament/domain/models/tournament_models.dart';
import 'package:pool_os/features/tournament/presentation/providers/tournament_providers.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

/// Read-only display of the race-to pair for each ready fixture in the
/// tournament. Pure presentational widget — no persistence, no mutation.
class HandicapEditor extends ConsumerWidget {
  final int tournamentId;
  final HandicapPolicy policy;
  final int baseRace;

  const HandicapEditor({
    super.key,
    required this.tournamentId,
    required this.policy,
    this.baseRace = 7,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final service = TournamentService();
    final tournamentAsync = ref.watch(tournamentProvider(tournamentId));
    final matchesAsync = ref.watch(matchesProvider(tournamentId));

    if (!policy.implemented) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.info_outline),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${l10n.get('tnmt_handicap_unavailable')}'
                  ' (${policy.code})',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return tournamentAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(l10n.get('tnmt_load_error'))),
      data: (tournament) => matchesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.get('tnmt_load_error'))),
        data: (matches) {
          if (tournament == null) {
            return Center(child: Text(l10n.get('tnmt_not_found')));
          }
          final ready = matches.where((m) => m.isReady).toList();
          if (ready.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  l10n.get('tnmt_handicap_no_fixtures'),
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            );
          }
          return ListView.separated(
            itemCount: ready.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final fixture = ready[i];
              final req = service.createMatchRequest(
                tournament: tournament,
                fixture: fixture,
                handicapPolicy: policy,
                baseRace: baseRace,
                requestedAt: DateTime.now(),
              );
              return _RaceRow(
                fixture: fixture,
                result: req,
                policyCode: policy.code,
              );
            },
          );
        },
      ),
    );
  }
}

class _RaceRow extends StatelessWidget {
  final TournamentMatch fixture;
  final MatchRequestResult result;
  final String policyCode;

  const _RaceRow({
    required this.fixture,
    required this.result,
    required this.policyCode,
  });

  @override
  Widget build(BuildContext context) {
    if (result.isUnavailable) {
      return ListTile(
        leading: const Icon(Icons.warning_amber),
        title: Text('R${fixture.roundIndex} · S${fixture.slotIndex}'),
        subtitle: Text(result.notAvailable!.reason),
      );
    }
    final req = result.request!;
    return ListTile(
      leading: CircleAvatar(child: Text('${req.racePlayerA}')),
      title: Text('A vs B — race ${req.racePlayerA} / ${req.racePlayerB}'),
      subtitle: Text(
        'round ${fixture.roundIndex}, slot ${fixture.slotIndex}'
        ' · policy $policyCode',
      ),
      trailing: const Icon(Icons.lock_outline, size: 16, color: Colors.grey),
    );
  }
}