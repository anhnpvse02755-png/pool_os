import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/statistics/presentation/statistics_provider.dart';
import 'package:pool_os/features/statistics/domain/models/statistics.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

class WinRateDetailWidget extends ConsumerWidget {
  const WinRateDetailWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final asyncValue = ref.watch(winRateDetailProvider);

    return asyncValue.when(
      data: (detail) => _buildContent(context, detail, l10n),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(l10n.get('error_loading_stats')),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WinRateDetail detail, AppLocalizations l10n) {
    if (detail.totalMatches == 0) {
      return _buildEmptyState(context, l10n);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCards(context, detail, l10n),
          const SizedBox(height: 24),
          _buildMatchHistory(context, detail, l10n),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sports_score,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.get('no_matches_yet'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.get('play_matches_to_see_stats'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, WinRateDetail detail, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            detail.totalMatches.toString(),
            l10n.get('total_matches'),
            Colors.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            context,
            detail.wonMatches.toString(),
            l10n.get('wins'),
            Colors.green,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            context,
            detail.lostMatches.toString(),
            l10n.get('losses'),
            Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchHistory(BuildContext context, WinRateDetail detail, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.get('match_history'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ...detail.matchHistory.map((match) => _buildMatchTile(context, match, l10n)),
      ],
    );
  }

  Widget _buildMatchTile(BuildContext context, MatchRecord match, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: match.isWin ? Colors.green.shade100 : Colors.red.shade100,
          child: Icon(
            match.isWin ? Icons.check : Icons.close,
            color: match.isWin ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          match.opponent ?? l10n.get('practice'),
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '${_formatDate(match.date)} • ${match.matchType}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: match.isWin ? Colors.green.shade100 : Colors.red.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            match.score,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: match.isWin ? Colors.green : Colors.red,
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
