import 'dart:io';

import 'package:drift/drift.dart' show Variable;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/event/data/repositories/event_repository.dart';
import 'package:pool_os/features/match/application/match_lifecycle_service.dart';
import 'package:pool_os/features/match/application/match_recording_service.dart';
import 'package:pool_os/features/match/data/repositories/match_repository.dart';
import 'package:pool_os/features/match/domain/match_lifecycle_policy.dart';
import 'package:pool_os/features/match/domain/models/match.dart';
import 'package:pool_os/features/player/data/database/app_database.dart';
import 'package:pool_os/features/rack/data/repositories/rack_repository.dart';
import 'package:pool_os/features/session/data/recording_coordinator.dart';
import 'package:pool_os/features/session/data/repositories/session_repository.dart';
import 'package:pool_os/features/shot/data/repositories/shot_repository.dart';

void main() {
  late AppDatabase database;
  late MatchRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = MatchRepository(database);
  });

  tearDown(() => database.close());

  test('start is conditional, canonical and idempotent only for equality',
      () async {
    await _insertSession(database, 1);
    await _insertMatch(database, id: 1, sessionId: 1, startTime: null);
    final supplied = DateTime.parse('2026-07-25T17:30:15.987654+07:00');

    await database.transaction(
      () => repository.startMatchLifecycle(1, supplied),
    );
    expect((await _rawLifecycle(database, 1)).start, 1784975415);

    await database.transaction(
      () => repository.startMatchLifecycle(1, supplied),
    );
    await expectLater(
      database.transaction(
        () => repository.startMatchLifecycle(
          1,
          supplied.add(const Duration(seconds: 1)),
        ),
      ),
      throwsA(_failure(MatchLifecycleFailureCode.idempotencyConflict)),
    );
  });

  test('start rejects completed and missing timestamp without mutation',
      () async {
    await _insertSession(database, 1);
    await _insertMatch(
      database,
      id: 1,
      sessionId: 1,
      startTime: 100,
      endTime: 200,
    );
    final before = await _rawLifecycle(database, 1);

    await expectLater(
      database.transaction(
        () => repository.startMatchLifecycle(
          1,
          DateTime.fromMillisecondsSinceEpoch(100000, isUtc: true),
        ),
      ),
      throwsA(_failure(MatchLifecycleFailureCode.invalidTransition)),
    );
    await expectLater(
      repository.startMatchLifecycle(999, null),
      throwsA(_failure(MatchLifecycleFailureCode.timestampMissing)),
    );
    expect(await _rawLifecycle(database, 1), before);
  });

  test('finish is atomic and idempotent only for the same canonical end',
      () async {
    await _insertSession(database, 1);
    await _insertMatch(database, id: 1, sessionId: 1, startTime: 100);
    final end = DateTime.fromMillisecondsSinceEpoch(200123, isUtc: true);

    await database.transaction(
      () => repository.finishMatchLifecycle(
        1,
        startedAt: null,
        endedAt: end,
      ),
    );
    expect((await _rawLifecycle(database, 1)).end, 200);
    await database.transaction(
      () => repository.finishMatchLifecycle(
        1,
        startedAt: null,
        endedAt: end,
      ),
    );
    await expectLater(
      database.transaction(
        () => repository.finishMatchLifecycle(
          1,
          startedAt: null,
          endedAt: end.add(const Duration(seconds: 1)),
        ),
      ),
      throwsA(_failure(MatchLifecycleFailureCode.idempotencyConflict)),
    );
    expect(await _rawLifecycle(database, 1), (start: 100, end: 200));
  });

  test('unstarted finish requires and atomically persists supplied start',
      () async {
    await _insertSession(database, 1);
    await _insertMatch(database, id: 1, sessionId: 1, startTime: null);
    final start = DateTime.fromMillisecondsSinceEpoch(100000, isUtc: true);
    final end = DateTime.fromMillisecondsSinceEpoch(200000, isUtc: true);

    await expectLater(
      database.transaction(
        () => repository.finishMatchLifecycle(
          1,
          startedAt: null,
          endedAt: end,
        ),
      ),
      throwsA(_failure(MatchLifecycleFailureCode.timestampMissing)),
    );
    expect(await _rawLifecycle(database, 1), (start: null, end: null));

    await expectLater(
      repository.finishMatchLifecycle(
        1,
        startedAt: end,
        endedAt: start,
      ),
      throwsA(_failure(MatchLifecycleFailureCode.timestampOrderInvalid)),
    );
    await database.transaction(
      () => repository.finishMatchLifecycle(
        1,
        startedAt: start,
        endedAt: end,
      ),
    );
    expect(await _rawLifecycle(database, 1), (start: 100, end: 200));
    await database.transaction(
      () => repository.finishMatchLifecycle(
        1,
        startedAt: start,
        endedAt: end,
      ),
    );
    await expectLater(
      database.transaction(
        () => repository.finishMatchLifecycle(
          1,
          startedAt: start.add(const Duration(seconds: 1)),
          endedAt: end,
        ),
      ),
      throwsA(_failure(MatchLifecycleFailureCode.idempotencyConflict)),
    );
    expect(await _rawLifecycle(database, 1), (start: 100, end: 200));
  });

  test('invalid legacy source fails closed without repair', () async {
    await _insertSession(database, 1);
    await _insertMatch(
      database,
      id: 1,
      sessionId: 1,
      startTime: null,
      endTime: 200,
    );
    await _insertMatch(
      database,
      id: 2,
      sessionId: 1,
      startTime: 300,
      endTime: 200,
    );

    for (final id in [1, 2]) {
      final before = await _rawLifecycle(database, id);
      await expectLater(
        database.transaction(
          () => repository.finishMatchLifecycle(
            id,
            startedAt: null,
            endedAt: DateTime.fromMillisecondsSinceEpoch(400000, isUtc: true),
          ),
        ),
        throwsA(_failure(MatchLifecycleFailureCode.invalidSourceState)),
      );
      expect(await _rawLifecycle(database, id), before);
    }
  });

  test('zero-row re-read preserves target and source failure precedence',
      () async {
    final end = DateTime.fromMillisecondsSinceEpoch(200000, isUtc: true);
    await expectLater(
      database.transaction(
        () => repository.finishMatchLifecycle(
          999,
          startedAt: null,
          endedAt: end,
        ),
      ),
      throwsA(_failure(MatchLifecycleFailureCode.targetNotFound)),
    );

    await _insertSession(database, 1);
    await _insertMatch(database, id: 1, sessionId: 1, startTime: 100);
    await database.customStatement(
      "UPDATE matches SET start_time = 'bad' WHERE id = 1",
    );
    await expectLater(
      database.transaction(
        () => repository.finishMatchLifecycle(
          1,
          startedAt: null,
          endedAt: end,
        ),
      ),
      throwsA(_failure(MatchLifecycleFailureCode.sourceReadFailure)),
    );
  });

  test('generic metadata update cannot change lifecycle fields', () async {
    await _insertSession(database, 1);
    await _insertMatch(database, id: 1, sessionId: 1, startTime: 100);
    final loaded = (await repository.getMatchById(1))!;

    await repository.updateMatch(
      Match(
        id: loaded.id,
        sessionId: loaded.sessionId,
        matchNumber: loaded.matchNumber,
        gameType: loaded.gameType,
        opponent: 'Changed',
        startTime: DateTime.fromMillisecondsSinceEpoch(500000, isUtc: true),
        endTime: DateTime.fromMillisecondsSinceEpoch(600000, isUtc: true),
        createdAt: loaded.createdAt,
      ),
    );

    expect((await repository.getMatchById(1))!.opponent, 'Changed');
    expect(await _rawLifecycle(database, 1), (start: 100, end: null));
  });

  test('concurrent finishes produce one commit and one conflict', () async {
    await _insertSession(database, 1);
    await _insertMatch(database, id: 1, sessionId: 1, startTime: 100);
    final ends = [200, 201];

    Future<MatchLifecycleFailureCode?> finish(int seconds) async {
      try {
        await database.transaction(
          () => repository.finishMatchLifecycle(
            1,
            startedAt: null,
            endedAt: DateTime.fromMillisecondsSinceEpoch(
              seconds * 1000,
              isUtc: true,
            ),
          ),
        );
        return null;
      } on MatchLifecycleException catch (error) {
        return error.code;
      }
    }

    final results = await Future.wait(ends.map(finish));
    expect(results.where((result) => result == null), hasLength(1));
    expect(
      results.where(
        (result) => result == MatchLifecycleFailureCode.idempotencyConflict,
      ),
      hasLength(1),
    );
    expect(ends, contains((await _rawLifecycle(database, 1)).end));
  });

  test('winner writes after lifecycle success and rolls back with it',
      () async {
    await _insertSession(database, 1);
    await _insertMatch(
      database,
      id: 1,
      sessionId: 1,
      startTime: 100,
      winner: 'Original',
    );
    final coordinator = _coordinator(database, repository);
    final end = DateTime.fromMillisecondsSinceEpoch(200000, isUtc: true);
    await database.customStatement('''
CREATE TRIGGER fail_match_winner
BEFORE UPDATE OF winner ON matches
BEGIN
  SELECT RAISE(ABORT, 'winner failure');
END
''');

    await expectLater(
      coordinator.finishMatch(1, winner: 'Player', endedAt: end),
      throwsA(_failure(MatchLifecycleFailureCode.databaseFailure)),
    );
    expect(await _rawLifecycle(database, 1), (start: 100, end: null));
    expect((await repository.getMatchById(1))!.winner, 'Original');

    await database.customStatement('DROP TRIGGER fail_match_winner');
    await coordinator.finishMatch(1, winner: 'Player', endedAt: end);
    expect(await _rawLifecycle(database, 1), (start: 100, end: 200));
    expect((await repository.getMatchById(1))!.winner, 'Player');
  });

  test('MatchRecordingService supplies canonical clock time and winner',
      () async {
    await _insertSession(database, 1);
    await _insertMatch(database, id: 1, sessionId: 1, startTime: 100);
    final coordinator = _coordinator(database, repository);
    final lifecycle = MatchLifecycleService(
      coordinator,
      clock: () => DateTime.parse('2026-07-25T17:30:15.987654+07:00'),
    );
    final recording = MatchRecordingService(
      coordinator,
      lifecycleService: lifecycle,
    );

    await recording.finishMatch(1, 'Player');

    expect(await _rawLifecycle(database, 1), (start: 100, end: 1784975415));
    expect((await repository.getMatchById(1))!.winner, 'Player');
  });

  test('completed lifecycle survives SQLite close and reopen', () async {
    await database.close();
    final directory =
        await Directory.systemTemp.createTemp('pool_os_match_lifecycle_');
    final file = File('${directory.path}/lifecycle.db');
    try {
      database = AppDatabase.forTesting(NativeDatabase(file));
      repository = MatchRepository(database);
      await _insertSession(database, 1);
      await _insertMatch(database, id: 1, sessionId: 1, startTime: 100);
      await database.transaction(
        () => repository.finishMatchLifecycle(
          1,
          startedAt: null,
          endedAt: DateTime.fromMillisecondsSinceEpoch(200000, isUtc: true),
        ),
      );
      await database.close();

      database = AppDatabase.forTesting(NativeDatabase(file));
      repository = MatchRepository(database);
      expect(await _rawLifecycle(database, 1), (start: 100, end: 200));
    } finally {
      await database.close();
      if (await directory.exists()) await directory.delete(recursive: true);
      database = AppDatabase.forTesting(NativeDatabase.memory());
      repository = MatchRepository(database);
    }
  });
}

RecordingCoordinator _coordinator(
  AppDatabase database,
  MatchRepository repository,
) {
  return RecordingCoordinator(
    database: database,
    sessionRepo: SessionRepository(database),
    matchRepo: repository,
    rackRepo: RackRepository(database),
    shotRepo: ShotRepository(database),
    eventRepo: EventRepository(database),
  );
}

Future<void> _insertSession(AppDatabase database, int id) {
  return database.customStatement(
    '''
INSERT INTO sessions (
  id, session_type, started_at, created_at, updated_at
) VALUES (?, ?, ?, ?, ?)
''',
    [id, 'match', 1, 1, 1],
  );
}

Future<void> _insertMatch(
  AppDatabase database, {
  required int id,
  required int sessionId,
  required int? startTime,
  int? endTime,
  String? winner,
}) {
  return database.customStatement(
    '''
INSERT INTO matches (
  id, session_id, match_number, game_type, winner, start_time, end_time,
  created_at
) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
''',
    [id, sessionId, id, 'match', winner, startTime, endTime, 1],
  );
}

Future<({int? start, int? end})> _rawLifecycle(
  AppDatabase database,
  int id,
) async {
  final row = await database.customSelect(
    'SELECT start_time, end_time FROM matches WHERE id = ?',
    variables: [Variable<int>(id)],
    readsFrom: {database.matches},
  ).getSingle();
  return (
    start: row.data['start_time'] as int?,
    end: row.data['end_time'] as int?,
  );
}

Matcher _failure(MatchLifecycleFailureCode code) =>
    isA<MatchLifecycleException>().having(
      (error) => error.code,
      'code',
      code,
    );
