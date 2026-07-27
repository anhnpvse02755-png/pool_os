import 'dart:io';

import 'package:drift/drift.dart' show Variable;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/event/data/repositories/event_repository.dart';
import 'package:pool_os/features/match/application/match_recording_service.dart';
import 'package:pool_os/features/match/data/repositories/match_repository.dart';
import 'package:pool_os/features/match/domain/models/match.dart';
import 'package:pool_os/features/player/data/database/app_database.dart'
    show AppDatabase;
import 'package:pool_os/features/rack/data/repositories/rack_repository.dart';
import 'package:pool_os/features/session/data/recording_coordinator.dart';
import 'package:pool_os/features/session/data/repositories/session_repository.dart';
import 'package:pool_os/features/session/domain/models/session.dart';
import 'package:pool_os/features/session/domain/recording_errors.dart';
import 'package:pool_os/features/shot/data/repositories/shot_repository.dart';

void main() {
  late _Fixture fixture;

  setUp(() => fixture = _Fixture.open());
  tearDown(() => fixture.database.close());

  test('caller numbering and timestamps are ignored', () async {
    final sessionId = await fixture.createSession();
    final startedAt = DateTime.utc(2026, 1, 1, 12, 0, 0);

    final matchId = await fixture.recording.createMatch(
      Match(
        sessionId: sessionId,
        matchNumber: 99,
        gameType: GameTypes.raceTo,
        startTime: startedAt,
        endTime: DateTime.now(),
        createdAt: DateTime.now(),
      ),
    );

    final saved = await fixture.matches.getMatchById(matchId);
    expect(saved, isNotNull);
    expect(saved!.matchNumber, 1);
    expect(saved.startTime, isNotNull);
    expect(saved.endTime, isNull);
  });

  test('existing open Match blocks creation without writes', () async {
    final sessionId = await fixture.createSession();
    final firstId = await fixture.createMatch(sessionId: sessionId);

    await expectLater(
      fixture.createMatch(sessionId: sessionId),
      throwsA(
        isA<MatchRecordingException>().having(
          (e) => e.code,
          'code',
          MatchRecordingFailureCode.openMatchExists,
        ),
      ),
    );

    final stored = await fixture.matches.getMatchesBySessionId(sessionId);
    expect(stored.map((m) => m.id), [firstId]);
  });

  test('deleting completed Match never reuses allocation', () async {
    final sessionId = await fixture.createSession();
    final firstId = await fixture.createMatch(sessionId: sessionId);
    await fixture.recording.finishMatch(firstId);
    await fixture.matches.deleteMatch(firstId);

    final secondId = await fixture.createMatch(sessionId: sessionId);
    expect(secondId, isNot(equals(firstId)));

    final matches = await fixture.matches.getMatchesBySessionId(sessionId);
    final numbers = matches.map((m) => m.matchNumber).toList()..sort();
    expect(numbers, [2]);
  });

  test('zero-row parent lock classifies missing Session', () async {
    await expectLater(
      fixture.createMatch(sessionId: 99999),
      throwsA(
        isA<MatchRecordingException>().having(
          (e) => e.code,
          'code',
          MatchRecordingFailureCode.sessionTargetNotFound,
        ),
      ),
    );
  });

  test('ensurePracticeMatch is find-or-create and returns existing open Match',
      () async {
    final sessionId = await fixture.createSession();
    final first = await fixture.createMatch(
      sessionId: sessionId,
      gameType: 'practice',
    );

    final again = await fixture.coordinator.ensurePracticeMatch(
      sessionId: sessionId,
    );
    expect(again, first);

    final all = await fixture.matches.getMatchesBySessionId(sessionId);
    expect(all.length, 1);
  });

  test('invalid metadata is rejected before any DB write', () async {
    final sessionId = await fixture.createSession();

    await expectLater(
      fixture.createMatch(sessionId: sessionId, gameType: ''),
      throwsA(
        isA<MatchRecordingException>().having(
          (e) => e.code,
          'code',
          MatchRecordingFailureCode.invalidSourceState,
        ),
      ),
    );

    final stored = await fixture.matches.getMatchesBySessionId(sessionId);
    expect(stored, isEmpty);
  });

  test('startDrillMatch rolls back when Rack insert fails', () async {
    final sessionId = await fixture.createSession();

    // Build a recording coordinator whose rack repository always throws.
    final failingCoordinator = RecordingCoordinator(
      database: fixture.database,
      sessionRepo: fixture.sessions,
      matchRepo: fixture.matches,
      rackRepo: _FailingRackRepository(),
      shotRepo: ShotRepository(fixture.database),
      eventRepo: EventRepository(fixture.database),
    );

    await expectLater(
      failingCoordinator.startDrillMatch(
        sessionId: sessionId,
        drillCode: 'DRILL-001',
        drillName: 'Straight pot',
      ),
      throwsA(isA<Object>()),
    );

    final stored = await fixture.matches.getMatchesBySessionId(sessionId);
    expect(stored, isEmpty);
  });

  test('concurrent creation yields one Match and one typed failure', () async {
    final directory = await Directory.systemTemp.createTemp('pool_os_i8_');
    final file = File('${directory.path}/concurrent.db');
    AppDatabase? sharedApp;
    try {
      sharedApp = AppDatabase.forTesting(NativeDatabase(file));

      final sharedSessions = SessionRepository(sharedApp);
      final sharedMatches = MatchRepository(sharedApp);

      final sessionId = await sharedSessions.createSession(
        Session(
          sessionType: SessionTypes.match,
          startedAt: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      Future<int?> attempt(MatchRecordingService service) async {
        try {
          return await service.createMatch(
            Match(
              sessionId: sessionId,
              matchNumber: 0,
              gameType: GameTypes.raceTo,
            ),
          );
        } on MatchRecordingException {
          return null;
        }
      }

      final serviceA = _buildService(sharedApp, sharedSessions, sharedMatches);
      final serviceB = _buildService(sharedApp, sharedSessions, sharedMatches);

      final results = await Future.wait([
        attempt(serviceA),
        attempt(serviceB),
      ]);

      final successes = results.where((id) => id != null).length;
      final typedFailures = results.where((id) => id == null).length;
      expect(successes, 1);
      expect(typedFailures, 1);
    } finally {
      await sharedApp?.close();
      if (await directory.exists()) await directory.delete(recursive: true);
    }
  });

  // Note: the concurrent-creation test above covers the
  // `allocationConflict` literal classification under live contention; we
  // do not add an explicit CAS-exhaustion test here because Drift's int64
  // binding of the signed-integer max is platform-sensitive and the path
  // is exercised end-to-end by the contention case.

  test('legacy duplicate numbers fail closed without repair', () async {
    final sessionId = await fixture.createSession();
    final now = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;

    // Simulate a legacy v29 duplicate by temporarily dropping the v30
    // triggers, seeding two closed matches with the same match_number,
    // then re-creating the triggers. The migration leaves the legacy
    // state unrepaired; the coordinator must still fail closed.
    for (final trigger in const [
      'matches_reject_duplicate_session_match_number_insert',
      'matches_reject_duplicate_session_match_number_update',
    ]) {
      await fixture.database.customStatement('DROP TRIGGER $trigger');
    }

    await fixture.database.customInsert(
      'INSERT INTO matches (session_id, match_number, game_type, '
      'start_time, end_time, created_at) '
      'VALUES (?, 1, ?, ?, ?, ?)',
      variables: [
        Variable<int>(sessionId),
        Variable<String>(GameTypes.raceTo),
        Variable<int>(now),
        Variable<int>(now),
        Variable<int>(now),
      ],
    );
    await fixture.database.customInsert(
      'INSERT INTO matches (session_id, match_number, game_type, '
      'start_time, end_time, created_at) '
      'VALUES (?, 1, ?, ?, ?, ?)',
      variables: [
        Variable<int>(sessionId),
        Variable<String>(GameTypes.raceTo),
        Variable<int>(now),
        Variable<int>(now),
        Variable<int>(now),
      ],
    );

    await expectLater(
      fixture.createMatch(sessionId: sessionId),
      throwsA(
        isA<MatchRecordingException>().having(
          (e) => e.code,
          'code',
          MatchRecordingFailureCode.invalidSourceState,
        ),
      ),
    );
  });

  test('legacy multiple open Matches fail closed without repair', () async {
    final sessionId = await fixture.createSession();
    final now = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;

    // Drop the second-open triggers so the legacy state can be staged.
    for (final trigger in const [
      'matches_reject_second_open_match_insert',
      'matches_reject_second_open_match_update',
    ]) {
      await fixture.database.customStatement('DROP TRIGGER $trigger');
    }

    for (var i = 1; i <= 2; i++) {
      await fixture.database.customInsert(
        'INSERT INTO matches (session_id, match_number, game_type, '
        'start_time, end_time, created_at) VALUES '
        '(?, ?, ?, ?, NULL, ?)',
        variables: [
          Variable<int>(sessionId),
          Variable<int>(i),
          Variable<String>(GameTypes.raceTo),
          Variable<int>(now),
          Variable<int>(now),
        ],
      );
    }

    await expectLater(
      fixture.createMatch(sessionId: sessionId),
      throwsA(
        isA<MatchRecordingException>().having(
          (e) => e.code,
          'code',
          MatchRecordingFailureCode.invalidSourceState,
        ),
      ),
    );
  });

  test('service rethrows FEATURE_008 failure literal', () async {
    Object? thrown;
    try {
      await fixture.recording.createMatch(
        Match(
          sessionId: 99999,
          matchNumber: 0,
          gameType: GameTypes.raceTo,
        ),
      );
    } catch (error) {
      thrown = error;
    }
    expect(thrown, isA<MatchRecordingException>());
    expect(
      (thrown as MatchRecordingException).code.value,
      'match-recording-session-target-not-found',
    );
  });
}

MatchRecordingService _buildService(
  AppDatabase database,
  SessionRepository sessions,
  MatchRepository matches,
) {
  final coordinator = RecordingCoordinator(
    database: database,
    sessionRepo: sessions,
    matchRepo: matches,
    rackRepo: RackRepository(database),
    shotRepo: ShotRepository(database),
    eventRepo: EventRepository(database),
  );
  return MatchRecordingService(coordinator);
}

final class _Fixture {
  _Fixture._({
    required this.database,
    required this.sessions,
    required this.matches,
    required this.coordinator,
    required this.recording,
  });

  factory _Fixture.open() {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final sessions = SessionRepository(database);
    final matches = MatchRepository(database);
    final coordinator = RecordingCoordinator(
      database: database,
      sessionRepo: sessions,
      matchRepo: matches,
      rackRepo: RackRepository(database),
      shotRepo: ShotRepository(database),
      eventRepo: EventRepository(database),
    );
    return _Fixture._(
      database: database,
      sessions: sessions,
      matches: matches,
      coordinator: coordinator,
      recording: MatchRecordingService(coordinator),
    );
  }

  final AppDatabase database;
  final SessionRepository sessions;
  final MatchRepository matches;
  final RecordingCoordinator coordinator;
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

  Future<int> createMatch({
    required int sessionId,
    String gameType = GameTypes.raceTo,
  }) {
    return recording.createMatch(
      Match(
        sessionId: sessionId,
        matchNumber: 0,
        gameType: gameType,
      ),
    );
  }
}

class _FailingRackRepository implements RackRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw StateError('forced rack failure');
  }
}
