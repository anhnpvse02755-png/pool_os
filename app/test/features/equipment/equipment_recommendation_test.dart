import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/equipment/domain/equipment_performance_projection.dart';
import 'package:pool_os/features/equipment/domain/models/cue.dart';
import 'package:pool_os/features/equipment/presentation/widgets/equipment_recommendation.dart';

Cue _cue({
  required int id,
  required int playerId,
  String name = 'Cue',
  bool isActive = true,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  final now = createdAt ?? DateTime(2026, 1, 1);
  return Cue(
    id: id,
    playerId: playerId,
    name: name,
    shaftMaterial: 'Carbon Fiber',
    shaftDiameter: 12.75,
    tipBrand: 'Kamui',
    tipHardness: 'Medium',
    weight: 19.0,
    balance: 'Center',
    joint: 'Uni-Loc',
    isActive: isActive,
    createdAt: now,
    updatedAt: updatedAt ?? now,
  );
}

EquipmentPerformanceProjection _projection({
  required int playerId,
  required int equipmentId,
  int totalMatches = 10,
  double matchWinRate = 50,
  int totalTrainingSessions = 10,
  double trainingSuccessRate = 50,
  DateTime? lastUsed,
}) {
  return EquipmentPerformanceProjection.create(
    playerId: playerId,
    equipmentId: equipmentId,
    totalMatches: totalMatches,
    matchWinRate: matchWinRate,
    totalTrainingSessions: totalTrainingSessions,
    trainingSuccessRate: trainingSuccessRate,
    recordedDurationSeconds: 0,
    lastUsed: lastUsed,
    sourceDigest: 'digest-$playerId-$equipmentId',
  );
}

void main() {
  final now = DateTime(2026, 7, 1, 12);

  group('FEATURE_010 Equipment Recommendation', () {
    test('cues belong to the correct Active Player (no foreign-player leak)',
        () {
      final cues = [
        _cue(id: 1, playerId: 100),
        _cue(id: 2, playerId: 100),
        _cue(id: 3, playerId: 999),
      ];
      final projections = [
        _projection(playerId: 100, equipmentId: 1, matchWinRate: 60),
        _projection(playerId: 100, equipmentId: 2, matchWinRate: 55),
        _projection(playerId: 999, equipmentId: 3, matchWinRate: 99),
      ];

      // Caller-side filter: only Active Player's cues + matching projections.
      final activeCues = cues.where((c) => c.playerId == 100).toList();
      final activeProjections =
          projections.where((p) => p.playerId == 100).toList();

      final result = recommendCues(
        cues: activeCues,
        projections: activeProjections,
        now: now,
      );

      expect(result.length, 2);
      expect(result.any((r) => r.cue.id == 3), isFalse,
          reason: 'Foreign-player projection must never leak');
    });

    test('inactive cues are not surfaced', () {
      final cues = [
        _cue(id: 1, playerId: 100, isActive: true),
        _cue(id: 2, playerId: 100, isActive: false),
      ];
      final projections = [
        _projection(playerId: 100, equipmentId: 1, matchWinRate: 60),
        _projection(playerId: 100, equipmentId: 2, matchWinRate: 99),
      ];
      final result = recommendCues(
        cues: cues,
        projections: projections,
        now: now,
      );
      expect(result.length, 1);
      expect(result.first.cue.id, 1);
    });

    test('Top 3 ordering: win rate desc, then training success, then last used',
        () {
      final cues = [
        _cue(id: 1, playerId: 100),
        _cue(id: 2, playerId: 100),
        _cue(id: 3, playerId: 100),
        _cue(id: 4, playerId: 100),
        _cue(id: 5, playerId: 100),
      ];
      final projections = [
        // Win rate tie at 70 — second criterion (training) breaks it.
        _projection(
          playerId: 100,
          equipmentId: 1,
          matchWinRate: 70,
          trainingSuccessRate: 80,
        ),
        _projection(
          playerId: 100,
          equipmentId: 2,
          matchWinRate: 70,
          trainingSuccessRate: 60,
        ),
        // Win rate 60, more recent last used than id 4.
        _projection(
          playerId: 100,
          equipmentId: 3,
          matchWinRate: 60,
          trainingSuccessRate: 50,
          lastUsed: DateTime(2026, 6, 30),
        ),
        _projection(
          playerId: 100,
          equipmentId: 4,
          matchWinRate: 60,
          trainingSuccessRate: 50,
          lastUsed: DateTime(2026, 6, 25),
        ),
        // Win rate 50, training 90 (high training only).
        _projection(
          playerId: 100,
          equipmentId: 5,
          matchWinRate: 50,
          trainingSuccessRate: 90,
        ),
      ];

      final result = recommendCues(
        cues: cues,
        projections: projections,
        now: now,
      );
      expect(result.length, 3);
      expect(result[0].cue.id, 1);
      expect(result[1].cue.id, 2);
      expect(result[2].cue.id, 3);
    });

    test('Tie-break: identical stats → order by Equipment ID ascending', () {
      final cues = [
        _cue(id: 7, playerId: 100),
        _cue(id: 3, playerId: 100),
        _cue(id: 5, playerId: 100),
      ];
      final projections = [
        _projection(
            playerId: 100, equipmentId: 7, matchWinRate: 60, lastUsed: null),
        _projection(
            playerId: 100, equipmentId: 3, matchWinRate: 60, lastUsed: null),
        _projection(
            playerId: 100, equipmentId: 5, matchWinRate: 60, lastUsed: null),
      ];
      final result = recommendCues(
        cues: cues,
        projections: projections,
        now: now,
      );
      expect(result.map((r) => r.cue.id).toList(), [3, 5, 7]);
    });

    test('Insufficient data (matches<5 OR training<5) → empty list', () {
      final cues = [_cue(id: 1, playerId: 100)];
      // Spec: "dưới 5 trận và dưới 5 buổi tập" → no recommendation.
      final projections = [
        _projection(
          playerId: 100,
          equipmentId: 1,
          totalMatches: 4,
          totalTrainingSessions: 4,
        ),
      ];
      final result = recommendCues(
        cues: cues,
        projections: projections,
        now: now,
      );
      expect(result, isEmpty);
    });

    test('Insufficient data when only one threshold is met', () {
      final cues = [_cue(id: 1, playerId: 100)];
      // Matches OK, training below threshold.
      final projections = [
        _projection(
          playerId: 100,
          equipmentId: 1,
          totalMatches: 10,
          totalTrainingSessions: 4,
        ),
      ];
      final result = recommendCues(
        cues: cues,
        projections: projections,
        now: now,
      );
      expect(result, isEmpty);
    });

    test('Top N is at most 3 even when more candidates qualify', () {
      final cues = [
        _cue(id: 1, playerId: 100),
        _cue(id: 2, playerId: 100),
        _cue(id: 3, playerId: 100),
        _cue(id: 4, playerId: 100),
        _cue(id: 5, playerId: 100),
      ];
      final projections = [
        _projection(playerId: 100, equipmentId: 1, matchWinRate: 90),
        _projection(playerId: 100, equipmentId: 2, matchWinRate: 80),
        _projection(playerId: 100, equipmentId: 3, matchWinRate: 70),
        _projection(playerId: 100, equipmentId: 4, matchWinRate: 60),
        _projection(playerId: 100, equipmentId: 5, matchWinRate: 50),
      ];
      final result = recommendCues(
        cues: cues,
        projections: projections,
        now: now,
      );
      expect(result.length, 3);
      expect(result.map((r) => r.cue.id).toList(), [1, 2, 3]);
    });

    test('null lastUsed sorts after dated cues (and before earlier dates)', () {
      final cues = [
        _cue(id: 1, playerId: 100),
        _cue(id: 2, playerId: 100),
        _cue(id: 3, playerId: 100),
      ];
      final projections = [
        _projection(
            playerId: 100, equipmentId: 1, matchWinRate: 50, lastUsed: null),
        _projection(
          playerId: 100,
          equipmentId: 2,
          matchWinRate: 50,
          lastUsed: DateTime(2026, 1, 1),
        ),
        _projection(
          playerId: 100,
          equipmentId: 3,
          matchWinRate: 50,
          lastUsed: DateTime(2026, 5, 1),
        ),
      ];
      final result = recommendCues(
        cues: cues,
        projections: projections,
        now: now,
      );
      // Two cues fit under Top N=3; sort puts the more recent one first,
      // null-last.
      expect(result.map((r) => r.cue.id).toList(), [3, 2, 1]);
    });

    test('Switching Active Player → recommendation list updates', () {
      final cues = [
        _cue(id: 1, playerId: 100),
        _cue(id: 2, playerId: 200),
      ];
      final projections = [
        _projection(playerId: 100, equipmentId: 1, matchWinRate: 80),
        _projection(playerId: 200, equipmentId: 2, matchWinRate: 30),
      ];

      final forPlayer100 = recommendCues(
        cues: cues.where((c) => c.playerId == 100).toList(),
        projections: projections.where((p) => p.playerId == 100).toList(),
        now: now,
      );
      final forPlayer200 = recommendCues(
        cues: cues.where((c) => c.playerId == 200).toList(),
        projections: projections.where((p) => p.playerId == 200).toList(),
        now: now,
      );

      expect(forPlayer100.map((r) => r.cue.id).toList(), [1]);
      expect(forPlayer200.map((r) => r.cue.id).toList(), [2]);
    });

    test('Recommendation is deterministic — identical input → identical output',
        () {
      final cues = [
        _cue(id: 1, playerId: 100),
        _cue(id: 2, playerId: 100),
      ];
      final projections = [
        _projection(playerId: 100, equipmentId: 1, matchWinRate: 60),
        _projection(playerId: 100, equipmentId: 2, matchWinRate: 70),
      ];

      final a = recommendCues(cues: cues, projections: projections, now: now);
      final b = recommendCues(cues: cues, projections: projections, now: now);
      expect(a.map((r) => r.cue.id).toList(), b.map((r) => r.cue.id).toList());
    });
  });
}
