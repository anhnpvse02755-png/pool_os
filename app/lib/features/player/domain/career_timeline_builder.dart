import 'career_timeline_projection.dart';

final class CareerPlayerFact {
  const CareerPlayerFact({required this.playerId, required this.createdAt});

  final int playerId;
  final DateTime createdAt;
}

final class CareerCompletedMatchFact {
  const CareerCompletedMatchFact({
    required this.sourceId,
    required this.matchNumber,
    required this.gameType,
    required this.opponent,
    required this.winner,
    required this.result,
    required this.completedAt,
    this.equipmentUsage = const [],
  });

  final int sourceId;
  final int matchNumber;
  final String gameType;
  final String? opponent;
  final String? winner;
  final String? result;
  final DateTime completedAt;
  final List<CareerEquipmentUsageRef> equipmentUsage;
}

final class CareerCompletedTrainingFact {
  const CareerCompletedTrainingFact({
    required this.sourceId,
    required this.goal,
    required this.completedAt,
    this.drillMatches = const [],
    this.equipmentUsage = const [],
  });

  final int sourceId;
  final String? goal;
  final DateTime completedAt;
  final List<CareerTrainingDrillMatchFact> drillMatches;
  final List<CareerEquipmentUsageRef> equipmentUsage;
}

final class CareerTrainingDrillMatchFact {
  const CareerTrainingDrillMatchFact({
    required this.sourceId,
    required this.matchNumber,
  });

  final int sourceId;
  final int matchNumber;
}

final class CareerPlayerModelFact {
  const CareerPlayerModelFact({
    required this.playerId,
    required this.overall,
    required this.confidence,
    required this.lastUpdated,
    required this.sourceDigest,
    required this.projectionDigest,
  });

  final int playerId;
  final double overall;
  final double confidence;
  final DateTime lastUpdated;
  final String sourceDigest;
  final String projectionDigest;
}

final class CareerMasteryFact {
  const CareerMasteryFact({
    required this.entryId,
    required this.stage,
    required this.score,
    required this.confidence,
    required this.lastEvidenceAt,
    required this.methodologyId,
  });

  final String entryId;
  final String stage;
  final double score;
  final double confidence;
  final DateTime? lastEvidenceAt;
  final String methodologyId;
}

final class CareerTimelineBuilder {
  const CareerTimelineBuilder();

  CareerTimelineProjection build({
    required CareerPlayerFact player,
    required List<CareerCompletedMatchFact> matches,
    required List<CareerCompletedTrainingFact> training,
    required CareerPlayerModelFact? playerModel,
    required List<CareerMasteryFact> mastery,
  }) {
    if (player.playerId <= 0 ||
        (playerModel != null && playerModel.playerId != player.playerId)) {
      throw ArgumentError('Career timeline source player does not match.');
    }

    final orderedMatches = [...matches]
      ..sort((left, right) => left.sourceId.compareTo(right.sourceId));
    final orderedTraining = [...training]
      ..sort((left, right) => left.sourceId.compareTo(right.sourceId));
    final orderedMastery = [...mastery]..sort((left, right) {
        final entryOrder = left.entryId.compareTo(right.entryId);
        return entryOrder != 0
            ? entryOrder
            : left.methodologyId.compareTo(right.methodologyId);
      });

    _validateUniqueSources(
      'match',
      orderedMatches.map((item) => item.sourceId.toString()),
    );
    for (final match in orderedMatches) {
      if (match.equipmentUsage.any(
        (usage) =>
            usage.matchId != match.sourceId ||
            usage.matchNumber != match.matchNumber,
      )) {
        throw ArgumentError('Match equipment provenance does not match.');
      }
    }
    for (final session in orderedTraining) {
      final drills = _orderedTrainingDrills(session.drillMatches);
      _validateUniqueSources(
        'training drill',
        drills.map((drill) => drill.sourceId.toString()),
      );
      final drillIdentities = {
        for (final drill in drills) '${drill.sourceId}:${drill.matchNumber}',
      };
      if (session.equipmentUsage.any(
        (usage) => !drillIdentities.contains(
          '${usage.matchId}:${usage.matchNumber}',
        ),
      )) {
        throw ArgumentError('Training equipment provenance does not match.');
      }
    }
    _validateUniqueSources(
      'training',
      orderedTraining.map((item) => item.sourceId.toString()),
    );
    _validateUniqueSources(
      'mastery',
      orderedMastery.map(
        (item) => '${item.entryId}:${item.methodologyId}',
      ),
    );

    final sourcePayload = <String, Object?>{
      'player': {
        'playerId': player.playerId,
        'createdAt': player.createdAt.toUtc().toIso8601String(),
      },
      'matches': orderedMatches.map(_matchSourceJson).toList(),
      'training': orderedTraining.map(_trainingSourceJson).toList(),
      'playerModel': playerModel == null
          ? null
          : {
              'playerId': playerModel.playerId,
              'overall': playerModel.overall,
              'confidence': playerModel.confidence,
              'lastUpdated': playerModel.lastUpdated.toUtc().toIso8601String(),
              'sourceDigest': playerModel.sourceDigest,
              'projectionDigest': playerModel.projectionDigest,
            },
      'mastery': orderedMastery.map(_masterySourceJson).toList(),
    };

    final events = <CareerTimelineEvent>[
      CareerTimelineEvent.create(
        type: CareerTimelineEventType.playerCreated,
        timestamp: player.createdAt,
        title: 'Player created',
        summary: 'Player record created.',
        sourceReference: 'player:${player.playerId}',
      ),
      ...orderedMatches.map(_matchEvent),
      ...orderedTraining.map(_trainingEvent),
      if (playerModel != null) _playerModelEvent(playerModel),
      ...orderedMastery
          .where((item) => item.lastEvidenceAt != null)
          .map(_masteryEvent),
    ];
    return CareerTimelineProjection.create(
      playerId: player.playerId,
      sourceDigest: careerTimelineDigest(sourcePayload),
      events: events,
    );
  }
}

Map<String, Object?> _matchSourceJson(CareerCompletedMatchFact item) => {
      'sourceId': item.sourceId,
      'matchNumber': item.matchNumber,
      'gameType': item.gameType,
      'opponent': item.opponent,
      'winner': item.winner,
      'result': item.result,
      'completedAt': item.completedAt.toUtc().toIso8601String(),
      'equipmentUsage': _orderedEquipmentUsage(item.equipmentUsage)
          .map((e) => e.toJson())
          .toList(),
    };

Map<String, Object?> _trainingSourceJson(CareerCompletedTrainingFact item) => {
      'sourceId': item.sourceId,
      'goal': item.goal,
      'completedAt': item.completedAt.toUtc().toIso8601String(),
      'drillMatches': _orderedTrainingDrills(item.drillMatches)
          .map(
            (drill) => {
              'sourceId': drill.sourceId,
              'matchNumber': drill.matchNumber,
            },
          )
          .toList(),
      'equipmentUsage': _orderedEquipmentUsage(item.equipmentUsage)
          .map((e) => e.toJson())
          .toList(),
    };

Map<String, Object?> _masterySourceJson(CareerMasteryFact item) => {
      'entryId': item.entryId,
      'stage': item.stage,
      'score': item.score,
      'confidence': item.confidence,
      'lastEvidenceAt': item.lastEvidenceAt?.toUtc().toIso8601String(),
      'methodologyId': item.methodologyId,
    };

CareerTimelineEvent _matchEvent(CareerCompletedMatchFact fact) {
  final details = <String>[
    'Match #${fact.matchNumber}',
    fact.gameType,
    if (fact.opponent?.trim().isNotEmpty ?? false)
      'opponent ${fact.opponent!.trim()}',
    if (fact.result?.trim().isNotEmpty ?? false) fact.result!.trim(),
  ];
  return CareerTimelineEvent.create(
    type: CareerTimelineEventType.completedMatch,
    timestamp: fact.completedAt,
    title: 'Match completed',
    summary: '${details.join(' | ')}.',
    sourceReference: 'match:${fact.sourceId}',
    equipmentUsage: fact.equipmentUsage,
  );
}

CareerTimelineEvent _trainingEvent(CareerCompletedTrainingFact fact) {
  final goal = fact.goal?.trim();
  return CareerTimelineEvent.create(
    type: CareerTimelineEventType.completedTraining,
    timestamp: fact.completedAt,
    title: 'Training completed',
    summary: goal == null || goal.isEmpty
        ? 'Training session #${fact.sourceId} completed.'
        : 'Training session #${fact.sourceId} completed | goal: $goal.',
    sourceReference: 'training:${fact.sourceId}',
    equipmentUsage: fact.equipmentUsage,
  );
}

CareerTimelineEvent _playerModelEvent(CareerPlayerModelFact fact) =>
    CareerTimelineEvent.create(
      type: CareerTimelineEventType.playerModelSnapshot,
      timestamp: fact.lastUpdated,
      title: 'Player Model snapshot',
      summary:
          'Recorded overall ${fact.overall} with confidence ${fact.confidence}.',
      sourceReference: 'player-model:${fact.playerId}:${fact.projectionDigest}',
    );

CareerTimelineEvent _masteryEvent(CareerMasteryFact fact) =>
    CareerTimelineEvent.create(
      type: CareerTimelineEventType.masteryEvidenceUpdated,
      timestamp: fact.lastEvidenceAt!,
      title: 'Mastery evidence updated',
      summary: '${fact.entryId} recorded stage ${fact.stage}, score '
          '${fact.score}, confidence ${fact.confidence}.',
      sourceReference: 'mastery:${fact.entryId}:${fact.methodologyId}',
    );

void _validateUniqueSources(String kind, Iterable<String> sources) {
  final values = sources.toList();
  if (values.toSet().length != values.length) {
    throw ArgumentError('Duplicate $kind timeline sources.');
  }
}

List<CareerEquipmentUsageRef> _orderedEquipmentUsage(
  List<CareerEquipmentUsageRef> usage,
) =>
    ([...usage]..sort(compareCareerEquipmentUsage));

List<CareerTrainingDrillMatchFact> _orderedTrainingDrills(
  List<CareerTrainingDrillMatchFact> drills,
) =>
    ([...drills]..sort((left, right) {
        final numberOrder = left.matchNumber.compareTo(right.matchNumber);
        return numberOrder != 0
            ? numberOrder
            : left.sourceId.compareTo(right.sourceId);
      }));
