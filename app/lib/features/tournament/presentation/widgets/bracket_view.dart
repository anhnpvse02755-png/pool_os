import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/tournament/domain/formats/tournament_format.dart';
import 'package:pool_os/features/tournament/domain/models/tournament_models.dart';
import 'package:pool_os/features/tournament/presentation/providers/tournament_providers.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

/// Task 13 — Bracket tab (Phần 4/5). Elimination formats render round-by-round
/// columns; round robin / league render a flat fixture list. Tapping a ready
/// fixture opens a dialog to record the winner (and optional rack score), which
/// auto-advances the winner for elimination brackets.
class BracketView extends ConsumerWidget {
  final int tournamentId;
  final TournamentType type;
  const BracketView(
      {super.key, required this.tournamentId, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final matchesAsync = ref.watch(matchesProvider(tournamentId));
    final participantsAsync = ref.watch(participantsProvider(tournamentId));

    return matchesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(l10n.get('tnmt_load_error'))),
      data: (matches) {
        if (matches.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                l10n.get('tnmt_no_bracket'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          );
        }
        final names = <int, String>{
          for (final p in participantsAsync.asData?.value ?? const [])
            if (p.id != null) p.id!: p.name,
        };
        final isElimination = type == TournamentType.singleElimination ||
            type == TournamentType.doubleElimination;
        return Column(
          children: [
            _capabilityBanner(context, l10n),
            Expanded(
              child: isElimination
                  ? _eliminationView(context, ref, l10n, matches, names)
                  : _listView(context, ref, l10n, matches, names),
            ),
          ],
        );
      },
    );
  }

  /// EPIC 04 Phase 2.4 — capability banner. Surfaces a friendly "planned"
  /// hint for formats whose generator is not implemented in Beta (PO
  /// 2026-07-31 — capability pattern, no exception).
  Widget _capabilityBanner(BuildContext context, AppLocalizations l10n) {
    final cap = tournamentFormatFor(type).capability;
    if (cap.implemented) return const SizedBox.shrink();
    final color = cap.supported ? Colors.amber : Colors.grey;
    return Material(
      color: color.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${l10n.get('tnmt_format_capability_hint')}'
                ' — code: ${cap.code}',
                style: TextStyle(color: color, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _eliminationView(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    List<TournamentMatch> matches,
    Map<int, String> names,
  ) {
    final rounds = <int, List<TournamentMatch>>{};
    for (final m in matches.where((m) => m.bracketGroup == 'M')) {
      rounds.putIfAbsent(m.roundIndex, () => []).add(m);
    }
    final roundKeys = rounds.keys.toList()..sort();
    final thirdPlace = matches.where((m) => m.bracketGroup == 'P').toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final r in roundKeys)
            SizedBox(
              width: 220,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      _roundName(l10n, r, roundKeys.length),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...(rounds[r]!
                        ..sort((a, b) => a.slotIndex.compareTo(b.slotIndex)))
                      .map((m) => _fixtureCard(context, ref, l10n, m, names)),
                ],
              ),
            ),
          if (thirdPlace.isNotEmpty)
            SizedBox(
              width: 220,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      l10n.get('tnmt_third_place'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...thirdPlace.map(
                    (m) => _fixtureCard(context, ref, l10n, m, names),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _listView(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    List<TournamentMatch> matches,
    Map<int, String> names,
  ) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: matches
          .map((m) => _fixtureCard(context, ref, l10n, m, names))
          .toList(),
    );
  }

  Widget _fixtureCard(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    TournamentMatch m,
    Map<int, String> names,
  ) {
    final aName = m.participantAId != null
        ? (names[m.participantAId] ?? '?')
        : l10n.get('tnmt_tbd');
    final bName = m.participantBId != null
        ? (names[m.participantBId] ?? '?')
        : l10n.get('tnmt_tbd');
    final aWon = m.winnerParticipantId != null &&
        m.winnerParticipantId == m.participantAId;
    final bWon = m.winnerParticipantId != null &&
        m.winnerParticipantId == m.participantBId;

    return Card(
      margin: const EdgeInsets.all(6),
      child: InkWell(
        onTap: m.isReady && !m.isResolved
            ? () => _recordDialog(context, ref, l10n, m, aName, bName)
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _side(aName, aWon, m.scoreA),
              const Divider(height: 8),
              _side(bName, bWon, m.scoreB),
              if (m.isReady && !m.isResolved)
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(l10n.get('tnmt_tap_to_record'),
                      style: const TextStyle(fontSize: 10, color: Colors.blue)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _side(String name, bool won, int? score) {
    return Row(
      children: [
        Expanded(
          child: Text(
            name,
            style: TextStyle(
              fontWeight: won ? FontWeight.bold : FontWeight.normal,
              color: won ? Colors.green : null,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (score != null)
          Text('$score', style: const TextStyle(fontWeight: FontWeight.bold)),
        if (won)
          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Icon(Icons.check_circle, size: 16, color: Colors.green),
          ),
      ],
    );
  }

  String _roundName(AppLocalizations l10n, int round, int total) {
    final fromEnd = total - round;
    if (fromEnd == 1) return l10n.get('tnmt_round_final');
    if (fromEnd == 2) return l10n.get('tnmt_round_semi');
    if (fromEnd == 3) return l10n.get('tnmt_round_quarter');
    return '${l10n.get('tnmt_round')} ${round + 1}';
  }

  Future<void> _recordDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    TournamentMatch m,
    String aName,
    String bName,
  ) async {
    final scoreACtrl = TextEditingController();
    final scoreBCtrl = TextEditingController();
    int? winner;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(l10n.get('tnmt_record_result')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<int>(
                value: m.participantAId!,
                groupValue: winner,
                onChanged: (v) => setState(() => winner = v),
                title: Text(aName),
                contentPadding: EdgeInsets.zero,
              ),
              RadioListTile<int>(
                value: m.participantBId!,
                groupValue: winner,
                onChanged: (v) => setState(() => winner = v),
                title: Text(bName),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: scoreACtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          labelText: '$aName ${l10n.get('tnmt_racks')}'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: scoreBCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          labelText: '$bName ${l10n.get('tnmt_racks')}'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.get('cancel')),
            ),
            FilledButton(
              onPressed: winner == null
                  ? null
                  : () async {
                      await ref.read(tournamentControllerProvider).recordResult(
                            tournamentId: tournamentId,
                            fixtureId: m.id!,
                            winnerParticipantId: winner!,
                            scoreA: int.tryParse(scoreACtrl.text.trim()),
                            scoreB: int.tryParse(scoreBCtrl.text.trim()),
                          );
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
              child: Text(l10n.get('save')),
            ),
          ],
        ),
      ),
    );
  }
}
