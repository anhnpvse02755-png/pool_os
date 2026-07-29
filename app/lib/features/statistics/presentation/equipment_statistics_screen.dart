// EPIC 02 — Statistics & Analytics — Phase 4: equipment statistics
// detail screen.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/statistics_analytics_service.dart';
import '../domain/models/analytics_period.dart';
import '../domain/models/analytics_snapshots.dart';
import 'widgets/trend_chart.dart';

class EquipmentStatisticsScreen extends ConsumerWidget {
  const EquipmentStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(equipmentStatisticsSnapshotProvider);
    final period = ref.watch(analyticsPeriodProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipment statistics'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: PeriodSelector(
                value: period,
                onChanged: (p) =>
                    ref.read(analyticsPeriodProvider.notifier).state = p,
              ),
            ),
          ),
        ],
      ),
      body: stats.when(
        data: (snap) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ranking', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    if (snap.ranked.isEmpty)
                      const ListTile(title: Text('No equipment usage yet')),
                    for (final entry in snap.ranked)
                      ListTile(
                        title: Text('Cue #${entry.equipmentId}'),
                        subtitle: Text(
                            'Usage: ${entry.usageCount}, Score: ${entry.score.toStringAsFixed(2)}'),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('Usage frequency',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TrendBarChart(summary: _usageSummary(snap)),
                ),
              ),
              const SizedBox(height: 16),
              Text('Win rate by equipment',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    for (final e in snap.winRateByEquipment.entries)
                      ListTile(
                        title: Text('Cue #${e.key}'),
                        trailing:
                            Text('${(e.value * 100).toStringAsFixed(0)}%'),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  TrendSummary _usageSummary(EquipmentStatisticsSnapshot snap) {
    final values = snap.usageFrequency.values.toList();
    if (values.isEmpty) return TrendSummary.empty();
    return TrendSummary(
      direction: TrendDirection.flat,
      current: values.reduce((a, b) => a + b) / values.length,
      previous: values.reduce((a, b) => a + b) / values.length,
      delta: 0,
      points: [
        for (var i = 0; i < values.length; i++)
          TrendPoint(
              date: DateTime(0, 1, 1).add(Duration(days: i)),
              value: values[i].toDouble()),
      ],
    );
  }
}
