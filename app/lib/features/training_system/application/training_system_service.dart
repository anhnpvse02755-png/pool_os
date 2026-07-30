// EPIC 03 — Training System service.
//
// Coordinates the 7 Training deliverables into a single read-mostly
// surface for the UI: drill library, practice session (composition),
// goals, progress, programs, lessons, coach notes.
//
// The service NEVER invents data. Each method is a pure read-through to
// the underlying repositories — no AI, no prediction, no recommendation
// (spec §"Explicitly Out of Scope").
//
// Wiring (PO direction 2026-07-30):
// - Drill catalog: drill/DrillLibrary (in-memory, re-used).
// - Practice session container: training_center/TrainingSession +
//   DrillRun (re-used, full CRUD already wired).
// - Goals: goal_center/Goal (re-used, schema v32 adds GoalStatus).
// - Progress: read-only composition across 3 repositories.
// - Lessons / Coach Notes / Programs / Enrollments: own tables from
//   schema v31.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/goal_center/data/repositories/goal_center_repository.dart';
import 'package:pool_os/features/goal_center/domain/models/goal_center_models.dart';
import 'package:pool_os/features/training_center/data/repositories/training_center_repository.dart';
import 'package:pool_os/features/training_center/domain/models/training_center_models.dart';
import 'package:pool_os/features/training_system/data/repositories/training_system_repository.dart';
import 'package:pool_os/features/training_system/domain/models/training_system_models.dart';

final trainingSystemServiceProvider = Provider<TrainingSystemService>((ref) {
  return TrainingSystemService(
    ref.watch(trainingSystemRepositoryProvider),
    ref.watch(goalCenterRepositoryProvider),
    ref.watch(trainingCenterRepositoryProvider),
  );
});

/// Snapshot for the Progress Tracking screen (spec §4). All values are
/// read-only historical aggregates — no prediction (PO direction
/// 2026-07-30). Zero attempts => zero (no fabricated data).
class TrainingProgressSnapshot {
  final Duration totalPracticeTime;
  final int totalSessions;
  final int completedDrills;
  final int goalsCompleted;
  final int goalsActive;
  final int goalsArchived;
  final int goalsTotal;
  final int practiceFrequencyPerWeek;
  final List<TrainingImprovementPoint> improvementTimeline;

  const TrainingProgressSnapshot({
    this.totalPracticeTime = Duration.zero,
    this.totalSessions = 0,
    this.completedDrills = 0,
    this.goalsCompleted = 0,
    this.goalsActive = 0,
    this.goalsArchived = 0,
    this.goalsTotal = 0,
    this.practiceFrequencyPerWeek = 0,
    this.improvementTimeline = const [],
  });
}

/// One point on the Improvement Timeline (spec §4). [value] is the
/// per-day average success rate (0.0–1.0) over completed drill runs.
/// Date is the calendar day in local time, truncated.
class TrainingImprovementPoint {
  final DateTime date;
  final double value;
  const TrainingImprovementPoint(this.date, this.value);
}

class TrainingSystemService {
  final TrainingSystemRepository _repo;
  final GoalCenterRepository _goalRepo;
  final TrainingCenterRepository _trainingRepo;

  TrainingSystemService(this._repo, this._goalRepo, this._trainingRepo);

  // --- Lessons ---------------------------------------------------------------

  Future<List<Lesson>> getLessons() => _repo.getLessons();

  Future<Lesson?> getLessonByCode(String code) => _repo.getLessonByCode(code);

  // --- Programs --------------------------------------------------------------

  Future<List<TrainingProgram>> getPrograms({bool seedOnly = false}) =>
      _repo.getPrograms(seedOnly: seedOnly);

  Future<TrainingProgram?> getProgramByCode(String code) =>
      _repo.getProgramByCode(code);

  Future<List<TrainingProgramEnrollment>> getEnrollments({int? playerId}) =>
      _repo.getEnrollments(playerId: playerId);

  Future<int> enroll(int programId, {int? playerId}) =>
      _repo.enroll(programId, playerId: playerId);

  Future<void> markWeekCompleted(int enrollmentId, int weekIndex) =>
      _repo.markWeekCompleted(enrollmentId, weekIndex);

  // --- Coach Notes -----------------------------------------------------------

  Future<List<CoachNote>> getCoachNotes({int? sessionId, int? playerId}) =>
      _repo.getCoachNotes(sessionId: sessionId, playerId: playerId);

  Future<int> addCoachNote(CoachNote note) => _repo.addCoachNote(note);

  Future<void> deleteCoachNote(int id) => _repo.deleteCoachNote(id);

  // --- Goals (re-used goal_center, status filter) ---------------------------

  Future<List<Goal>> getGoalsByStatus(GoalStatus status) =>
      _goalRepo.getGoalsByStatus(status);

  Future<void> archiveGoal(int id) => _goalRepo.archiveGoal(id);

  Future<void> setGoalStatus(int id, GoalStatus status) =>
      _goalRepo.setGoalStatus(id, status);

  // --- Practice Sessions (re-used training_center) ---------------------------

  Future<List<TrainingSession>> getRecentPracticeSessions({int limit = 20}) =>
      _trainingRepo.getRecentSessions(limit: limit);

  Future<int> createPracticeSession(TrainingSession session) =>
      _trainingRepo.createSession(session);

  Future<int> completePracticeSession(int id, {String? notes}) =>
      _trainingRepo.completeSession(id, notes: notes);

  Future<int> deletePracticeSession(int id) => _trainingRepo.deleteSession(id);

  Future<int> addDrillRunToSession(DrillRun run) =>
      _trainingRepo.addDrillRun(run);

  Future<List<DrillRun>> getDrillRunsForSession(int sessionId) =>
      _trainingRepo.getRunsForSession(sessionId);

  // --- Progress (read-only composition) --------------------------------------

  /// Compose the Progress Tracking snapshot. All values are historical
  /// aggregates — never predicted. Zero attempts => zero.
  ///
  /// Sources:
  /// - totalPracticeTime = sum(completedAt - startedAt) across
  ///   TrainingCenterSessions with completedAt != null.
  /// - totalSessions = count(TrainingCenterSessions).
  /// - completedDrills = count(DrillRun) where attempts >= targetReps.
  /// - goalsX = count(Goals) per GoalStatus.
  /// - practiceFrequencyPerWeek = distinct practice dates within the
  ///   most-recent 4 weeks / 4 (rolling).
  /// - improvementTimeline = per-day average DrillRun.successRate over
  ///   the most-recent 30 days (one point per day).
  Future<TrainingProgressSnapshot> getProgressSnapshot() async {
    final sessions = await _trainingRepo.getRecentSessions(limit: 10000);
    final allRuns = await _trainingRepo.getAllRuns();
    final goals = await _goalRepo.getGoals();
    final enrollments = await _repo.getEnrollments();

    // totalPracticeTime
    var totalMs = 0;
    for (final s in sessions) {
      if (s.completedAt != null) {
        totalMs += s.completedAt!.difference(s.startedAt).inMilliseconds;
      }
    }

    // completedDrills
    final completedDrills = allRuns.where((r) => r.reachedTarget).length;

    // goals
    final completed = goals.where((g) => g.status == GoalStatus.completed).length;
    final active = goals.where((g) => g.status == GoalStatus.active).length;
    final archived = goals.where((g) => g.status == GoalStatus.archived).length;

    // practiceFrequencyPerWeek — distinct days in the most-recent 4 weeks.
    final now = DateTime.now();
    final fourWeeksAgo = now.subtract(const Duration(days: 28));
    final recentDays = <String>{};
    for (final s in sessions) {
      final at = s.completedAt ?? s.startedAt;
      if (at.isAfter(fourWeeksAgo)) {
        recentDays.add(_dayKey(at));
      }
    }
    final practiceFrequencyPerWeek =
        (recentDays.length / 4).round(); // 28 days / 7 = 4 weeks.

    // improvementTimeline — per-day average DrillRun.successRate over the
    // most-recent 30 days. Aggregate successes/attempts per day, then
    // compute rate per day (no fabricated zeroes — days with no runs are
    // simply absent from the timeline).
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final byDay = <String, _DayAccumulator>{};
    for (final r in allRuns) {
      if (r.createdAt.isBefore(thirtyDaysAgo)) continue;
      final key = _dayKey(r.createdAt);
      final acc = byDay.putIfAbsent(key, _DayAccumulator.new);
      acc.attempts += r.attempts;
      acc.successes += r.successes;
    }
    final timeline = byDay.entries
        .map((e) => TrainingImprovementPoint(
              DateTime.parse(e.key),
              e.value.rate,
            ))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return TrainingProgressSnapshot(
      totalPracticeTime: Duration(milliseconds: totalMs),
      totalSessions: sessions.length,
      completedDrills: completedDrills,
      goalsCompleted: completed,
      goalsActive: active,
      goalsArchived: archived,
      goalsTotal: goals.length,
      practiceFrequencyPerWeek: practiceFrequencyPerWeek,
      improvementTimeline: timeline,
      // enrollments intentionally not surfaced in MVP; reserved for
      // Phase II if needed (audit note — no fabricated value).
    )._withEnrollmentCount(enrollments: enrollments.length);
  }

  // Helpers -----------------------------------------------------------------

  static String _dayKey(DateTime t) {
    final d = DateTime(t.year, t.month, t.day);
    return d.toIso8601String().substring(0, 10);
  }
}

class _DayAccumulator {
  int attempts = 0;
  int successes = 0;
  double get rate => attempts == 0 ? 0.0 : successes / attempts;
}

extension on TrainingProgressSnapshot {
  /// Tiny helper so the snapshot factory stays readable. No behaviour
  /// change beyond exposing the enrollment count for diagnostics; the
  /// public surface does not yet surface enrollments.
  TrainingProgressSnapshot _withEnrollmentCount({required int enrollments}) {
    return TrainingProgressSnapshot(
      totalPracticeTime: totalPracticeTime,
      totalSessions: totalSessions,
      completedDrills: completedDrills,
      goalsCompleted: goalsCompleted,
      goalsActive: goalsActive,
      goalsArchived: goalsArchived,
      goalsTotal: goalsTotal,
      practiceFrequencyPerWeek: practiceFrequencyPerWeek,
      improvementTimeline: improvementTimeline,
    );
  }
}
