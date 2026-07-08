import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/statistics/presentation/statistics_provider.dart';
import 'package:pool_os/features/statistics/domain/models/statistics.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

class ShotStatisticsWidget extends ConsumerWidget {
  const ShotStatisticsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final asyncValue = ref.watch(shotStatisticsProvider);

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

  Widget _buildContent(BuildContext context, ShotStatistics detail, AppLocalizations l10n) {
    if (detail.totalShots == 0) {
      return _buildEmptyState(context, l10n);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCards(context, detail, l10n),
          const SizedBox(height: 24),
          _buildShotTypeStats(context, detail, l10n),
          const SizedBox(height: 24),
          _buildDifficultyStats(context, detail, l10n),
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
              Icons.gps_fixed,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.get('no_shots_yet'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.get('take_shots_to_see_stats'),
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

  Widget _buildSummaryCards(BuildContext context, ShotStatistics detail, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            detail.totalShots.toString(),
            l10n.get('total_shots'),
            Colors.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            context,
            detail.madeShots.toString(),
            l10n.get('made_shots'),
            Colors.green,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            context,
            detail.missedShots.toString(),
            l10n.get('missed_shots'),
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

  Widget _buildShotTypeStats(BuildContext context, ShotStatistics detail, AppLocalizations l10n) {
    if (detail.byType.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.get('shots_by_type'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: detail.byType.entries.map((entry) {
              final stats = entry.value;
              return ListTile(
                title: Text(entry.key),
                subtitle: LinearProgressIndicator(
                  value: stats.successRate,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(_getSuccessColor(stats.successRate)),
                ),
                trailing: Text(
                  '${(stats.successRate * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getSuccessColor(stats.successRate),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultyStats(BuildContext context, ShotStatistics detail, AppLocalizations l10n) {
    if (detail.byDifficulty.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.get('shots_by_difficulty'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: detail.byDifficulty.entries.map((entry) {
              final stats = entry.value;
              return ListTile(
                title: Text(entry.key),
                subtitle: LinearProgressIndicator(
                  value: stats.successRate,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(_getSuccessColor(stats.successRate)),
                ),
                trailing: Text(
                  '${(stats.successRate * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getSuccessColor(stats.successRate),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Color _getSuccessColor(double rate) {
    if (rate >= 0.7) return Colors.green;
    if (rate >= 0.5) return Colors.amber;
    if (rate >= 0.3) return Colors.orange;
    return Colors.red;
  }
}
