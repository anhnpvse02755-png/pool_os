import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/player/data/database/app_database.dart';
import 'package:pool_os/features/player/data/repositories/player_repository.dart';
import 'package:pool_os/features/player/domain/models/player.dart' as domain;
import 'package:pool_os/features/player/domain/player_lifecycle_failure.dart';

void main() {
  late AppDatabase database;
  late PlayerRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = PlayerRepository(database);
  });

  tearDown(() => database.close());

  test('empty storage has no active Player', () async {
    expect(await repository.getActivePlayer(), isNull);
  });

  test('first create is active and later creates preserve it', () async {
    final first = await repository.createPlayer(
      _player('First', isActive: false),
    );
    final second = await repository.createPlayer(
      _player('Second', isActive: true),
    );

    expect((await repository.getActivePlayer())?.id, first);
    expect((await repository.getPlayerById(first))?.isActive, isTrue);
    expect((await repository.getPlayerById(second))?.isActive, isFalse);
    await _expectExactOneActive(database);
  });

  test('switch validates target, is atomic, and is idempotent', () async {
    final first = await repository.createPlayer(_player('First'));
    final second = await repository.createPlayer(_player('Second'));

    await expectLater(
      repository.switchActivePlayer(9999),
      throwsA(_lifecycleFailure(PlayerLifecycleFailureCode.targetNotFound)),
    );
    expect((await repository.getActivePlayer())?.id, first);

    await repository.switchActivePlayer(second);
    expect((await repository.getActivePlayer())?.id, second);

    await database.customStatement('''
      CREATE TRIGGER reject_player_update
      BEFORE UPDATE ON players
      BEGIN
        SELECT RAISE(ABORT, 'unexpected update');
      END
    ''');
    await repository.switchActivePlayer(second);
    expect((await repository.getActivePlayer())?.id, second);
  });

  test('profile update cannot write isActive or change selection', () async {
    final first = await repository.createPlayer(_player('First'));
    final second = await repository.createPlayer(_player('Second'));
    final active = await repository.getPlayerById(first);
    final inactive = await repository.getPlayerById(second);

    await repository.updatePlayer(
      active!.copyWith(name: 'Active renamed', isActive: false),
    );
    await repository.updatePlayer(
      inactive!.copyWith(name: 'Renamed', isActive: true),
    );

    expect((await repository.getPlayerById(first))?.name, 'Active renamed');
    expect((await repository.getPlayerById(first))?.isActive, isTrue);
    expect((await repository.getPlayerById(second))?.name, 'Renamed');
    expect((await repository.getPlayerById(second))?.isActive, isFalse);
    expect((await repository.getActivePlayer())?.id, first);
  });

  test('delete preserves or deterministically hands off selection', () async {
    final first = await repository.createPlayer(_player('First'));
    final second = await repository.createPlayer(_player('Second'));
    final third = await repository.createPlayer(_player('Third'));

    await repository.deletePlayer(second);
    expect((await repository.getActivePlayer())?.id, first);

    await repository.switchActivePlayer(third);
    await repository.deletePlayer(third);
    expect((await repository.getActivePlayer())?.id, first);

    await repository.deletePlayer(first);
    expect(await repository.getActivePlayer(), isNull);
    expect(await repository.getAllPlayers(), isEmpty);
  });

  test('failed switch rolls back and preserves prior selection', () async {
    final first = await repository.createPlayer(_player('First'));
    final second = await repository.createPlayer(_player('Second'));
    await database.customStatement('''
      CREATE TRIGGER reject_target_activation
      BEFORE UPDATE OF is_active ON players
      WHEN NEW.id = $second AND NEW.is_active = 1
      BEGIN
        SELECT RAISE(ABORT, 'forced activation failure');
      END
    ''');

    await expectLater(
      repository.switchActivePlayer(second),
      throwsA(_lifecycleFailure(PlayerLifecycleFailureCode.databaseFailure)),
    );

    expect((await repository.getActivePlayer())?.id, first);
    await _expectExactOneActive(database);
  });

  test('strict read fails closed without repairing invalid storage', () async {
    final first = await repository.createPlayer(_player('First'));
    final second = await repository.createPlayer(_player('Second'));
    await database.customStatement('DROP INDEX players_single_active_idx');
    await database.customStatement('UPDATE players SET is_active = 0');

    await expectLater(
      repository.getActivePlayer(),
      throwsA(_lifecycleFailure(PlayerLifecycleFailureCode.invariantViolated)),
    );
    expect(await _activeIds(database), isEmpty);

    await database.customStatement(
      'UPDATE players SET is_active = 1 WHERE id IN (?, ?)',
      [first, second],
    );
    await expectLater(
      repository.getActivePlayer(),
      throwsA(_lifecycleFailure(PlayerLifecycleFailureCode.invariantViolated)),
    );
    expect(await _activeIds(database), [first, second]);
  });

  test('partial unique index rejects a second active row', () async {
    await repository.createPlayer(_player('First'));
    final second = await repository.createPlayer(_player('Second'));

    await expectLater(
      (database.update(database.players)
            ..where((table) => table.id.equals(second)))
          .write(const PlayersCompanion(isActive: Value(true))),
      throwsA(isA<Exception>()),
    );
    await _expectExactOneActive(database);
  });

  test('concurrent creates and switches retain exactly one active row',
      () async {
    final ids = await Future.wait(
      List.generate(
        8,
        (index) => repository.createPlayer(_player('Player $index')),
      ),
    );
    await _expectExactOneActive(database);

    await Future.wait(ids.reversed.map(repository.switchActivePlayer));

    await _expectExactOneActive(database);
    expect(ids, contains((await repository.getActivePlayer())?.id));
  });

  test('selected identity survives SQLite close and reopen', () async {
    await database.close();
    final directory = await Directory.systemTemp.createTemp('pool_os_active_');
    final file = File('${directory.path}/active-player.db');
    try {
      database = AppDatabase.forTesting(NativeDatabase(file));
      repository = PlayerRepository(database);
      await repository.createPlayer(_player('First'));
      final second = await repository.createPlayer(_player('Second'));
      await repository.switchActivePlayer(second);
      await database.close();

      database = AppDatabase.forTesting(NativeDatabase(file));
      repository = PlayerRepository(database);
      expect((await repository.getActivePlayer())?.id, second);
      await _expectExactOneActive(database);
    } finally {
      await database.close();
      if (await directory.exists()) await directory.delete(recursive: true);
      database = AppDatabase.forTesting(NativeDatabase.memory());
      repository = PlayerRepository(database);
    }
  });
}

domain.Player _player(String name, {bool isActive = true}) => domain.Player(
      name: name,
      dominantHand: 'right',
      language: 'en',
      measurementSystem: 'metric',
      theme: 'dark',
      isActive: isActive,
    );

Matcher _lifecycleFailure(PlayerLifecycleFailureCode code) =>
    isA<PlayerLifecycleException>().having(
      (error) => error.code,
      'code',
      code,
    );

Future<List<int>> _activeIds(AppDatabase database) async {
  final rows = await (database.select(database.players)
        ..where((table) => table.isActive.equals(true))
        ..orderBy([(table) => OrderingTerm.asc(table.id)]))
      .get();
  return rows.map((row) => row.id).toList(growable: false);
}

Future<void> _expectExactOneActive(AppDatabase database) async {
  final all = await database.select(database.players).get();
  expect(all, isNotEmpty);
  expect(await _activeIds(database), hasLength(1));
}
