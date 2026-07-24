import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../session/application/training_session_execution_service.dart';
import '../../session/presentation/session_summary_screen.dart';
import 'training_statistics_panel.dart';

class TrainingHistoryView extends ConsumerWidget {
  const TrainingHistoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref
          .read(trainingSessionExecutionServiceProvider)
          .loadCompletedSessions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) return Text(snapshot.error.toString());
        final history = snapshot.data ?? const [];
        if (history.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TrainingStatisticsPanel(),
            const SizedBox(height: 24),
            Text(
              'Training history',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...history.map((entry) {
              final attempts = entry.exercises.fold<int>(
                0,
                (sum, exercise) => sum + exercise.attempts,
              );
              final successes = entry.exercises.fold<int>(
                0,
                (sum, exercise) => sum + exercise.successes,
              );
              return Card(
                child: ListTile(
                  key: ValueKey('training-history-${entry.session.id}'),
                  leading: CircleAvatar(child: Text('$successes/$attempts')),
                  title: Text('Training Session #${entry.session.id}'),
                  subtitle: Text(
                    '${_formatDate(entry.session.startedAt)} - '
                    '${_formatDuration(entry.session.duration)}\n'
                    '${entry.exercises.length} exercises',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TrainingDetailScreen(
                        sessionId: entry.session.id!,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime value) =>
      '${value.day}/${value.month}/${value.year}';

  String _formatDuration(Duration value) {
    final hours = value.inHours;
    final minutes = value.inMinutes.remainder(60);
    return hours == 0 ? '${value.inMinutes}m' : '${hours}h ${minutes}m';
  }
}

class TrainingDetailScreen extends ConsumerWidget {
  const TrainingDetailScreen({super.key, required this.sessionId});

  final int sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Training detail')),
      body: FutureBuilder(
        future: ref
            .read(trainingSessionExecutionServiceProvider)
            .loadCompletedSession(sessionId),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          final history = snapshot.data;
          if (history == null) {
            return const Center(child: Text('Training session not found'));
          }
          final attempts = history.exercises.fold<int>(
            0,
            (sum, exercise) => sum + exercise.attempts,
          );
          final successes = history.exercises.fold<int>(
            0,
            (sum, exercise) => sum + exercise.successes,
          );
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.link),
                  title: const Text('Session summary'),
                  subtitle: Text('Session #${history.session.id}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SessionSummaryScreen(
                        sessionId: history.session.id!,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _Metric(label: 'Success', value: '$successes'),
                      _Metric(
                        label: 'Miss',
                        value: '${attempts - successes}',
                      ),
                      _Metric(
                        label: 'Duration',
                        value: '${history.session.duration.inMinutes}m',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Exercise timeline',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...history.exercises.map(
                (exercise) => Card(
                  child: ListTile(
                    leading: Icon(
                      exercise.completed
                          ? Icons.check_circle
                          : Icons.pending_outlined,
                      color: exercise.completed ? Colors.green : null,
                    ),
                    title: Text(exercise.name),
                    subtitle: Text(exercise.code),
                    trailing: Text(
                      '${exercise.successes}/${exercise.attempts}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          Text(label),
        ],
      );
}
