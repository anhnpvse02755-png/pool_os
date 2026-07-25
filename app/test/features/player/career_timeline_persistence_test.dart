import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/player/data/database/app_database.dart'
    show AppDatabase;
import 'package:pool_os/features/player/data/repositories/player_repository.dart';
import 'package:pool_os/features/player/domain/career_timeline_builder.dart';
import 'package:pool_os/features/player/domain/career_timeline_projection.dart';
import 'package:pool_os/features/player/domain/models/player.dart' as domain;

void main() {
  test('cache delete and rebuild is byte-for-byte identical', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = PlayerRepository(database);
    final playerId = await repository.createPlayer(_player());
    final original = _projection(playerId);
    await repository.saveCareerTimelineProjection(original);

    expect(await repository.deleteCareerTimelineProjection(playerId), 1);
    expect(await repository.getCareerTimelineProjection(playerId), isNull);
    final rebuilt = _projection(playerId);
    await repository.saveCareerTimelineProjection(rebuilt);
    final restored = await repository.getCareerTimelineProjection(playerId);

    expect(jsonEncode(rebuilt.toJson()), jsonEncode(original.toJson()));
    expect(restored?.toJson(), original.toJson());
    expect(restored?.digest, original.digest);
  });

  test('projection survives SQLite close and reopen', () async {
    final directory = await Directory.systemTemp.createTemp('pool_os_career_');
    final file = File('${directory.path}/career.db');
    try {
      var database = AppDatabase.forTesting(NativeDatabase(file));
      var repository = PlayerRepository(database);
      final playerId = await repository.createPlayer(_player());
      final projection = _projection(playerId);
      await repository.saveCareerTimelineProjection(projection);
      await database.close();

      database = AppDatabase.forTesting(NativeDatabase(file));
      repository = PlayerRepository(database);
      final restored = await repository.getCareerTimelineProjection(playerId);

      expect(restored?.toJson(), projection.toJson());
      await database.close();
    } finally {
      if (await directory.exists()) await directory.delete(recursive: true);
    }
  });
}

domain.Player _player() => domain.Player(
      name: 'Career Player',
      dominantHand: 'right',
      language: 'en',
      measurementSystem: 'cm',
      theme: 'system',
      createdAt: DateTime.utc(2026, 7, 1),
      updatedAt: DateTime.utc(2026, 7, 1),
    );

CareerTimelineProjection _projection(int playerId) =>
    const CareerTimelineBuilder().build(
      player: CareerPlayerFact(
        playerId: playerId,
        createdAt: DateTime.utc(2026, 7, 1),
      ),
      matches: [
        CareerCompletedMatchFact(
          sourceId: 10,
          matchNumber: 1,
          gameType: 'race_to',
          opponent: 'Opponent',
          winner: 'Player',
          result: '7-4',
          completedAt: DateTime.utc(2026, 7, 2),
        ),
      ],
      training: const [],
      playerModel: null,
      mastery: const [],
    );
