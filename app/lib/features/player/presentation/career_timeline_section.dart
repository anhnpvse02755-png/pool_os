import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../application/career_timeline_service.dart';
import '../domain/career_timeline_projection.dart';

final careerTimelineProvider =
    FutureProvider.autoDispose<CareerTimelineProjection?>((ref) {
  return ref.watch(careerTimelineServiceProvider).rebuildActivePlayer();
});

class CareerTimelineSection extends ConsumerWidget {
  const CareerTimelineSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeline = ref.watch(careerTimelineProvider);
    return Card(
      key: const ValueKey('career-timeline-section'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.timeline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Career Timeline',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            timeline.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stackTrace) => Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  tooltip: 'Reload timeline',
                  onPressed: () => ref.invalidate(careerTimelineProvider),
                  icon: const Icon(Icons.refresh),
                ),
              ),
              data: (projection) {
                final events = projection?.events ?? const [];
                if (events.isEmpty) {
                  return const Text('No recorded career events.');
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: events.length,
                  separatorBuilder: (_, __) => const Divider(height: 20),
                  itemBuilder: (context, index) =>
                      _CareerTimelineEventTile(event: events[index]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CareerTimelineEventTile extends StatelessWidget {
  const _CareerTimelineEventTile({required this.event});

  final CareerTimelineEvent event;

  @override
  Widget build(BuildContext context) {
    final localTimestamp = event.timestamp.toLocal();
    final locale = Localizations.localeOf(context).toLanguageTag();
    final timestamp = DateFormat.yMMMd(locale).add_Hm().format(localTimestamp);
    return Semantics(
      key: ValueKey('career-timeline-event-${event.eventId}'),
      container: true,
      label: '${event.title}, $timestamp, ${event.sourceReference}',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: Icon(_iconFor(event.type), size: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  timestamp,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(event.summary),
                if (event.equipmentUsage.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  for (final usage in event.equipmentUsage)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        'Match #${usage.matchNumber} | '
                        '${_roleLabel(usage.role)} | Cue #${usage.cueId} | '
                        '${usage.snapshotReference}',
                        key: ValueKey(
                          'career-timeline-equipment-'
                          '${usage.matchId}-${usage.role.name}',
                        ),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                ],
                const SizedBox(height: 4),
                Text(
                  event.sourceReference,
                  key: ValueKey(
                    'career-timeline-source-${event.eventId}',
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

IconData _iconFor(CareerTimelineEventType type) => switch (type) {
      CareerTimelineEventType.playerCreated => Icons.person_add_alt_1,
      CareerTimelineEventType.completedMatch => Icons.sports,
      CareerTimelineEventType.completedTraining => Icons.fitness_center,
      CareerTimelineEventType.playerModelSnapshot => Icons.insights,
      CareerTimelineEventType.masteryEvidenceUpdated => Icons.school,
    };

String _roleLabel(CareerEquipmentRole role) => switch (role) {
      CareerEquipmentRole.playing => 'Playing',
      CareerEquipmentRole.breakCue => 'Break',
      CareerEquipmentRole.jump => 'Jump',
    };
