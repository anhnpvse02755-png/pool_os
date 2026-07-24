import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/player/data/database/app_database.dart';
import 'package:pool_os/features/player/data/repositories/player_repository.dart';
import 'package:pool_os/features/player/domain/models/player.dart' as domain;
import 'package:pool_os/features/player_model/application/player_progress_calculator.dart';
import 'package:pool_os/features/player_model/domain/player_progress_projection.dart';

void main() {
  test('projection persists by existing player identity with its digest',
      () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = PlayerRepository(database);
    final playerId = await repository.createPlayer(
      domain.Player(
        name: 'Projection Player',
        dominantHand: 'right',
        language: 'en',
        measurementSystem: 'cm',
        theme: 'system',
      ),
    );
    final projection = const PlayerProgressCalculator().calculate(
      playerId: playerId,
      activities: [
        PlayerProgressActivity(
          kind: PlayerProgressActivityKind.training,
          sourceId: 'training:1',
          occurredAt: DateTime.utc(2026, 7, 24),
          rackCount: 1,
          wins: 0,
          attempts: 10,
          successes: 8,
          breakAttempts: 0,
          breakSuccesses: 0,
          scratches: 0,
          positionErrors: 1,
          safetyErrors: 0,
          kickErrors: 0,
          jumpErrors: 0,
          confidenceValues: [80],
        ),
      ],
      mastery: const [],
      fallbackUpdatedAt: DateTime.utc(2026),
    );

    final saveTimer = Stopwatch()..start();
    await repository.saveProgressProjection(projection);
    saveTimer.stop();
    final loadTimer = Stopwatch()..start();
    final restored = await repository.getProgressProjection(playerId);
    loadTimer.stop();

    expect(restored, isNotNull);
    expect(restored!.toJson(), projection.toJson());
    expect(restored.digest, projection.digest);
    expect(saveTimer.elapsedMilliseconds, lessThan(300));
    expect(loadTimer.elapsedMilliseconds, lessThan(100));
  });

  test('projection survives closing and reopening SQLite', () async {
    final directory = await Directory.systemTemp.createTemp('pool_os_player_');
    final file = File('${directory.path}/player-model.db');
    try {
      var database = AppDatabase.forTesting(NativeDatabase(file));
      var repository = PlayerRepository(database);
      final playerId = await repository.createPlayer(_player());
      final projection = _projection(playerId);
      await repository.saveProgressProjection(projection);
      await database.close();

      database = AppDatabase.forTesting(NativeDatabase(file));
      repository = PlayerRepository(database);
      final restored = await repository.getProgressProjection(playerId);

      expect(restored?.toJson(), projection.toJson());
      await database.close();
    } finally {
      if (await directory.exists()) await directory.delete(recursive: true);
    }
  });

  test('projection is a deletable cache rebuilt byte-for-byte', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = PlayerRepository(database);
    final playerId = await repository.createPlayer(_player());
    final original = _projection(playerId);
    await repository.saveProgressProjection(original);

    await (database.delete(database.playerModelProjections)
          ..where((table) => table.playerId.equals(playerId)))
        .go();
    expect(await repository.getProgressProjection(playerId), isNull);

    final rebuilt = _projection(playerId);
    await repository.saveProgressProjection(rebuilt);
    final restored = await repository.getProgressProjection(playerId);

    expect(rebuilt.toJson(), original.toJson());
    expect(rebuilt.digest, original.digest);
    expect(restored?.toJson(), original.toJson());
  });
}

domain.Player _player() => domain.Player(
      name: 'Projection Player',
      dominantHand: 'right',
      language: 'en',
      measurementSystem: 'cm',
      theme: 'system',
    );

PlayerProgressProjection _projection(int playerId) =>
    const PlayerProgressCalculator().calculate(
      playerId: playerId,
      activities: [
        PlayerProgressActivity(
          kind: PlayerProgressActivityKind.training,
          sourceId: 'training:restart',
          occurredAt: DateTime.utc(2026, 7, 24),
          rackCount: 1,
          wins: 0,
          attempts: 10,
          successes: 8,
          breakAttempts: 0,
          breakSuccesses: 0,
          scratches: 0,
          positionErrors: 1,
          safetyErrors: 0,
          kickErrors: 0,
          jumpErrors: 0,
          confidenceValues: [80],
        ),
      ],
      mastery: const [],
      fallbackUpdatedAt: DateTime.utc(2026),
    );
