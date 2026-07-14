import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/club/presentation/providers/club_providers.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

/// Task 14 — Statistics tab (Phần 7). Club-wide aggregate counts only: total
/// matches, total racks, total training time, and the most-active / most-wins /
/// most-improved members. "Chỉ tổng hợp. Không AI." A null superlative renders
/// as "—" rather than a guessed name.
class ClubStatsTab extends ConsumerWidget {
  final int clubId;
  const ClubStatsTab({super.key, required this.clubId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final statsAsync = ref.watch(clubStatisticsProvider(clubId));

    return statsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(l10n.get('club_load_error'))),
      data: (s) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _statTile(l10n.get('club_stat_matches'), '${s.totalMatches}',
                Icons.sports_esports),
            _statTile(
                l10n.get('club_stat_racks'), '${s.totalRacks}', Icons.sports),
            _statTile(l10n.get('club_stat_training'),
                _formatDuration(s.totalTrainingTime), Icons.timer),
            const Divider(height: 24),
            _superlativeTile(l10n.get('club_stat_most_active'),
                s.mostActiveMemberName, Icons.local_fire_department),
            _superlativeTile(l10n.get('club_stat_most_wins'),
                s.mostWinsMemberName, Icons.emoji_events),
            _superlativeTile(l10n.get('club_stat_most_improved'),
                s.mostImprovedMemberName, Icons.trending_up),
            if (s.totalMatches == 0)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  l10n.get('club_stat_empty'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
          ],
        );
      },
    );
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  Widget _statTile(String label, String value, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        trailing: Text(value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _superlativeTile(String label, String? name, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: name != null ? Colors.teal : Colors.grey),
        title: Text(label),
        trailing: Text(name ?? '—',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
