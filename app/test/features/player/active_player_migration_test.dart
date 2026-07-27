import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/player/data/database/app_database.dart';
import 'package:pool_os/features/player/data/repositories/player_repository.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  test('v29 migration preserves the valid empty state', () async {
    await _withLegacyDatabase(const [], (database, repository) async {
      expect(await repository.getActivePlayer(), isNull);
      expect(await _activeIds(database), isEmpty);
      await _expectUniqueIndex(database);
    });
  });

  test('v29 migration preserves one valid active Player', () async {
    await _withLegacyDatabase(
      const [
        (id: 4, active: true),
        (id: 2, active: false),
        (id: 8, active: false),
      ],
      (database, repository) async {
        expect((await repository.getActivePlayer())?.id, 4);
        expect(await _activeIds(database), [4]);
        await _expectUniqueIndex(database);
      },
    );
  });

  test('v29 migration repairs zero active to the smallest Player ID', () async {
    await _withLegacyDatabase(
      const [
        (id: 9, active: false),
        (id: 2, active: false),
        (id: 5, active: false),
      ],
      (database, repository) async {
        expect((await repository.getActivePlayer())?.id, 2);
        expect(await _activeIds(database), [2]);
        expect(await _projectionDigest(database), 'projection-sentinel');
        await _expectUniqueIndex(database);
      },
    );
  });

  test('v29 migration retains the smallest existing active Player ID',
      () async {
    await _withLegacyDatabase(
      const [
        (id: 1, active: false),
        (id: 7, active: true),
        (id: 3, active: true),
        (id: 5, active: false),
      ],
      (database, repository) async {
        expect((await repository.getActivePlayer())?.id, 3);
        expect(await _activeIds(database), [3]);
        await _expectUniqueIndex(database);

        await expectLater(
          (database.update(database.players)
                ..where((table) => table.id.equals(1)))
              .write(const PlayersCompanion(isActive: Value(true))),
          throwsA(isA<Exception>()),
        );
      },
    );
  });

  test('repair and index creation roll back in the migration transaction',
      () async {
    final directory = await Directory.systemTemp.createTemp('pool_os_v29_');
    final file = File('${directory.path}/rollback.db');
    final legacy = _createLegacyDatabase(
      file,
      const [
        (id: 1, active: false),
        (id: 2, active: false),
      ],
    );
    legacy.execute('''
      CREATE TRIGGER reject_active_player_repair
      BEFORE UPDATE OF is_active ON players
      BEGIN
        SELECT RAISE(ABORT, 'forced migration failure');
      END
    ''');
    legacy.dispose();

    AppDatabase? database;
    try {
      database = AppDatabase.forTesting(NativeDatabase(file));
      await expectLater(
        database.customSelect('SELECT 1').get(),
        throwsA(isA<Exception>()),
      );
      await database.close();
      database = null;

      final inspected = sqlite.sqlite3.open(file.path);
      try {
        final rows = inspected.select(
          'SELECT id, is_active FROM players ORDER BY id',
        );
        expect(rows.map((row) => row['is_active']), [0, 0]);
        expect(inspected.userVersion, 28);
        expect(
          inspected.select('''
            SELECT name FROM sqlite_master
            WHERE type = 'index' AND name = 'players_single_active_idx'
          '''),
          isEmpty,
        );
      } finally {
        inspected.dispose();
      }
    } finally {
      await database?.close();
      if (await directory.exists()) await directory.delete(recursive: true);
    }
  });
}

typedef LegacyPlayer = ({int id, bool active});

Future<void> _withLegacyDatabase(
  List<LegacyPlayer> players,
  Future<void> Function(AppDatabase database, PlayerRepository repository)
      verify,
) async {
  final directory = await Directory.systemTemp.createTemp('pool_os_v29_');
  final file = File('${directory.path}/migration.db');
  _createLegacyDatabase(file, players).dispose();
  AppDatabase? database;
  try {
    database = AppDatabase.forTesting(NativeDatabase(file));
    final repository = PlayerRepository(database);
    await verify(database, repository);
    final version = await database
        .customSelect('PRAGMA user_version')
        .map((row) => row.read<int>('user_version'))
        .getSingle();
    expect(version, 30);
  } finally {
    await database?.close();
    if (await directory.exists()) await directory.delete(recursive: true);
  }
}

sqlite.Database _createLegacyDatabase(
  File file,
  List<LegacyPlayer> players,
) {
  final legacy = sqlite.sqlite3.open(file.path);
  legacy.execute('''
    CREATE TABLE players (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      dominant_hand TEXT NOT NULL DEFAULT 'right',
      language TEXT NOT NULL DEFAULT 'vi',
      measurement_system TEXT NOT NULL DEFAULT 'metric',
      theme TEXT NOT NULL DEFAULT 'dark',
      is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
      avatar_path TEXT,
      age INTEGER,
      gender TEXT,
      club_region TEXT,
      rank TEXT,
      main_game TEXT,
      goal TEXT,
      play_styles TEXT NOT NULL DEFAULT '[]',
      training_goals TEXT NOT NULL DEFAULT '[]',
      started_playing_at INTEGER,
      has_competed INTEGER NOT NULL DEFAULT 0 CHECK (has_competed IN (0, 1)),
      hours_per_week INTEGER,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
  ''');
  legacy.execute('''
    CREATE TABLE player_model_projections (
      player_id INTEGER NOT NULL PRIMARY KEY,
      digest TEXT NOT NULL
    )
  ''');
  legacy.execute(
    'INSERT INTO player_model_projections (player_id, digest) VALUES (1, ?)',
    ['projection-sentinel'],
  );
  for (final player in players) {
    legacy.execute('''
      INSERT INTO players (id, name, is_active, created_at, updated_at)
      VALUES (?, ?, ?, ?, ?)
    ''', [
      player.id,
      'Player ${player.id}',
      player.active ? 1 : 0,
      0,
      0,
    ]);
  }
  legacy.userVersion = 28;
  return legacy;
}

Future<List<int>> _activeIds(AppDatabase database) async {
  final rows = await (database.select(database.players)
        ..where((table) => table.isActive.equals(true))
        ..orderBy([(table) => OrderingTerm.asc(table.id)]))
      .get();
  return rows.map((row) => row.id).toList(growable: false);
}

Future<String> _projectionDigest(AppDatabase database) async {
  return database
      .customSelect('SELECT digest FROM player_model_projections')
      .map((row) => row.read<String>('digest'))
      .getSingle();
}

Future<void> _expectUniqueIndex(AppDatabase database) async {
  final rows = await database.customSelect('''
    SELECT name FROM sqlite_master
    WHERE type = 'index' AND name = 'players_single_active_idx'
  ''').get();
  expect(rows, hasLength(1));
}
