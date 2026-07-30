// EPIC 03 — Lesson screen.
//
// Static learning content. Read-only — no AI, no adaptive learning,
// no completion tracking at MVP (per PO direction 2026-07-30).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/training_system/presentation/providers/training_system_providers.dart';

class LessonScreen extends ConsumerWidget {
  const LessonScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessons = ref.watch(lessonsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Lessons')),
      body: lessons.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (data) => ListView.separated(
          itemCount: data.length,
          separatorBuilder: (_, __) => const Divider(height: 0),
          itemBuilder: (context, i) {
            final l = data[i];
            return ListTile(
              title: Text(l.title),
              subtitle: Text(
                '${l.difficulty ?? '-'} · '
                'drills: ${l.requiredDrills.join(', ')}',
              ),
              onTap: () => _showLesson(context, l),
            );
          },
        ),
      ),
    );
  }

  void _showLesson(context, l) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(l.description),
              const SizedBox(height: 12),
              const Text('Objectives:'),
              for (final o in l.objectives) Text('• $o'),
              const SizedBox(height: 12),
              const Text('Required drills:'),
              for (final d in l.requiredDrills) Text('• $d'),
              if (l.references.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('References:'),
                for (final r in l.references) Text('• $r'),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
