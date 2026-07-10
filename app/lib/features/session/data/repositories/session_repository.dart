import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/player/data/database/app_database.dart' as db;
import 'package:pool_os/features/session/domain/models/session.dart';
import 'package:pool_os/features/player/data/providers/database_providers.dart';

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository(ref.watch(databaseProvider));
});

class SessionRepository {
  final db.AppDatabase _db;

  SessionRepository(this._db);

  Future<List<Session>> getAllSessions() async {
    final results = await _db.select(_db.sessions).get();
    return results.map(_mapToSession).toList();
  }

  Future<Session?> getSessionById(int id) async {
    final result = await (_db.select(_db.sessions)
          ..where((s) => s.id.equals(id)))
        .getSingleOrNull();
    if (result == null) return null;
    return _mapToSession(result);
  }

  Future<Session?> getActiveSession() async {
    // RFC-301: tolerate >1 unfinished session (getSingleOrNull would throw).
    // The most recently started open session is treated as the active one.
    final result = await (_db.select(_db.sessions)
          ..where((s) => s.finishedAt.isNull())
          ..orderBy([(s) => OrderingTerm.desc(s.startedAt)])
          ..limit(1))
        .getSingleOrNull();
    if (result == null) return null;
    return _mapToSession(result);
  }

  Future<List<Session>> getSessionsByDateRange(
      DateTime start, DateTime end) async {
    final results = await (_db.select(_db.sessions)
          ..where((s) => s.startedAt.isBiggerOrEqualValue(start))
          ..where((s) => s.startedAt.isSmallerOrEqualValue(end)))
        .get();
    return results.map(_mapToSession).toList();
  }

  Future<int> createSession(Session session) async {
    return _db.into(_db.sessions).insert(
      db.SessionsCompanion.insert(
        sessionType: session.sessionType,
        location: Value(session.location),
        table: Value(session.table),
        cloth: Value(session.cloth),
        balls: Value(session.balls),
        trainingGoal: Value(session.trainingGoal),
        notes: Value(session.notes),
        weather: Value(session.weather),
        startedAt: session.startedAt,
        finishedAt: Value(session.finishedAt),
        createdAt: Value(session.createdAt),
        updatedAt: Value(session.updatedAt),
      ),
    );
  }

  Future<bool> updateSession(Session session) async {
    final updatedRows = await (_db.update(_db.sessions)
          ..where((s) => s.id.equals(session.id!)))
        .write(
      db.SessionsCompanion(
        sessionType: Value(session.sessionType),
        location: Value(session.location),
        table: Value(session.table),
        cloth: Value(session.cloth),
        balls: Value(session.balls),
        trainingGoal: Value(session.trainingGoal),
        notes: Value(session.notes),
        weather: Value(session.weather),
        startedAt: Value(session.startedAt),
        finishedAt: Value(session.finishedAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
    return updatedRows > 0;
  }

  Future<int> finishSession(int id) async {
    return (_db.update(_db.sessions)..where((s) => s.id.equals(id))).write(
      db.SessionsCompanion(
        finishedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> deleteSession(int id) async {
    return (_db.delete(_db.sessions)..where((s) => s.id.equals(id))).go();
  }

  Future<int> reactivateSession(int id) async {
    return (_db.update(_db.sessions)..where((s) => s.id.equals(id))).write(
      db.SessionsCompanion(
        finishedAt: const Value(null),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Session _mapToSession(db.Session data) {
    return Session(
      id: data.id,
      sessionType: data.sessionType,
      location: data.location,
      table: data.table,
      cloth: data.cloth,
      balls: data.balls,
      trainingGoal: data.trainingGoal,
      notes: data.notes,
      weather: data.weather,
      startedAt: data.startedAt,
      finishedAt: data.finishedAt,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }
}
