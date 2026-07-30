// EPIC 03 — Training System providers.
//
// All read state comes from the service (DB); nothing is fabricated. No
// AI, no recommendation, no prediction — just historical data per PO
// direction 2026-07-30.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/goal_center/domain/models/goal_center_models.dart';
import 'package:pool_os/features/training_center/domain/models/training_center_models.dart';
import 'package:pool_os/features/training_system/application/training_system_service.dart';
import 'package:pool_os/features/training_system/domain/models/training_system_models.dart';

// --- Lessons -----------------------------------------------------------------

final lessonsProvider = FutureProvider<List<Lesson>>((ref) {
  return ref.watch(trainingSystemServiceProvider).getLessons();
});

final lessonByCodeProvider =
    FutureProvider.family<Lesson?, String>((ref, code) {
  return ref.watch(trainingSystemServiceProvider).getLessonByCode(code);
});

// --- Programs & Enrollments --------------------------------------------------

final programsProvider =
    FutureProvider.family<List<TrainingProgram>, bool>((ref, seedOnly) {
  return ref.watch(trainingSystemServiceProvider)
      .getPrograms(seedOnly: seedOnly);
});

final programByCodeProvider =
    FutureProvider.family<TrainingProgram?, String>((ref, code) {
  return ref.watch(trainingSystemServiceProvider).getProgramByCode(code);
});

final enrollmentsProvider =
    FutureProvider.family<List<TrainingProgramEnrollment>, int?>((ref, playerId) {
  return ref
      .watch(trainingSystemServiceProvider)
      .getEnrollments(playerId: playerId);
});

class EnrollController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  EnrollController(this.ref) : super(const AsyncValue.data(null));

  Future<void> enroll(int programId, {int? playerId}) async {
    state = const AsyncValue.loading();
    try {
      await ref
          .read(trainingSystemServiceProvider)
          .enroll(programId, playerId: playerId);
      ref.invalidate(enrollmentsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markWeekCompleted(int enrollmentId, int weekIndex) async {
    state = const AsyncValue.loading();
    try {
      await ref
          .read(trainingSystemServiceProvider)
          .markWeekCompleted(enrollmentId, weekIndex);
      ref.invalidate(enrollmentsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final enrollControllerProvider =
    StateNotifierProvider<EnrollController, AsyncValue<void>>((ref) {
  return EnrollController(ref);
});

// --- Coach Notes -------------------------------------------------------------

final coachNotesProvider = FutureProvider.family<
    List<CoachNote>,
    ({int? sessionId, int? playerId})>((ref, args) {
  return ref
      .watch(trainingSystemServiceProvider)
      .getCoachNotes(sessionId: args.sessionId, playerId: args.playerId);
});

class CoachNoteController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  CoachNoteController(this.ref) : super(const AsyncValue.data(null));

  Future<void> add(CoachNote note) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(trainingSystemServiceProvider).addCoachNote(note);
      ref.invalidate(coachNotesProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> delete(int id) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(trainingSystemServiceProvider).deleteCoachNote(id);
      ref.invalidate(coachNotesProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final coachNoteControllerProvider =
    StateNotifierProvider<CoachNoteController, AsyncValue<void>>((ref) {
  return CoachNoteController(ref);
});

// --- Goals (re-used GoalCenter with status filter) --------------------------

final goalsByStatusProvider =
    FutureProvider.family<List<Goal>, GoalStatus>((ref, status) {
  return ref.watch(trainingSystemServiceProvider).getGoalsByStatus(status);
});

class GoalStatusController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  GoalStatusController(this.ref) : super(const AsyncValue.data(null));

  Future<void> archive(int id) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(trainingSystemServiceProvider).archiveGoal(id);
      ref.invalidate(goalsByStatusProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> setStatus(int id, GoalStatus status) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(trainingSystemServiceProvider).setGoalStatus(id, status);
      ref.invalidate(goalsByStatusProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final goalStatusControllerProvider =
    StateNotifierProvider<GoalStatusController, AsyncValue<void>>((ref) {
  return GoalStatusController(ref);
});

// --- Practice Sessions (re-used TrainingCenter) -----------------------------

final recentPracticeSessionsProvider =
    FutureProvider.family<List<TrainingSession>, int>((ref, limit) {
  return ref
      .watch(trainingSystemServiceProvider)
      .getRecentPracticeSessions(limit: limit);
});

final drillRunsForSessionProvider =
    FutureProvider.family<List<DrillRun>, int>((ref, sessionId) {
  return ref
      .watch(trainingSystemServiceProvider)
      .getDrillRunsForSession(sessionId);
});

class PracticeSessionController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  PracticeSessionController(this.ref) : super(const AsyncValue.data(null));

  Future<int> start(TrainingSession session) async {
    state = const AsyncValue.loading();
    try {
      final id = await ref
          .read(trainingSystemServiceProvider)
          .createPracticeSession(session);
      ref.invalidate(recentPracticeSessionsProvider);
      state = const AsyncValue.data(null);
      return id;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> complete(int id, {String? notes}) async {
    state = const AsyncValue.loading();
    try {
      await ref
          .read(trainingSystemServiceProvider)
          .completePracticeSession(id, notes: notes);
      ref.invalidate(recentPracticeSessionsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> delete(int id) async {
    state = const AsyncValue.loading();
    try {
      await ref
          .read(trainingSystemServiceProvider)
          .deletePracticeSession(id);
      ref.invalidate(recentPracticeSessionsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<int> addDrillRun(DrillRun run) async {
    state = const AsyncValue.loading();
    try {
      final id = await ref
          .read(trainingSystemServiceProvider)
          .addDrillRunToSession(run);
      ref.invalidate(drillRunsForSessionProvider);
      state = const AsyncValue.data(null);
      return id;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final practiceSessionControllerProvider = StateNotifierProvider<
    PracticeSessionController, AsyncValue<void>>((ref) {
  return PracticeSessionController(ref);
});

// --- Progress (read-only composition) ---------------------------------------

final progressSnapshotProvider =
    FutureProvider<TrainingProgressSnapshot>((ref) {
  return ref.watch(trainingSystemServiceProvider).getProgressSnapshot();
});
