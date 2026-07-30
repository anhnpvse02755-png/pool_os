// EPIC 03 — Training System integration tests.
//
// Covers the 4 new tables (Lessons, CoachNotes, TrainingPrograms,
// TrainingProgramEnrollments) + the v32 Goals status column. All tests
// run against an in-memory Drift database. No AI, no recommendation,
// no prediction per PO direction 2026-07-30.

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/goal_center/data/repositories/goal_center_repository.dart';
import 'package:pool_os/features/goal_center/domain/models/goal_center_models.dart';
import 'package:pool_os/features/player/data/database/app_database.dart' as db;
import 'package:pool_os/features/player/data/providers/database_providers.dart';
import 'package:pool_os/features/training_center/data/repositories/training_center_repository.dart';
import 'package:pool_os/features/training_center/domain/models/training_center_models.dart';
import 'package:pool_os/features/training_system/application/training_system_service.dart';
import 'package:pool_os/features/training_system/data/repositories/training_system_repository.dart';
import 'package:pool_os/features/training_system/data/training_system_seeds.dart';
import 'package:pool_os/features/training_system/domain/models/training_system_models.dart';

void main() {
  late ProviderContainer container;
  late db.AppDatabase database;

  setUp(() {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(database),
    ]);
  });

  tearDown(() async {
    container.dispose();
    await database.close();
  });

  TrainingSystemRepository trainingRepo() =>
      container.read(trainingSystemRepositoryProvider);
  TrainingCenterRepository trainingCenterRepo() =>
      container.read(trainingCenterRepositoryProvider);
  GoalCenterRepository goalRepo() =>
      container.read(goalCenterRepositoryProvider);
  TrainingSystemService service() =>
      container.read(trainingSystemServiceProvider);

  group('Lessons (read-only seed)', () {
    test('seedTrainingSystem populates Lessons table', () async {
      await seedTrainingSystem(trainingRepo());
      final lessons = await trainingRepo().getLessons();
      expect(lessons, isNotEmpty);
      expect(lessons.first.code, isNotEmpty);
      expect(lessons.first.title, isNotEmpty);
    });

    test('getLessonByCode returns matching lesson', () async {
      await seedTrainingSystem(trainingRepo());
      final lesson =
          await trainingRepo().getLessonByCode('lesson_stroke_basics');
      expect(lesson, isNotNull);
      expect(lesson!.requiredDrills, contains('stopShot'));
    });

    test('getLessonByCode returns null for unknown code', () async {
      await seedTrainingSystem(trainingRepo());
      final lesson = await trainingRepo().getLessonByCode('nonexistent');
      expect(lesson, isNull);
    });
  });

  group('CoachNotes (write)', () {
    test('addCoachNote + getCoachNotes round-trip', () async {
      final id = await trainingRepo().addCoachNote(CoachNote(
        category: CoachNoteCategory.mistake,
        body: 'Hit too thin on the cut shot',
        createdAt: DateTime.now(),
      ));
      expect(id, greaterThan(0));

      final notes = await trainingRepo().getCoachNotes();
      expect(notes.length, 1);
      expect(notes.first.body, 'Hit too thin on the cut shot');
      expect(notes.first.category, CoachNoteCategory.mistake);
    });

    test('deleteCoachNote removes the row', () async {
      final id = await trainingRepo().addCoachNote(CoachNote(
        category: CoachNoteCategory.observation,
        body: 'test',
        createdAt: DateTime.now(),
      ));
      await trainingRepo().deleteCoachNote(id);
      final remaining = await trainingRepo().getCoachNotes();
      expect(remaining, isEmpty);
    });

    test('CoachNoteCategoryInfo.fromCode maps all codes', () {
      for (final c in CoachNoteCategory.values) {
        expect(CoachNoteCategoryInfo.fromCode(c.code), c);
      }
    });

    test('CoachNoteCategoryInfo.fromCode returns observation for unknown', () {
      expect(
        CoachNoteCategoryInfo.fromCode('nonexistent'),
        CoachNoteCategory.observation,
      );
    });
  });

  group('Programs + Enrollments', () {
    test('seedTrainingSystem populates TrainingPrograms', () async {
      await seedTrainingSystem(trainingRepo());
      final programs = await trainingRepo().getPrograms();
      expect(programs, isNotEmpty);
      expect(programs.first.code, isNotEmpty);
    });

    test('getPrograms(seedOnly:true) returns only seed programs', () async {
      await seedTrainingSystem(trainingRepo());
      final seeds = await trainingRepo().getPrograms(seedOnly: true);
      expect(seeds.every((p) => p.isSeed), isTrue);
    });

    test('upsertCustomProgram persists a custom program', () async {
      final id = await trainingRepo().upsertCustomProgram(TrainingProgram(
        code: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        title: 'My Custom Program',
        description: 'Test',
        difficulty: ProgramDifficulty.custom,
        weekCount: 4,
        hierarchy: const TrainingProgramHierarchy(),
        isSeed: false,
        createdAt: DateTime.now(),
      ));
      expect(id, greaterThan(0));
    });

    test('enroll + markWeekCompleted progresses week-by-week', () async {
      await seedTrainingSystem(trainingRepo());
      final programs = await trainingRepo().getPrograms(seedOnly: true);
      final enrollId = await trainingRepo().enroll(programs.first.id!);

      await trainingRepo().markWeekCompleted(enrollId, 1);
      final e1 = await trainingRepo().getEnrollments();
      expect(e1.first.completedWeeks, contains(1));

      await trainingRepo().markWeekCompleted(enrollId, 2);
      final e2 = await trainingRepo().getEnrollments();
      expect(e2.first.completedWeeks, containsAll([1, 2]));
    });

    test('markWeekCompleted sets completedAt when all weeks done', () async {
      await seedTrainingSystem(trainingRepo());
      final programs = await trainingRepo().getPrograms(seedOnly: true);
      final program = programs.first;
      final enrollId = await trainingRepo().enroll(program.id!);

      for (var w = 1; w <= program.weekCount; w++) {
        await trainingRepo().markWeekCompleted(enrollId, w);
      }
      final enrollments = await trainingRepo().getEnrollments();
      final mine = enrollments.firstWhere((e) => e.id == enrollId);
      expect(mine.isComplete, isTrue);
    });
  });

  group('Domain enum helpers', () {
    test('ProgramDifficultyInfo.fromCode maps all codes', () {
      for (final d in ProgramDifficulty.values) {
        expect(ProgramDifficultyInfo.fromCode(d.code), d);
      }
    });

    test('ProgramDifficultyInfo.fromCode returns custom for unknown', () {
      expect(
        ProgramDifficultyInfo.fromCode('nonexistent'),
        ProgramDifficulty.custom,
      );
    });

    test('TrainingProgramHierarchy round-trips through JSON', () {
      const original = TrainingProgramHierarchy(weeks: []);
      final encoded = original.toJsonString();
      final decoded = TrainingProgramHierarchy.fromJsonString(encoded);
      expect(decoded.totalDrills, 0);
    });

    test('TrainingProgramHierarchy.fromJsonString handles malformed JSON', () {
      final result = TrainingProgramHierarchy.fromJsonString('not json');
      expect(result.totalDrills, 0);
    });
  });

  group('v32 Goals: GoalStatus lifecycle', () {
    test('default status is active', () async {
      final id = await goalRepo().createGoal(Goal(
        title: 'Practice 5 days',
        metric: GoalMetric.practiceHours,
        target: 5,
        createdAt: DateTime.now(),
      ));
      final goal = await goalRepo().getGoalById(id);
      expect(goal!.status, GoalStatus.active);
    });

    test('archiveGoal moves to archived', () async {
      final id = await goalRepo().createGoal(Goal(
        title: 'Test',
        metric: GoalMetric.totalMatches,
        target: 10,
        createdAt: DateTime.now(),
      ));
      await goalRepo().archiveGoal(id);
      final goal = await goalRepo().getGoalById(id);
      expect(goal!.status, GoalStatus.archived);
    });

    test('setGoalStatus round-trip', () async {
      final id = await goalRepo().createGoal(Goal(
        title: 'Test',
        metric: GoalMetric.totalMatches,
        target: 10,
        createdAt: DateTime.now(),
      ));
      await goalRepo().setGoalStatus(id, GoalStatus.notStarted);
      expect((await goalRepo().getGoalById(id))!.status, GoalStatus.notStarted);
      await goalRepo().setGoalStatus(id, GoalStatus.completed);
      expect((await goalRepo().getGoalById(id))!.status, GoalStatus.completed);
    });

    test('getGoalsByStatus filters correctly', () async {
      await goalRepo().createGoal(Goal(
        title: 'Active',
        metric: GoalMetric.totalMatches,
        target: 10,
        createdAt: DateTime.now(),
      ));
      final id = await goalRepo().createGoal(Goal(
        title: 'Archived',
        metric: GoalMetric.totalMatches,
        target: 10,
        createdAt: DateTime.now(),
      ));
      await goalRepo().archiveGoal(id);

      final active = await goalRepo().getGoalsByStatus(GoalStatus.active);
      final archived = await goalRepo().getGoalsByStatus(GoalStatus.archived);
      expect(active.where((g) => g.title == 'Active'), isNotEmpty);
      expect(archived.where((g) => g.title == 'Archived'), isNotEmpty);
    });

    test('markGoalComplete sets status to completed', () async {
      final id = await goalRepo().createGoal(Goal(
        title: 'Test',
        metric: GoalMetric.totalMatches,
        target: 10,
        createdAt: DateTime.now(),
      ));
      await goalRepo().markGoalComplete(id, DateTime.now());
      final goal = await goalRepo().getGoalById(id);
      expect(goal!.status, GoalStatus.completed);
      expect(goal.isComplete, isTrue);
      expect(goal.completedAt, isNotNull);
    });
  });

  group('Service composition (progress snapshot)', () {
    test('zero state returns zero values, no fabricated data', () async {
      final snap = await service().getProgressSnapshot();
      expect(snap.totalPracticeTime, Duration.zero);
      expect(snap.totalSessions, 0);
      expect(snap.completedDrills, 0);
      expect(snap.goalsTotal, 0);
      expect(snap.practiceFrequencyPerWeek, 0);
      expect(snap.improvementTimeline, isEmpty);
    });

    test('completed TrainingCenterSession is persisted', () async {
      final start = DateTime(2026, 7, 30, 10);
      final id = await trainingCenterRepo().createSession(
        TrainingSession(startedAt: start),
      );
      await trainingCenterRepo().completeSession(
        id,
        notes: 'Done',
      );
      final rows = await trainingCenterRepo().getRecentSessions(limit: 10);
      expect(rows.length, 1);
      expect(rows.first.completedAt, isNotNull);
    });

    test('goals count appears in snapshot', () async {
      await goalRepo().createGoal(Goal(
        title: 'Test',
        metric: GoalMetric.totalMatches,
        target: 10,
        createdAt: DateTime.now(),
      ));
      final snap = await service().getProgressSnapshot();
      expect(snap.goalsTotal, 1);
      expect(snap.goalsActive, 1);
      expect(snap.goalsCompleted, 0);
    });
  });

  group('Practice session delegation', () {
    test('createPracticeSession delegates to training_center', () async {
      final id = await service().createPracticeSession(
        TrainingSession(startedAt: DateTime.now()),
      );
      expect(id, greaterThan(0));
    });

    test('addDrillRunToSession delegates to training_center', () async {
      final sessionId = await service().createPracticeSession(
        TrainingSession(startedAt: DateTime.now()),
      );
      final runId = await service().addDrillRunToSession(DrillRun(
        sessionId: sessionId,
        drillCode: 'stopShot',
        drillName: 'Stop Shot',
        category: 'stop',
        targetReps: 10,
        attempts: 5,
        successes: 4,
        createdAt: DateTime.now(),
      ));
      expect(runId, greaterThan(0));
    });
  });
}
