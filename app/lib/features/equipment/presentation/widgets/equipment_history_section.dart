import 'package:flutter/material.dart';
import 'package:pool_os/features/player/domain/career_timeline_projection.dart';

/// FEATURE_011 — Equipment History
///
/// Source spec: `architecture/product/features/FEATURE_011_EQUIPMENT_HISTORY.md`.
///
/// Reads ONLY the existing [CareerTimelineEvent] projection. Filters events
/// to the currently-viewed equipment cue and to the Active Player (caller
/// responsibility). Does not introduce any new event type, projection,
/// repository, or service. Per PO amendment 2026-07-28, only
/// `completedMatch` and `completedTraining` are surfaced.
///
/// Output is deterministic, Newest → Oldest, day-grouped.
class EquipmentHistoryEvent {
  const EquipmentHistoryEvent({
    required this.event,
  });

  final CareerTimelineEvent event;
}

List<EquipmentHistoryEvent> filterEquipmentHistory({
  required List<CareerTimelineEvent> events,
  required int equipmentId,
}) {
  if (equipmentId <= 0) return const <EquipmentHistoryEvent>[];
  final filtered = <CareerTimelineEvent>[];
  for (final event in events) {
    // Spec rule 4: only Match and Training.
    if (event.type != CareerTimelineEventType.completedMatch &&
        event.type != CareerTimelineEventType.completedTraining) {
      continue;
    }
    // Spec rule 2: only events that used this cue.
    final usesThisCue = event.equipmentUsage.any(
      (usage) => usage.cueId == equipmentId,
    );
    if (!usesThisCue) continue;
    filtered.add(event);
  }
  // Spec rule 3: newest first. Stable sort by timestamp desc; tie-break
  // by eventId ascending to keep determinism even when two events share
  // a timestamp.
  filtered.sort((a, b) {
    final cmp = b.timestamp.compareTo(a.timestamp);
    if (cmp != 0) return cmp;
    return a.eventId.compareTo(b.eventId);
  });
  return filtered
      .map((e) => EquipmentHistoryEvent(event: e))
      .toList(growable: false);
}

bool _dateIsSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String _dayLabel(DateTime value, DateTime now, bool vi) {
  final local = value.toLocal();
  if (_dateIsSameDay(local, now)) {
    return vi ? 'Hôm nay' : 'Today';
  }
  final yesterday = now.subtract(const Duration(days: 1));
  if (_dateIsSameDay(local, yesterday)) {
    return vi ? 'Hôm qua' : 'Yesterday';
  }
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final m = months[local.month - 1];
  final d = local.day.toString().padLeft(2, '0');
  return '$m $d';
}

String _typeLabel(CareerTimelineEventType type, bool vi) {
  switch (type) {
    case CareerTimelineEventType.completedMatch:
      return vi ? 'Trận đấu' : 'Match';
    case CareerTimelineEventType.completedTraining:
      return vi ? 'Buổi tập' : 'Training';
    default:
      // Filter should have removed these, but render defensively.
      return type.name;
  }
}

/// Pure mapping from a filtered event to its first cue usage for navigation.
({int matchId, int? cueId})? matchLinkForEvent(CareerTimelineEvent event) {
  if (event.equipmentUsage.isEmpty) return null;
  final usage = event.equipmentUsage.first;
  return (matchId: usage.matchId, cueId: usage.cueId);
}

class EquipmentHistorySection extends StatelessWidget {
  const EquipmentHistorySection({
    super.key,
    required this.events,
    required this.equipmentId,
    required this.now,
    required this.locale,
    this.onEventTap,
  });

  final List<CareerTimelineEvent> events;
  final int equipmentId;
  final DateTime now;
  final String locale;

  /// Optional tap handler. The widget itself does not know about router
  /// navigation — it only emits the underlying event so the host screen can
  /// push the existing Match/Training detail screen. Per spec rule, no new
  /// detail screens are created.
  final void Function(CareerTimelineEvent event)? onEventTap;

  @override
  Widget build(BuildContext context) {
    final vi = locale == 'vi';
    final filtered =
        filterEquipmentHistory(events: events, equipmentId: equipmentId);

    final title = vi ? 'Lịch sử' : 'History';
    final emptyText =
        vi ? 'Chưa có lịch sử sử dụng.' : 'Chưa có lịch sử sử dụng.';

    return Container(
      key: const ValueKey('equipment-history-section'),
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            key: const ValueKey('equipment-history-title'),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          if (filtered.isEmpty)
            Text(
              emptyText,
              key: const ValueKey('equipment-history-empty'),
            )
          else
            _buildList(context, filtered, vi),
        ],
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    List<EquipmentHistoryEvent> items,
    bool vi,
  ) {
    final groups = <String, List<EquipmentHistoryEvent>>{};
    final groupOrder = <String>[];
    for (final item in items) {
      final label = _dayLabel(item.event.timestamp.toLocal(), now, vi);
      if (!groups.containsKey(label)) {
        groups[label] = <EquipmentHistoryEvent>[];
        groupOrder.add(label);
      }
      groups[label]!.add(item);
    }
    return Column(
      key: const ValueKey('equipment-history-list'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < groupOrder.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          Text(
            groupOrder[i],
            key: ValueKey('equipment-history-day-$i'),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          for (final item in groups[groupOrder[i]]!)
            InkWell(
              key: ValueKey(
                'equipment-history-event-${item.event.eventId}',
              ),
              onTap: onEventTap == null ? null : () => onEventTap!(item.event),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    const Text('•  '),
                    Expanded(
                      child: Text(_typeLabel(item.event.type, vi)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }
}
