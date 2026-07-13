import 'models/career_models.dart';

/// Task 11 — pure timeline logic (no DB, no Flutter). Takes a flat list of
/// [TimelineEvent]s (built by the repository from real recorded rows) and
/// applies filtering + day-grouping for display. Deterministic and unit-
/// testable with hand-built fixtures. No AI, no fabrication — it only orders
/// and groups what actually happened.
class TimelineAggregator {
  const TimelineAggregator._();

  /// Filter events by the selected [types] (Phần 7). An empty/absent selection
  /// means "all types". Optionally bound by [from]/[to] (inclusive) for the
  /// time filter. Preserves input order among matches.
  static List<TimelineEvent> filter(
    List<TimelineEvent> events, {
    Set<TimelineEventType>? types,
    DateTime? from,
    DateTime? to,
  }) {
    return events.where((e) {
      if (types != null && types.isNotEmpty && !types.contains(e.type)) {
        return false;
      }
      if (from != null && e.date.isBefore(from)) return false;
      if (to != null && e.date.isAfter(to)) return false;
      return true;
    }).toList();
  }

  /// Group events into [TimelineDay]s, newest day first and newest event first
  /// within each day (Phần 1 — the journal reads top-down, most recent first).
  static List<TimelineDay> groupByDay(List<TimelineEvent> events) {
    final byDay = <DateTime, List<TimelineEvent>>{};
    for (final e in events) {
      final day = DateTime(e.date.year, e.date.month, e.date.day);
      byDay.putIfAbsent(day, () => []).add(e);
    }

    final days = byDay.keys.toList()..sort((a, b) => b.compareTo(a));
    return days.map((day) {
      final dayEvents = byDay[day]!
        ..sort((a, b) => b.date.compareTo(a.date));
      return TimelineDay(day: day, events: dayEvents);
    }).toList();
  }

  /// Convenience: filter then group in one call.
  static List<TimelineDay> filterAndGroup(
    List<TimelineEvent> events, {
    Set<TimelineEventType>? types,
    DateTime? from,
    DateTime? to,
  }) {
    return groupByDay(filter(events, types: types, from: from, to: to));
  }
}
