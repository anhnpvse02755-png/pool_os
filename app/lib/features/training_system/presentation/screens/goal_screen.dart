// EPIC 03 — Goal screen.
//
// Lists goals grouped by GoalStatus (notStarted / active / completed /
// archived). Per PO direction 2026-07-30. Re-uses goal_center/Goal with
// the v32 status column.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/goal_center/domain/models/goal_center_models.dart';
import 'package:pool_os/features/training_system/presentation/providers/training_system_providers.dart';

class GoalScreen extends ConsumerStatefulWidget {
  const GoalScreen({super.key});

  @override
  ConsumerState<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends ConsumerState<GoalScreen> {
  GoalStatus _filter = GoalStatus.active;

  @override
  Widget build(BuildContext context) {
    final goals = ref.watch(goalsByStatusProvider(_filter));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goals'),
        actions: [
          PopupMenuButton<GoalStatus>(
            tooltip: 'Filter by status',
            initialValue: _filter,
            onSelected: (s) => setState(() => _filter = s),
            itemBuilder: (context) => [
              for (final s in GoalStatus.values)
                PopupMenuItem(value: s, child: Text(s.code)),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_filter.code),
                  const Icon(Icons.expand_more),
                ],
              ),
            ),
          ),
        ],
      ),
      body: goals.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (data) => data.isEmpty
            ? const Center(child: Text('No goals in this state.'))
            : ListView.separated(
                itemCount: data.length,
                separatorBuilder: (_, __) => const Divider(height: 0),
                itemBuilder: (context, i) {
                  final g = data[i];
                  return ListTile(
                    title: Text(g.title),
                    subtitle: Text(
                      '${g.metric.code} · target ${g.target}'
                      '${g.note == null ? '' : ' · ${g.note}'}',
                    ),
                    trailing: _statusChip(g.status, g.isComplete),
                  );
                },
              ),
      ),
    );
  }

  Widget _statusChip(GoalStatus status, bool isComplete) {
    final color = switch (status) {
      GoalStatus.active => Colors.blue,
      GoalStatus.completed => Colors.green,
      GoalStatus.archived => Colors.grey,
      GoalStatus.notStarted => Colors.orange,
    };
    return Chip(
      label: Text(status.code, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
      visualDensity: VisualDensity.compact,
    );
  }
}
