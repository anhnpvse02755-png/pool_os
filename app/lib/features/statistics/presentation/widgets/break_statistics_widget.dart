import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/statistics/presentation/statistics_provider.dart';
import 'package:pool_os/features/statistics/domain/models/statistics.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

class BreakStatisticsWidget extends ConsumerWidget {
  const BreakStatisticsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final asyncValue = ref.watch(breakStatisticsProvider);

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

  Widget _buildContent(BuildContext context, BreakStatistics detail, AppLocalizations l10n) {
    if (detail.totalBreaks == 0) {
      return _buildEmptyState(context, l10n);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCards(context, detail, l10n),
          const SizedBox(height: 24),
          _buildBreakHistory(context, detail, l10n),
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
              Icons.sports_bar,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.get('no_breaks_yet'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.get('play_breaks_to_see_stats'),
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

  Widget _buildSummaryCards(BuildContext context, BreakStatistics detail, AppLocalizations l10n) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                detail.totalBreaks.toString(),
                l10n.get('total_breaks'),
                Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                context,
                detail.successfulBreaks.toString(),
                l10n.get('successful_breaks'),
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                detail.dryBreaks.toString(),
                l10n.get('dry_breaks'),
                Colors.orange,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                context,
                detail.scratches.toString(),
                l10n.get('break_scratches'),
                Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '${(detail.successRate * 100).toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                        ),
                        Text(
                          l10n.get('success_rate'),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey,
                              ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          detail.avgBallsPocketed.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                        ),
                        Text(
                          l10n.get('avg_balls_pocketed'),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
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
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakHistory(BuildContext context, BreakStatistics detail, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.get('break_history'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ...detail.breakHistory.map((brk) => _buildBreakTile(context, brk, l10n)),
      ],
    );
  }

  Widget _buildBreakTile(BuildContext context, BreakRecord brk, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: brk.isSuccess
                  ? Colors.green.shade100
                  : brk.isDryBreak
                      ? Colors.orange.shade100
                      : Colors.red.shade100,
              child: Icon(
                brk.isSuccess
                    ? Icons.check
                    : brk.isDryBreak
                        ? Icons.warning
                        : Icons.close,
                color: brk.isSuccess
                    ? Colors.green
                    : brk.isDryBreak
                        ? Colors.orange
                        : Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(brk.date),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Row(
                    children: [
                      if (brk.isScratch) ...[
                        Icon(Icons.water_drop, size: 14, color: Colors.blue.shade400),
                        const SizedBox(width: 4),
                        Text(
                          l10n.get('scratch'),
                          style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        '${brk.ballsPocketed} ${l10n.get('balls')}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (brk.largestRun != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${l10n.get('run')}: ${brk.largestRun}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: brk.isSuccess
                    ? Colors.green.shade100
                    : brk.isDryBreak
                        ? Colors.orange.shade100
                        : Colors.red.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                brk.isSuccess
                    ? l10n.get('success')
                    : brk.isDryBreak
                        ? l10n.get('dry_break')
                        : l10n.get('miss'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: brk.isSuccess
                      ? Colors.green
                      : brk.isDryBreak
                          ? Colors.orange
                          : Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
