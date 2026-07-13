import 'package:drift/drift.dart' show QueryExecutor, Value;
import 'package:drift/native.dart' show NativeDatabase;
import 'package:flutter_test/flutter_test.dart';
// Hide the generated Drift `Goal` data class so it doesn't collide with the
// domain `Goal` model; the test only needs the DB companions + AppDatabase.
import 'package:pool_os/features/player/data/database/app_database.dart'
    hide Goal;
import 'package:pool_os/features/goal_center/data/repositories/goal_center_repository.dart';
import 'package:pool_os/features/goal_center/domain/achievement_catalog.dart';
import 'package:pool_os/features/goal_center/domain/goal_evaluator.dart';
import 'package:pool_os/features/goal_center/domain/models/goal_center_models.dart';

/// TASK 10 — Goal & Progress Center.
///
/// Exercises (1) the pure [GoalEvaluator] + [AchievementCatalog] with hand-built
/// [PlayerMetrics] fixtures (no DB), and (2) the repository against an in-memory
/// DB: goal CRUD, unlock persistence, and the metrics snapshot computed from
/// recorded matches/racks/shots + training. No AI, no fabricated data — a metric
/// with no attempts reports 0, and a badge unlocks only when a real value
/// crosses its threshold. Nothing here writes to the LOCKED recording pipeline.
void main() {
  group('GoalEvaluator (Phần 2 — progress)', () {
    test('rate goal: progress is the absolute rate, no baseline maths', () {
      final goal = Goal(
        title: 'Long pot 80%',
        metric: GoalMetric.longPotRate,
        target: 80,
        baseline: 0,
        createdAt: DateTime(2026, 7, 1),
      );
      final p = GoalEvaluator.progressFor(
        goal,
        const PlayerMetrics(longPotRate: 72),
      );
      expect(p.current, 72);
      expect(p.target, 80);
      expect(p.percent, 90); // 72/80
      expect(p.isReached, isFalse);
    });

    test('cumulative goal: progress is measured from the creation baseline', () {
      // Created after 40 wins with "win 10 more" => target 50, baseline 40.
      final metricsAtCreation = const PlayerMetrics(matchesWon: 40);
      final target = GoalEvaluator.targetForNewGoal(
          GoalMetric.matchesWon, 10, metricsAtCreation);
      final baseline = GoalEvaluator.baselineForNewGoal(
          GoalMetric.matchesWon, metricsAtCreation);
      expect(target, 50);
      expect(baseline, 40);

      final goal = Goal(
        title: 'Win 10 matches',
        metric: GoalMetric.matchesWon,
        target: target,
        baseline: baseline,
        createdAt: DateTime(2026, 7, 1),
      );

      // 5 more wins since creation (45 total) => 5/10 = 50%.
      final p = GoalEvaluator.progressFor(
          goal, const PlayerMetrics(matchesWon: 45));
      expect(p.current, 5);
      expect(p.percent, 50);
      expect(p.isReached, isFalse);

      // Target reached at 50 total.
      final done = GoalEvaluator.progressFor(
          goal, const PlayerMetrics(matchesWon: 50));
      expect(done.isReached, isTrue);
    });

    test('progress never exceeds 100% or goes negative', () {
      final goal = Goal(
        title: 'Break & run',
        metric: GoalMetric.breakAndRuns,
        target: 1,
        baseline: 0,
        createdAt: DateTime(2026, 7, 1),
      );
      final over = GoalEvaluator.progressFor(
          goal, const PlayerMetrics(breakAndRuns: 5));
      expect(over.ratio, 1.0);
      expect(over.isReached, isTrue);
    });
  });

  group('GoalEvaluator (Phần 7 — notifications)', () {
    Goal goal() => Goal(
          title: 'x',
          metric: GoalMetric.longPotRate,
          target: 100,
          createdAt: DateTime(2026, 7, 1),
        );

    test('fires the highest newly-crossed threshold, once', () {
      // 92% -> crosses .9
      final p = GoalProgress(goal: goal(), current: 92, target: 100);
      final fire = GoalEvaluator.nextGoalNotifyThreshold(p, 0.75);
      expect(fire, 0.9);
    });

    test('does not refire an already-notified threshold', () {
      // 55% -> only .5
      final p = GoalProgress(goal: goal(), current: 55, target: 100);
      final fire = GoalEvaluator.nextGoalNotifyThreshold(p, 0.5);
      expect(fire, isNull);
    });

    test('completion (100%) fires the 1.0 threshold', () {
      final p = GoalProgress(goal: goal(), current: 100, target: 100);
      final fire = GoalEvaluator.nextGoalNotifyThreshold(p, 0.9);
      expect(fire, 1.0);
    });
  });

  group('AchievementCatalog (Phần 3/4/5)', () {
    test('badges unlock exactly at their threshold', () {
      final first = AchievementCatalog.byKey('first_match_win')!;
      expect(first.isUnlocked(const PlayerMetrics(matchesWon: 0)), isFalse);
      expect(first.isUnlocked(const PlayerMetrics(matchesWon: 1)), isTrue);

      final shots1k = AchievementCatalog.byKey('shots_1000')!;
      expect(shots1k.isUnlocked(const PlayerMetrics(totalShots: 999)), isFalse);
      expect(shots1k.isUnlocked(const PlayerMetrics(totalShots: 1000)), isTrue);
    });

    test('badge keys are unique across all kinds', () {
      final keys = AchievementCatalog.all.map((b) => b.key).toList();
      expect(keys.toSet().length, keys.length);
    });

    test('newlyUnlockedKeys returns only unlocked-and-unstored badges', () {
      final metrics = const PlayerMetrics(matchesWon: 3, totalShots: 1200);
      // first_match_win + shots_1000 unlocked; pretend first is already stored.
      final fresh = GoalEvaluator.newlyUnlockedKeys(metrics, {'first_match_win'});
      expect(fresh, contains('shots_1000'));
      expect(fresh, isNot(contains('first_match_win')));
    });

    test('badgeStatuses flags unlocked-but-unseen as new', () {
      final metrics = const PlayerMetrics(matchesWon: 1);
      final statuses = GoalEvaluator.badgeStatuses(
        AchievementCatalog.achievements,
        metrics,
        unlockedAt: {'first_match_win': DateTime(2026, 7, 1)},
        seen: <String>{},
      );
      final first =
          statuses.firstWhere((s) => s.badge.key == 'first_match_win');
      expect(first.unlocked, isTrue);
      expect(first.isNew, isTrue);
    });
  });

  group('GoalCenterRepository (DB round-trips)', () {
    late AppDatabase db;
    late GoalCenterRepository repo;

    AppDatabase openDb(QueryExecutor executor) {
      final database = AppDatabase.forTesting(executor);
      repo = GoalCenterRepository(database);
      return database;
    }

    setUp(() => db = openDb(NativeDatabase.memory()));
    tearDown(() async => db.close());

    test('create → read → delete a goal round-trips fields', () async {
      final id = await repo.createGoal(Goal(
        title: 'Win 10 matches',
        metric: GoalMetric.matchesWon,
        target: 50,
        baseline: 40,
        note: 'season goal',
        createdAt: DateTime(2026, 7, 1),
      ));
      final goal = await repo.getGoalById(id);
      expect(goal, isNotNull);
      expect(goal!.title, 'Win 10 matches');
      expect(goal.metric, GoalMetric.matchesWon);
      expect(goal.target, 50);
      expect(goal.baseline, 40);
      expect(goal.note, 'season goal');

      await repo.deleteGoal(id);
      expect(await repo.getGoalById(id), isNull);
    });

    test('markGoalComplete + notified-progress persist', () async {
      final id = await repo.createGoal(Goal(
        title: 'x',
        metric: GoalMetric.longPotRate,
        target: 80,
        createdAt: DateTime(2026, 7, 1),
      ));
      await repo.setGoalNotifiedProgress(id, 0.75);
      await repo.markGoalComplete(id, DateTime(2026, 7, 5));
      final goal = await repo.getGoalById(id);
      expect(goal!.lastNotifiedProgress, 0.75);
      expect(goal.isComplete, isTrue);
    });

    test('recordUnlock is idempotent; markSeen clears the new flag', () async {
      await repo.recordUnlock('first_match_win', DateTime(2026, 7, 1));
      await repo.recordUnlock('first_match_win', DateTime(2026, 7, 2));
      final unlocked = await repo.getUnlockedAt();
      expect(unlocked.length, 1);
      expect(unlocked['first_match_win'], DateTime(2026, 7, 1)); // first wins

      expect(await repo.getSeenKeys(), isEmpty);
      await repo.markSeen(['first_match_win']);
      expect(await repo.getSeenKeys(), contains('first_match_win'));
    });

    test('hasAnyGoal reflects seeding state', () async {
      expect(await repo.hasAnyGoal(), isFalse);
      await repo.createGoal(Goal(
        title: 'x',
        metric: GoalMetric.totalShots,
        target: 100,
        createdAt: DateTime(2026, 7, 1),
      ));
      expect(await repo.hasAnyGoal(), isTrue);
    });
  });

  group('GoalCenterRepository.computeMetrics (read-only over pipeline)', () {
    late AppDatabase db;
    late GoalCenterRepository repo;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = GoalCenterRepository(db);
    });
    tearDown(() async => db.close());

    test('empty DB yields all-zero metrics (no fabricated data)', () async {
      final m = await repo.computeMetrics();
      expect(m.totalMatches, 0);
      expect(m.totalShots, 0);
      expect(m.longPotRate, 0);
      expect(m.stopShotRate, 0);
      expect(m.matchesWon, 0);
      expect(m.breakAndRuns, 0);
    });

    test('counts matches/racks/shots and long-pot rate from real rows',
        () async {
      // One session -> one match won by Player -> one rack -> two hard shots
      // (one made). Long pot rate should be 50%.
      final sessionId = await db.into(db.sessions).insert(
            SessionsCompanion.insert(
              sessionType: 'match',
              startedAt: DateTime(2026, 7, 1, 10),
              finishedAt: Value(DateTime(2026, 7, 1, 11)), // 1h practice
            ),
          );
      final matchId = await db.into(db.matches).insert(
            MatchesCompanion.insert(
              sessionId: sessionId,
              matchNumber: 1,
              gameType: '9ball',
              winner: const Value('Player'),
            ),
          );
      final rackId = await db.into(db.racks).insert(
            RacksCompanion.insert(
              matchId: matchId,
              rackNumber: 1,
              result: true,
              breakSuccess: const Value(true),
              largestRun: const Value(9), // qualifies as break & run
            ),
          );
      await db.into(db.shots).insert(ShotsCompanion.insert(
            rackId: rackId,
            shotNumber: 1,
            shotType: 'normal',
            difficulty: 'hard',
            result: 'made',
            positionQuality: const Value('good'),
          ));
      await db.into(db.shots).insert(ShotsCompanion.insert(
            rackId: rackId,
            shotNumber: 2,
            shotType: 'normal',
            difficulty: 'extreme',
            result: 'missed',
            positionQuality: const Value('bad'),
          ));

      final m = await repo.computeMetrics();
      expect(m.totalMatches, 1);
      expect(m.totalRacks, 1);
      expect(m.totalShots, 2);
      expect(m.matchesWon, 1);
      expect(m.breakAndRuns, 1); // won + break success + run >= 8
      expect(m.longPotRate, 50); // 1 of 2 hard/extreme made
      expect(m.stopShotRate, 50); // 1 of 2 positioned came out good
      expect(m.practiceHours, closeTo(1.0, 0.01));
    });

    test('scratch on a shot breaks the scratch-free streak', () async {
      final sessionId = await db.into(db.sessions).insert(
            SessionsCompanion.insert(
              sessionType: 'match',
              startedAt: DateTime(2026, 7, 1, 10),
            ),
          );
      final matchId = await db.into(db.matches).insert(
            MatchesCompanion.insert(
              sessionId: sessionId,
              matchNumber: 1,
              gameType: '9ball',
              winner: const Value('Player'),
            ),
          );
      final rackId = await db.into(db.racks).insert(
            RacksCompanion.insert(
              matchId: matchId,
              rackNumber: 1,
              result: true,
            ),
          );
      await db.into(db.shots).insert(ShotsCompanion.insert(
            rackId: rackId,
            shotNumber: 1,
            shotType: 'normal',
            difficulty: 'medium',
            result: 'scratch',
          ));

      final m = await repo.computeMetrics();
      expect(m.scratchFreeMatches, 0);
    });
  });
}
