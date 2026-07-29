// EPIC 02 — Statistics & Analytics — Phase F: trend screen.

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/statistics_analytics_service.dart';
import '../domain/models/trend_aggregations.dart';
import 'widgets/trend_chart.dart';

class TrendScreen extends ConsumerWidget {
  const TrendScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trend = ref.watch(trendSummaryProvider);
    final heatmap = ref.watch(activityHeatmapProvider);
    final bucket = ref.watch(trendBucketProvider);
    final period = ref.watch(analyticsPeriodProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trend analysis'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              children: [
                for (final b in TrendBucket.values)
                  ChoiceChip(
                    label: Text(b.label),
                    selected: bucket == b,
                    onSelected: (_) =>
                        ref.read(trendBucketProvider.notifier).state = b,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Win rate trend',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 200,
                  child: trend.when(
                    data: (snap) => _winRateLine(snap),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Error: $e'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Moving average (7-bucket)',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 160,
                  child: trend.when(
                    data: (snap) => _movingAvgLine(snap),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Error: $e'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Practice frequency',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 160,
                  child: trend.when(
                    data: (snap) => _practiceFreqBar(snap),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Error: $e'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Training trend',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 160,
                  child: trend.when(
                    data: (snap) => _trainingArea(snap),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Error: $e'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Activity heatmap (weekday × hour)',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: heatmap.when(
                  data: (h) => _heatmap(h),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error: $e'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _winRateLine(TrendSummaryExt snap) {
    if (snap.points.isEmpty) {
      return const Center(child: Text('No data yet'));
    }
    final spots = <FlSpot>[
      for (var i = 0; i < snap.points.length; i++)
        FlSpot(i.toDouble(), snap.points[i].winRate),
    ];
    return LineChart(LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.blue,
          barWidth: 3,
          dotData: const FlDotData(show: true),
        ),
      ],
      titlesData: const FlTitlesData(show: false),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
    ));
  }

  Widget _movingAvgLine(TrendSummaryExt snap) {
    if (snap.movingAverage.isEmpty) {
      return const Center(child: Text('No data yet'));
    }
    final spots = <FlSpot>[
      for (var i = 0; i < snap.movingAverage.length; i++)
        FlSpot(i.toDouble(), snap.movingAverage[i]),
    ];
    return LineChart(LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.orange,
          barWidth: 2,
          dotData: const FlDotData(show: false),
        ),
      ],
      titlesData: const FlTitlesData(show: false),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
    ));
  }

  Widget _practiceFreqBar(TrendSummaryExt snap) {
    if (snap.points.isEmpty) {
      return const Center(child: Text('No data yet'));
    }
    final groups = <BarChartGroupData>[
      for (var i = 0; i < snap.points.length; i++)
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: snap.points[i].practiceFrequency,
              width: 6,
              color: Colors.green,
            ),
          ],
        ),
    ];
    return BarChart(BarChartData(
      barGroups: groups,
      titlesData: const FlTitlesData(show: false),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
    ));
  }

  Widget _trainingArea(TrendSummaryExt snap) {
    if (snap.points.isEmpty) {
      return const Center(child: Text('No data yet'));
    }
    final spots = <FlSpot>[
      for (var i = 0; i < snap.points.length; i++)
        FlSpot(i.toDouble(), snap.points[i].trainingCount.toDouble()),
    ];
    return LineChart(LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.purple,
          barWidth: 3,
          belowBarData: BarAreaData(
            show: true,
            color: Colors.purple.withValues(alpha: 0.2),
          ),
          dotData: const FlDotData(show: false),
        ),
      ],
      titlesData: const FlTitlesData(show: false),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
    ));
  }

  Widget _heatmap(ActivityHeatmap h) {
    Color colorFor(int value) {
      if (h.maxCount == 0) return Colors.grey.shade100;
      final t = value / h.maxCount;
      return Color.lerp(Colors.blue.shade50, Colors.blue.shade900, t) ??
          Colors.grey;
    }

    final weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var h2 = 0; h2 < 24; h2 += 2)
                Container(
                  width: 28,
                  alignment: Alignment.center,
                  child: Text(
                    '$h2',
                    style: const TextStyle(fontSize: 9),
                  ),
                ),
            ],
          ),
        ),
        for (var d = 0; d < 7; d++)
          Row(
            children: [
              SizedBox(
                width: 32,
                child:
                    Text(weekdayLabels[d], style: const TextStyle(fontSize: 11)),
              ),
              for (var h2 = 0; h2 < 24; h2++)
                Container(
                  width: 24,
                  height: 18,
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: colorFor(h.cells[d][h2]),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
