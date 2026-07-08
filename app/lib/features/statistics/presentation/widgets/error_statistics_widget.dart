import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/statistics/presentation/statistics_provider.dart';
import 'package:pool_os/features/statistics/domain/models/statistics.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

class ErrorStatisticsWidget extends ConsumerWidget {
  const ErrorStatisticsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final asyncValue = ref.watch(errorStatisticsProvider);

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

  Widget _buildContent(BuildContext context, ErrorStatistics detail, AppLocalizations l10n) {
    if (detail.totalErrors == 0) {
      return _buildEmptyState(context, l10n);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(context, detail, l10n),
          const SizedBox(height: 24),
          _buildErrorCategories(context, detail, l10n),
          const SizedBox(height: 24),
          _buildErrorTimeline(context, detail, l10n),
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
              Icons.check_circle,
              size: 64,
              color: Colors.green.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.get('no_errors_recorded'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.get('great_performance'),
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

  Widget _buildSummaryCard(BuildContext context, ErrorStatistics detail, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber, color: Colors.orange.shade400, size: 32),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.get('total_errors')}: ${detail.totalErrors}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  l10n.get('error_count_description'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCategories(BuildContext context, ErrorStatistics detail, AppLocalizations l10n) {
    if (detail.errorsByType.isEmpty) return const SizedBox.shrink();

    final sortedEntries = detail.errorsByType.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.get('error_by_type'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: sortedEntries.map((entry) {
              final total = detail.totalErrors;
              final percentage = total > 0 ? entry.value / total : 0.0;
              return ListTile(
                leading: _getErrorIcon(entry.key),
                title: Text(_formatErrorType(entry.key)),
                subtitle: LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(_getErrorColor(entry.key)),
                ),
                trailing: Text(
                  '${entry.value}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getErrorColor(entry.key),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorTimeline(BuildContext context, ErrorStatistics detail, AppLocalizations l10n) {
    if (detail.errorHistory.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.get('error_timeline'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ...detail.errorHistory.take(20).map((error) => _buildErrorTile(context, error, l10n)),
      ],
    );
  }

  Widget _buildErrorTile(BuildContext context, ErrorRecord error, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getErrorColor(error.errorType).withAlpha(26),
          child: Icon(
            _getErrorIcon(error.errorType).icon,
            color: _getErrorColor(error.errorType),
            size: 20,
          ),
        ),
        title: Text(_formatErrorType(error.errorType)),
        subtitle: Text(
          '${_formatDate(error.timestamp)} • ${error.category}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: error.severity != null
            ? Chip(
                label: Text(
                  error.severity!,
                  style: const TextStyle(fontSize: 10),
                ),
                backgroundColor: _getSeverityColor(error.severity!).withAlpha(26),
                labelStyle: TextStyle(color: _getSeverityColor(error.severity!)),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )
            : null,
      ),
    );
  }

  Icon _getErrorIcon(String errorType) {
    final type = errorType.toLowerCase();
    if (type.contains('scratch')) return Icon(Icons.water_drop, color: Colors.blue.shade400);
    if (type.contains('miss')) return Icon(Icons.close, color: Colors.red.shade400);
    if (type.contains('position')) return Icon(Icons.location_off, color: Colors.orange.shade400);
    if (type.contains('safety')) return Icon(Icons.security, color: Colors.purple.shade400);
    if (type.contains('kick')) return Icon(Icons.sports_cricket, color: Colors.brown.shade400);
    if (type.contains('jump')) return Icon(Icons.height, color: Colors.teal.shade400);
    return Icon(Icons.error_outline, color: Colors.grey.shade400);
  }

  Color _getErrorColor(String errorType) {
    final type = errorType.toLowerCase();
    if (type.contains('scratch')) return Colors.blue;
    if (type.contains('miss')) return Colors.red;
    if (type.contains('position')) return Colors.orange;
    if (type.contains('safety')) return Colors.purple;
    if (type.contains('kick')) return Colors.brown;
    if (type.contains('jump')) return Colors.teal;
    return Colors.grey;
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
      case 'critical':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.yellow.shade700;
      default:
        return Colors.grey;
    }
  }

  String _formatErrorType(String type) {
    return type.replaceAll('_', ' ').split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
