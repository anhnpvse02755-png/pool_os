import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/equipment/application/career_equipment_snapshot_source.dart';
import 'package:pool_os/features/equipment/data/repositories/equipment_repository.dart';
import 'package:pool_os/features/equipment/data/repositories/match_equipment_snapshot_repository.dart';
import 'package:pool_os/features/equipment/domain/models/cue.dart' as domain;
import 'package:pool_os/features/mastery/domain/models/mastery_models.dart';
import 'package:pool_os/features/match/application/player_career_match_source.dart';
import 'package:pool_os/features/match/domain/models/match.dart';
import 'package:pool_os/features/player/application/career_timeline_service.dart';
import 'package:pool_os/features/player/data/database/app_database.dart';
import 'package:pool_os/features/player/data/repositories/player_repository.dart';
import 'package:pool_os/features/player/domain/models/player.dart' as domain;
import 'package:pool_os/features/session/domain/models/session.dart';
import 'package:pool_os/features/training/application/player_career_training_source.dart';

void main() {
  test('public hooks expose only completed historical facts for the Player',
      () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = PlayerRepository(database);
    final playerId = await repository.createPlayer(_player('Active'));
    final otherPlayerId = await repository.createPlayer(_player('Other'));
    await repository.setActivePlayer(playerId);
    final matchEnd = DateTime.utc(2026, 7, 10, 10);
    final trainingEnd = DateTime.utc(2026, 7, 11, 10);

    final matchSession = await _session(
      database,
      playerId: playerId,
      type: SessionTypes.match,
      finishedAt: matchEnd,
    );
    await _match(database, matchSession, endTime: matchEnd);
    final unfinishedSession = await _session(
      database,
      playerId: playerId,
      type: SessionTypes.match,
    );
    await _match(database, unfinishedSession);
    final otherSession = await _session(
      database,
      playerId: otherPlayerId,
      type: SessionTypes.match,
      finishedAt: matchEnd,
    );
    await _match(database, otherSession, endTime: matchEnd);
    await _session(
      database,
      playerId: playerId,
      type: SessionTypes.training,
      finishedAt: trainingEnd,
    );

    final matchFacts =
        await PlayerCareerMatchSource(database).loadForPlayer(playerId);
    final trainingFacts =
        await PlayerCareerTrainingSource(database).loadForPlayer(playerId);

    expect(matchFacts, hasLength(1));
    expect(matchFacts.single.completedAt, matchEnd);
    expect(trainingFacts, hasLength(1));
    expect(trainingFacts.single.completedAt, trainingEnd);
  });

  test('service rebuilds direct source references and persists the cache',
      () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = PlayerRepository(database);
    final playerId = await repository.createPlayer(_player('Timeline'));
    final completedAt = DateTime.utc(2026, 7, 12, 15);
    final sessionId = await _session(
      database,
      playerId: playerId,
      type: SessionTypes.match,
      finishedAt: completedAt,
    );
    final matchId = await _match(
      database,
      sessionId,
      endTime: completedAt,
    );
    final equipment = EquipmentRepository(database);
    final snapshots = MatchEquipmentSnapshotRepository(
      database,
      equipment,
      repository,
    );
    final cueA = await equipment.createCue(_cue('Cue A'));
    final cueB = await equipment.createCue(_cue('Cue B'));
    await equipment.setActiveCueByType(
      cueA,
      cueType: 'playing',
      playerId: playerId,
    );
    await snapshots.captureForMatch(matchId);
    await equipment.setActiveCueByType(
      cueB,
      cueType: 'playing',
      playerId: playerId,
    );
    final service = CareerTimelineService(
      players: repository,
      matches: PlayerCareerMatchSource(database),
      training: PlayerCareerTrainingSource(database),
      equipmentSnapshots: CareerEquipmentSnapshotSource(snapshots),
      loadPlayerModel: () async => null,
      loadMastery: () async => MasterySnapshot(
        generatedAt: DateTime.utc(2026, 7, 25),
        entries: const {},
        paths: const <LearningPathMastery>[],
      ),
    );

    final rebuilt = await service.rebuildActivePlayer();
    final stored = await repository.getCareerTimelineProjection(playerId);

    expect(
      rebuilt?.events.map((event) => event.sourceReference),
      containsAll(['player:$playerId', 'match:$matchId']),
    );
    expect(stored?.toJson(), rebuilt?.toJson());
    final matchEvent = rebuilt!.events.singleWhere(
      (event) => event.sourceReference == 'match:$matchId',
    );
    expect(matchEvent.equipmentUsage.single.cueId, cueA);
    expect(matchEvent.equipmentUsage.single.cueId, isNot(cueB));

    await repository.deleteCareerTimelineProjection(playerId);
    final rebuiltAfterDelete = await service.rebuildActivePlayer();
    expect(
      jsonEncode(rebuiltAfterDelete?.toJson()),
      jsonEncode(rebuilt.toJson()),
    );
  });

  test('training aggregates immutable snapshots from all completed drills',
      () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = PlayerRepository(database);
    final playerId = await repository.createPlayer(_player('Training'));
    final end = DateTime.utc(2026, 7, 13, 15);
    final sessionId = await _session(
      database,
      playerId: playerId,
      type: SessionTypes.training,
      finishedAt: end,
    );
    final matchTwo = await _match(
      database,
      sessionId,
      endTime: end,
      matchNumber: 2,
      gameType: GameTypes.drill,
    );
    final matchOne = await _match(
      database,
      sessionId,
      endTime: end,
      matchNumber: 1,
      gameType: GameTypes.drill,
    );
    await database.into(database.matchEquipmentSnapshots).insert(
          MatchEquipmentSnapshotsCompanion.insert(
            matchId: matchTwo,
            playingCueId: const Value(42),
            createdAt: end,
          ),
        );
    await database.into(database.matchEquipmentSnapshots).insert(
          MatchEquipmentSnapshotsCompanion.insert(
            matchId: matchOne,
            playingCueId: const Value(41),
            breakCueId: const Value(41),
            createdAt: end,
          ),
        );
    final snapshots = MatchEquipmentSnapshotRepository(
      database,
      EquipmentRepository(database),
      repository,
    );
    final service = CareerTimelineService(
      players: repository,
      matches: PlayerCareerMatchSource(database),
      training: PlayerCareerTrainingSource(database),
      equipmentSnapshots: CareerEquipmentSnapshotSource(snapshots),
      loadPlayerModel: () async => null,
      loadMastery: () async => MasterySnapshot(
        generatedAt: end,
        entries: const {},
        paths: const <LearningPathMastery>[],
      ),
    );

    final projection = await service.rebuildActivePlayer();
    final training = projection!.events.singleWhere(
      (event) => event.sourceReference == 'training:$sessionId',
    );
    expect(
      training.equipmentUsage.map((usage) => usage.matchId),
      [matchOne, matchOne, matchTwo],
    );
    expect(
      training.equipmentUsage.map((usage) => usage.cueId),
      [41, 41, 42],
    );
    expect(
      projection.events.where(
        (event) => event.sourceReference.startsWith('match:'),
      ),
      isEmpty,
    );
  });
}

domain.Player _player(String name) => domain.Player(
      name: name,
      dominantHand: 'right',
      language: 'en',
      measurementSystem: 'cm',
      theme: 'system',
      createdAt: DateTime.utc(2026, 7, 1),
      updatedAt: DateTime.utc(2026, 7, 1),
    );

Future<int> _session(
  AppDatabase database, {
  required int playerId,
  required String type,
  DateTime? finishedAt,
}) {
  final startedAt = DateTime.utc(2026, 7, 1, 8);
  return database.into(database.sessions).insert(
        SessionsCompanion.insert(
          playerId: Value(playerId),
          sessionType: type,
          startedAt: startedAt,
          finishedAt: Value(finishedAt),
          createdAt: Value(startedAt),
          updatedAt: Value(finishedAt ?? startedAt),
        ),
      );
}

Future<int> _match(
  AppDatabase database,
  int sessionId, {
  DateTime? endTime,
  int matchNumber = 1,
  String gameType = GameTypes.raceTo,
}) {
  return database.into(database.matches).insert(
        MatchesCompanion.insert(
          sessionId: sessionId,
          matchNumber: matchNumber,
          gameType: gameType,
          endTime: Value(endTime),
          createdAt: Value(DateTime.utc(2026, 7, 1, 8)),
        ),
      );
}

domain.Cue _cue(String name) => domain.Cue(
      name: name,
      shaftMaterial: 'Carbon',
      shaftDiameter: 12.5,
      tipBrand: 'Kamui',
      tipHardness: 'Medium',
      weight: 19,
      balance: 'Center',
      joint: 'Radial',
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
