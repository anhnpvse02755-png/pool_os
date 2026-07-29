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
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatisticsMetricTile(
                      label: 'Draws',
                      value: snap.draws.toString(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: StatisticsMetricTile(
                      label: 'Win %',
                      value: '${(snap.winRate * 100).toStringAsFixed(0)}%',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatisticsMetricTile(
                      label: 'Lose %',
                      value: '${(snap.loseRate * 100).toStringAsFixed(0)}%',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatisticsMetricTile(
                      label: 'Avg duration',
                      value: _duration(snap.averageMatchDuration),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatisticsMetricTile(
                      label: 'Longest',
                      value: _duration(snap.longestMatch),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: StatisticsMetricTile(
                      label: 'Current streak',
                      value: snap.currentStreak.toString(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatisticsMetricTile(
                      label: 'Best streak',
                      value: snap.highestWinStreak.toString(),
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
              Text('Race distribution',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TrendPieChart(distribution: snap.raceDistribution),
                ),
              ),
              const SizedBox(height: 16),
              Text('Game type distribution',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TrendPieChart(
                      distribution: snap.gameTypeDistribution),
                ),
              ),
              const SizedBox(height: 16),
              Text('Match type (single/double)',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TrendPieChart(
                      distribution: snap.matchTypeDistribution),
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

  String _duration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h == 0) return '${m}m';
    return '${h}h ${m}m';
  }
}
