import 'dart:io';
import 'package:drift/native.dart' show NativeDatabase;
import 'package:drift/drift.dart' show QueryExecutor;
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/player/data/database/app_database.dart' show AppDatabase;
import 'package:pool_os/features/session/data/recording_coordinator.dart';
import 'package:pool_os/features/session/data/repositories/session_repository.dart';
import 'package:pool_os/features/match/data/repositories/match_repository.dart';
import 'package:pool_os/features/rack/data/repositories/rack_repository.dart';
import 'package:pool_os/features/shot/data/repositories/shot_repository.dart';
import 'package:pool_os/features/event/data/repositories/event_repository.dart';
import 'package:pool_os/features/session/domain/models/session.dart';
import 'package:pool_os/features/match/domain/models/match.dart';
import 'package:pool_os/features/shot/domain/models/shot.dart';
import 'package:pool_os/features/event/domain/models/event.dart';
import 'package:pool_os/features/session/domain/recording_errors.dart';

/// RFC-301 Recording Pipeline integration tests.
///
/// Exercise the pipeline end-to-end against an in-memory SQLite database with
/// foreign keys enforced, asserting the RFC business rules:
///  * no orphan rows / no fake IDs (rackId=0, shotId=0),
///  * persist-first with real auto-increment IDs flowing across layers,
///  * atomicity of the create chain,
///  * durability across a database "restart".
void main() {
  late AppDatabase db;
  late RecordingCoordinator coordinator;
  late SessionRepository sessionRepo;
  late MatchRepository matchRepo;
  late RackRepository rackRepo;
  late ShotRepository shotRepo;
  late EventRepository eventRepo;

  AppDatabase openDb(QueryExecutor executor) {
    final database = AppDatabase.forTesting(executor);
    sessionRepo = SessionRepository(database);
    matchRepo = MatchRepository(database);
    rackRepo = RackRepository(database);
    shotRepo = ShotRepository(database);
    eventRepo = EventRepository(database);
    coordinator = RecordingCoordinator(
      database: database,
      sessionRepo: sessionRepo,
      matchRepo: matchRepo,
      rackRepo: rackRepo,
      shotRepo: shotRepo,
      eventRepo: eventRepo,
    );
    return database;
  }

  setUp(() {
    db = openDb(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> startPracticeSession() async {
    final now = DateTime.now();
    return sessionRepo.createSession(
      Session(
        sessionType: SessionTypes.practice,
        startedAt: now,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Shot buildShot(int rackId) => Shot(
        rackId: rackId,
        shotNumber: 1,
        shotType: ShotTypes.normalShot,
        difficulty: ShotDifficulty.medium,
        result: ShotResult.made,
      );

  test('Practice pipeline persists Shot and Event with real parent IDs', () async {
    final sessionId = await startPracticeSession();

    final matchId = await coordinator.ensurePracticeMatch(sessionId: sessionId);
    final rackId = await coordinator.ensureCurrentRack(matchId: matchId);
    expect(rackId, greaterThan(0));

    final shotId = await coordinator.recordShot(rackId: rackId, shot: buildShot(rackId));
    expect(shotId, greaterThan(0));

    final eventId = await coordinator.recordEvent(
      shotId: shotId,
      event: Event(category: EventCategory.stroke, type: StrokeEventTypes.gripTight),
    );
    expect(eventId, greaterThan(0));

    // Read back from DB: parents must be the real IDs, never 0.
    final shots = await shotRepo.getShotsByRackId(rackId);
    expect(shots, hasLength(1));
    expect(shots.single.rackId, rackId);
    expect(shots.single.rackId, isNot(0));

    final events = await eventRepo.getEventsByShotId(shotId);
    expect(events, hasLength(1));
    expect(events.single.shotId, shotId);
    expect(events.single.shotId, isNot(0));
  });

  test('recordShot rejects a non-existent Rack (no orphan)', () async {
    expect(
      () => coordinator.recordShot(rackId: 9999, shot: buildShot(9999)),
      throwsA(isA<RecordingIntegrityException>()),
    );
    final count = await shotRepo.getShotCountByRackId(9999);
    expect(count, 0);
  });

  test('recordShot rejects rackId=0 (the old fake-ID path)', () async {
    expect(
      () => coordinator.recordShot(rackId: 0, shot: buildShot(0)),
      throwsA(isA<RecordingIntegrityException>()),
    );
  });

  test('recordEvent rejects a non-existent Shot (no orphan)', () async {
    expect(
      () => coordinator.recordEvent(
        shotId: 9999,
        event: Event(category: EventCategory.stroke, type: StrokeEventTypes.gripTight),
      ),
      throwsA(isA<RecordingIntegrityException>()),
    );
    final count = await eventRepo.getEventCountByShotId(9999);
    expect(count, 0);
  });

  test('EventRepository.createEvent rejects null shotId directly', () async {
    expect(
      () => eventRepo.createEvent(
        Event(category: EventCategory.stroke, type: StrokeEventTypes.gripTight),
      ),
      throwsA(isA<RecordingIntegrityException>()),
    );
  });

  test('Match supports arbitrary race and winner uses playerScore >= raceTo', () async {
    final now = DateTime.now();
    final sessionId = await sessionRepo.createSession(
      Session(sessionType: SessionTypes.match, startedAt: now, createdAt: now, updatedAt: now),
    );
    // Race to 11 must be storable (no hardcoded 5/7).
    final matchId = await matchRepo.createMatch(
      Match(sessionId: sessionId, matchNumber: 1, gameType: 'race_to_11', raceTo: 11, startTime: now),
    );
    // Play 11 winning racks; each rack is a real child of the match.
    for (var i = 0; i < 11; i++) {
      await coordinator.ensureCurrentRackForResult(matchId: matchId, result: true);
    }
    final wins = await rackRepo.getWinCountByMatchId(matchId);
    final match = await matchRepo.getMatchById(matchId);
    expect(match!.raceTo, 11);
    // Winner condition per RFC: playerScore >= raceTo.
    expect(wins >= match.raceTo!, isTrue);
  });

  test('Data survives a database restart (close + reopen on the same file)', () async {
    // Write to an on-disk database, close it, then reopen the SAME file to
    // simulate an app restart (RFC Rule #7: nothing disappears after restart).
    final dir = await Directory.systemTemp.createTemp('rfc301_');
    final file = File('${dir.path}/pool_os_test.db');

    int rackId;
    int shotId;
    try {
      db = openDb(NativeDatabase(file));
      final sessionId = await startPracticeSession();
      final matchId = await coordinator.ensurePracticeMatch(sessionId: sessionId);
      rackId = await coordinator.ensureCurrentRack(matchId: matchId);
      shotId = await coordinator.recordShot(rackId: rackId, shot: buildShot(rackId));
      await coordinator.recordEvent(
        shotId: shotId,
        event: Event(category: EventCategory.stroke, type: StrokeEventTypes.gripTight),
      );
      await db.close();

      // Reopen the same file — data must still be there.
      db = openDb(NativeDatabase(file));
      final sessions = await sessionRepo.getAllSessions();
      expect(sessions, isNotEmpty);
      final shots = await shotRepo.getShotsByRackId(rackId);
      expect(shots, hasLength(1));
      expect(shots.single.rackId, rackId);
      final events = await eventRepo.getEventsByShotId(shotId);
      expect(events, hasLength(1));
      expect(events.single.shotId, shotId);
    } finally {
      // Close before deleting so Windows releases the file lock.
      await db.close();
      if (await dir.exists()) await dir.delete(recursive: true);
      // Reopen a throwaway in-memory db so the group tearDown's close() is safe.
      db = openDb(NativeDatabase.memory());
    }
  });

  test('finishSession closes the open match atomically', () async {
    final sessionId = await startPracticeSession();
    await coordinator.ensurePracticeMatch(sessionId: sessionId);

    await coordinator.finishSession(sessionId);

    final activeMatch = await matchRepo.getActiveMatchBySessionId(sessionId);
    expect(activeMatch, isNull, reason: 'open match should be finished');
    final activeSession = await sessionRepo.getActiveSession();
    expect(activeSession, isNull, reason: 'session should be finished');
  });

  test('Rack Match-Mode fields round-trip via real columns (no JSON blob)', () async {
    final sessionId = await startPracticeSession();
    final matchId = await coordinator.ensurePracticeMatch(sessionId: sessionId);
    final rackId = await coordinator.ensureCurrentRack(matchId: matchId);

    final rack = (await rackRepo.getRackById(rackId))!;
    final updated = rack.copyWith(
      ballsPotted: 7,
      largestRun: 5,
      breakSuccess: true,
      bestStrengths: ['position_play', 'break_effective'],
      biggestMistakes: ['long_pots'],
      notes: 'clean notes without blob',
    );
    await rackRepo.updateRack(updated);

    final reloaded = (await rackRepo.getRackById(rackId))!;
    expect(reloaded.ballsPotted, 7);
    expect(reloaded.largestRun, 5);
    expect(reloaded.breakSuccess, isTrue);
    expect(reloaded.bestStrengths, containsAll(['position_play', 'break_effective']));
    expect(reloaded.biggestMistakes, contains('long_pots'));
    // notes must NOT carry a __RACK_DATA__ blob anymore.
    expect(reloaded.notes, 'clean notes without blob');
    expect(reloaded.notes, isNot(contains('__RACK_DATA__')));
  });
}
