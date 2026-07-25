import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/player/domain/career_timeline_builder.dart';
import 'package:pool_os/features/player/domain/career_timeline_projection.dart';

void main() {
  group('CareerTimelineBuilder', () {
    test('rebuild is byte deterministic with stable ordering and digests', () {
      final forward = _build();
      final reversed = _build(reverseSources: true);

      expect(jsonEncode(reversed.toJson()), jsonEncode(forward.toJson()));
      expect(reversed.sourceDigest, forward.sourceDigest);
      expect(reversed.digest, forward.digest);
      expect(
        forward.events.map((event) => event.timestamp),
        orderedEquals(
          [...forward.events.map((event) => event.timestamp)]
            ..sort((left, right) => right.compareTo(left)),
        ),
      );
    });

    test('canonical equipment payload retains every role and provenance', () {
      final projection = _build();
      final match = projection.events.singleWhere(
        (event) => event.sourceReference == 'match:11',
      );
      expect(
        match.equipmentUsage.map((usage) => usage.role),
        [
          CareerEquipmentRole.playing,
          CareerEquipmentRole.breakCue,
          CareerEquipmentRole.jump,
        ],
      );
      expect(match.equipmentUsage.map((usage) => usage.cueId), [31, 31, 33]);
      expect(
        match.equipmentUsage.map((usage) => usage.snapshotReference).toSet(),
        {'equipment-snapshot:match:11'},
      );

      final training = projection.events.singleWhere(
        (event) => event.sourceReference == 'training:21',
      );
      expect(training.equipmentUsage.map((usage) => usage.matchId), [101, 102]);
      expect(training.equipmentUsage.map((usage) => usage.cueId), [41, 42]);
    });

    test('equipment payload participates in event ID and projection digest',
        () {
      final original = _build();
      final changed = _build(matchPlayingCueId: 99);
      final originalMatch = original.events.singleWhere(
        (event) => event.sourceReference == 'match:11',
      );
      final changedMatch = changed.events.singleWhere(
        (event) => event.sourceReference == 'match:11',
      );
      expect(changedMatch.eventId, isNot(originalMatch.eventId));
      expect(changed.sourceDigest, isNot(original.sourceDigest));
      expect(changed.digest, isNot(original.digest));
    });

    test('missing snapshot emits no inferred equipment usage', () {
      final projection = _build(includeEquipment: false);
      expect(
        projection.events.expand((event) => event.equipmentUsage),
        isEmpty,
      );
      expect(jsonEncode(projection.toJson()), isNot(contains('activeCue')));
    });

    test('adding a historical fact does not mutate existing events', () {
      final original = _build();
      final extended = _build(
        additionalMatches: [
          CareerCompletedMatchFact(
            sourceId: 13,
            matchNumber: 3,
            gameType: 'race_to',
            opponent: 'C',
            winner: 'Player',
            result: '7-4',
            completedAt: DateTime.utc(2026, 7, 8, 18),
          ),
        ],
      );
      final extendedBySource = {
        for (final event in extended.events)
          event.sourceReference: event.toJson(),
      };
      for (final event in original.events) {
        expect(extendedBySource[event.sourceReference], event.toJson());
      }
    });

    test('every event has a rebuildable source reference', () {
      for (final event in _build().events) {
        final rebuilt = CareerTimelineEvent.create(
          type: event.type,
          timestamp: event.timestamp,
          title: event.title,
          summary: event.summary,
          sourceReference: event.sourceReference,
          equipmentUsage: event.equipmentUsage,
        );
        expect(rebuilt.eventId, event.eventId);
        expect(event.sourceReference, matches(RegExp(r'^[a-z-]+:.+')));
      }
    });

    test('rejects Match equipment provenance from another Match', () {
      expect(
        () => const CareerTimelineBuilder().build(
          player: CareerPlayerFact(
            playerId: 7,
            createdAt: DateTime.utc(2026, 7, 1),
          ),
          matches: [
            CareerCompletedMatchFact(
              sourceId: 11,
              matchNumber: 1,
              gameType: 'race_to',
              opponent: null,
              winner: null,
              result: null,
              completedAt: DateTime.utc(2026, 7, 2),
              equipmentUsage: const [
                CareerEquipmentUsageRef(
                  matchId: 12,
                  matchNumber: 1,
                  snapshotReference: 'equipment-snapshot:match:12',
                  role: CareerEquipmentRole.playing,
                  cueId: 31,
                ),
              ],
            ),
          ],
          training: const [],
          playerModel: null,
          mastery: const [],
        ),
        throwsArgumentError,
      );
    });

    test('rejects Training equipment outside its completed Drill Matches', () {
      expect(
        () => const CareerTimelineBuilder().build(
          player: CareerPlayerFact(
            playerId: 7,
            createdAt: DateTime.utc(2026, 7, 1),
          ),
          matches: const [],
          training: [
            CareerCompletedTrainingFact(
              sourceId: 21,
              goal: null,
              completedAt: DateTime.utc(2026, 7, 2),
              drillMatches: const [
                CareerTrainingDrillMatchFact(sourceId: 101, matchNumber: 1),
              ],
              equipmentUsage: const [
                CareerEquipmentUsageRef(
                  matchId: 102,
                  matchNumber: 2,
                  snapshotReference: 'equipment-snapshot:match:102',
                  role: CareerEquipmentRole.playing,
                  cueId: 41,
                ),
              ],
            ),
          ],
          playerModel: null,
          mastery: const [],
        ),
        throwsArgumentError,
      );
    });

    test('rejects equipment usage on non-activity events', () {
      expect(
        () => CareerTimelineEvent.create(
          type: CareerTimelineEventType.playerCreated,
          timestamp: DateTime.utc(2026, 7, 1),
          title: 'Player created',
          summary: 'Player record created.',
          sourceReference: 'player:7',
          equipmentUsage: const [
            CareerEquipmentUsageRef(
              matchId: 11,
              matchNumber: 1,
              snapshotReference: 'equipment-snapshot:match:11',
              role: CareerEquipmentRole.playing,
              cueId: 31,
            ),
          ],
        ),
        throwsArgumentError,
      );
    });
  });
}

CareerTimelineProjection _build({
  bool reverseSources = false,
  bool includeEquipment = true,
  int matchPlayingCueId = 31,
  List<CareerCompletedMatchFact> additionalMatches = const [],
}) {
  final matchUsage = <CareerEquipmentUsageRef>[
    if (includeEquipment)
      const CareerEquipmentUsageRef(
        matchId: 11,
        matchNumber: 1,
        snapshotReference: 'equipment-snapshot:match:11',
        role: CareerEquipmentRole.jump,
        cueId: 33,
      ),
    if (includeEquipment)
      const CareerEquipmentUsageRef(
        matchId: 11,
        matchNumber: 1,
        snapshotReference: 'equipment-snapshot:match:11',
        role: CareerEquipmentRole.breakCue,
        cueId: 31,
      ),
    if (includeEquipment)
      CareerEquipmentUsageRef(
        matchId: 11,
        matchNumber: 1,
        snapshotReference: 'equipment-snapshot:match:11',
        role: CareerEquipmentRole.playing,
        cueId: matchPlayingCueId,
      ),
  ];
  final matches = <CareerCompletedMatchFact>[
    CareerCompletedMatchFact(
      sourceId: 11,
      matchNumber: 1,
      gameType: 'race_to',
      opponent: 'A',
      winner: 'Player',
      result: '7-5',
      completedAt: DateTime.utc(2026, 7, 3, 10),
      equipmentUsage:
          reverseSources ? matchUsage.reversed.toList() : matchUsage,
    ),
    ...additionalMatches,
  ];
  final trainingUsage = <CareerEquipmentUsageRef>[
    if (includeEquipment)
      const CareerEquipmentUsageRef(
        matchId: 102,
        matchNumber: 2,
        snapshotReference: 'equipment-snapshot:match:102',
        role: CareerEquipmentRole.playing,
        cueId: 42,
      ),
    if (includeEquipment)
      const CareerEquipmentUsageRef(
        matchId: 101,
        matchNumber: 1,
        snapshotReference: 'equipment-snapshot:match:101',
        role: CareerEquipmentRole.playing,
        cueId: 41,
      ),
  ];
  final training = <CareerCompletedTrainingFact>[
    CareerCompletedTrainingFact(
      sourceId: 21,
      goal: 'Break control',
      completedAt: DateTime.utc(2026, 7, 4, 12),
      drillMatches: reverseSources
          ? const [
              CareerTrainingDrillMatchFact(sourceId: 101, matchNumber: 1),
              CareerTrainingDrillMatchFact(sourceId: 102, matchNumber: 2),
            ]
          : const [
              CareerTrainingDrillMatchFact(sourceId: 102, matchNumber: 2),
              CareerTrainingDrillMatchFact(sourceId: 101, matchNumber: 1),
            ],
      equipmentUsage:
          reverseSources ? trainingUsage.reversed.toList() : trainingUsage,
    ),
  ];
  return const CareerTimelineBuilder().build(
    player: CareerPlayerFact(
      playerId: 7,
      createdAt: DateTime.utc(2026, 7, 1, 8),
    ),
    matches: reverseSources ? matches.reversed.toList() : matches,
    training: reverseSources ? training.reversed.toList() : training,
    playerModel: CareerPlayerModelFact(
      playerId: 7,
      overall: 68,
      confidence: 74,
      lastUpdated: DateTime.utc(2026, 7, 7),
      sourceDigest: 'model-source',
      projectionDigest: 'model-projection',
    ),
    mastery: [
      CareerMasteryFact(
        entryId: 'position-play',
        stage: 'practicing',
        score: 62,
        confidence: 0.8,
        lastEvidenceAt: DateTime.utc(2026, 7, 6),
        methodologyId: 'mastery-v1',
      ),
    ],
  );
}
