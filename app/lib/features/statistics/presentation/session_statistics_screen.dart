// EPIC 02 — Statistics & Analytics — Phase 4: session statistics
// detail screen.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/statistics_analytics_service.dart';
import 'widgets/trend_chart.dart';

class SessionStatisticsScreen extends ConsumerWidget {
  const SessionStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(sessionStatisticsSnapshotProvider);
    final period = ref.watch(analyticsPeriodProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session statistics'),
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
                      label: 'Sessions',
                      value: snap.totalSessions.toString(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatisticsMetricTile(
                      label: 'Training',
                      value: snap.trainingVolume.toString(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatisticsMetricTile(
                      label: 'Matches',
                      value: snap.matchVolume.toString(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: StatisticsMetricTile(
                      label: 'Avg duration',
                      value: _fmtDuration(snap.averageDuration),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatisticsMetricTile(
                      label: 'Total',
                      value: _fmtDuration(snap.totalDuration),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('History',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    if (snap.history.isEmpty)
                      const ListTile(title: Text('No sessions yet')),
                    for (final e in snap.history)
                      ListTile(
                        title: Text(
                            'Session #${e.sessionId.isEmpty ? "?" : e.sessionId}'),
                        subtitle: Text(_fmtDuration(e.duration)),
                        trailing: Text(e.startedAt.toString().split(' ').first),
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

  String _fmtDuration(Duration d) {
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    if (d.inMinutes > 0) return '${d.inMinutes}m';
    return '${d.inSeconds}s';
  }
}
