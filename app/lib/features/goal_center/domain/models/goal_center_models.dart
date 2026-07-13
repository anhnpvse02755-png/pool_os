// Task 10 — Goal & Progress Center domain models.
//
// Pure Dart, no persistence annotations (mirrors the training_center/ feature).
// This layer is a NON-AI goal, achievement, streak and milestone system. Goals
// track a live [GoalMetric] computed read-only from data the player already
// recorded; achievements/streaks/milestones are derived on demand and only
// their unlocked-at timestamp is persisted. Nothing here writes to the LOCKED
// RFC-301/302 recording pipeline — it only reads from it.

/// How a [Goal]'s progress is measured. Each metric knows its unit ([isPercent]
/// vs a raw count) so the UI can render "72% → 80%" or "0 / 1" correctly. The
/// [PlayerMetrics] snapshot supplies the current value for every metric; goals
/// never fabricate data — a metric with no underlying attempts reports 0.
enum GoalMetric {
  /// Count of matches won (winner == 'Player').
  matchesWon,

  /// Count of break-and-run racks (break made + ran the rack out).
  breakAndRuns,

  /// Long-pot (hard/extreme difficulty) success rate, 0..100.
  longPotRate,

  /// Stop-shot proxy success rate from position play, 0..100.
  stopShotRate,

  /// Total shots recorded.
  totalShots,

  /// Total matches played.
  totalMatches,

  /// Total racks played.
  totalRacks,

  /// Total hours logged across finished recording sessions + training.
  practiceHours,

  /// Longest current streak of consecutive scratch-free matches, count.
  scratchFreeMatches,

  /// Consecutive days with at least one practice/training session, count.
  trainingDayStreak,
}

extension GoalMetricInfo on GoalMetric {
  /// Stable code stored in the DB (never localized, never reordered).
  String get code {
    switch (this) {
      case GoalMetric.matchesWon:
        return 'matches_won';
      case GoalMetric.breakAndRuns:
        return 'break_and_runs';
      case GoalMetric.longPotRate:
        return 'long_pot_rate';
      case GoalMetric.stopShotRate:
        return 'stop_shot_rate';
      case GoalMetric.totalShots:
        return 'total_shots';
      case GoalMetric.totalMatches:
        return 'total_matches';
      case GoalMetric.totalRacks:
        return 'total_racks';
      case GoalMetric.practiceHours:
        return 'practice_hours';
      case GoalMetric.scratchFreeMatches:
        return 'scratch_free_matches';
      case GoalMetric.trainingDayStreak:
        return 'training_day_streak';
    }
  }

  /// A percentage metric renders "72% → 80%"; otherwise "3 / 10".
  bool get isPercent =>
      this == GoalMetric.longPotRate || this == GoalMetric.stopShotRate;

  /// l10n key for the human label (see app_localizations gc_metric_*).
  String get labelKey => 'gc_metric_$code';

  static GoalMetric fromCode(String code) {
    return GoalMetric.values.firstWhere(
      (m) => m.code == code,
      orElse: () => GoalMetric.totalShots,
    );
  }
}

/// Phần 1/2 — a goal the player is pursuing. Progress against [target] is
/// computed live from a [PlayerMetrics] snapshot; nothing is stored except the
/// definition, a creation-time [baseline] (so rate goals measure improvement
/// since the goal began), and completion bookkeeping.
class Goal {
  final int? id;
  final int? playerId;
  final String title;
  final GoalMetric metric;
  final double target;
  final double baseline;
  final String? note;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime? completedAt;
  final double lastNotifiedProgress;

  const Goal({
    this.id,
    this.playerId,
    required this.title,
    required this.metric,
    required this.target,
    this.baseline = 0,
    this.note,
    this.isDefault = false,
    required this.createdAt,
    this.completedAt,
    this.lastNotifiedProgress = 0,
  });

  bool get isComplete => completedAt != null;

  Goal copyWith({
    int? id,
    int? playerId,
    String? title,
    GoalMetric? metric,
    double? target,
    double? baseline,
    String? note,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? completedAt,
    double? lastNotifiedProgress,
  }) {
    return Goal(
      id: id ?? this.id,
      playerId: playerId ?? this.playerId,
      title: title ?? this.title,
      metric: metric ?? this.metric,
      target: target ?? this.target,
      baseline: baseline ?? this.baseline,
      note: note ?? this.note,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      lastNotifiedProgress: lastNotifiedProgress ?? this.lastNotifiedProgress,
    );
  }
}

/// A [Goal] paired with its live progress against a [PlayerMetrics] snapshot.
/// Pure view data — no persistence. For count metrics [current]/[target] are
/// raw counts; for percent metrics they are 0..100.
class GoalProgress {
  final Goal goal;

  /// Current metric value (already baseline-adjusted for count metrics that
  /// started mid-history — see [GoalEvaluator]).
  final double current;

  /// The finish line in the SAME (baseline-adjusted) unit as [current], so
  /// current/target reads honestly. For a "win 10 more matches" goal this is 10,
  /// not the absolute 50 stored on the goal. For rate goals it equals the stored
  /// target (no baseline maths).
  final double target;

  const GoalProgress({
    required this.goal,
    required this.current,
    required this.target,
  });

  /// 0.0–1.0 clamped. Zero target guards against divide-by-zero.
  double get ratio =>
      target <= 0 ? 0.0 : (current / target).clamp(0.0, 1.0).toDouble();

  /// Reached the finish line (independent of the stored completedAt, so the UI
  /// reflects live data even before the repository persists completion).
  bool get isReached => current >= target;

  int get percent => (ratio * 100).round();
}

/// Phần 3/4/5 — a badge the player can unlock: an achievement, a streak level,
/// or a milestone. Definitions live in [AchievementCatalog]; each knows how to
/// read its current value from a [PlayerMetrics] snapshot and whether it is
/// unlocked. Only the first-unlock timestamp is persisted (AchievementUnlocks).
enum BadgeKind { achievement, streak, milestone }

class Badge {
  final String key; // stable catalog code
  final BadgeKind kind;
  final String titleKey; // l10n key
  final String descriptionKey; // l10n key

  /// Reads the current progress value for this badge from a metrics snapshot.
  final double Function(PlayerMetrics) valueOf;

  /// The value at which the badge unlocks.
  final double threshold;

  const Badge({
    required this.key,
    required this.kind,
    required this.titleKey,
    required this.descriptionKey,
    required this.valueOf,
    required this.threshold,
  });

  double progressValue(PlayerMetrics m) => valueOf(m);

  bool isUnlocked(PlayerMetrics m) => valueOf(m) >= threshold;

  double ratio(PlayerMetrics m) =>
      threshold <= 0 ? 0.0 : (valueOf(m) / threshold).clamp(0.0, 1.0).toDouble();
}

/// A [Badge] resolved against a metrics snapshot, plus persisted unlock state.
class BadgeStatus {
  final Badge badge;
  final double current;
  final bool unlocked;
  final DateTime? unlockedAt;
  final bool isNew; // unlocked but not yet marked seen

  const BadgeStatus({
    required this.badge,
    required this.current,
    required this.unlocked,
    this.unlockedAt,
    this.isNew = false,
  });

  double get ratio => badge.threshold <= 0
      ? 0.0
      : (current / badge.threshold).clamp(0.0, 1.0).toDouble();
}

/// An immutable snapshot of every raw number the goal/achievement layer needs,
/// computed once (read-only) from the recording pipeline + training tables so
/// each goal and badge is a pure function of this struct. Keeping it flat makes
/// the [GoalEvaluator] and [AchievementCatalog] trivially unit-testable with
/// hand-built fixtures — no DB required.
class PlayerMetrics {
  final int matchesWon;
  final int breakAndRuns;
  final double longPotRate; // 0..100
  final int longPotAttempts;
  final double stopShotRate; // 0..100
  final int stopShotAttempts;
  final int totalShots;
  final int totalMatches;
  final int totalRacks;
  final double practiceHours;
  final int scratchFreeMatches; // current trailing streak
  final int trainingDayStreak; // consecutive practice days
  final int matchWinStreak; // current trailing win streak

  const PlayerMetrics({
    this.matchesWon = 0,
    this.breakAndRuns = 0,
    this.longPotRate = 0,
    this.longPotAttempts = 0,
    this.stopShotRate = 0,
    this.stopShotAttempts = 0,
    this.totalShots = 0,
    this.totalMatches = 0,
    this.totalRacks = 0,
    this.practiceHours = 0,
    this.scratchFreeMatches = 0,
    this.trainingDayStreak = 0,
    this.matchWinStreak = 0,
  });

  /// Raw value for a [GoalMetric] in that metric's unit.
  double valueFor(GoalMetric metric) {
    switch (metric) {
      case GoalMetric.matchesWon:
        return matchesWon.toDouble();
      case GoalMetric.breakAndRuns:
        return breakAndRuns.toDouble();
      case GoalMetric.longPotRate:
        return longPotRate;
      case GoalMetric.stopShotRate:
        return stopShotRate;
      case GoalMetric.totalShots:
        return totalShots.toDouble();
      case GoalMetric.totalMatches:
        return totalMatches.toDouble();
      case GoalMetric.totalRacks:
        return totalRacks.toDouble();
      case GoalMetric.practiceHours:
        return practiceHours;
      case GoalMetric.scratchFreeMatches:
        return scratchFreeMatches.toDouble();
      case GoalMetric.trainingDayStreak:
        return trainingDayStreak.toDouble();
    }
  }

  /// True when a metric is a monotonic counter (progress = total, not a rate).
  /// Rate metrics (long pot / stop shot) are NOT baseline-adjusted — the goal
  /// is "reach 80%", not "add 80 points".
  static bool isCumulative(GoalMetric metric) {
    switch (metric) {
      case GoalMetric.matchesWon:
      case GoalMetric.breakAndRuns:
      case GoalMetric.totalShots:
      case GoalMetric.totalMatches:
      case GoalMetric.totalRacks:
      case GoalMetric.practiceHours:
        return true;
      case GoalMetric.longPotRate:
      case GoalMetric.stopShotRate:
      case GoalMetric.scratchFreeMatches:
      case GoalMetric.trainingDayStreak:
        return false;
    }
  }
}
