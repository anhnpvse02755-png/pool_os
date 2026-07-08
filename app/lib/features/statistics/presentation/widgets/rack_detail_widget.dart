import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/statistics/presentation/statistics_provider.dart';
import 'package:pool_os/features/statistics/domain/models/statistics.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

class RackDetailWidget extends ConsumerWidget {
  const RackDetailWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final asyncValue = ref.watch(rackDetailProvider);

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

  Widget _buildContent(BuildContext context, RackDetail detail, AppLocalizations l10n) {
    if (detail.totalRacks == 0) {
      return _buildEmptyState(context, l10n);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCards(context, detail, l10n),
          const SizedBox(height: 24),
          _buildRackHistory(context, detail, l10n),
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
              Icons.grid_view,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.get('no_racks_yet'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.get('play_racks_to_see_stats'),
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

  Widget _buildSummaryCards(BuildContext context, RackDetail detail, AppLocalizations l10n) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                detail.totalRacks.toString(),
                l10n.get('total_racks'),
                Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                context,
                detail.wonRacks.toString(),
                l10n.get('racks_won'),
                Colors.green,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                context,
                detail.lostRacks.toString(),
                l10n.get('racks_lost'),
                Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emoji_events, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  '${l10n.get('win_rate')}: ${(detail.winRate * 100).toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRackHistory(BuildContext context, RackDetail detail, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.get('rack_history'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ...detail.rackHistory.map((rack) => _buildRackTile(context, rack, l10n)),
      ],
    );
  }

  Widget _buildRackTile(BuildContext context, RackRecord rack, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: rack.won ? Colors.green.shade100 : Colors.red.shade100,
                  child: Icon(
                    rack.won ? Icons.check : Icons.close,
                    color: rack.won ? Colors.green : Colors.red,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(rack.date),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      if (rack.confidence != null)
                        Text(
                          '${l10n.get('confidence')}: ${rack.confidence}/10',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${l10n.get('balls_run')}: ${rack.ballsRun}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '${l10n.get('largest_run')}: ${rack.largestRun}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            if (rack.biggestStrength != null || rack.biggestMistake != null) ...[
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              if (rack.biggestStrength != null)
                Row(
                  children: [
                    Icon(Icons.thumb_up, size: 16, color: Colors.green.shade400),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        rack.biggestStrength!,
                        style: TextStyle(fontSize: 12, color: Colors.green.shade700),
                      ),
                    ),
                  ],
                ),
              if (rack.biggestMistake != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.thumb_down, size: 16, color: Colors.red.shade400),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        rack.biggestMistake!,
                        style: TextStyle(fontSize: 12, color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
