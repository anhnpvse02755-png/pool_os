// EPIC 02 — Statistics & Analytics — Phase 4: player statistics
// detail screen.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/statistics_analytics_service.dart';
import 'widgets/trend_chart.dart';

class PlayerStatisticsScreen extends ConsumerWidget {
  const PlayerStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(playerStatisticsSnapshotProvider);
    final period = ref.watch(analyticsPeriodProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Player statistics'),
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
                      value: snap.matchCount.toString(),
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
                      label: 'Win rate',
                      value: '${(snap.winRate * 100).toStringAsFixed(0)}%',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: StatisticsMetricTile(
                      label: 'Best streak',
                      value: snap.bestWinStreak.toString(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatisticsMetricTile(
                      label: 'Avg duration',
                      value: _duration(snap.averageMatchDuration),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Head-to-head',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    if (snap.headToHead.isEmpty)
                      const ListTile(title: Text('No opponents yet')),
                    for (final e in snap.headToHead.values)
                      ListTile(
                        title: Text(e.opponent),
                        subtitle: Text(
                            'Wins: ${e.wins}, Losses: ${e.losses}, Matches: ${e.matches}'),
                        trailing: Text(
                            '${(e.winRate * 100).toStringAsFixed(0)}%'),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('Opponents',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    if (snap.opponentHistory.isEmpty)
                      const ListTile(title: Text('No opponents yet')),
                    for (final e in snap.opponentHistory.entries)
                      ListTile(
                        title: Text(e.key),
                        trailing: Text('${e.value}'),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('Recent activity',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    if (snap.recentActivity.isEmpty)
                      const ListTile(title: Text('No recent activity')),
                    for (final e in snap.recentActivity)
                      ListTile(
                        title: Text(e.title),
                        subtitle: Text(e.kind),
                        trailing: Text(e.date.toString().split(' ').first),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('Performance trend',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TrendDirectionChip(summary: snap.performanceTrend),
                      const SizedBox(height: 12),
                      TrendLineChart(summary: snap.performanceTrend),
                    ],
                  ),
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
