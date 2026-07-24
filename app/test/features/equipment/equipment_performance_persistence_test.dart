import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/equipment/application/equipment_performance_calculator.dart';
import 'package:pool_os/features/equipment/data/repositories/equipment_repository.dart';
import 'package:pool_os/features/equipment/domain/equipment_performance_projection.dart';
import 'package:pool_os/features/equipment/domain/models/cue.dart';
import 'package:pool_os/features/player/data/database/app_database.dart'
    show AppDatabase;
import 'package:pool_os/features/player/data/repositories/player_repository.dart';
import 'package:pool_os/features/player/domain/models/player.dart' as domain;

void main() {
  test('cache delete and rebuild reproduces identical JSON and digest',
      () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final fixture = await _Fixture.open(database);
    final original = _projection(fixture.playerId, fixture.cueId);
    await fixture.equipment.replacePerformanceProjections(
      fixture.playerId,
      [original],
    );

    await database.delete(database.equipmentPerformanceProjections).go();
    expect(
      await fixture.equipment.getPerformanceProjections(fixture.playerId),
      isEmpty,
    );
    final rebuilt = _projection(fixture.playerId, fixture.cueId);
    await fixture.equipment.replacePerformanceProjections(
      fixture.playerId,
      [rebuilt],
    );
    final restored =
        (await fixture.equipment.getPerformanceProjections(fixture.playerId))
            .single;

    expect(rebuilt.toJson(), original.toJson());
    expect(restored.toJson(), original.toJson());
  });

  test('projection survives SQLite close and reopen', () async {
    final directory = await Directory.systemTemp.createTemp('pool_os_equip_');
    final file = File('${directory.path}/equipment.db');
    try {
      var database = AppDatabase.forTesting(NativeDatabase(file));
      var fixture = await _Fixture.open(database);
      final projection = _projection(fixture.playerId, fixture.cueId);
      await fixture.equipment.replacePerformanceProjections(
        fixture.playerId,
        [projection],
      );
      await database.close();

      database = AppDatabase.forTesting(NativeDatabase(file));
      fixture = _Fixture(
        playerId: fixture.playerId,
        cueId: fixture.cueId,
        equipment: EquipmentRepository(database),
      );
      final restored =
          (await fixture.equipment.getPerformanceProjections(fixture.playerId))
              .single;
      expect(restored.toJson(), projection.toJson());
      await database.close();
    } finally {
      if (await directory.exists()) await directory.delete(recursive: true);
    }
  });

  test('cue ownership and active selection are scoped by Player', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final players = PlayerRepository(database);
    final firstPlayer = await players.createPlayer(_player('First'));
    final secondPlayer = await players.createPlayer(_player('Second'));
    final equipment = EquipmentRepository(database);
    final firstCue = await equipment.createCue(
      _cue().copyWith(playerId: firstPlayer, name: 'First Cue'),
    );
    final secondCue = await equipment.createCue(
      _cue().copyWith(playerId: secondPlayer, name: 'Second Cue'),
    );

    expect(
      (await equipment.getAllCues(playerId: firstPlayer)).map((cue) => cue.id),
      [firstCue],
    );
    expect(
      (await equipment.getAllCues(playerId: secondPlayer)).map((cue) => cue.id),
      [secondCue],
    );
    await equipment.setActiveCueByType(
      firstCue,
      cueType: 'playing',
      playerId: firstPlayer,
    );
    await equipment.setActiveCueByType(
      secondCue,
      cueType: 'playing',
      playerId: secondPlayer,
    );
    expect(
      (await equipment.getActiveCueByType(
        'playing',
        playerId: firstPlayer,
      ))
          ?.id,
      firstCue,
    );
    expect(
      (await equipment.getActiveCueByType(
        'playing',
        playerId: secondPlayer,
      ))
          ?.id,
      secondCue,
    );
  });
}

final class _Fixture {
  const _Fixture({
    required this.playerId,
    required this.cueId,
    required this.equipment,
  });

  static Future<_Fixture> open(AppDatabase database) async {
    final players = PlayerRepository(database);
    final playerId = await players.createPlayer(_player('Equipment Player'));
    final equipment = EquipmentRepository(database);
    final cueId = await equipment.createCue(_cue());
    return _Fixture(
      playerId: playerId,
      cueId: cueId,
      equipment: equipment,
    );
  }

  final int playerId;
  final int cueId;
  final EquipmentRepository equipment;
}

domain.Player _player(String name) => domain.Player(
      name: name,
      dominantHand: 'right',
      language: 'en',
      measurementSystem: 'cm',
      theme: 'system',
    );

Cue _cue() => Cue(
      name: 'Revo',
      shaftMaterial: 'Revo',
      shaftDiameter: 12.4,
      tipBrand: 'Kamui',
      tipHardness: 'Medium',
      weight: 19,
      balance: 'Center',
      joint: 'Radial',
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );

EquipmentPerformanceProjection _projection(int playerId, int cueId) =>
    const EquipmentPerformanceCalculator().calculate(
      playerId: playerId,
      equipmentId: cueId,
      activities: [
        EquipmentPerformanceActivity(
          kind: EquipmentActivityKind.match,
          sourceId: 'match:1',
          sessionId: 1,
          endedAt: DateTime.utc(2026, 7, 24),
          durationSeconds: 3600,
          won: true,
          attempts: 0,
          successes: 0,
        ),
      ],
    );
