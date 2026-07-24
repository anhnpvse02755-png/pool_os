import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/equipment/application/equipment_performance_calculator.dart';

void main() {
  const calculator = EquipmentPerformanceCalculator();
  final match = _activity(
    kind: EquipmentActivityKind.match,
    id: 'match:1',
    sessionId: 1,
    endedAt: DateTime.utc(2026, 7, 1, 10),
    duration: 3600,
    won: true,
    attempts: 0,
    successes: 0,
  );
  final trainingOne = _activity(
    kind: EquipmentActivityKind.training,
    id: 'training:2:1',
    sessionId: 2,
    endedAt: DateTime.utc(2026, 7, 2, 10),
    duration: 1800,
    won: false,
    attempts: 10,
    successes: 7,
  );
  final trainingTwo = _activity(
    kind: EquipmentActivityKind.training,
    id: 'training:2:2',
    sessionId: 2,
    endedAt: DateTime.utc(2026, 7, 2, 10),
    duration: 1800,
    won: false,
    attempts: 10,
    successes: 9,
  );

  test('replay is canonical and aggregates Match and Training facts', () {
    final left = calculator.calculate(
      playerId: 3,
      equipmentId: 8,
      activities: [match, trainingOne, trainingTwo],
    );
    final right = calculator.calculate(
      playerId: 3,
      equipmentId: 8,
      activities: [trainingTwo, match, trainingOne],
    );

    expect(right.toJson(), left.toJson());
    expect(right.digest, left.digest);
    expect(left.totalMatches, 1);
    expect(left.matchWinRate, 100);
    expect(left.totalTrainingSessions, 1);
    expect(left.trainingSuccessRate, 80);
    expect(left.recordedDurationSeconds, 5400);
    expect(left.lastUsed, DateTime.utc(2026, 7, 2, 10));
  });

  test('empty source produces a valid zero rebuildable projection', () {
    final projection = calculator.calculate(
      playerId: 3,
      equipmentId: 8,
      activities: const [],
    );

    expect(projection.totalMatches, 0);
    expect(projection.totalTrainingSessions, 0);
    expect(projection.lastUsed, isNull);
    expect(projection.sourceDigest, isNotEmpty);
  });

  test('duplicate semantic source fails closed', () {
    expect(
      () => calculator.calculate(
        playerId: 3,
        equipmentId: 8,
        activities: [match, match],
      ),
      throwsArgumentError,
    );
  });
}

EquipmentPerformanceActivity _activity({
  required EquipmentActivityKind kind,
  required String id,
  required int sessionId,
  required DateTime endedAt,
  required int duration,
  required bool won,
  required int attempts,
  required int successes,
}) =>
    EquipmentPerformanceActivity(
      kind: kind,
      sourceId: id,
      sessionId: sessionId,
      endedAt: endedAt,
      durationSeconds: duration,
      won: won,
      attempts: attempts,
      successes: successes,
    );
