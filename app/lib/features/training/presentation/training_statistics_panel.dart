import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/training_statistics_service.dart';

class TrainingStatisticsPanel extends ConsumerWidget {
  const TrainingStatisticsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.read(trainingStatisticsServiceProvider).load(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) return Text(snapshot.error.toString());
        final statistics = snapshot.data;
        if (statistics == null || statistics.sessionCount == 0) {
          return const SizedBox.shrink();
        }
        final rate = statistics.attempts == 0
            ? 0
            : (statistics.successes * 100 / statistics.attempts).round();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Training performance',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [
                _Metric(
                  label: 'Sessions',
                  value: '${statistics.sessionCount}',
                ),
                _Metric(
                  label: 'Exercises',
                  value: '${statistics.exerciseCount}',
                ),
                _Metric(
                  label: 'Attempts',
                  value: '${statistics.attempts}',
                ),
                _Metric(label: 'Success rate', value: '$rate%'),
                _Metric(
                  label: 'Successes',
                  value: '${statistics.successes}',
                ),
                _Metric(
                  label: 'Duration',
                  value: _duration(statistics.duration),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Recent sessions',
                style: Theme.of(context).textTheme.titleSmall),
            ...statistics.recent.take(5).map(
                  (entry) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Session #${entry.sessionId}'),
                    subtitle: Text(
                      '${entry.exercises} exercises - '
                      '${entry.successes}/${entry.attempts}',
                    ),
                    trailing: Text(
                      '${(entry.successRate * 100).round()}% - '
                      '${_duration(entry.duration)}',
                    ),
                  ),
                ),
            const SizedBox(height: 12),
            Text('Drill performance',
                style: Theme.of(context).textTheme.titleSmall),
            ...statistics.drills.map(
              (entry) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(entry.name),
                subtitle: Text('${entry.successes}/${entry.attempts} success'),
                trailing:
                    Text('${(entry.successRate * 100).toStringAsFixed(1)}%'),
              ),
            ),
            const SizedBox(height: 12),
            Text('Last 5 sessions',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: statistics.trend
                  .map(
                    (entry) => Chip(
                      label: Text(
                        '#${entry.sessionId} '
                        '${(entry.successRate * 100).round()}%',
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        );
      },
    );
  }

  String _duration(Duration value) {
    final hours = value.inHours;
    final minutes = value.inMinutes.remainder(60);
    return hours == 0 ? '${value.inMinutes}m' : '${hours}h ${minutes}m';
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value, style: Theme.of(context).textTheme.titleLarge),
              Text(label),
            ],
          ),
        ),
      );
}
