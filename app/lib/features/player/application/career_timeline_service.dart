import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/wiring/mastery_providers.dart';
import '../../equipment/application/career_equipment_snapshot_source.dart';
import '../../mastery/domain/models/mastery_models.dart';
import '../../match/application/player_career_match_source.dart';
import '../../player_model/application/player_progress_service.dart';
import '../../player_model/domain/player_progress_projection.dart';
import '../../training/application/player_career_training_source.dart';
import '../data/repositories/player_repository.dart';
import '../domain/career_timeline_builder.dart';
import '../domain/career_timeline_projection.dart';

typedef PlayerModelTimelineLoader = Future<PlayerProgressProjection?>
    Function();
typedef MasteryTimelineLoader = Future<MasterySnapshot> Function();

final careerTimelineServiceProvider = Provider<CareerTimelineService>((ref) {
  return CareerTimelineService(
    players: ref.watch(playerRepositoryProvider),
    matches: ref.watch(playerCareerMatchSourceProvider),
    training: ref.watch(playerCareerTrainingSourceProvider),
    equipmentSnapshots: ref.watch(careerEquipmentSnapshotSourceProvider),
    loadPlayerModel: () =>
        ref.read(playerProgressServiceProvider).loadOrRefreshActivePlayer(),
    loadMastery: () => ref.read(masterySnapshotProvider.future),
  );
});

final class CareerTimelineService {
  const CareerTimelineService({
    required PlayerRepository players,
    required PlayerCareerMatchSource matches,
    required PlayerCareerTrainingSource training,
    required CareerEquipmentSnapshotSource equipmentSnapshots,
    required PlayerModelTimelineLoader loadPlayerModel,
    required MasteryTimelineLoader loadMastery,
    CareerTimelineBuilder builder = const CareerTimelineBuilder(),
  })  : _players = players,
        _matches = matches,
        _training = training,
        _equipmentSnapshots = equipmentSnapshots,
        _loadPlayerModel = loadPlayerModel,
        _loadMastery = loadMastery,
        _builder = builder;

  final PlayerRepository _players;
  final PlayerCareerMatchSource _matches;
  final PlayerCareerTrainingSource _training;
  final CareerEquipmentSnapshotSource _equipmentSnapshots;
  final PlayerModelTimelineLoader _loadPlayerModel;
  final MasteryTimelineLoader _loadMastery;
  final CareerTimelineBuilder _builder;

  Future<CareerTimelineProjection?> loadActivePlayer() async {
    final playerId = (await _players.getActivePlayer())?.id;
    return playerId == null
        ? null
        : _players.getCareerTimelineProjection(playerId);
  }

  Future<CareerTimelineProjection?> loadOrRebuildActivePlayer() async {
    final stored = await loadActivePlayer();
    return stored ?? rebuildActivePlayer();
  }

  Future<CareerTimelineProjection?> rebuildActivePlayer() async {
    final player = await _players.getActivePlayer();
    final playerId = player?.id;
    if (player == null || playerId == null) return null;

    final historySources = await Future.wait<Object>([
      _matches.loadForPlayer(playerId),
      _training.loadForPlayer(playerId),
    ]);
    final matchFacts = historySources[0] as List<CompletedMatchTimelineFact>;
    final trainingFacts =
        historySources[1] as List<CompletedTrainingTimelineFact>;
    final matchNumbers = <int, int>{
      for (final fact in matchFacts) fact.id: fact.matchNumber,
      for (final training in trainingFacts)
        for (final match in training.drillMatches) match.id: match.matchNumber,
    };
    final sources = await Future.wait<Object?>([
      _equipmentSnapshots.loadForMatchIds(matchNumbers.keys),
      _loadPlayerModel(),
      _loadMastery(),
    ]);
    final snapshotFacts = sources[0] as List<CareerEquipmentSnapshotUsageFact>;
    final playerModel = sources[1] as PlayerProgressProjection?;
    final mastery = sources[2] as MasterySnapshot;
    final usageByMatch = <int, List<CareerEquipmentUsageRef>>{};
    for (final fact in snapshotFacts) {
      final matchNumber = matchNumbers[fact.matchId];
      if (matchNumber == null) continue;
      (usageByMatch[fact.matchId] ??= []).add(
        CareerEquipmentUsageRef(
          matchId: fact.matchId,
          matchNumber: matchNumber,
          snapshotReference: fact.snapshotReference,
          role: switch (fact.role) {
            CareerEquipmentSnapshotRole.playing => CareerEquipmentRole.playing,
            CareerEquipmentSnapshotRole.breakCue =>
              CareerEquipmentRole.breakCue,
            CareerEquipmentSnapshotRole.jump => CareerEquipmentRole.jump,
          },
          cueId: fact.cueId,
        ),
      );
    }

    final projection = _builder.build(
      player: CareerPlayerFact(
        playerId: playerId,
        createdAt: player.createdAt,
      ),
      matches: matchFacts
          .map(
            (fact) => CareerCompletedMatchFact(
              sourceId: fact.id,
              matchNumber: fact.matchNumber,
              gameType: fact.gameType,
              opponent: fact.opponent,
              winner: fact.winner,
              result: fact.result,
              completedAt: fact.completedAt,
              equipmentUsage: usageByMatch[fact.id] ?? const [],
            ),
          )
          .toList(),
      training: trainingFacts
          .map(
            (fact) => CareerCompletedTrainingFact(
              sourceId: fact.id,
              goal: fact.goal,
              completedAt: fact.completedAt,
              drillMatches: fact.drillMatches
                  .map(
                    (match) => CareerTrainingDrillMatchFact(
                      sourceId: match.id,
                      matchNumber: match.matchNumber,
                    ),
                  )
                  .toList(),
              equipmentUsage: [
                for (final match in fact.drillMatches)
                  ...usageByMatch[match.id] ?? const [],
              ],
            ),
          )
          .toList(),
      playerModel: playerModel == null
          ? null
          : CareerPlayerModelFact(
              playerId: playerModel.playerId,
              overall: playerModel.overall,
              confidence: playerModel.confidence,
              lastUpdated: playerModel.lastUpdated,
              sourceDigest: playerModel.sourceDigest,
              projectionDigest: playerModel.digest,
            ),
      mastery: mastery.entries.values
          .map(
            (fact) => CareerMasteryFact(
              entryId: fact.entryId,
              stage: fact.stage.name,
              score: fact.score,
              confidence: fact.confidence,
              lastEvidenceAt: fact.lastEvidenceAt,
              methodologyId: fact.methodologyId,
            ),
          )
          .toList(),
    );
    await _players.saveCareerTimelineProjection(projection);
    return projection;
  }
}
