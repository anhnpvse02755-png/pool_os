// Task 11 — Player Timeline & Career domain models.
//
// Pure Dart, no persistence. This feature is a READ-ONLY aggregation over data
// the player already recorded across other features (sessions, matches, racks,
// equipment/cues, Task 09 training, Task 10 goals/achievements). It stores
// nothing new — no DB tables, no migration. It only reads and presents the
// player's development journey as a timeline + a career summary. No AI, no
// coach, no recommendation. Nothing here touches the LOCKED recording pipeline.

/// The category of a [TimelineEvent], used both for its icon/label and as the
/// filter dimension (Phần 7 — Search & Filter). Each value maps to one source
/// the aggregator reads from.
enum TimelineEventType {
  /// A recording session was started (practice or match session).
  session,

  /// A match finished with a decided winner (win/loss).
  match,

  /// A goal was completed (Task 10).
  goal,

  /// An achievement / streak / milestone was unlocked (Task 10).
  achievement,

  /// A cue / equipment item was added (Task 04 equipment).
  equipment,

  /// A training session was logged (Task 09 Training Center).
  training,
}

extension TimelineEventTypeInfo on TimelineEventType {
  /// Stable code (used by the filter chips + l10n keys). Never localized.
  String get code {
    switch (this) {
      case TimelineEventType.session:
        return 'session';
      case TimelineEventType.match:
        return 'match';
      case TimelineEventType.goal:
        return 'goal';
      case TimelineEventType.achievement:
        return 'achievement';
      case TimelineEventType.equipment:
        return 'equipment';
      case TimelineEventType.training:
        return 'training';
    }
  }

  /// l10n key for the filter label / section header.
  String get labelKey => 'career_filter_$code';
}

/// One entry on the player's development timeline (Phần 1). Denormalised, pure
/// display data built by the aggregator from a source row. [title] and
/// [subtitle] are already-resolved display strings (the aggregator localizes
/// them once), so the widget just renders. [detail] carries an optional extra
/// line (e.g. a race format or run length). [win] is set only for match events.
class TimelineEvent {
  final DateTime date;
  final TimelineEventType type;
  final String title;
  final String? subtitle;
  final String? detail;

  /// For match events: true = win, false = loss, null = not a match / undecided.
  final bool? win;

  const TimelineEvent({
    required this.date,
    required this.type,
    required this.title,
    this.subtitle,
    this.detail,
    this.win,
  });
}

/// A group of [TimelineEvent]s that fall on the same calendar day (Phần 1 —
/// the timeline renders day headers with the events beneath).
class TimelineDay {
  final DateTime day; // date-only (midnight local)
  final List<TimelineEvent> events;

  const TimelineDay({required this.day, required this.events});
}

/// Phần 2 — Career Summary. A read-only roll-up of the whole journey. Every
/// field is counted from real recorded rows; nothing is fabricated (a player
/// with no data gets zeros and a null [startedAt]).
class CareerSummary {
  final DateTime? startedAt; // first recorded activity, null if none
  final int totalMatches;
  final int totalRacks;
  final int totalShots;
  final double totalHours;
  final int goalsCompleted;
  final int achievementsUnlocked;
  final int equipmentUsed; // distinct cues/equipment owned
  final int matchesWon;
  final int trainingSessions;

  const CareerSummary({
    this.startedAt,
    this.totalMatches = 0,
    this.totalRacks = 0,
    this.totalShots = 0,
    this.totalHours = 0,
    this.goalsCompleted = 0,
    this.achievementsUnlocked = 0,
    this.equipmentUsed = 0,
    this.matchesWon = 0,
    this.trainingSessions = 0,
  });

  bool get isEmpty =>
      totalMatches == 0 &&
      totalRacks == 0 &&
      totalShots == 0 &&
      trainingSessions == 0;

  /// Number of days since the journey started (inclusive), or 0 when empty.
  int daysSinceStart(DateTime now) {
    if (startedAt == null) return 0;
    final start = DateTime(startedAt!.year, startedAt!.month, startedAt!.day);
    final today = DateTime(now.year, now.month, now.day);
    return today.difference(start).inDays + 1;
  }
}
