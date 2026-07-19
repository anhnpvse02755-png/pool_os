import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/performance/data/performance_snapshot_repository.dart';
import 'package:pool_os/features/performance/domain/performance_snapshot.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

class PerformanceScreen extends ConsumerWidget {
  const PerformanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final snapshot = ref.watch(performanceSnapshotProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.get('performance'))),
      body: snapshot.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l10n.get('error_loading_data'))),
        data: (data) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(performanceSnapshotProvider),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              Text(
                '${data.sourceMatches} ${l10n.get('matches').toLowerCase()} | '
                '${data.sourceRacks} ${l10n.get('rack_count').toLowerCase()} | '
                '${data.sourceShots} ${l10n.get('shot_count').toLowerCase()}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 20),
              for (var index = 0;
                  index < PerformanceDimension.values.length;
                  index++) ...[
                _metric(
                  context,
                  l10n,
                  data.metric(PerformanceDimension.values[index]),
                ),
                if (index < PerformanceDimension.values.length - 1)
                  const Divider(height: 28),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _metric(
    BuildContext context,
    AppLocalizations l10n,
    PerformanceMetric metric,
  ) {
    final score = metric.score;
    final color = _scoreColor(context, score);
    return Semantics(
      label: _label(l10n, metric.dimension),
      value: score == null ? l10n.get('coach_v2_conf_insufficient') : '$score',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _label(l10n, metric.dimension),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                score == null ? '--' : '${score.round()}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score == null ? 0 : score / 100,
              minHeight: 8,
              color: color,
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Text(
                '${l10n.get('performance_sample')}: ${metric.sampleSize}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              Text(
                _confidence(l10n, metric.confidence),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _label(AppLocalizations l10n, PerformanceDimension dimension) {
    return switch (dimension) {
      PerformanceDimension.execution => l10n.get('performance_execution'),
      PerformanceDimension.decision => l10n.get('skill_decision'),
      PerformanceDimension.cueBall => l10n.get('performance_cue_ball'),
      PerformanceDimension.breakShot => l10n.get('skill_break'),
      PerformanceDimension.safety => l10n.get('skill_safety'),
      PerformanceDimension.mental => l10n.get('skill_mental'),
      PerformanceDimension.consistency => l10n.get('skill_consistency'),
    };
  }

  String _confidence(
    AppLocalizations l10n,
    PerformanceConfidence confidence,
  ) {
    return switch (confidence) {
      PerformanceConfidence.high => l10n.get('coach_v2_conf_high'),
      PerformanceConfidence.medium => l10n.get('coach_v2_conf_medium'),
      PerformanceConfidence.low => l10n.get('coach_v2_conf_low'),
      PerformanceConfidence.insufficient =>
        l10n.get('coach_v2_conf_insufficient'),
    };
  }

  Color _scoreColor(BuildContext context, double? score) {
    if (score == null) return Theme.of(context).colorScheme.outline;
    if (score >= 75) return Colors.green;
    if (score >= 55) return Colors.blue;
    return Colors.orange;
  }
}
