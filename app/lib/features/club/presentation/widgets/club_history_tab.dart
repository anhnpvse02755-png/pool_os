import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/club/domain/models/club_models.dart';
import 'package:pool_os/features/club/presentation/providers/club_providers.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

/// Task 14 — History tab (Phần 4/5/6). Lists what belongs to the club: linked
/// Matches, Training sessions and Tournaments. Each is a soft-ref [ClubLink] the
/// user attaches; removing a link never deletes the source row. A club match /
/// training / tournament is recorded through its own existing pipeline — this
/// tab only shows the membership, honoring "Không sửa Recording Pipeline".
class ClubHistoryTab extends ConsumerWidget {
  final int clubId;
  const ClubHistoryTab({super.key, required this.clubId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final matches = ref.watch(clubLinksProvider(LinksArgs(clubId, ClubLinkKind.match)));
    final trainings =
        ref.watch(clubLinksProvider(LinksArgs(clubId, ClubLinkKind.training)));
    final tournaments =
        ref.watch(clubLinksProvider(LinksArgs(clubId, ClubLinkKind.tournament)));

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _section(context, ref, l10n, l10n.get('club_hist_matches'),
            Icons.sports_esports, ClubLinkKind.match, matches),
        _section(context, ref, l10n, l10n.get('club_hist_trainings'),
            Icons.fitness_center, ClubLinkKind.training, trainings),
        _section(context, ref, l10n, l10n.get('club_hist_tournaments'),
            Icons.emoji_events, ClubLinkKind.tournament, tournaments),
      ],
    );
  }

  Widget _section(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    String title,
    IconData icon,
    ClubLinkKind kind,
    AsyncValue<List<ClubLink>> linksAsync,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Text(title,
                    style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: 8),
            linksAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(8),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Text(l10n.get('club_load_error')),
              data: (links) {
                if (links.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(l10n.get('club_hist_empty'),
                        style: const TextStyle(color: Colors.grey)),
                  );
                }
                return Column(
                  children: [
                    for (final link in links)
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.link, size: 18),
                        title: Text('#${link.refId}'),
                        subtitle: Text(_formatDate(link.createdAt)),
                        trailing: IconButton(
                          icon: const Icon(Icons.link_off, size: 18),
                          tooltip: l10n.get('club_unlink'),
                          onPressed: () => ref
                              .read(clubControllerProvider)
                              .removeLink(clubId, link.id!),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
