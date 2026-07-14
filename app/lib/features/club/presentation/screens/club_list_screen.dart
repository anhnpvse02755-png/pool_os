import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/club/domain/models/club_models.dart';
import 'package:pool_os/features/club/presentation/providers/club_providers.dart';
import 'package:pool_os/features/club/presentation/screens/club_create_screen.dart';
import 'package:pool_os/features/club/presentation/screens/club_detail_screen.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

/// Task 14 — Club list (Phần 1/9 entry). Shows every club newest first; tap
/// opens the detail screen, FAB creates a new one, long-press deletes.
class ClubListScreen extends ConsumerWidget {
  const ClubListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final listAsync = ref.watch(clubListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.get('club_title')), centerTitle: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ClubCreateScreen()),
        ),
        icon: const Icon(Icons.add),
        label: Text(l10n.get('club_new')),
      ),
      body: listAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.get('club_load_error'))),
        data: (clubs) {
          if (clubs.isEmpty) return _empty(context, l10n);
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: clubs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) => _card(context, ref, l10n, clubs[i]),
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
          const Icon(Icons.groups_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(l10n.get('club_empty_title'),
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              l10n.get('club_empty_body'),
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
    Club c,
  ) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.teal.withValues(alpha: 0.15),
          child: const Icon(Icons.groups, color: Colors.teal),
        ),
        title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          [
            if (c.location != null && c.location!.isNotEmpty) c.location!,
            if (c.managerName != null && c.managerName!.isNotEmpty)
              '${l10n.get('club_manager')}: ${c.managerName}',
          ].join(' • '),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ClubDetailScreen(clubId: c.id!)),
        ),
        onLongPress: () => _confirmDelete(context, ref, l10n, c),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    Club c,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.get('club_delete_title')),
        content: Text(l10n.get('club_delete_body')),
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
    if (ok == true && c.id != null) {
      await ref.read(clubControllerProvider).delete(c.id!);
    }
  }
}
