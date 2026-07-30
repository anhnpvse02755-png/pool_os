// EPIC 03 — Practice Session screen.
//
// Re-uses training_center/TrainingSession + DrillRun. Player can start
// a new session, list recent sessions, and complete / delete existing
// entries. No AI, no recommendation.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/training_center/domain/models/training_center_models.dart';
import 'package:pool_os/features/training_system/presentation/providers/training_system_providers.dart';

class PracticeSessionScreen extends ConsumerWidget {
  const PracticeSessionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(recentPracticeSessionsProvider(20));
    return Scaffold(
      appBar: AppBar(title: const Text('Practice Session')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _startSession(context, ref),
        child: const Icon(Icons.add),
      ),
      body: sessions.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (data) => data.isEmpty
            ? const Center(child: Text('No practice sessions yet.'))
            : ListView.separated(
                itemCount: data.length,
                separatorBuilder: (_, __) => const Divider(height: 0),
                itemBuilder: (context, i) {
                  final s = data[i];
                  return ListTile(
                    title: Text(
                      'Session #${s.id} · ${_formatDate(s.startedAt)}',
                    ),
                    subtitle: Text(
                      s.isComplete ? 'Completed' : 'In progress',
                    ),
                    trailing: s.isComplete
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.check),
                            onPressed: () => ref
                                .read(practiceSessionControllerProvider.notifier)
                                .complete(s.id!),
                          ),
                  );
                },
              ),
      ),
    );
  }

  Future<void> _startSession(BuildContext context, WidgetRef ref) async {
    final id = await ref
        .read(practiceSessionControllerProvider.notifier)
        .start(TrainingSession(startedAt: DateTime.now()));
    if (context.mounted && id > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Started session #$id')),
      );
    }
  }

  static String _formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}
