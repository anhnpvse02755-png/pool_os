// EPIC 02 — Statistics & Analytics — Phase 4: match statistics
// detail screen.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/statistics_analytics_service.dart';
import 'widgets/trend_chart.dart';

class MatchStatisticsScreen extends ConsumerWidget {
  const MatchStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(matchStatisticsSnapshotProvider);
    final period = ref.watch(analyticsPeriodProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Match statistics'),
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
              Row(
                children: [
                  Expanded(
                    child: StatisticsMetricTile(
                      label: 'Matches',
                      value: snap.totalMatches.toString(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatisticsMetricTile(
                      label: 'Wins',
                      value: snap.wins.toString(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatisticsMetricTile(
                      label: 'Losses',
                      value: snap.losses.toString(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: StatisticsMetricTile(
                      label: 'Win rate',
                      value: '${(snap.winRate * 100).toStringAsFixed(0)}%',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatisticsMetricTile(
                      label: 'Streak',
                      value: snap.currentStreak.toString(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Trend', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TrendDirectionChip(summary: snap.trend),
                      const SizedBox(height: 12),
                      TrendLineChart(summary: snap.trend),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Distribution',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TrendPieChart(distribution: snap.distribution),
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
}
