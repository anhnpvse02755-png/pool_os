// EPIC 05 §2.4 — Learning Path UI shell.
//
// Spec §2.4:
//   - Learning Path Browser
//   - Learning Path Detail
//   - Progress                  (read-only)
//   - Completed
//   - Estimated Hours
//   - Required Skills
//   - Prerequisites
//   - Dependencies
//   - Learning Order
//
// PO 2026-07-31 — read-only. Progress is sourced from the player's existing
// knowledge items but the widget itself never mutates state. No AI.
// Reuses [LearningPathLoaderService] for the deterministic ordering.

import 'package:flutter/material.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

/// Lightweight view-model used by both the Browser and Detail screens.
/// Sourced directly from the existing [LearningPath] and [LearningPhase]
/// classes in [LearningPathLoaderService].
class LearningPathView {
  final String id;
  final String title;
  final String titleVi;
  final String description;
  final String playerLevel;
  final int estimatedMinutes;
  final List<String> requiredSkills;
  final List<String> prerequisites;
  final List<String> dependencies;
  final List<LearningPhaseView> phases;

  const LearningPathView({
    required this.id,
    required this.title,
    required this.titleVi,
    required this.description,
    required this.playerLevel,
    required this.estimatedMinutes,
    required this.requiredSkills,
    required this.prerequisites,
    required this.dependencies,
    required this.phases,
  });

  /// Estimated hours — derived (minutes/60). Pure projection.
  int get estimatedHours => (estimatedMinutes / 60).ceil();

  /// Number of items across all phases — pure count.
  int get totalItems => phases.fold(0, (s, p) => s + p.itemIds.length);
}

class LearningPhaseView {
  final String id;
  final String title;
  final List<String> itemIds;
  const LearningPhaseView({
    required this.id,
    required this.title,
    required this.itemIds,
  });
}

/// Read-only Learning Path Browser.
class LearningPathBrowser extends StatelessWidget {
  final List<LearningPathView> paths;
  final void Function(LearningPathView) onOpen;

  const LearningPathBrowser({
    super.key,
    required this.paths,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (paths.isEmpty) {
      return Center(child: Text(l10n.get('knowledge_no_paths')));
    }
    return ListView.separated(
      itemCount: paths.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final p = paths[index];
        return ListTile(
          leading: const Icon(Icons.school_outlined),
          title: Text(p.title),
          subtitle: Text(
            '${p.playerLevel} · ${p.estimatedHours}h · ${p.totalItems} items',
            style: const TextStyle(fontSize: 12),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => onOpen(p),
        );
      },
    );
  }
}

/// Read-only Learning Path Detail. Surfaces Progress as the count of
/// completed items divided by the total — sourced from the caller's
/// already-existing knowledge-item repository.
class LearningPathDetail extends StatelessWidget {
  final LearningPathView path;
  final int completedItemCount;

  const LearningPathDetail({
    super.key,
    required this.path,
    required this.completedItemCount,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
        path.totalItems == 0 ? 0.0 : completedItemCount / path.totalItems;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(path.title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(path.description),
        const SizedBox(height: 16),
        _ProgressBar(value: progress, completed: completedItemCount, total: path.totalItems),
        const SizedBox(height: 16),
        _SectionTitle('Estimated Hours'),
        Text('${path.estimatedHours}h (${path.estimatedMinutes} min)'),
        if (path.requiredSkills.isNotEmpty) ...[
          const SizedBox(height: 12),
          _SectionTitle('Required Skills'),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: path.requiredSkills.map((s) => Chip(label: Text(s))).toList(),
          ),
        ],
        if (path.prerequisites.isNotEmpty) ...[
          const SizedBox(height: 12),
          _SectionTitle('Prerequisites'),
          ...path.prerequisites.map((s) => ListTile(
                dense: true,
                leading: const Icon(Icons.lock_outline),
                title: Text(s),
              )),
        ],
        if (path.dependencies.isNotEmpty) ...[
          const SizedBox(height: 12),
          _SectionTitle('Dependencies'),
          ...path.dependencies.map((s) => ListTile(
                dense: true,
                leading: const Icon(Icons.link),
                title: Text(s),
              )),
        ],
        const SizedBox(height: 12),
        _SectionTitle('Learning Order'),
        ..._buildOrderList(),
      ],
    );
  }

  Iterable<Widget> _buildOrderList() sync* {
    var step = 1;
    for (final phase in path.phases) {
      yield Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          'Phase: ${phase.title}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
      for (final id in phase.itemIds) {
        yield ListTile(
          dense: true,
          leading: CircleAvatar(
            radius: 12,
            child: Text('$step', style: const TextStyle(fontSize: 11)),
          ),
          title: Text(id),
        );
        step += 1;
      }
    }
  }
}

class _ProgressBar extends StatelessWidget {
  final double value;
  final int completed;
  final int total;
  const _ProgressBar({
    required this.value,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LinearProgressIndicator(value: value.clamp(0.0, 1.0)),
        const SizedBox(height: 4),
        Text(
          '$completed / $total completed',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}