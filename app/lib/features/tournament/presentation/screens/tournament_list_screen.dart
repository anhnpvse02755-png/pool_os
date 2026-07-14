import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/tournament/domain/models/tournament_models.dart';
import 'package:pool_os/features/tournament/presentation/providers/tournament_providers.dart';
import 'package:pool_os/features/tournament/presentation/screens/tournament_create_screen.dart';
import 'package:pool_os/features/tournament/presentation/screens/tournament_detail_screen.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

/// Task 13 — Tournament list (Phần 1/9 entry). Shows every tournament newest
/// first with a status chip; tap opens the detail screen, FAB creates a new one.
class TournamentListScreen extends ConsumerWidget {
  const TournamentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final listAsync = ref.watch(tournamentListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.get('tnmt_title')), centerTitle: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreate(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.get('tnmt_new')),
      ),
      body: listAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.get('tnmt_load_error'))),
        data: (tournaments) {
          if (tournaments.isEmpty) return _empty(context, l10n);
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: tournaments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) =>
                _card(context, ref, l10n, tournaments[i]),
          );
        },
      ),
    );
  }

  Widget _empty(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.emoji_events_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(l10n.get('tnmt_empty_title'),
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              l10n.get('tnmt_empty_body'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    Tournament t,
  ) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _statusColor(t.status).withValues(alpha: 0.15),
          child: Icon(Icons.emoji_events, color: _statusColor(t.status)),
        ),
        title: Text(t.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${l10n.get(t.type.labelKey)}'
          '${t.location != null && t.location!.isNotEmpty ? ' • ${t.location}' : ''}',
        ),
        trailing: _statusChip(l10n, t.status),
        onTap: () => _openDetail(context, t.id!),
        onLongPress: () => _confirmDelete(context, ref, l10n, t),
      ),
    );
  }

  Widget _statusChip(AppLocalizations l10n, TournamentStatus status) {
    return Chip(
      label: Text(l10n.get(status.labelKey),
          style: const TextStyle(fontSize: 11, color: Colors.white)),
      backgroundColor: _statusColor(status),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
    );
  }

  Color _statusColor(TournamentStatus status) {
    switch (status) {
      case TournamentStatus.upcoming:
        return Colors.blueGrey;
      case TournamentStatus.active:
        return Colors.green;
      case TournamentStatus.completed:
        return Colors.deepPurple;
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    Tournament t,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.get('tnmt_delete_title')),
        content: Text(l10n.get('tnmt_delete_body')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.get('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.get('delete')),
          ),
        ],
      ),
    );
    if (ok == true && t.id != null) {
      await ref.read(tournamentControllerProvider).delete(t.id!);
    }
  }

  void _openCreate(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TournamentCreateScreen()),
    );
  }

  void _openDetail(BuildContext context, int id) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TournamentDetailScreen(tournamentId: id)),
    );
  }
}
