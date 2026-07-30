// EPIC 03 — Drill Library screen.
//
// Re-uses the built-in [DrillLibrary] from app/lib/features/drill/.
// Read-only catalog — no AI, no recommendation, no ordering.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/drill/data/drill_library.dart';
import 'package:pool_os/features/drill/domain/models/drill.dart';

class DrillLibraryScreen extends ConsumerWidget {
  const DrillLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drills = DrillLibrary.getAllDrills();
    return Scaffold(
      appBar: AppBar(title: const Text('Drill Library')),
      body: ListView.separated(
        itemCount: drills.length,
        separatorBuilder: (_, __) => const Divider(height: 0),
        itemBuilder: (context, i) {
          final d = drills[i];
          return ListTile(
            title: Text(d.name),
            subtitle: Text('${d.category} · ${d.difficulty}'),
            trailing: Text('${d.difficultyStars}★'),
            onTap: () => _showDrillDetail(context, d),
          );
        },
      ),
    );
  }

  void _showDrillDetail(BuildContext context, Drill d) {
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
              Text(d.name, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Category: ${d.category}'),
              Text('Difficulty: ${d.difficulty} (${d.difficultyStars})'),
              Text('Target: ${d.targetScore}'),
              Text('Duration: ${d.timeLimitMinutes} min'),
              if (d.equipment != null) Text('Equipment: ${d.equipment}'),
              const SizedBox(height: 12),
              Text(d.description),
              const SizedBox(height: 12),
              const Text('Instructions:'),
              for (final s in d.instructions) Text('• $s'),
              if (d.commonMistakes != null && d.commonMistakes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('Common mistakes:'),
                for (final s in d.commonMistakes!) Text('• $s'),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
