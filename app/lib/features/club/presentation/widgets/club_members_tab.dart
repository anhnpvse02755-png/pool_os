import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/club/domain/models/club_models.dart';
import 'package:pool_os/features/club/presentation/providers/club_providers.dart';
import 'package:pool_os/features/player/presentation/player_provider.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

/// Task 14 — Members tab (Phần 2). Add a saved Player or an invited guest,
/// change roles, confirm invites, and remove members.
class ClubMembersTab extends ConsumerWidget {
  final int clubId;
  const ClubMembersTab({super.key, required this.clubId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final membersAsync = ref.watch(clubMembersProvider(clubId));

    return membersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(l10n.get('club_load_error'))),
      data: (members) {
        return Column(
          children: [
            Expanded(
              child: members.isEmpty
                  ? Center(
                      child: Text(l10n.get('club_no_members'),
                          style: const TextStyle(color: Colors.grey)),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: members.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) =>
                          _tile(context, ref, l10n, members[i]),
                    ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _addDialog(context, ref, l10n),
                    icon: const Icon(Icons.person_add),
                    label: Text(l10n.get('club_add_member')),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _tile(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    ClubMember m,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor:
            m.role == ClubRole.owner ? Colors.amber : Colors.teal.shade200,
        child: Text(m.name.isNotEmpty ? m.name[0].toUpperCase() : '?'),
      ),
      title: Row(
        children: [
          Flexible(child: Text(m.name, overflow: TextOverflow.ellipsis)),
          if (m.invited) ...[
            const SizedBox(width: 6),
            Chip(
              label: Text(l10n.get('club_invited'),
                  style: const TextStyle(fontSize: 10)),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
            ),
          ],
        ],
      ),
      subtitle: Text(
        '${l10n.get(m.role.labelKey)}'
        '${m.isGuest ? ' • ${l10n.get('club_guest')}' : ''}',
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (action) => _onAction(ref, l10n, m, action),
        itemBuilder: (ctx) => [
          if (m.invited)
            PopupMenuItem(
                value: 'confirm', child: Text(l10n.get('club_confirm_invite'))),
          PopupMenuItem(
              value: 'role_owner', child: Text(l10n.get('club_role_owner'))),
          PopupMenuItem(
              value: 'role_admin', child: Text(l10n.get('club_role_admin'))),
          PopupMenuItem(
              value: 'role_member', child: Text(l10n.get('club_role_member'))),
          PopupMenuItem(value: 'remove', child: Text(l10n.get('remove'))),
        ],
      ),
    );
  }

  void _onAction(
    WidgetRef ref,
    AppLocalizations l10n,
    ClubMember m,
    String action,
  ) {
    final controller = ref.read(clubControllerProvider);
    switch (action) {
      case 'confirm':
        controller.confirmInvite(clubId, m.id!);
      case 'role_owner':
        controller.setRole(clubId, m.id!, ClubRole.owner);
      case 'role_admin':
        controller.setRole(clubId, m.id!, ClubRole.admin);
      case 'role_member':
        controller.setRole(clubId, m.id!, ClubRole.member);
      case 'remove':
        controller.removeMember(clubId, m.id!);
    }
  }

  Future<void> _addDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final players = ref.read(playerNotifierProvider).players;
    final guestCtrl = TextEditingController();
    var invite = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) => Padding(
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
                Text(l10n.get('club_add_member'),
                    style: Theme.of(ctx).textTheme.titleMedium),
                const SizedBox(height: 12),
                if (players.isNotEmpty) ...[
                  Text(l10n.get('club_pick_player'),
                      style: Theme.of(ctx).textTheme.labelLarge),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final pl in players)
                        ActionChip(
                          label: Text(pl.name),
                          onPressed: () {
                            ref.read(clubControllerProvider).addMember(
                                  ClubMember(
                                    clubId: clubId,
                                    playerId: pl.id,
                                    name: pl.name,
                                    joinedAt: DateTime.now(),
                                  ),
                                );
                            Navigator.pop(ctx);
                          },
                        ),
                    ],
                  ),
                  const Divider(height: 24),
                ],
                Text(l10n.get('club_add_guest'),
                    style: Theme.of(ctx).textTheme.labelLarge),
                const SizedBox(height: 4),
                CheckboxListTile(
                  value: invite,
                  onChanged: (v) => setState(() => invite = v ?? false),
                  title: Text(l10n.get('club_as_invite')),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: guestCtrl,
                        decoration: InputDecoration(
                          hintText: l10n.get('club_guest_name'),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () {
                        final name = guestCtrl.text.trim();
                        if (name.isEmpty) return;
                        ref.read(clubControllerProvider).addMember(
                              ClubMember(
                                clubId: clubId,
                                name: name,
                                invited: invite,
                                joinedAt: DateTime.now(),
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
          ),
        );
      },
    );
  }
}
