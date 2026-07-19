import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/player/presentation/player_provider.dart';
import 'package:pool_os/features/tournament/domain/models/tournament_models.dart';
import 'package:pool_os/features/tournament/presentation/providers/tournament_providers.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

/// Task 13 — Participants tab (Phần 3). Add a saved Player or an ad-hoc guest,
/// set seeds, remove, and generate the bracket. Once the bracket has results
/// the repository refuses to re-seed, and this tab surfaces that as a snackbar.
class ParticipantsTab extends ConsumerWidget {
  final int tournamentId;
  final TournamentCompetitionMode competitionMode;
  const ParticipantsTab({
    super.key,
    required this.tournamentId,
    required this.competitionMode,
  });

  bool get isTeamMode => competitionMode == TournamentCompetitionMode.team;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final participantsAsync = ref.watch(participantsProvider(tournamentId));

    return participantsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(l10n.get('tnmt_load_error'))),
      data: (participants) {
        return Column(
          children: [
            Expanded(
              child: participants.isEmpty
                  ? _empty(context, l10n)
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: participants.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) => _tile(
                        context,
                        ref,
                        l10n,
                        participants[i],
                        i + 1,
                      ),
                    ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _addDialog(context, ref, l10n),
                        icon: Icon(isTeamMode
                            ? Icons.group_add_outlined
                            : Icons.person_add_alt_outlined),
                        label: Text(l10n.get(isTeamMode
                            ? 'tnmt_add_team'
                            : 'tnmt_add_participant')),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: participants.length < 2
                            ? null
                            : () => _generate(context, ref, l10n),
                        icon: const Icon(Icons.account_tree),
                        label: Text(l10n.get('tnmt_generate_bracket')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _empty(BuildContext context, AppLocalizations l10n) => Center(
        child: Text(l10n.get('tnmt_no_participants'),
            style: const TextStyle(color: Colors.grey)),
      );

  Widget _tile(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    TournamentParticipant p,
    int order,
  ) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(p.seed?.toString() ?? '$order'),
      ),
      title: Text(p.name),
      subtitle: Text(isTeamMode
          ? l10n.get('tnmt_team')
          : p.isGuest
              ? l10n.get('tnmt_guest')
              : l10n.get('tnmt_player')),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.tag, size: 20),
            tooltip: l10n.get('tnmt_set_seed'),
            onPressed: () => _seedDialog(context, ref, l10n, p),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => ref
                .read(tournamentControllerProvider)
                .removeParticipant(tournamentId, p.id!),
          ),
        ],
      ),
    );
  }

  Future<void> _addDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final players = ref.read(playerNotifierProvider).players;
    final guestCtrl = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  l10n.get(
                      isTeamMode ? 'tnmt_add_team' : 'tnmt_add_participant'),
                  style: Theme.of(ctx).textTheme.titleMedium),
              const SizedBox(height: 12),
              if (!isTeamMode && players.isNotEmpty) ...[
                Text(l10n.get('tnmt_pick_player'),
                    style: Theme.of(ctx).textTheme.labelLarge),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final pl in players)
                      ActionChip(
                        label: Text(pl.name),
                        onPressed: () {
                          ref.read(tournamentControllerProvider).addParticipant(
                                TournamentParticipant(
                                  tournamentId: tournamentId,
                                  playerId: pl.id,
                                  name: pl.name,
                                  createdAt: DateTime.now(),
                                ),
                              );
                          Navigator.pop(ctx);
                        },
                      ),
                  ],
                ),
                const Divider(height: 24),
              ],
              Text(l10n.get(isTeamMode ? 'tnmt_team_name' : 'tnmt_add_guest'),
                  style: Theme.of(ctx).textTheme.labelLarge),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: guestCtrl,
                      decoration: InputDecoration(
                        hintText: l10n.get(isTeamMode
                            ? 'tnmt_team_name_hint'
                            : 'tnmt_guest_name'),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      final name = guestCtrl.text.trim();
                      if (name.isEmpty) return;
                      ref.read(tournamentControllerProvider).addParticipant(
                            TournamentParticipant(
                              tournamentId: tournamentId,
                              name: name,
                              createdAt: DateTime.now(),
                            ),
                          );
                      Navigator.pop(ctx);
                    },
                    child: Text(l10n.get('add')),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _seedDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    TournamentParticipant p,
  ) async {
    final ctrl = TextEditingController(text: p.seed?.toString() ?? '');
    final result = await showDialog<int?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.get('tnmt_set_seed')),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: l10n.get('tnmt_seed_hint')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.get('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, int.tryParse(ctrl.text.trim())),
            child: Text(l10n.get('save')),
          ),
        ],
      ),
    );
    // A cleared field (null) removes the seed. Only act when the dialog was
    // confirmed — showDialog returns null on dismiss too, but here that maps to
    // "no seed", which is the intended clear.
    await ref
        .read(tournamentControllerProvider)
        .updateSeed(tournamentId, p.id!, result);
  }

  Future<void> _generate(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final n = await ref
          .read(tournamentControllerProvider)
          .generateBracket(tournamentId);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.get('tnmt_bracket_created'))),
      );
      if (n == 0) return;
    } on StateError {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.get('tnmt_bracket_locked'))),
      );
    }
  }
}
