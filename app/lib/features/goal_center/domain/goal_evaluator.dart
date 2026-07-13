import 'achievement_catalog.dart';
import 'models/goal_center_models.dart';

/// Task 10 — pure goal/achievement logic (no DB, no Flutter). Every method is a
/// deterministic function of a [PlayerMetrics] snapshot plus stored state, so it
/// can be unit-tested with hand-built fixtures. There is NO AI: progress is
/// arithmetic against fixed targets, and a badge unlocks only when a real value
/// crosses a fixed threshold.
class GoalEvaluator {
  const GoalEvaluator._();

  /// Progress for one goal against a metrics snapshot.
  ///
  /// For cumulative counters (matches won, total shots, hours…) the goal means
  /// "reach N *from when I started this goal*", so the creation-time baseline is
  /// subtracted from both current and target. A goal created after 40 matches
  /// won with target 10 needs 10 *more* wins (baseline 40 → done at 50), which
  /// is the honest reading of "win 10 matches". Rate metrics are absolute (reach
  /// 80%), so no baseline maths applies.
  static GoalProgress progressFor(Goal goal, PlayerMetrics metrics) {
    final raw = metrics.valueFor(goal.metric);
    if (PlayerMetrics.isCumulative(goal.metric)) {
      // "Reach N more from now": both current and target are measured relative
      // to the creation-time baseline, so 45 wins on a baseline-40/target-50
      // goal reads as 5 / 10, not 5 / 50.
      final current = (raw - goal.baseline).clamp(0.0, double.infinity);
      final target = (goal.target - goal.baseline).clamp(0.0, double.infinity);
      return GoalProgress(
        goal: goal,
        current: current.toDouble(),
        target: target.toDouble(),
      );
    }
    // Rate metrics are absolute — the stored target is the finish line as-is.
    return GoalProgress(goal: goal, current: raw, target: goal.target);
  }

  /// Compute progress for many goals at once (display order preserved).
  static List<GoalProgress> progressForAll(
    List<Goal> goals,
    PlayerMetrics metrics,
  ) {
    return goals.map((g) => progressFor(g, metrics)).toList();
  }

  /// The target value to store for a cumulative goal so the UI reads
  /// "reach [amount] more". For a cumulative metric this is baseline + amount;
  /// for a rate metric the target is the absolute percentage the player typed.
  static double targetForNewGoal(
    GoalMetric metric,
    double amount,
    PlayerMetrics metricsAtCreation,
  ) {
    if (PlayerMetrics.isCumulative(metric)) {
      return metricsAtCreation.valueFor(metric) + amount;
    }
    return amount;
  }

  /// Baseline to snapshot at goal creation (only meaningful for cumulative
  /// metrics; rate metrics store 0).
  static double baselineForNewGoal(
    GoalMetric metric,
    PlayerMetrics metricsAtCreation,
  ) {
    return PlayerMetrics.isCumulative(metric)
        ? metricsAtCreation.valueFor(metric)
        : 0;
  }

  /// Resolve every catalog badge against a metrics snapshot + persisted unlock
  /// timestamps. [unlockedAt] maps badgeKey → first-unlock time; [seen] is the
  /// set of badge keys already acknowledged (so isNew is false for them).
  static List<BadgeStatus> badgeStatuses(
    List<Badge> badges,
    PlayerMetrics metrics, {
    required Map<String, DateTime> unlockedAt,
    required Set<String> seen,
  }) {
    return badges.map((b) {
      final current = b.progressValue(metrics);
      final unlocked = b.isUnlocked(metrics) || unlockedAt.containsKey(b.key);
      return BadgeStatus(
        badge: b,
        current: current,
        unlocked: unlocked,
        unlockedAt: unlockedAt[b.key],
        isNew: unlocked && !seen.contains(b.key),
      );
    }).toList();
  }

  /// Badge keys that are unlocked by the metrics but have no stored timestamp
  /// yet — the repository persists these (with now()) so they unlock exactly
  /// once. Pure: caller supplies the already-known keys.
  static List<String> newlyUnlockedKeys(
    PlayerMetrics metrics,
    Set<String> alreadyStored,
  ) {
    return AchievementCatalog.all
        .where((b) => b.isUnlocked(metrics) && !alreadyStored.contains(b.key))
        .map((b) => b.key)
        .toList();
  }

  // --- Notifications (Phần 7) ----------------------------------------------

  /// A "you're almost there" / "you just completed" in-app notice for a goal.
  static const List<double> _notifyThresholds = [0.5, 0.75, 0.9, 1.0];

  /// Given a goal's progress and the highest ratio already notified, returns the
  /// next crossed threshold to fire (or null). Fires once per threshold: 50%,
  /// 75%, 90%, 100%. Caller persists the returned ratio as lastNotifiedProgress.
  static double? nextGoalNotifyThreshold(GoalProgress p, double lastNotified) {
    double? fire;
    for (final t in _notifyThresholds) {
      if (p.ratio >= t && lastNotified < t) {
        fire = t; // keep the highest crossed threshold
      }
    }
    return fire;
  }
}
