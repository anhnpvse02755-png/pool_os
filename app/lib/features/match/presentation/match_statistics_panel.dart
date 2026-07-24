import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/match_statistics_service.dart';

class MatchStatisticsPanel extends ConsumerWidget {
  const MatchStatisticsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.read(matchStatisticsServiceProvider).load(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) return Text(snapshot.error.toString());
        final statistics = snapshot.data;
        if (statistics == null || statistics.matchCount == 0) {
          return const SizedBox.shrink();
        }
        final winRate = statistics.rackCount == 0
            ? 0
            : (statistics.wins * 100 / statistics.rackCount).round();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Match performance',
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
                _Metric(label: 'Matches', value: '${statistics.matchCount}'),
                _Metric(label: 'Racks', value: '${statistics.rackCount}'),
                _Metric(label: 'Win rate', value: '$winRate%'),
                _Metric(
                  label: 'Duration',
                  value: _formatDuration(statistics.duration),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...statistics.performance.take(5).map(
                  (entry) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      child: Text('${entry.wins}-${entry.losses}'),
                    ),
                    title: Text(
                      entry.match.opponent?.trim().isNotEmpty == true
                          ? entry.match.opponent!
                          : 'Match #${entry.match.matchNumber}',
                    ),
                    subtitle: Text(
                      '${(entry.winRate * 100).round()}% rack win rate',
                    ),
                    trailing: Text(_formatDuration(
                      entry.match.duration ?? Duration.zero,
                    )),
                  ),
                ),
          ],
        );
      },
    );
  }

  String _formatDuration(Duration value) {
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
