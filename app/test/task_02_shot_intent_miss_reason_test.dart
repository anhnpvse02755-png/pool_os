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
import 'package:pool_os/features/shot/domain/models/shot.dart';

/// Task 02 — a Shot is now a complete data unit: it carries `intent` (what the
/// player meant to do) and `missReason` (why it failed, null when made). These
/// tests assert both columns round-trip through persistence, that a made shot
/// leaves missReason null, and that they survive a database restart (schema
/// v13 migration is additive — see _migrateToV13).
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

  Future<int> newPracticeRack() async {
    final now = DateTime.now();
    final sessionId = await sessionRepo.createSession(
      Session(
        sessionType: SessionTypes.practice,
        startedAt: now,
        createdAt: now,
        updatedAt: now,
      ),
    );
    final matchId = await coordinator.ensurePracticeMatch(sessionId: sessionId);
    return coordinator.ensureCurrentRack(matchId: matchId);
  }

  test('missed Shot round-trips intent + missReason through the DB', () async {
    final rackId = await newPracticeRack();

    final shotId = await coordinator.recordShot(
      rackId: rackId,
      shot: Shot(
        rackId: rackId,
        shotNumber: 1,
        shotType: ShotTypes.normalShot,
        difficulty: ShotDifficulty.hard,
        result: ShotResult.missed,
        intent: 'pot',
        missReason: 'aim',
      ),
    );
    expect(shotId, greaterThan(0));

    final stored = await shotRepo.getShotById(shotId);
    expect(stored, isNotNull);
    expect(stored!.intent, 'pot');
    expect(stored.missReason, 'aim');
    expect(stored.result, ShotResult.missed);
  });

  test('made Shot keeps intent but leaves missReason null', () async {
    final rackId = await newPracticeRack();

    final shotId = await coordinator.recordShot(
      rackId: rackId,
      shot: Shot(
        rackId: rackId,
        shotNumber: 1,
        shotType: ShotTypes.normalShot,
        difficulty: ShotDifficulty.easy,
        result: ShotResult.made,
        intent: 'position',
        // missReason intentionally omitted — a made shot has no failure cause.
      ),
    );

    final stored = await shotRepo.getShotById(shotId);
    expect(stored, isNotNull);
    expect(stored!.intent, 'position');
    expect(stored.missReason, isNull);
  });

  test('intent + missReason survive a database restart (schema v13)', () async {
    final dir = await Directory.systemTemp.createTemp('task02_');
    final file = File('${dir.path}/pool_os_test.db');

    int shotId;
    try {
      db = openDb(NativeDatabase(file));
      final rackId = await newPracticeRack();
      shotId = await coordinator.recordShot(
        rackId: rackId,
        shot: Shot(
          rackId: rackId,
          shotNumber: 1,
          shotType: ShotTypes.normalShot,
          difficulty: ShotDifficulty.medium,
          result: ShotResult.missed,
          intent: 'safety',
          missReason: 'nerves',
        ),
      );
      await db.close();

      // Reopen the same file — the new columns must still hold their values.
      db = openDb(NativeDatabase(file));
      final stored = await shotRepo.getShotById(shotId);
      expect(stored, isNotNull);
      expect(stored!.intent, 'safety');
      expect(stored.missReason, 'nerves');
    } finally {
      await db.close();
      if (await dir.exists()) await dir.delete(recursive: true);
      db = openDb(NativeDatabase.memory());
    }
  });
}
