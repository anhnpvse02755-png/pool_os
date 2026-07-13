import 'package:flutter/material.dart';
import 'package:pool_os/features/goal_center/domain/models/goal_center_models.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

/// Task 10 — one achievement / streak / milestone tile (Phần 3/4/5). Shows the
/// badge locked (greyed, with progress toward the threshold) or unlocked (lit,
/// with a "mới" flag if not yet acknowledged). Pure display from [BadgeStatus].
class BadgeTile extends StatelessWidget {
  final BadgeStatus status;

  const BadgeTile({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final unlocked = status.unlocked;
    final color = unlocked ? _kindColor(status.badge.kind) : Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: unlocked ? color.withAlpha(15) : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withAlpha(unlocked ? 40 : 20),
              ),
              child: Icon(
                unlocked ? _kindIcon(status.badge.kind) : Icons.lock_outline,
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          l10n.get(status.badge.titleKey),
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: unlocked ? null : Colors.grey,
                              ),
                        ),
                      ),
                      if (status.isNew) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            l10n.get('gc_new'),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.get(status.badge.descriptionKey),
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey),
                  ),
                  if (!unlocked) ...[
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: status.ratio,
                        minHeight: 5,
                        backgroundColor: Colors.grey.withAlpha(40),
                        valueColor: AlwaysStoppedAnimation(color),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${status.current.round()} / ${status.badge.threshold.round()}',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ),
            if (unlocked)
              Icon(Icons.check_circle, color: color, size: 20),
          ],
        ),
      ),
    );
  }

  Color _kindColor(BadgeKind kind) {
    switch (kind) {
      case BadgeKind.achievement:
        return Colors.amber.shade700;
      case BadgeKind.streak:
        return Colors.deepOrange;
      case BadgeKind.milestone:
        return Colors.indigo;
    }
  }

  IconData _kindIcon(BadgeKind kind) {
    switch (kind) {
      case BadgeKind.achievement:
        return Icons.emoji_events;
      case BadgeKind.streak:
        return Icons.local_fire_department;
      case BadgeKind.milestone:
        return Icons.flag;
    }
  }
}
