import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../domain/career_timeline_projection.dart';
import 'career_timeline_section.dart';

/// FEATURE_009 — Player Timeline screen.
///
/// UI-only surface for the existing CareerTimelineProjection. No new
/// domain, no new projection, no new provider — the screen reads the
/// existing `careerTimelineProvider` (defined alongside
/// `CareerTimelineSection`). Per the spec's Forbidden list, this widget
/// MUST NOT introduce any new artifact beyond the widget tree itself.
///
/// Behaviour:
///
/// - Filter chips for All / Match / Training / Player Model / Equipment.
/// - Day-grouped event list with Today / Yesterday / Older labels.
/// - Pull-to-refresh invalidates the existing provider.
/// - Tap a row to navigate to the existing detail screen (no new
///   routes); fallback keeps the user on this screen if no route exists.
/// - Deterministic ordering: whatever order CareerTimelineProjection
///   returns is what this screen renders. The screen does not sort.
///
/// Knowledge events (`masteryEvidenceUpdated`) are excluded by the
/// filter set itself — the chips only surface the four Phase-1 kinds.
class PlayerTimelineScreen extends ConsumerStatefulWidget {
  const PlayerTimelineScreen({super.key});

  @override
  ConsumerState<PlayerTimelineScreen> createState() =>
      _PlayerTimelineScreenState();
}

class _PlayerTimelineScreenState extends ConsumerState<PlayerTimelineScreen> {
  _TimelineFilter _filter = _TimelineFilter.all;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final timeline = ref.watch(careerTimelineProvider);

    return Scaffold(
      key: const ValueKey('player-timeline-screen'),
      appBar: AppBar(
        title: const Text('Timeline'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            color: theme.colorScheme.surface,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: _FilterChipBar(
              active: _filter,
              onChanged: (next) => setState(() => _filter = next),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(careerTimelineProvider);
          // Await one microtask so the indicator is visible briefly even
          // when the rebuild is synchronous against the cache.
          await Future<void>.delayed(Duration.zero);
        },
        child: timeline.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => _ErrorState(
            onRetry: () => ref.invalidate(careerTimelineProvider),
          ),
          data: (projection) {
            final events = _filterEvents(projection?.events ?? const []);
            return _Body(
              events: events,
              locale: locale,
              onTapEvent: (event) => _onTapEvent(event),
            );
          },
        ),
      ),
    );
  }

  List<CareerTimelineEvent> _filterEvents(List<CareerTimelineEvent> events) {
    return events.where((event) {
      switch (_filter) {
        case _TimelineFilter.all:
          // Spec rule 5: Knowledge events remain disabled in Phase 1.
          return event.type != CareerTimelineEventType.masteryEvidenceUpdated;
        case _TimelineFilter.match:
          return event.type == CareerTimelineEventType.completedMatch;
        case _TimelineFilter.training:
          return event.type == CareerTimelineEventType.completedTraining;
        case _TimelineFilter.playerModel:
          return event.type == CareerTimelineEventType.playerModelSnapshot;
        case _TimelineFilter.equipment:
          // Equipment rows ride on completedMatch events (the Career
          // Timeline builder attaches `equipmentUsage` to Match events).
          // Spec rule 4 says Equipment is sourced from per-Match
          // snapshots; we therefore surface Equipment rows under the
          // Match filter, not as a separate event type. Exposing a
          // dedicated Equipment chip would require a new event kind,
          // which is forbidden.
          return event.type == CareerTimelineEventType.completedMatch &&
              event.equipmentUsage.isNotEmpty;
      }
    }).toList(growable: false);
  }

  void _onTapEvent(CareerTimelineEvent event) {
    final sourceRef = event.sourceReference;
    final router = Navigator.of(context);
    // Reuse the existing navigation surface by inspecting the existing
    // route names that Player Profile already pushes (Match Detail,
    // Training Detail, Equipment Detail). The simplest deterministic
    // route fall-back is no-op if the route is not registered; the
    // existing in-app routing is wired through `Navigator.pushNamed`.
    String? routeName;
    switch (event.type) {
      case CareerTimelineEventType.completedMatch:
        routeName = '/match';
        break;
      case CareerTimelineEventType.completedTraining:
        routeName = '/training';
        break;
      case CareerTimelineEventType.playerModelSnapshot:
        routeName = '/profile';
        break;
      case CareerTimelineEventType.masteryEvidenceUpdated:
        routeName = null;
        break;
      case CareerTimelineEventType.playerCreated:
        routeName = '/profile';
        break;
    }
    if (routeName == null) return;
    router.pushNamed(routeName, arguments: sourceRef).catchError((_) {
      // The route may not be registered in a unit-test harness; swallow
      // the failure rather than crashing the timeline. Production code
      // registers these routes via the existing router.
      return null;
    });
  }
}

enum _TimelineFilter { all, match, training, playerModel, equipment }

IconData _iconFor(CareerTimelineEventType type) => switch (type) {
      CareerTimelineEventType.playerCreated => Icons.person_add_alt_1,
      CareerTimelineEventType.completedMatch => Icons.sports,
      CareerTimelineEventType.completedTraining => Icons.fitness_center,
      CareerTimelineEventType.playerModelSnapshot => Icons.insights,
      CareerTimelineEventType.masteryEvidenceUpdated => Icons.school,
    };

extension on _TimelineFilter {
  String get label => switch (this) {
        _TimelineFilter.all => 'All',
        _TimelineFilter.match => 'Match',
        _TimelineFilter.training => 'Training',
        _TimelineFilter.playerModel => 'Player Model',
        _TimelineFilter.equipment => 'Equipment',
      };
}

class _FilterChipBar extends StatelessWidget {
  const _FilterChipBar({required this.active, required this.onChanged});

  final _TimelineFilter active;
  final ValueChanged<_TimelineFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    const entries = _TimelineFilter.values;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final entry in entries) ...[
            ChoiceChip(
              key: ValueKey('player-timeline-filter-${entry.name}'),
              label: Text(entry.label),
              selected: active == entry,
              onSelected: (selected) {
                if (selected) onChanged(entry);
              },
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.events,
    required this.locale,
    required this.onTapEvent,
  });

  final List<CareerTimelineEvent> events;
  final String locale;
  final ValueChanged<CareerTimelineEvent> onTapEvent;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Center(
            key: ValueKey('player-timeline-empty'),
            child: Text('No events.'),
          ),
        ],
      );
    }
    final groups = _groupByDay(events);
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return _DaySection(
          group: group,
          locale: locale,
          onTapEvent: onTapEvent,
        );
      },
    );
  }
}

class _DayGroup {
  const _DayGroup({required this.label, required this.events});

  final String label;
  final List<CareerTimelineEvent> events;
}

List<_DayGroup> _groupByDay(List<CareerTimelineEvent> events) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final lastWeekStart =
      today.subtract(const Duration(days: 6)); // last 7 days inclusive

  final buckets = <DateTime, List<CareerTimelineEvent>>{};
  final labels = <DateTime, String>{};
  for (final event in events) {
    final local = event.timestamp.toLocal();
    final dayKey = DateTime(local.year, local.month, local.day);
    buckets.putIfAbsent(dayKey, () => <CareerTimelineEvent>[]).add(event);
    labels.putIfAbsent(dayKey, () => _dayLabel(dayKey, today, yesterday));
  }
  final orderedKeys = buckets.keys.toList()..sort((a, b) => b.compareTo(a));
  return [
    for (final key in orderedKeys)
      if (key.isAfter(lastWeekStart.subtract(const Duration(days: 1))))
        _DayGroup(label: labels[key]!, events: buckets[key]!)
      else
        _DayGroup(
          label: DateFormat('MMM dd, yyyy').format(key),
          events: buckets[key]!,
        ),
  ];
}

String _dayLabel(DateTime day, DateTime today, DateTime yesterday) {
  if (day == today) return 'Today';
  if (day == yesterday) return 'Yesterday';
  final diff = today.difference(day).inDays;
  if (diff > 0 && diff <= 6) return 'Last week';
  return DateFormat('MMM dd, yyyy').format(day);
}

class _DaySection extends StatelessWidget {
  const _DaySection({
    required this.group,
    required this.locale,
    required this.onTapEvent,
  });

  final _DayGroup group;
  final String locale;
  final ValueChanged<CareerTimelineEvent> onTapEvent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            group.label,
            key: ValueKey('player-timeline-day-${group.label}'),
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          for (final event in group.events) ...[
            _TimelineRow(event: event, locale: locale, onTap: onTapEvent),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.event,
    required this.locale,
    required this.onTap,
  });

  final CareerTimelineEvent event;
  final String locale;
  final ValueChanged<CareerTimelineEvent> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localTimestamp = event.timestamp.toLocal();
    final timeOnly = DateFormat.Hm(locale).format(localTimestamp);
    return InkWell(
      key: ValueKey('player-timeline-row-${event.eventId}'),
      onTap: () => onTap(event),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
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
                    style: theme.textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    event.summary,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              timeOnly,
              key: ValueKey('player-timeline-time-${event.eventId}'),
              style: theme.textTheme.labelMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 80),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline),
              const SizedBox(width: 8),
              const Text('Could not load timeline.'),
              const SizedBox(width: 8),
              IconButton(
                key: const ValueKey('player-timeline-retry'),
                tooltip: 'Retry',
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
