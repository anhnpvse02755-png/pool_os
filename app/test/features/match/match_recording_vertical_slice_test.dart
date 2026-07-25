import 'dart:io';

import 'package:drift/drift.dart' show QueryExecutor;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/event/data/repositories/event_repository.dart';
import 'package:pool_os/features/match/application/match_recording_service.dart';
import 'package:pool_os/features/match/data/repositories/match_repository.dart';
import 'package:pool_os/features/match/domain/models/match.dart';
import 'package:pool_os/features/player/data/database/app_database.dart'
    show AppDatabase;
import 'package:pool_os/features/rack/data/repositories/rack_repository.dart';
import 'package:pool_os/features/rack/domain/models/rack.dart';
import 'package:pool_os/features/session/data/recording_coordinator.dart';
import 'package:pool_os/features/session/data/repositories/session_repository.dart';
import 'package:pool_os/features/session/domain/models/session.dart';
import 'package:pool_os/features/shot/data/repositories/shot_repository.dart';

void main() {
  late _Fixture fixture;

  setUp(() => fixture = _Fixture.open(NativeDatabase.memory()));
  tearDown(() => fixture.database.close());

  test('creates a persisted match through the execution framework', () async {
    final sessionId = await fixture.createSession();

    final matchId = await fixture.recording.createMatch(
      Match(
        sessionId: sessionId,
        matchNumber: 99,
        gameType: GameTypes.raceTo,
        raceTo: 2,
      ),
    );

    final saved = await fixture.matches.getMatchById(matchId);
    expect(saved, isNotNull);
    expect(saved!.matchNumber, 1);
    expect(saved.startTime, isNotNull);
  });

  test('records racks in owner-assigned order and persists score', () async {
    final matchId = await fixture.createMatch();

    await fixture.recording.recordRack(
      Rack(matchId: matchId, rackNumber: 50, result: true),
    );
    await fixture.recording.recordRack(
      Rack(matchId: matchId, rackNumber: 50, result: false),
    );

    final racks = await fixture.racks.getRacksByMatchId(matchId);
    expect(racks.map((rack) => rack.rackNumber), [1, 2]);
    expect(racks.map((rack) => rack.result), [true, false]);
  });

  test('finishes the session and its open match atomically', () async {
    final sessionId = await fixture.createSession();
    final matchId = await fixture.createMatch(sessionId: sessionId);

    await fixture.recording.finishSession(sessionId);

    expect((await fixture.sessions.getSessionById(sessionId))!.finishedAt,
        isNotNull);
    expect((await fixture.matches.getMatchById(matchId))!.endTime, isNotNull);
  });

  test('refreshes player progress after a successful match finish', () async {
    var refreshes = 0;
    var equipmentRefreshes = 0;
    var careerRefreshes = 0;
    await fixture.database.close();
    fixture = _Fixture.open(
      NativeDatabase.memory(),
      refreshPlayerProgress: () async => refreshes += 1,
      refreshEquipmentPerformance: () async => equipmentRefreshes += 1,
      refreshCareerTimeline: () async => careerRefreshes += 1,
    );
    final matchId = await fixture.createMatch();

    await fixture.recording.finishMatch(matchId);

    expect(refreshes, 1);
    expect(equipmentRefreshes, 1);
    expect(careerRefreshes, 1);
  });

  test('fails closed instead of persisting an orphan rack', () async {
    expect(
      () => fixture.recording.recordRack(
        Rack(matchId: 9999, rackNumber: 1, result: true),
      ),
      throwsStateError,
    );
    expect(await fixture.racks.getRacksByMatchId(9999), isEmpty);
  });

  test('history survives closing and reopening the database', () async {
    final directory = await Directory.systemTemp.createTemp('pool_os_i1_');
    final file = File('${directory.path}/recording.db');
    try {
      await fixture.database.close();
      fixture = _Fixture.open(NativeDatabase(file));
      final sessionId = await fixture.createSession();
      final matchId = await fixture.createMatch(sessionId: sessionId);
      await fixture.recording.recordRack(
        Rack(matchId: matchId, rackNumber: 1, result: true),
      );
      await fixture.recording.finishSession(sessionId);
      await fixture.database.close();

      fixture = _Fixture.open(NativeDatabase(file));
      final sessions = await fixture.sessions.getAllSessions();
      final matches = await fixture.matches.getMatchesBySessionId(sessionId);
      final racks = await fixture.racks.getRacksByMatchId(matchId);
      expect(sessions.single.id, sessionId);
      expect(sessions.single.finishedAt, isNotNull);
      expect(matches.single.id, matchId);
      expect(matches.single.endTime, isNotNull);
      expect(racks.single.result, isTrue);
    } finally {
      await fixture.database.close();
      if (await directory.exists()) await directory.delete(recursive: true);
      fixture = _Fixture.open(NativeDatabase.memory());
    }
  });
}

final class _Fixture {
  _Fixture._({
    required this.database,
    required this.sessions,
    required this.matches,
    required this.racks,
    required this.recording,
  });

  factory _Fixture.open(
    QueryExecutor executor, {
    Future<void> Function()? refreshPlayerProgress,
    Future<void> Function()? refreshEquipmentPerformance,
    Future<void> Function()? refreshCareerTimeline,
  }) {
    final database = AppDatabase.forTesting(executor);
    final sessions = SessionRepository(database);
    final matches = MatchRepository(database);
    final racks = RackRepository(database);
    final coordinator = RecordingCoordinator(
      database: database,
      sessionRepo: sessions,
      matchRepo: matches,
      rackRepo: racks,
      shotRepo: ShotRepository(database),
      eventRepo: EventRepository(database),
    );
    return _Fixture._(
      database: database,
      sessions: sessions,
      matches: matches,
      racks: racks,
      recording: MatchRecordingService(
        coordinator,
        refreshPlayerProgress: refreshPlayerProgress,
        refreshEquipmentPerformance: refreshEquipmentPerformance,
        refreshCareerTimeline: refreshCareerTimeline,
      ),
    );
  }

  final AppDatabase database;
  final SessionRepository sessions;
  final MatchRepository matches;
  final RackRepository racks;
  final MatchRecordingService recording;

  Future<int> createSession() {
    final now = DateTime.now();
    return sessions.createSession(
      Session(
        sessionType: SessionTypes.match,
        startedAt: now,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<int> createMatch({int? sessionId}) async {
    final ownerSessionId = sessionId ?? await createSession();
    return recording.createMatch(
      Match(
        sessionId: ownerSessionId,
        matchNumber: 1,
        gameType: GameTypes.raceTo,
        raceTo: 2,
      ),
    );
  }
}
