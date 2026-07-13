import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/goal_center/data/repositories/goal_center_repository.dart';
import 'package:pool_os/features/goal_center/domain/achievement_catalog.dart';
import 'package:pool_os/features/goal_center/domain/goal_evaluator.dart';
import 'package:pool_os/features/goal_center/domain/models/goal_center_models.dart';

// Task 10 — Goal & Progress Center providers. Every read comes from the
// repository (DB) or the pure evaluator over a real metrics snapshot; nothing
// is fabricated (DoD: no fake data). No AI, no recommendation — just goals,
// achievements, streaks and milestones computed from recorded play.

/// The live [PlayerMetrics] snapshot, computed read-only from the recording
/// pipeline + training tables. Every goal and badge is scored against this.
final playerMetricsProvider = FutureProvider<PlayerMetrics>((ref) async {
  final repo = ref.watch(goalCenterRepositoryProvider);
  return repo.computeMetrics();
});

/// All goals, active-first (Phần 1/2). Refreshable after create/update/delete.
final goalsProvider = FutureProvider<List<Goal>>((ref) async {
  final repo = ref.watch(goalCenterRepositoryProvider);
  return repo.getGoals();
});

/// Goals paired with live progress against the metrics snapshot. Persists
/// completion the first time a goal is reached so the UI shows a "done" state
/// and the badge/notification layers can react. Side-effect kept here (not in
/// build of a widget) so it runs once per recompute.
final goalProgressProvider =
    FutureProvider<List<GoalProgress>>((ref) async {
  final repo = ref.watch(goalCenterRepositoryProvider);
  final goals = await ref.watch(goalsProvider.future);
  final metrics = await ref.watch(playerMetricsProvider.future);

  final progresses = GoalEvaluator.progressForAll(goals, metrics);

  // Persist first-time completion (idempotent — only when not already stored).
  for (final p in progresses) {
    if (p.isReached && !p.goal.isComplete && p.goal.id != null) {
      await repo.markGoalComplete(p.goal.id!, DateTime.now());
    }
  }
  return progresses;
});

/// Whether any active goal has crossed a new notify threshold (Phần 7). Returns
/// the goals + their freshly-crossed threshold so the UI can surface an in-app
/// banner, then persists lastNotifiedProgress so each threshold fires once.
class GoalNotice {
  final Goal goal;
  final GoalProgress progress;
  final double threshold; // 0.5 / 0.75 / 0.9 / 1.0

  const GoalNotice({
    required this.goal,
    required this.progress,
    required this.threshold,
  });
}

final goalNoticesProvider = FutureProvider<List<GoalNotice>>((ref) async {
  final repo = ref.watch(goalCenterRepositoryProvider);
  final progresses = await ref.watch(goalProgressProvider.future);

  final notices = <GoalNotice>[];
  for (final p in progresses) {
    if (p.goal.id == null) continue;
    final t = GoalEvaluator.nextGoalNotifyThreshold(
      p,
      p.goal.lastNotifiedProgress,
    );
    if (t != null) {
      notices.add(GoalNotice(goal: p.goal, progress: p, threshold: t));
      await repo.setGoalNotifiedProgress(p.goal.id!, t);
    }
  }
  return notices;
});

/// Resolved badge statuses for every catalog entry, split by kind. Persists any
/// newly-unlocked badge's timestamp (once) so the "mới" flag and notifications
/// work. Returns all three kinds in one struct to avoid recomputing metrics.
class BadgeBoard {
  final List<BadgeStatus> achievements;
  final List<BadgeStatus> streaks;
  final List<BadgeStatus> milestones;

  const BadgeBoard({
    required this.achievements,
    required this.streaks,
    required this.milestones,
  });

  List<BadgeStatus> get all => [...achievements, ...streaks, ...milestones];

  int get unlockedCount => all.where((b) => b.unlocked).length;

  List<BadgeStatus> get newlyUnlocked =>
      all.where((b) => b.isNew).toList();
}

final badgeBoardProvider = FutureProvider<BadgeBoard>((ref) async {
  final repo = ref.watch(goalCenterRepositoryProvider);
  final metrics = await ref.watch(playerMetricsProvider.future);

  // Persist first-time unlocks so "new" + timestamps are stable across reloads.
  final stored = await repo.getUnlockedAt();
  final fresh = GoalEvaluator.newlyUnlockedKeys(metrics, stored.keys.toSet());
  if (fresh.isNotEmpty) {
    final now = DateTime.now();
    for (final key in fresh) {
      await repo.recordUnlock(key, now);
    }
  }

  final unlockedAt = await repo.getUnlockedAt();
  final seen = await repo.getSeenKeys();

  List<BadgeStatus> resolve(List<Badge> badges) => GoalEvaluator.badgeStatuses(
        badges,
        metrics,
        unlockedAt: unlockedAt,
        seen: seen,
      );

  return BadgeBoard(
    achievements: resolve(AchievementCatalog.achievements),
    streaks: resolve(AchievementCatalog.streaks),
    milestones: resolve(AchievementCatalog.milestones),
  );
});

/// Controller for goal mutations + acknowledging "new" badges. Kept thin: it
/// delegates to the repository and invalidates the read providers so the UI
/// refreshes from the source of truth.
class GoalCenterController {
  final Ref _ref;
  GoalCenterController(this._ref);

  GoalCenterRepository get _repo =>
      _ref.read(goalCenterRepositoryProvider);

  /// Create a goal. For cumulative metrics [amount] is "how many more"; the
  /// baseline + target are computed from the current metrics snapshot so the
  /// goal reads honestly ("win 10 matches" = 10 more wins from now).
  Future<void> createGoal({
    required String title,
    required GoalMetric metric,
    required double amount,
    String? note,
    bool isDefault = false,
  }) async {
    final metrics = await _ref.read(playerMetricsProvider.future);
    final target = GoalEvaluator.targetForNewGoal(metric, amount, metrics);
    final baseline = GoalEvaluator.baselineForNewGoal(metric, metrics);
    await _repo.createGoal(Goal(
      title: title,
      metric: metric,
      target: target,
      baseline: baseline,
      note: note,
      isDefault: isDefault,
      createdAt: DateTime.now(),
    ));
    _invalidate();
  }

  Future<void> deleteGoal(int id) async {
    await _repo.deleteGoal(id);
    _invalidate();
  }

  Future<void> acknowledgeBadges(Iterable<String> keys) async {
    await _repo.markSeen(keys);
    _ref.invalidate(badgeBoardProvider);
  }

  void _invalidate() {
    _ref.invalidate(goalsProvider);
    _ref.invalidate(goalProgressProvider);
    _ref.invalidate(goalNoticesProvider);
    _ref.invalidate(badgeBoardProvider);
  }
}

final goalCenterControllerProvider = Provider<GoalCenterController>((ref) {
  return GoalCenterController(ref);
});

/// Default goals seeded on first visit (Phần 1 — "Có Goal mặc định"). Idempotent
/// via [GoalCenterRepository.hasAnyGoal]; runs against the current metrics so
/// cumulative baselines are correct. Returns true if it seeded.
final seedDefaultGoalsProvider = FutureProvider<bool>((ref) async {
  final repo = ref.watch(goalCenterRepositoryProvider);
  if (await repo.hasAnyGoal()) return false;

  final metrics = await repo.computeMetrics();
  final now = DateTime.now();

  // A small, sensible starter set spanning counts + rates (Phần 1 examples).
  final defaults = <_DefaultGoal>[
    _DefaultGoal('gc_default_first_bnr', GoalMetric.breakAndRuns, 1),
    _DefaultGoal('gc_default_long_pot_70', GoalMetric.longPotRate, 70),
    _DefaultGoal('gc_default_stop_shot_80', GoalMetric.stopShotRate, 80),
    _DefaultGoal('gc_default_win_10', GoalMetric.matchesWon, 10),
    _DefaultGoal('gc_default_scratch_free_10', GoalMetric.scratchFreeMatches, 10),
  ];

  for (final d in defaults) {
    await repo.createGoal(Goal(
      title: d.titleKey, // resolved to l10n at display time
      metric: d.metric,
      target: GoalEvaluator.targetForNewGoal(d.metric, d.amount, metrics),
      baseline: GoalEvaluator.baselineForNewGoal(d.metric, metrics),
      isDefault: true,
      createdAt: now,
    ));
  }
  return true;
});

class _DefaultGoal {
  final String titleKey;
  final GoalMetric metric;
  final double amount;
  const _DefaultGoal(this.titleKey, this.metric, this.amount);
}
