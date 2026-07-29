// EPIC 02 — Statistics & Analytics — Phase 4: dashboard screen.
//
// Summary-only surface. Re-uses the Phase 5 chart primitives to
// render the dashboard tiles. The screen is a thin ConsumerWidget
// over `dashboardSnapshotProvider`.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/statistics/presentation/widgets/trend_chart.dart';

import '../application/statistics_analytics_service.dart';
import '../domain/models/analytics_snapshots.dart';

class DashboardScreenV2 extends ConsumerWidget {
  const DashboardScreenV2({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardSnapshotProvider);
    final period = ref.watch(analyticsPeriodProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
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
      body: dashboard.when(
        data: (snap) => _DashboardBody(snapshot: snap),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.snapshot});
  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Summary', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: StatisticsMetricTile(
                  label: 'Total matches',
                  value: snapshot.totalMatches.toString(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatisticsMetricTile(
                  label: 'Win rate',
                  value: '${(snapshot.winRate * 100).toStringAsFixed(0)}%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: StatisticsMetricTile(
                  label: 'Sessions',
                  value: snapshot.totalSessions.toString(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatisticsMetricTile(
                  label: 'Equipment used',
                  value: snapshot.totalEquipmentUsed.toString(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Recent performance',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TrendDirectionChip(summary: snapshot.recentPerformance),
                  const SizedBox(height: 12),
                  TrendLineChart(summary: snapshot.recentPerformance),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Recent activity',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                if (snapshot.recentActivity.isEmpty)
                  const ListTile(title: Text('No recent activity')),
                for (final entry in snapshot.recentActivity)
                  ListTile(
                    title: Text(entry.title),
                    subtitle: Text(entry.subtitle),
                    trailing: Text(entry.date.toString().split(' ').first),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
