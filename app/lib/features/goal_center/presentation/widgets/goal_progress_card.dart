import 'package:flutter/material.dart';
import 'package:pool_os/features/goal_center/domain/models/goal_center_models.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

/// Task 10 — one goal row with its live progress bar (Phần 2). Renders a percent
/// metric as "72% → 80%" and a count metric as "3 / 10". Pure display; the ratio
/// and completion state come from [GoalProgress] (no fabricated numbers).
class GoalProgressCard extends StatelessWidget {
  final GoalProgress progress;
  final VoidCallback? onDelete;

  const GoalProgressCard({super.key, required this.progress, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final goal = progress.goal;
    final isPercent = goal.metric.isPercent;
    final done = progress.isReached;

    final currentText = isPercent
        ? '${progress.current.round()}%'
        : '${progress.current.round()}';
    final targetText =
        isPercent ? '${goal.target.round()}%' : '${goal.target.round()}';

    // Default goals store an l10n key as their title; custom goals store text.
    final title = goal.isDefault ? l10n.get(goal.title) : goal.title;

    final barColor = done ? Colors.green : Theme.of(context).colorScheme.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  done ? Icons.check_circle : Icons.flag_outlined,
                  color: barColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                if (goal.isDefault)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Chip(
                      label: Text(
                        l10n.get('gc_default_badge'),
                        style: const TextStyle(fontSize: 11),
                      ),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    tooltip: l10n.get('delete'),
                    onPressed: onDelete,
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              l10n.get(goal.metric.labelKey),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress.ratio,
                minHeight: 10,
                backgroundColor: Colors.grey.withAlpha(40),
                valueColor: AlwaysStoppedAnimation(barColor),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  done
                      ? l10n.get('gc_goal_done')
                      : '$currentText / $targetText',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: done ? Colors.green : null,
                      ),
                ),
                Text(
                  '${progress.percent}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: barColor,
                      ),
                ),
              ],
            ),
            if (goal.note != null && goal.note!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                goal.note!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontStyle: FontStyle.italic, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
