import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/equipment/application/equipment_performance_projection_service.dart';
import 'package:pool_os/features/equipment/data/repositories/equipment_repository.dart';
import 'package:pool_os/features/equipment/data/repositories/match_equipment_snapshot_repository.dart';
import 'package:pool_os/features/equipment/domain/models/cue.dart';
import 'package:pool_os/features/match/data/repositories/match_repository.dart';
import 'package:pool_os/features/match/domain/models/match.dart';
import 'package:pool_os/features/player/data/database/app_database.dart'
    show AppDatabase;
import 'package:pool_os/features/player/data/repositories/player_repository.dart';
import 'package:pool_os/features/player/domain/models/player.dart' as domain;
import 'package:pool_os/features/rack/data/repositories/rack_repository.dart';
import 'package:pool_os/features/rack/domain/models/rack.dart';
import 'package:pool_os/features/session/data/repositories/session_repository.dart';
import 'package:pool_os/features/session/domain/models/session.dart';

void main() {
  test('equipment switch preserves historical Match attribution', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final players = PlayerRepository(database);
    await players.createPlayer(
      domain.Player(
        name: 'Switch Player',
        dominantHand: 'right',
        language: 'en',
        measurementSystem: 'cm',
        theme: 'system',
      ),
    );
    final equipment = EquipmentRepository(database);
    final firstCue = await equipment.createCue(_cue('Revo'));
    final secondCue = await equipment.createCue(_cue('Maple'));
    final sessions = SessionRepository(database);
    final matches = MatchRepository(database);
    final racks = RackRepository(database);
    final snapshots = MatchEquipmentSnapshotRepository(database, equipment);
    final service = EquipmentPerformanceProjectionService(
      players: players,
      equipment: equipment,
      sessions: sessions,
      matches: matches,
      racks: racks,
      snapshots: snapshots,
    );

    await _recordMatch(
      equipment: equipment,
      sessions: sessions,
      matches: matches,
      racks: racks,
      snapshots: snapshots,
      cueId: firstCue,
      index: 1,
      won: true,
    );
    await _recordMatch(
      equipment: equipment,
      sessions: sessions,
      matches: matches,
      racks: racks,
      snapshots: snapshots,
      cueId: secondCue,
      index: 2,
      won: false,
    );

    final beforeSwitch = await service.refreshActivePlayer();
    final first =
        beforeSwitch.singleWhere((item) => item.equipmentId == firstCue);
    final second =
        beforeSwitch.singleWhere((item) => item.equipmentId == secondCue);
    expect(first.totalMatches, 1);
    expect(first.matchWinRate, 100);
    expect(second.totalMatches, 1);
    expect(second.matchWinRate, 0);

    await equipment.setActiveCueByType(firstCue, cueType: 'playing');
    final afterSwitch = await service.refreshActivePlayer();
    expect(afterSwitch.map((item) => item.toJson()),
        beforeSwitch.map((item) => item.toJson()));
  });

  test('Training snapshot and source rebuild preserve every projection field',
      () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final players = PlayerRepository(database);
    final playerId = await players.createPlayer(
      domain.Player(
        name: 'Training Player',
        dominantHand: 'right',
        language: 'en',
        measurementSystem: 'cm',
        theme: 'system',
      ),
    );
    final equipment = EquipmentRepository(database);
    final firstCue = await equipment.createCue(
      _cue('Training Revo').copyWith(playerId: playerId),
    );
    final secondCue = await equipment.createCue(
      _cue('Training Maple').copyWith(playerId: playerId),
    );
    final sessions = SessionRepository(database);
    final matches = MatchRepository(database);
    final racks = RackRepository(database);
    final snapshots = MatchEquipmentSnapshotRepository(database, equipment);
    final service = EquipmentPerformanceProjectionService(
      players: players,
      equipment: equipment,
      sessions: sessions,
      matches: matches,
      racks: racks,
      snapshots: snapshots,
    );
    final start = DateTime.utc(2026, 7, 3, 8);
    final end = DateTime.utc(2026, 7, 3, 8, 30);
    final sessionId = await sessions.createSession(
      Session(
        sessionType: SessionTypes.training,
        startedAt: start,
        finishedAt: end,
        createdAt: start,
        updatedAt: end,
      ),
    );
    final matchId = await matches.createMatch(
      Match(
        sessionId: sessionId,
        matchNumber: 1,
        gameType: GameTypes.drill,
        startTime: start,
        endTime: end,
        createdAt: start,
      ),
    );
    await equipment.setActiveCueByType(
      firstCue,
      cueType: 'playing',
      playerId: playerId,
    );
    await snapshots.captureForMatch(matchId);
    await equipment.setActiveCueByType(
      secondCue,
      cueType: 'playing',
      playerId: playerId,
    );
    await snapshots.captureForMatch(matchId);
    await racks.createRack(
      Rack(
        matchId: matchId,
        rackNumber: 1,
        result: true,
        ballsPotted: 7,
        easyMissCount: 2,
        hardMissCount: 1,
        createdAt: end,
      ),
    );

    final original = await service.refreshActivePlayer();
    final first = original.singleWhere((item) => item.equipmentId == firstCue);
    final second =
        original.singleWhere((item) => item.equipmentId == secondCue);
    expect(first.totalTrainingSessions, 1);
    expect(first.trainingSuccessRate, 70);
    expect(first.recordedDurationSeconds, 1800);
    expect(first.lastUsed, end);
    expect(second.totalTrainingSessions, 0);

    await equipment.replacePerformanceProjections(playerId, const []);
    final rebuilt = await service.refreshActivePlayer();

    expect(
      rebuilt.map((item) => item.toJson()).toList(),
      original.map((item) => item.toJson()).toList(),
    );
  });
}

Future<void> _recordMatch({
  required EquipmentRepository equipment,
  required SessionRepository sessions,
  required MatchRepository matches,
  required RackRepository racks,
  required MatchEquipmentSnapshotRepository snapshots,
  required int cueId,
  required int index,
  required bool won,
}) async {
  await equipment.setActiveCueByType(cueId, cueType: 'playing');
  final start = DateTime.utc(2026, 7, index, 8);
  final end = DateTime.utc(2026, 7, index, 9);
  final sessionId = await sessions.createSession(
    Session(
      sessionType: SessionTypes.match,
      startedAt: start,
      finishedAt: end,
      createdAt: start,
      updatedAt: end,
    ),
  );
  final matchId = await matches.createMatch(
    Match(
      sessionId: sessionId,
      matchNumber: 1,
      gameType: GameTypes.raceTo,
      winner: won ? 'Player' : 'Opponent',
      startTime: start,
      endTime: end,
      createdAt: start,
    ),
  );
  await snapshots.captureForMatch(matchId);
  await racks.createRack(
    Rack(
      matchId: matchId,
      rackNumber: 1,
      result: won,
      ballsPotted: won ? 8 : 4,
      easyMissCount: won ? 1 : 5,
      createdAt: end,
    ),
  );
}

Cue _cue(String name) => Cue(
      name: name,
      shaftMaterial: name,
      shaftDiameter: 12.5,
      tipBrand: 'Kamui',
      tipHardness: 'Medium',
      weight: 19,
      balance: 'Center',
      joint: 'Radial',
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
