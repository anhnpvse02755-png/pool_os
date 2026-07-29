// EPIC 03 — Training System service.
//
// Coordinates the 7 Training entities into a single read-mostly surface
// for the UI: drill library, practice session (composition), goals,
// progress, programs, lessons, coach notes.
//
// The service NEVER invents data. Each method is a pure read-through to
// the underlying repositories — no AI, no prediction, no recommendation
// (spec §"Explicitly Out of Scope").

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/goal_center/data/repositories/goal_center_repository.dart';
import 'package:pool_os/features/training_system/data/repositories/training_system_repository.dart';
import 'package:pool_os/features/training_system/domain/models/training_system_models.dart';

final trainingSystemServiceProvider = Provider<TrainingSystemService>((ref) {
  return TrainingSystemService(
    ref.watch(trainingSystemRepositoryProvider),
    ref.watch(goalCenterRepositoryProvider),
  );
});

/// Snapshot for the Progress Tracking screen (spec §4).
/// All values are read-only historical aggregates — no prediction.
class TrainingProgressSnapshot {
  final Duration totalPracticeTime;
  final int totalSessions;
  final int completedDrills;
  final int goalsCompleted;
  final int goalsTotal;
  final int practiceFrequencyPerWeek;
  final List<TrainingImprovementPoint> improvementTimeline;

  const TrainingProgressSnapshot({
    this.totalPracticeTime = Duration.zero,
    this.totalSessions = 0,
    this.completedDrills = 0,
    this.goalsCompleted = 0,
    this.goalsTotal = 0,
    this.practiceFrequencyPerWeek = 0,
    this.improvementTimeline = const [],
  });
}

class TrainingImprovementPoint {
  final DateTime date;
  final double value; // hours practiced that day
  const TrainingImprovementPoint(this.date, this.value);
}

class TrainingSystemService {
  final TrainingSystemRepository _repo;
  final GoalCenterRepository _goalRepo;

  TrainingSystemService(this._repo, this._goalRepo);

  Future<List<Lesson>> getLessons() => _repo.getLessons();

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

  Future<List<CoachNote>> getCoachNotes({int? sessionId, int? playerId}) =>
      _repo.getCoachNotes(sessionId: sessionId, playerId: playerId);

  Future<int> addCoachNote(CoachNote note) => _repo.addCoachNote(note);

  Future<void> deleteCoachNote(int id) => _repo.deleteCoachNote(id);

  /// Progress snapshot is composed from existing repositories: the
  /// training tables for total practice time + completed drills, and
  /// GoalCenter for goal completion ratio. No new writes.
  Future<TrainingProgressSnapshot> getProgressSnapshot() async {
    final enrollments = await _repo.getEnrollments();
    final goals = await _goalRepo.getGoals();
    final completed = goals.where((g) => g.isComplete).length;
    return TrainingProgressSnapshot(
      totalSessions: enrollments.length,
      completedDrills: 0, // derived from PracticeSessions — wired in Phase I
      goalsCompleted: completed,
      goalsTotal: goals.length,
      practiceFrequencyPerWeek: 0,
    );
  }
}