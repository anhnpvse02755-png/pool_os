// EPIC 02 — Statistics & Analytics — Revision 4.
//
// Performance screen. Renders derived indicators computed by the
// PerformanceCalculator.

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/statistics_analytics_service.dart';
import '../domain/models/performance_snapshots.dart';
import 'widgets/trend_chart.dart';

class StatisticsPerformanceScreen extends ConsumerWidget {
  const StatisticsPerformanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perf = ref.watch(performanceSnapshotProvider);
    final period = ref.watch(analyticsPeriodProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance'),
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
      body: perf.when(
        data: (snap) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: StatisticsMetricTile(
                      label: 'Improvement %',
                      value: _pct(snap.improvementPct),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatisticsMetricTile(
                      label: 'Consistency',
                      value: _pct(snap.consistency),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatisticsMetricTile(
                      label: 'Activity',
                      value: _pct(snap.activity),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: StatisticsMetricTile(
                      label: 'Hot streak',
                      value: snap.hotStreak.toString(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatisticsMetricTile(
                      label: 'Cold streak',
                      value: snap.coldStreak.toString(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatisticsMetricTile(
                      label: 'Sessions/h',
                      value: snap.sessionEfficiency.toStringAsFixed(2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: StatisticsMetricTile(
                      label: 'Practice / total',
                      value: _pct(snap.practiceVsMatchRatio),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Win rate over time',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 200,
                    child: _WinRateLine(points: snap.winRateOverTime),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Equipment effectiveness',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    if (snap.equipmentEffectiveness.isEmpty)
                      const ListTile(title: Text('No equipment data')),
                    for (final e in snap.equipmentEffectiveness)
                      ListTile(
                        title: Text('Cue #${e.equipmentId}'),
                        subtitle: Text('Usage: ${e.usageCount}'),
                        trailing: Text(
                            '${(e.winRate * 100).toStringAsFixed(0)}%'),
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

  String _pct(double v) => '${(v * 100).toStringAsFixed(0)}%';
}

class _WinRateLine extends StatelessWidget {
  const _WinRateLine({required this.points});
  final List<WinRateOverTimePoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const Center(child: Text('No matches yet'));
    }
    final spots = <FlSpot>[
      for (var i = 0; i < points.length; i++)
        FlSpot(i.toDouble(), points[i].winRate),
    ];
    return LineChart(LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Theme.of(context).colorScheme.primary,
          barWidth: 3,
          dotData: const FlDotData(show: true),
        ),
      ],
      titlesData: const FlTitlesData(show: false),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
    ));
  }
}
