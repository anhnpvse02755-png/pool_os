// EPIC 03 — Training System repository.
//
// Maps the 3 new Training entities (Lesson, CoachNote, TrainingProgram)
// to/from the Drift tables introduced in schema v31. Read-only on the
// public `lessons` + `training_programs` seeds; write on `coach_notes`
// and `training_program_enrollments` (per-player rows).
//
// All other training CRUD lives in the existing repositories
// (GoalCenterRepository, TrainingCenterRepository). This file is the
// home only of the new Training entities.

import 'dart:convert' as convert;

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/player/data/database/app_database.dart' as db;
import 'package:pool_os/features/player/data/providers/database_providers.dart';
import 'package:pool_os/features/training_system/domain/models/training_system_models.dart';

final trainingSystemRepositoryProvider =
    Provider<TrainingSystemRepository>((ref) {
  return TrainingSystemRepository(ref.watch(databaseProvider));
});

/// Map a row → [Lesson]. The seed `lessons` table is read-only; the
/// per-player `completedAt` is read from the seed itself for now and
/// Phase I will wire a sidecar table once per-player completion is
/// persisted. For MVP the public seed has no completions.
Lesson _mapLesson(db.Lesson row) => Lesson(
      id: row.id,
      code: row.code,
      title: row.title,
      description: row.description,
      objectives: _decodeStringList(row.objectives),
      requiredDrills: _decodeStringList(row.requiredDrills),
      references: _decodeStringList(row.references),
      difficulty: row.difficulty,
      skillLevel: row.skillLevel,
      orderIndex: row.orderIndex,
      createdAt: row.createdAt,
    );

CoachNote _mapCoachNote(db.CoachNote row) {
  return CoachNote(
    id: row.id,
    playerId: row.playerId,
    sessionId: row.sessionId,
    category: CoachNoteCategoryInfo.fromCode(row.category),
    body: row.body,
    createdAt: row.createdAt,
  );
}

TrainingProgram _mapProgram(db.TrainingProgram row) {
  return TrainingProgram(
    id: row.id,
    playerId: row.playerId,
    code: row.code,
    title: row.title,
    description: row.description,
    difficulty: ProgramDifficultyInfo.fromCode(row.difficulty),
    weekCount: row.weekCount,
    hierarchy: TrainingProgramHierarchy.fromJsonString(row.hierarchy),
    isSeed: row.isSeed,
    createdAt: row.createdAt,
  );
}

TrainingProgramEnrollment _mapEnrollment(
    db.TrainingProgramEnrollment row) {
  return TrainingProgramEnrollment(
    id: row.id,
    playerId: row.playerId,
    programId: row.programId,
    currentWeek: row.currentWeek,
    completedWeeks: _decodeIntList(row.completedWeeks),
    startedAt: row.startedAt,
    completedAt: row.completedAt,
  );
}

List<String> _decodeStringList(String raw) {
  if (raw.isEmpty) return const [];
  try {
    final v = convert.jsonDecode(raw);
    if (v is List) {
      return v.map((e) => e.toString()).toList();
    }
  } catch (_) {}
  return const [];
}

List<int> _decodeIntList(String raw) {
  if (raw.isEmpty) return const [];
  try {
    final v = convert.jsonDecode(raw);
    if (v is List) {
      return v.map((e) => (e as num).toInt()).toList();
    }
  } catch (_) {}
  return const [];
}

class TrainingSystemRepository {
  final db.AppDatabase _db;

  TrainingSystemRepository(this._db);

  // --- Lessons (read-only seed, per-player completion sidecar) ------------

  Future<List<Lesson>> getLessons() async {
    final rows = await (_db.select(_db.lessons)
          ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
        .get();
    return rows.map((r) => _mapLesson(r)).toList();
  }

  Future<Lesson?> getLessonByCode(String code) async {
    final row = await (_db.select(_db.lessons)..where((t) => t.code.equals(code)))
        .getSingleOrNull();
    return row == null ? null : _mapLesson(row);
  }

  // --- Coach Notes (write) -------------------------------------------------

  Future<List<CoachNote>> getCoachNotes({int? sessionId, int? playerId}) async {
    final q = _db.select(_db.coachNotes)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    if (sessionId != null) {
      q.where((t) => t.sessionId.equals(sessionId));
    } else if (playerId != null) {
      q.where((t) => t.playerId.equals(playerId));
    }
    final rows = await q.get();
    return rows.map(_mapCoachNote).toList();
  }

  Future<int> addCoachNote(CoachNote note) async {
    return _db.into(_db.coachNotes).insert(
          db.CoachNotesCompanion.insert(
            playerId: Value(note.playerId),
            sessionId: Value(note.sessionId),
            category: note.category.code,
            body: note.body,
          ),
        );
  }

  Future<void> deleteCoachNote(int id) async {
    await (_db.delete(_db.coachNotes)..where((t) => t.id.equals(id))).go();
  }

  // --- Training Programs (read seed + read/write custom) -------------------

  Future<List<TrainingProgram>> getPrograms({bool seedOnly = false}) async {
    final q = _db.select(_db.trainingPrograms)
      ..orderBy([(t) => OrderingTerm.asc(t.difficulty)]);
    if (seedOnly) {
      q.where((t) => t.isSeed.equals(true));
    }
    final rows = await q.get();
    return rows.map(_mapProgram).toList();
  }

  Future<TrainingProgram?> getProgramByCode(String code) async {
    final row = await (_db.select(_db.trainingPrograms)
          ..where((t) => t.code.equals(code)))
        .getSingleOrNull();
    return row == null ? null : _mapProgram(row);
  }

  Future<int> upsertCustomProgram(TrainingProgram program) async {
    return _db.into(_db.trainingPrograms).insertOnConflictUpdate(
          db.TrainingProgramsCompanion.insert(
            playerId: Value(program.playerId),
            code: program.code,
            title: program.title,
            description: program.description,
            difficulty: Value(program.difficulty.code),
            weekCount: Value(program.weekCount),
            hierarchy: Value(program.hierarchy.toJsonString()),
            isSeed: Value(program.isSeed),
          ),
        );
  }

  Future<void> deleteCustomProgram(int id) async {
    await (_db.delete(_db.trainingPrograms)
          ..where((t) => t.id.equals(id) & t.isSeed.equals(false)))
        .go();
  }

  // --- Enrollments (per-player program progress) --------------------------

  Future<List<TrainingProgramEnrollment>> getEnrollments({int? playerId}) async {
    final q = _db.select(_db.trainingProgramEnrollments)
      ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]);
    if (playerId != null) {
      q.where((t) => t.playerId.equals(playerId));
    }
    final rows = await q.get();
    return rows.map(_mapEnrollment).toList();
  }

  Future<TrainingProgramEnrollment?> getEnrollmentForProgram(int programId,
      {int? playerId}) async {
    final q = _db.select(_db.trainingProgramEnrollments)
      ..where((t) => t.programId.equals(programId))
      ..limit(1);
    if (playerId != null) {
      q.where((t) => t.playerId.equals(playerId));
    }
    final row = await q.getSingleOrNull();
    return row == null ? null : _mapEnrollment(row);
  }

  Future<int> enroll(int programId, {int? playerId}) async {
    return _db.into(_db.trainingProgramEnrollments).insert(
          db.TrainingProgramEnrollmentsCompanion.insert(
            playerId: Value(playerId),
            programId: Value(programId),
            currentWeek: const Value(1),
            completedWeeks: const Value('[]'),
          ),
        );
  }

  Future<void> markWeekCompleted(int enrollmentId, int weekIndex) async {
    final row = await (_db.select(_db.trainingProgramEnrollments)
          ..where((t) => t.id.equals(enrollmentId)))
        .getSingleOrNull();
    if (row == null) return;
    final existing = _decodeIntList(row.completedWeeks).toSet()..add(weekIndex);
    final sorted = existing.toList()..sort();
    final totalWeeks = row.programId == 0 ? 0 : (row.currentWeek);
    await (_db.update(_db.trainingProgramEnrollments)
          ..where((t) => t.id.equals(enrollmentId)))
        .write(db.TrainingProgramEnrollmentsCompanion(
      currentWeek: Value(weekIndex + 1),
      completedWeeks: Value(convert.jsonEncode(sorted)),
      completedAt: sorted.length >= totalWeeks && totalWeeks > 0
          ? Value(DateTime.now())
          : const Value.absent(),
    ));
  }
}