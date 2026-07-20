import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pool_os/features/competition/application/competition_history_query.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

class CompetitionHistoryScreen extends ConsumerWidget {
  const CompetitionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final history = ref.watch(competitionHistoryProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.get('session_history'))),
      body: history.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l10n.get('error_loading_data'))),
        data: (items) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(competitionHistoryProvider),
          child: items.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 160),
                    Icon(Icons.history,
                        size: 48, color: Theme.of(context).colorScheme.outline),
                    const SizedBox(height: 12),
                    Text(l10n.get('no_sessions_yet'),
                        textAlign: TextAlign.center),
                  ],
                )
              : ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 72),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      minVerticalPadding: 14,
                      leading: const CircleAvatar(
                        child: Icon(Icons.sports_score_outlined),
                      ),
                      title: Text(item.opponent ?? l10n.get('match')),
                      subtitle: Text(
                        '${_formatDate(item.session.startedAt)} | '
                        '${item.matchCount} ${l10n.get('matches').toLowerCase()}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push(
                        '/session/history/${item.session.id}',
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  String _formatDate(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/'
      '${value.month.toString().padLeft(2, '0')}/${value.year}';
}
