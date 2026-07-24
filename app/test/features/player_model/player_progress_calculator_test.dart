import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/player_model/application/player_progress_calculator.dart';
import 'package:pool_os/features/player_model/domain/player_progress_projection.dart';

void main() {
  const calculator = PlayerProgressCalculator();
  final first = _activity(
    id: 'first',
    at: DateTime.utc(2026, 7, 1),
    wins: 1,
    successes: 3,
  );
  final second = _activity(
    id: 'second',
    at: DateTime.utc(2026, 7, 2),
    wins: 3,
    successes: 8,
  );
  final mastery = [
    PlayerMasteryMetric(
      knowledgeId: 'knowledge.position',
      score: 0.8,
      confidence: 0.7,
      lastEvidenceAt: DateTime.utc(2026, 7, 2),
    ),
    PlayerMasteryMetric(
      knowledgeId: 'knowledge.break',
      score: 0.6,
      confidence: 0.5,
      lastEvidenceAt: DateTime.utc(2026, 7, 1),
    ),
  ];

  test('canonical replay produces identical JSON and digest', () {
    final left = calculator.calculate(
      playerId: 7,
      activities: [first, second],
      mastery: mastery,
      fallbackUpdatedAt: DateTime.utc(2026),
    );
    final right = calculator.calculate(
      playerId: 7,
      activities: [second, first],
      mastery: mastery.reversed.toList(),
      fallbackUpdatedAt: DateTime.utc(2026),
    );

    expect(right.toJson(), left.toJson());
    expect(right.digest, left.digest);
    expect(left.skills, hasLength(PlayerSkillDimension.values.length));
    expect(left.strengths, hasLength(5));
    expect(left.weaknesses, hasLength(5));
    expect(left.trend, greaterThan(50));
    expect(left.mastery, 70);
    expect(left.skills.every((score) => score.value >= 0 && score.value <= 100),
        isTrue);
  });

  test('rejects duplicate semantic activity and mastery identities', () {
    expect(
      () => calculator.calculate(
        playerId: 7,
        activities: [first, first],
        mastery: mastery,
        fallbackUpdatedAt: DateTime.utc(2026),
      ),
      throwsArgumentError,
    );
    expect(
      () => calculator.calculate(
        playerId: 7,
        activities: [first],
        mastery: [mastery.first, mastery.first],
        fallbackUpdatedAt: DateTime.utc(2026),
      ),
      throwsArgumentError,
    );
  });

  test('projection is immutable and rejects incomplete skill vectors', () {
    final projection = calculator.calculate(
      playerId: 7,
      activities: [first],
      mastery: const [],
      fallbackUpdatedAt: DateTime.utc(2026),
    );

    expect(() => projection.skills.add(projection.skills.first),
        throwsUnsupportedError);
    expect(
      () => PlayerProgressProjection.create(
        playerId: 7,
        skills: projection.skills.take(7).toList(),
        overall: 50,
        confidence: 50,
        trend: 50,
        mastery: 50,
        strengths: projection.strengths,
        weaknesses: projection.weaknesses,
        trendPoints: const [50],
        sourceMatchCount: 1,
        sourceTrainingCount: 0,
        lastUpdated: DateTime.utc(2026),
        sourceDigest: 'source',
      ),
      throwsArgumentError,
    );
  });
}

PlayerProgressActivity _activity({
  required String id,
  required DateTime at,
  required int wins,
  required int successes,
}) =>
    PlayerProgressActivity(
      kind: PlayerProgressActivityKind.match,
      sourceId: id,
      occurredAt: at,
      rackCount: 4,
      wins: wins,
      attempts: 10,
      successes: successes,
      breakAttempts: 4,
      breakSuccesses: wins,
      scratches: 1,
      positionErrors: 2,
      safetyErrors: 1,
      kickErrors: 1,
      jumpErrors: 0,
      confidenceValues: const [60, 70],
    );
