import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/player/data/database/app_database.dart' as db;
import 'package:pool_os/features/player/data/providers/database_providers.dart';
import 'package:pool_os/features/goal_center/domain/models/goal_center_models.dart';
import 'package:pool_os/features/shot/domain/models/shot.dart' show ShotResult;

final goalCenterRepositoryProvider = Provider<GoalCenterRepository>((ref) {
  return GoalCenterRepository(ref.watch(databaseProvider));
});

/// Task 10 — the only gateway between the Goal Center presentation layer and
/// Drift. It (1) persists goals + achievement-unlock timestamps, and (2)
/// computes a read-only [PlayerMetrics] snapshot from the recording pipeline +
/// training tables. It NEVER writes to Sessions/Matches/Racks/Shots/Events —
/// those are LOCKED; it only reads them to score goals and badges honestly.
class GoalCenterRepository {
  final db.AppDatabase _db;

  GoalCenterRepository(this._db);

  // --- Goals (Phần 1/2) -----------------------------------------------------

  Future<List<Goal>> getGoals() async {
    final rows = await (_db.select(_db.goals)
          ..orderBy([
            // Active goals first, then by newest.
            (t) => OrderingTerm.asc(t.completedAt),
            (t) => OrderingTerm.desc(t.createdAt),
          ]))
        .get();
    return rows.map(_mapGoal).toList();
  }

  Future<Goal?> getGoalById(int id) async {
    final row = await (_db.select(_db.goals)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _mapGoal(row);
  }

  Future<int> createGoal(Goal goal) async {
    return _db.into(_db.goals).insert(
          db.GoalsCompanion.insert(
            playerId: Value(goal.playerId),
            title: goal.title,
            metric: goal.metric.code,
            targetValue: goal.target,
            baselineValue: Value(goal.baseline),
            note: Value(goal.note),
            isDefault: Value(goal.isDefault),
            createdAt: goal.createdAt,
            completedAt: Value(goal.completedAt),
            lastNotifiedProgress: Value(goal.lastNotifiedProgress),
            status: Value(goal.status.code),
          ),
        );
  }

  Future<bool> updateGoal(Goal goal) async {
    final updated = await (_db.update(_db.goals)
          ..where((t) => t.id.equals(goal.id!)))
        .write(
      db.GoalsCompanion(
        title: Value(goal.title),
        metric: Value(goal.metric.code),
        targetValue: Value(goal.target),
        baselineValue: Value(goal.baseline),
        note: Value(goal.note),
        completedAt: Value(goal.completedAt),
        lastNotifiedProgress: Value(goal.lastNotifiedProgress),
        status: Value(goal.status.code),
      ),
    );
    return updated > 0;
  }

  Future<int> deleteGoal(int id) {
    return (_db.delete(_db.goals)..where((t) => t.id.equals(id))).go();
  }

  Future<void> markGoalComplete(int id, DateTime at) async {
    await (_db.update(_db.goals)..where((t) => t.id.equals(id))).write(
      db.GoalsCompanion(
        completedAt: Value(at),
        status: const Value('completed'),
      ),
    );
  }

  /// EPIC 03 — archive a goal. Archived goals are hidden from the active list
  /// but remain queryable via [getGoalsByStatus]. Archived ≠ deleted: the row
  /// is preserved so progress history is intact.
  Future<void> archiveGoal(int id) async {
    await (_db.update(_db.goals)..where((t) => t.id.equals(id))).write(
      const db.GoalsCompanion(status: Value('archived')),
    );
  }

  Future<void> setGoalStatus(int id, GoalStatus status) async {
    await (_db.update(_db.goals)..where((t) => t.id.equals(id))).write(
      db.GoalsCompanion(status: Value(status.code)),
    );
  }

  Future<List<Goal>> getGoalsByStatus(GoalStatus status) async {
    final rows = await (_db.select(_db.goals)
          ..where((t) => t.status.equals(status.code))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
    return rows.map(_mapGoal).toList();
  }

  Future<void> setGoalNotifiedProgress(int id, double ratio) async {
    await (_db.update(_db.goals)..where((t) => t.id.equals(id))).write(
      db.GoalsCompanion(lastNotifiedProgress: Value(ratio)),
    );
  }

  /// True when at least one goal row exists (used to seed defaults once).
  Future<bool> hasAnyGoal() async {
    final row = await (_db.select(_db.goals)..limit(1)).getSingleOrNull();
    return row != null;
  }

  // --- Achievement unlocks (Phần 3/4/5) ------------------------------------

  Future<Map<String, DateTime>> getUnlockedAt() async {
    final rows = await _db.select(_db.achievementUnlocks).get();
    return {for (final r in rows) r.badgeKey: r.unlockedAt};
  }

  Future<Set<String>> getSeenKeys() async {
    final rows = await (_db.select(_db.achievementUnlocks)
          ..where((t) => t.seen.equals(true)))
        .get();
    return rows.map((r) => r.badgeKey).toSet();
  }

  /// Persist a first-time unlock (idempotent — ignores keys already stored).
  Future<void> recordUnlock(String badgeKey, DateTime at) async {
    final existing = await (_db.select(_db.achievementUnlocks)
          ..where((t) => t.badgeKey.equals(badgeKey)))
        .getSingleOrNull();
    if (existing != null) return;
    await _db.into(_db.achievementUnlocks).insert(
          db.AchievementUnlocksCompanion.insert(
            badgeKey: badgeKey,
            unlockedAt: at,
          ),
        );
  }

  /// Mark badges as acknowledged so their "new" flag clears.
  Future<void> markSeen(Iterable<String> badgeKeys) async {
    for (final key in badgeKeys) {
      await (_db.update(_db.achievementUnlocks)
            ..where((t) => t.badgeKey.equals(key)))
          .write(const db.AchievementUnlocksCompanion(seen: Value(true)));
    }
  }

  // --- Metrics snapshot (read-only over the LOCKED pipeline) ----------------

  /// Compute every raw number the goal/achievement layer needs, in one pass
  /// over the recorded data. Pure read: nothing here mutates the recording
  /// pipeline. Zero attempts => zero rate (no fabricated data — DoD of Task 10).
  Future<PlayerMetrics> computeMetrics() async {
    final matches = await _db.select(_db.matches).get();
    final racks = await _db.select(_db.racks).get();
    final shots = await _db.select(_db.shots).get();
    final sessions = await _db.select(_db.sessions).get();
    final trainingSessions =
        await _db.select(_db.trainingCenterSessions).get();
    final drillRuns = await _db.select(_db.drillRuns).get();

    // --- Counts -------------------------------------------------------------
    final totalShots = shots.length;
    final totalMatches = matches.length;
    final totalRacks = racks.length;
    final matchesWon =
        matches.where((m) => m.winner == 'Player').length;

    // --- Break & run (RFC-301 real columns) --------------------------------
    // A break-and-run = won the rack, broke successfully, and ran a big cluster
    // in a single visit. largestRun >= 8 mirrors the statistics engine's
    // threshold; result==true means the rack was won.
    final breakAndRuns = racks
        .where((r) => r.result && r.breakSuccess && r.largestRun >= 8)
        .length;

    // --- Long pot rate (hard/extreme difficulty shots) ---------------------
    final longShots = shots
        .where((s) => s.difficulty == 'hard' || s.difficulty == 'extreme')
        .toList();
    final longMade =
        longShots.where((s) => s.result == ShotResult.made).length;
    final longPotRate =
        longShots.isEmpty ? 0.0 : (longMade / longShots.length) * 100;

    // --- Stop-shot proxy: cue-ball control -------------------------------
    // Stop shots are about landing the cue ball where intended. Among shots
    // that recorded a position outcome, the share that came out perfect/good.
    final positioned =
        shots.where((s) => s.positionQuality != null).toList();
    final positionGood = positioned
        .where((s) =>
            s.positionQuality == 'perfect' || s.positionQuality == 'good')
        .length;
    final stopShotRate =
        positioned.isEmpty ? 0.0 : (positionGood / positioned.length) * 100;

    // --- Practice hours: finished recording sessions + training sessions ---
    var practiceMinutes = 0.0;
    for (final s in sessions) {
      if (s.finishedAt != null) {
        practiceMinutes +=
            s.finishedAt!.difference(s.startedAt).inMinutes.toDouble();
      }
    }
    for (final t in trainingSessions) {
      if (t.completedAt != null) {
        practiceMinutes +=
            t.completedAt!.difference(t.startedAt).inMinutes.toDouble();
      }
    }
    final practiceHours = practiceMinutes / 60.0;

    // --- Streaks ------------------------------------------------------------
    final matchWinStreak = _trailingMatchWinStreak(matches);
    final scratchFree = _trailingScratchFreeMatches(matches, racks, shots);
    final trainingStreak =
        _trainingDayStreak(sessions, trainingSessions, drillRuns);

    return PlayerMetrics(
      matchesWon: matchesWon,
      breakAndRuns: breakAndRuns,
      longPotRate: longPotRate,
      longPotAttempts: longShots.length,
      stopShotRate: stopShotRate,
      stopShotAttempts: positioned.length,
      totalShots: totalShots,
      totalMatches: totalMatches,
      totalRacks: totalRacks,
      practiceHours: practiceHours,
      scratchFreeMatches: scratchFree,
      trainingDayStreak: trainingStreak,
      matchWinStreak: matchWinStreak,
    );
  }

  /// Trailing count of consecutive most-recent matches the player won.
  int _trailingMatchWinStreak(List<db.Matche> matches) {
    final decided = matches.where((m) => m.winner != null).toList()
      ..sort((a, b) => _matchOrder(b).compareTo(_matchOrder(a)));
    var streak = 0;
    for (final m in decided) {
      if (m.winner == 'Player') {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  /// Trailing count of consecutive most-recent matches with no scratch (neither
  /// a scratch shot nor a scratch on the break).
  int _trailingScratchFreeMatches(
    List<db.Matche> matches,
    List<db.Rack> racks,
    List<db.Shot> shots,
  ) {
    final racksByMatch = <int, List<db.Rack>>{};
    for (final r in racks) {
      racksByMatch.putIfAbsent(r.matchId, () => []).add(r);
    }
    final shotsByRack = <int, List<db.Shot>>{};
    for (final s in shots) {
      shotsByRack.putIfAbsent(s.rackId, () => []).add(s);
    }

    bool matchHadScratch(db.Matche m) {
      final mRacks = racksByMatch[m.id] ?? const [];
      for (final r in mRacks) {
        if (r.breakScratch) return true;
        for (final s in shotsByRack[r.id] ?? const <db.Shot>[]) {
          if (s.result == ShotResult.scratch) return true;
        }
      }
      return false;
    }

    // Only matches that were actually played (have at least one rack) count.
    final played = matches
        .where((m) => (racksByMatch[m.id] ?? const []).isNotEmpty)
        .toList()
      ..sort((a, b) => _matchOrder(b).compareTo(_matchOrder(a)));

    var streak = 0;
    for (final m in played) {
      if (matchHadScratch(m)) break;
      streak++;
    }
    return streak;
  }

  /// Consecutive-day streak ending on the most recent activity day. A day
  /// counts if it has a finished recording session, a training session, or a
  /// drill run. Uses local calendar days.
  int _trainingDayStreak(
    List<db.Session> sessions,
    List<db.TrainingCenterSession> trainingSessions,
    List<db.DrillRun> drillRuns,
  ) {
    final days = <DateTime>{};
    void add(DateTime d) => days.add(DateTime(d.year, d.month, d.day));
    for (final s in sessions) {
      add(s.startedAt);
    }
    for (final t in trainingSessions) {
      add(t.startedAt);
    }
    for (final r in drillRuns) {
      add(r.createdAt);
    }
    if (days.isEmpty) return 0;

    final sorted = days.toList()..sort((a, b) => b.compareTo(a));
    var streak = 1;
    var cursor = sorted.first;
    for (var i = 1; i < sorted.length; i++) {
      final expected = cursor.subtract(const Duration(days: 1));
      if (sorted[i] == expected) {
        streak++;
        cursor = sorted[i];
      } else {
        break;
      }
    }
    return streak;
  }

  /// Ordering key for a match: prefer startTime, then createdAt, then id.
  int _matchOrder(db.Matche m) {
    return (m.startTime ?? m.createdAt).millisecondsSinceEpoch;
  }

  // --- Mappers -------------------------------------------------------------

  Goal _mapGoal(db.Goal row) => Goal(
        id: row.id,
        playerId: row.playerId,
        title: row.title,
        metric: GoalMetricInfo.fromCode(row.metric),
        target: row.targetValue,
        baseline: row.baselineValue,
        note: row.note,
        isDefault: row.isDefault,
        createdAt: row.createdAt,
        completedAt: row.completedAt,
        lastNotifiedProgress: row.lastNotifiedProgress,
        status: GoalStatusInfo.fromCode(row.status),
      );
}
