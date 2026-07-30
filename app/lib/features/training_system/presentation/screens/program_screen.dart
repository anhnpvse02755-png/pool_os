// EPIC 03 — Personal Training Program screen.
//
// Lists seed programs (Beginner / Intermediate / Advanced) and any
// custom programs the player has authored. Player can enroll into a
// program and mark weeks completed.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/training_system/domain/models/training_system_models.dart';
import 'package:pool_os/features/training_system/presentation/providers/training_system_providers.dart';

class ProgramScreen extends ConsumerWidget {
  const ProgramScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programs = ref.watch(programsProvider(false));
    final enrollments = ref.watch(enrollmentsProvider(null));
    return Scaffold(
      appBar: AppBar(title: const Text('Personal Training Program')),
      body: programs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (data) => ListView.separated(
          itemCount: data.length,
          separatorBuilder: (_, __) => const Divider(height: 0),
          itemBuilder: (context, i) {
            final p = data[i];
            final enrolled = enrollments.maybeWhen(
              data: (list) => list.any((e) => e.programId == p.id),
              orElse: () => false,
            );
            return ListTile(
              title: Text(p.title),
              subtitle: Text(
                '${p.difficulty.code} · ${p.weekCount} weeks · '
                '${p.hierarchy.totalDrills} drills'
                '${p.isSeed ? ' · seed' : ''}',
              ),
              trailing: enrolled
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => ref
                          .read(enrollControllerProvider.notifier)
                          .enroll(p.id!),
                    ),
              onTap: () => _showHierarchy(context, p),
            );
          },
        ),
      ),
    );
  }

  void _showHierarchy(context, p) {
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
              Text(p.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(p.description),
              const SizedBox(height: 12),
              for (final w in p.hierarchy.weeks) ...[
                Text('Week ${w.weekIndex}: ${w.title}',
                    style: Theme.of(context).textTheme.titleMedium),
                for (final d in w.days) ...[
                  Text('Day ${d.dayIndex}: ${d.title}'),
                  for (final dr in d.drills)
                    Text('  • ${dr.drillCode} × ${dr.targetReps}'
                        '${dr.note == null ? '' : ' — ${dr.note}'}'),
                ],
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
