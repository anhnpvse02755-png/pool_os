import 'dart:io';

import 'package:drift/drift.dart' show Variable;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/match/data/repositories/match_repository.dart';
import 'package:pool_os/features/player/data/database/app_database.dart'
    show AppDatabase;
import 'package:pool_os/features/session/data/repositories/session_repository.dart';
import 'package:pool_os/features/session/domain/models/session.dart';
import 'package:sqlite3/sqlite3.dart' as raw;

void main() {
  late Directory directory;
  late File file;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('pool_os_mig_');
    file = File('${directory.path}/migration.db');
  });

  tearDown(() async {
    if (await directory.exists()) await directory.delete(recursive: true);
  });

  test('onCreate creates v30 schema with sidecar and triggers', () async {
    final app = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(app.close);

    expect(app.schemaVersion, 30);

    final tables = await app
        .customSelect(
          'SELECT name FROM sqlite_master WHERE type = \'table\' ORDER BY name',
        )
        .get();
    final names = tables.map((row) => row.data['name'] as String).toSet();
    expect(names, contains('match_number_allocations'));
    expect(names, contains('sessions'));
    expect(names, contains('matches'));

    final triggers = await app
        .customSelect(
          'SELECT name FROM sqlite_master WHERE type = \'trigger\' ORDER BY name',
        )
        .get();
    final triggerNames =
        triggers.map((row) => row.data['name'] as String).toSet();
    expect(
        triggerNames,
        containsAll(<String>[
          'matches_reject_nonpositive_match_number_insert',
          'matches_reject_duplicate_session_match_number_insert',
          'matches_reject_second_open_match_insert',
          'matches_reject_nonpositive_match_number_update',
          'matches_reject_duplicate_session_match_number_update',
          'matches_reject_second_open_match_update',
        ]));
  });

  test('migration upgrade from v29 file installs sidecar and triggers',
      () async {
    final upgraded = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(upgraded.close);

    expect(upgraded.schemaVersion, 30);
    final sidecar = await upgraded
        .customSelect(
          'SELECT name FROM sqlite_master '
          'WHERE type = \'table\' AND name = \'match_number_allocations\'',
        )
        .get();
    expect(sidecar.length, 1);

    final triggers = await upgraded
        .customSelect(
          'SELECT name FROM sqlite_master WHERE type = \'trigger\' '
          'ORDER BY name',
        )
        .get();
    final triggerNames =
        triggers.map((row) => row.data['name'] as String).toSet();
    expect(
        triggerNames,
        containsAll(<String>[
          'matches_reject_nonpositive_match_number_insert',
          'matches_reject_duplicate_session_match_number_insert',
          'matches_reject_second_open_match_insert',
          'matches_reject_nonpositive_match_number_update',
          'matches_reject_duplicate_session_match_number_update',
          'matches_reject_second_open_match_update',
        ]));
  });

  test('reopening an upgraded file is a no-op', () async {
    final first = AppDatabase.forTesting(NativeDatabase(file));
    final firstTriggers = await first
        .customSelect(
          'SELECT name FROM sqlite_master WHERE type = \'trigger\' ORDER BY name',
        )
        .get();
    final firstSidecar = await first
        .customSelect(
          'SELECT COUNT(*) AS n FROM match_number_allocations',
        )
        .getSingle();
    await first.close();

    final second = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(second.close);
    final secondTriggers = await second
        .customSelect(
          'SELECT name FROM sqlite_master WHERE type = \'trigger\' ORDER BY name',
        )
        .get();
    final secondSidecar = await second
        .customSelect(
          'SELECT COUNT(*) AS n FROM match_number_allocations',
        )
        .getSingle();

    expect(
      firstTriggers.map((row) => row.data['name']).toList(),
      secondTriggers.map((row) => row.data['name']).toList(),
    );
    expect(firstSidecar.data['n'], secondSidecar.data['n']);
  });

  test('parent foreign key rejects orphan allocation', () async {
    final app = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(app.close);

    expect(
      () => app.customInsert(
        'INSERT INTO match_number_allocations (session_id, last_allocated) '
        'VALUES (?, 0)',
        variables: [Variable<int>(99999)],
      ),
      throwsA(isA<Object>()),
    );
  });

  test('onCreate seed fills one allocation per pre-existing Session', () async {
    final rawDb = _openRaw(file.path);
    rawDb.execute('''
      CREATE TABLE sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_type TEXT NOT NULL,
        started_at INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    rawDb.execute(
      'INSERT INTO sessions (session_type, started_at, created_at, updated_at) '
      'VALUES (?, ?, ?, ?)',
      ['match', 1, 1, 1],
    );
    rawDb.execute(
      'INSERT INTO sessions (session_type, started_at, created_at, updated_at) '
      'VALUES (?, ?, ?, ?)',
      ['match', 2, 2, 2],
    );
    rawDb.dispose();

    final app = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(app.close);

    final allocations = await app
        .customSelect(
          'SELECT session_id, last_allocated '
          'FROM match_number_allocations ORDER BY session_id',
        )
        .get();
    expect(allocations.length, 2);
    for (final row in allocations) {
      expect(row.data['last_allocated'], 0);
    }
  });

  test('direct trigger rejects non-positive insert', () async {
    final app = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(app.close);
    final sessionId = await _createSession(app);

    expect(
      () => app.customInsert(
        'INSERT INTO matches (session_id, match_number, game_type) '
        'VALUES (?, 0, ?)',
        variables: [
          Variable<int>(sessionId),
          Variable<String>('nine_ball'),
        ],
      ),
      throwsA(isA<Object>()),
    );
  });

  test('direct trigger rejects duplicate insert', () async {
    final app = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(app.close);
    final sessionId = await _createSession(app);

    await app.customInsert(
      'INSERT INTO matches (session_id, match_number, game_type) '
      'VALUES (?, 1, ?)',
      variables: [
        Variable<int>(sessionId),
        Variable<String>('nine_ball'),
      ],
    );

    expect(
      () => app.customInsert(
        'INSERT INTO matches (session_id, match_number, game_type) '
        'VALUES (?, 1, ?)',
        variables: [
          Variable<int>(sessionId),
          Variable<String>('nine_ball'),
        ],
      ),
      throwsA(isA<Object>()),
    );
  });

  test('direct trigger rejects reparent collision', () async {
    final app = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(app.close);
    final first = await _createSession(app);
    final second = await _createSession(app);

    await app.customInsert(
      'INSERT INTO matches (session_id, match_number, game_type) '
      'VALUES (?, 1, ?)',
      variables: [
        Variable<int>(first),
        Variable<String>('nine_ball'),
      ],
    );
    final otherId = await app.customInsert(
      'INSERT INTO matches (session_id, match_number, game_type) '
      'VALUES (?, 1, ?)',
      variables: [
        Variable<int>(second),
        Variable<String>('nine_ball'),
      ],
    );

    expect(
      () => app.customUpdate(
        'UPDATE matches SET session_id = ? WHERE id = ?',
        variables: [Variable<int>(first), Variable<int>(otherId)],
        updates: {app.matches},
      ),
      throwsA(isA<Object>()),
    );
  });

  test('direct trigger rejects renumber collision', () async {
    final app = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(app.close);
    final sessionId = await _createSession(app);

    await app.customInsert(
      'INSERT INTO matches (session_id, match_number, game_type) '
      'VALUES (?, 1, ?)',
      variables: [
        Variable<int>(sessionId),
        Variable<String>('nine_ball'),
      ],
    );
    final second = await app.customInsert(
      'INSERT INTO matches (session_id, match_number, game_type, end_time) '
      'VALUES (?, 2, ?, ?)',
      variables: [
        Variable<int>(sessionId),
        Variable<String>('nine_ball'),
        Variable<int>(1),
      ],
    );

    expect(
      () => app.customUpdate(
        'UPDATE matches SET match_number = 1 WHERE id = ?',
        variables: [Variable<int>(second)],
        updates: {app.matches},
      ),
      throwsA(isA<Object>()),
    );
  });

  test('direct trigger rejects second open on insert', () async {
    final app = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(app.close);
    final sessionId = await _createSession(app);

    await app.customInsert(
      'INSERT INTO matches (session_id, match_number, game_type) '
      'VALUES (?, 1, ?)',
      variables: [
        Variable<int>(sessionId),
        Variable<String>('nine_ball'),
      ],
    );

    expect(
      () => app.customInsert(
        'INSERT INTO matches (session_id, match_number, game_type) '
        'VALUES (?, 2, ?)',
        variables: [
          Variable<int>(sessionId),
          Variable<String>('nine_ball'),
        ],
      ),
      throwsA(isA<Object>()),
    );
  });

  test('direct trigger rejects second open on reparent/update', () async {
    final app = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(app.close);
    final first = await _createSession(app);
    final second = await _createSession(app);

    await app.customInsert(
      'INSERT INTO matches (session_id, match_number, game_type) '
      'VALUES (?, 1, ?)',
      variables: [
        Variable<int>(first),
        Variable<String>('nine_ball'),
      ],
    );
    final otherId = await app.customInsert(
      'INSERT INTO matches (session_id, match_number, game_type, end_time) '
      'VALUES (?, 1, ?, ?)',
      variables: [
        Variable<int>(second),
        Variable<String>('nine_ball'),
        Variable<int>(100),
      ],
    );

    expect(
      () => app.customUpdate(
        'UPDATE matches SET session_id = ?, end_time = NULL WHERE id = ?',
        variables: [Variable<int>(first), Variable<int>(otherId)],
        updates: {app.matches},
      ),
      throwsA(isA<Object>()),
    );
  });

  test('v30 schema is reachable through SessionRepository', () async {
    final app = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(app.close);
    final sessionId =
        await SessionRepository(app).createSession(_matchSession());
    final all = await SessionRepository(app).getAllSessions();
    expect(all.length, 1);
    expect(all.single.id, sessionId);
  });

  test('MatchRepository primitives see and write the sidecar', () async {
    final app = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(app.close);
    final sessionId = await _createSession(app);
    final repository = MatchRepository(app);

    final before = await repository.readMatchNumberAllocation(sessionId);
    expect(before, isNull);
    await repository.ensureAllocationExists(sessionId);
    final afterEnsure = await repository.readMatchNumberAllocation(sessionId);
    expect(afterEnsure, 0);

    final casAffected = await repository.casMatchNumberAllocation(
      sessionId: sessionId,
      expectedLastAllocated: 0,
      candidateLastAllocated: 1,
    );
    expect(casAffected, 1);
    final advanced = await repository.readMatchNumberAllocation(sessionId);
    expect(advanced, 1);
  });
}

Future<int> _createSession(AppDatabase app) async {
  final now = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
  return app.customInsert(
    'INSERT INTO sessions (session_type, started_at, created_at, '
    'updated_at) VALUES (?, ?, ?, ?)',
    variables: [
      Variable<String>('match'),
      Variable<int>(now),
      Variable<int>(now),
      Variable<int>(now),
    ],
  );
}

raw.Database _openRaw(String path) {
  final database = raw.sqlite3.open(path);
  database.execute('PRAGMA foreign_keys = ON');
  return database;
}

Session _matchSession() {
  final now = DateTime.now();
  return Session(
    sessionType: SessionTypes.match,
    startedAt: now,
    createdAt: now,
    updatedAt: now,
  );
}
