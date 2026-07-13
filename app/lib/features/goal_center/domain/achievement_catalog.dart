import 'models/goal_center_models.dart';

/// Task 10 — the fixed catalog of achievements, streaks and milestones (Phần
/// 3/4/5). Each [Badge] is a pure definition: how to read its value from a
/// [PlayerMetrics] snapshot and the threshold at which it unlocks. There is NO
/// AI here — a badge is unlocked iff its real recorded value crosses a fixed
/// line. Titles/descriptions are l10n keys resolved in the UI.
///
/// Keys are stable strings persisted in AchievementUnlocks; never rename or
/// reorder existing entries (append new ones).
class AchievementCatalog {
  const AchievementCatalog._();

  // --- Phần 3 — Achievements (one-off firsts + count feats) ----------------
  static final List<Badge> achievements = [
    Badge(
      key: 'first_match_win',
      kind: BadgeKind.achievement,
      titleKey: 'gc_ach_first_match_win',
      descriptionKey: 'gc_ach_first_match_win_desc',
      valueOf: (m) => m.matchesWon.toDouble(),
      threshold: 1,
    ),
    Badge(
      key: 'first_break_and_run',
      kind: BadgeKind.achievement,
      titleKey: 'gc_ach_first_bnr',
      descriptionKey: 'gc_ach_first_bnr_desc',
      valueOf: (m) => m.breakAndRuns.toDouble(),
      threshold: 1,
    ),
    Badge(
      key: 'win_streak_5',
      kind: BadgeKind.achievement,
      titleKey: 'gc_ach_win_streak_5',
      descriptionKey: 'gc_ach_win_streak_5_desc',
      valueOf: (m) => m.matchWinStreak.toDouble(),
      threshold: 5,
    ),
    Badge(
      key: 'shots_1000',
      kind: BadgeKind.achievement,
      titleKey: 'gc_ach_shots_1000',
      descriptionKey: 'gc_ach_shots_1000_desc',
      valueOf: (m) => m.totalShots.toDouble(),
      threshold: 1000,
    ),
    Badge(
      key: 'matches_100',
      kind: BadgeKind.achievement,
      titleKey: 'gc_ach_matches_100',
      descriptionKey: 'gc_ach_matches_100_desc',
      valueOf: (m) => m.totalMatches.toDouble(),
      threshold: 100,
    ),
    Badge(
      key: 'long_pot_70',
      kind: BadgeKind.achievement,
      titleKey: 'gc_ach_long_pot_70',
      descriptionKey: 'gc_ach_long_pot_70_desc',
      valueOf: (m) => m.longPotRate,
      threshold: 70,
    ),
  ];

  // --- Phần 4 — Streaks -----------------------------------------------------
  static final List<Badge> streaks = [
    Badge(
      key: 'train_streak_7',
      kind: BadgeKind.streak,
      titleKey: 'gc_streak_train_7',
      descriptionKey: 'gc_streak_train_7_desc',
      valueOf: (m) => m.trainingDayStreak.toDouble(),
      threshold: 7,
    ),
    Badge(
      key: 'train_streak_10',
      kind: BadgeKind.streak,
      titleKey: 'gc_streak_train_10',
      descriptionKey: 'gc_streak_train_10_desc',
      valueOf: (m) => m.trainingDayStreak.toDouble(),
      threshold: 10,
    ),
    Badge(
      key: 'scratch_free_10',
      kind: BadgeKind.streak,
      titleKey: 'gc_streak_scratch_free_10',
      descriptionKey: 'gc_streak_scratch_free_10_desc',
      valueOf: (m) => m.scratchFreeMatches.toDouble(),
      threshold: 10,
    ),
  ];

  // --- Phần 5 — Milestones (cumulative totals) ------------------------------
  static final List<Badge> milestones = [
    Badge(
      key: 'milestone_matches_100',
      kind: BadgeKind.milestone,
      titleKey: 'gc_mile_matches_100',
      descriptionKey: 'gc_mile_matches_100_desc',
      valueOf: (m) => m.totalMatches.toDouble(),
      threshold: 100,
    ),
    Badge(
      key: 'milestone_racks_500',
      kind: BadgeKind.milestone,
      titleKey: 'gc_mile_racks_500',
      descriptionKey: 'gc_mile_racks_500_desc',
      valueOf: (m) => m.totalRacks.toDouble(),
      threshold: 500,
    ),
    Badge(
      key: 'milestone_shots_10000',
      kind: BadgeKind.milestone,
      titleKey: 'gc_mile_shots_10000',
      descriptionKey: 'gc_mile_shots_10000_desc',
      valueOf: (m) => m.totalShots.toDouble(),
      threshold: 10000,
    ),
    Badge(
      key: 'milestone_hours_100',
      kind: BadgeKind.milestone,
      titleKey: 'gc_mile_hours_100',
      descriptionKey: 'gc_mile_hours_100_desc',
      valueOf: (m) => m.practiceHours,
      threshold: 100,
    ),
  ];

  /// Every badge across all three kinds, in display order.
  static List<Badge> get all => [...achievements, ...streaks, ...milestones];

  static Badge? byKey(String key) {
    for (final b in all) {
      if (b.key == key) return b;
    }
    return null;
  }
}
