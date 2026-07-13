import 'package:flutter/material.dart';
import 'package:pool_os/features/career/domain/models/career_models.dart';

/// Task 11 — one entry on the timeline (Phần 1). A left rail with a type icon +
/// connector line, then the event's title/subtitle/detail. Pure display from a
/// [TimelineEvent] — the "development journal" look the spec asks for.
class TimelineEventTile extends StatelessWidget {
  final TimelineEvent event;
  final bool isFirst;
  final bool isLast;

  const TimelineEventTile({
    super.key,
    required this.event,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(event.type);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left rail: connector line + dot.
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: 2,
                    color: isFirst
                        ? Colors.transparent
                        : Colors.grey.withAlpha(60),
                  ),
                ),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withAlpha(40),
                    border: Border.all(color: color, width: 2),
                  ),
                  child: Icon(_typeIcon(event.type), size: 16, color: color),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast
                        ? Colors.transparent
                        : Colors.grey.withAlpha(60),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Content.
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              event.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                            ),
                          ),
                          Text(
                            _time(event.date),
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                      if (event.subtitle != null &&
                          event.subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          event.subtitle!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                      if (event.detail != null && event.detail!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          event.detail!,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _time(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Color _typeColor(TimelineEventType type) {
    switch (type) {
      case TimelineEventType.session:
        return Colors.blue;
      case TimelineEventType.match:
        return Colors.orange;
      case TimelineEventType.goal:
        return Colors.indigo;
      case TimelineEventType.achievement:
        return Colors.amber.shade700;
      case TimelineEventType.equipment:
        return Colors.deepPurple;
      case TimelineEventType.training:
        return Colors.teal;
    }
  }

  IconData _typeIcon(TimelineEventType type) {
    switch (type) {
      case TimelineEventType.session:
        return Icons.sports_bar;
      case TimelineEventType.match:
        return Icons.emoji_events;
      case TimelineEventType.goal:
        return Icons.flag;
      case TimelineEventType.achievement:
        return Icons.military_tech;
      case TimelineEventType.equipment:
        return Icons.sports_esports;
      case TimelineEventType.training:
        return Icons.fitness_center;
    }
  }
}
