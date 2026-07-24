import 'dart:math' as math;

import '../domain/player_progress_projection.dart';

enum PlayerProgressActivityKind { match, training }

final class PlayerProgressActivity {
  const PlayerProgressActivity({
    required this.kind,
    required this.sourceId,
    required this.occurredAt,
    required this.rackCount,
    required this.wins,
    required this.attempts,
    required this.successes,
    required this.breakAttempts,
    required this.breakSuccesses,
    required this.scratches,
    required this.positionErrors,
    required this.safetyErrors,
    required this.kickErrors,
    required this.jumpErrors,
    required this.confidenceValues,
  });

  final PlayerProgressActivityKind kind;
  final String sourceId;
  final DateTime occurredAt;
  final int rackCount;
  final int wins;
  final int attempts;
  final int successes;
  final int breakAttempts;
  final int breakSuccesses;
  final int scratches;
  final int positionErrors;
  final int safetyErrors;
  final int kickErrors;
  final int jumpErrors;
  final List<int> confidenceValues;

  double get outcome => kind == PlayerProgressActivityKind.match
      ? _rate(wins, rackCount)
      : _rate(successes, attempts);

  Map<String, Object> toJson() => {
        'kind': kind.name,
        'sourceId': sourceId,
        'occurredAt': occurredAt.toUtc().toIso8601String(),
        'rackCount': rackCount,
        'wins': wins,
        'attempts': attempts,
        'successes': successes,
        'breakAttempts': breakAttempts,
        'breakSuccesses': breakSuccesses,
        'scratches': scratches,
        'positionErrors': positionErrors,
        'safetyErrors': safetyErrors,
        'kickErrors': kickErrors,
        'jumpErrors': jumpErrors,
        'confidenceValues': confidenceValues,
      };
}

final class PlayerMasteryMetric {
  const PlayerMasteryMetric({
    required this.knowledgeId,
    required this.score,
    required this.confidence,
    required this.lastEvidenceAt,
  });

  final String knowledgeId;
  final double score;
  final double confidence;
  final DateTime? lastEvidenceAt;

  Map<String, Object?> toJson() => {
        'knowledgeId': knowledgeId,
        'score': score,
        'confidence': confidence,
        'lastEvidenceAt': lastEvidenceAt?.toUtc().toIso8601String(),
      };
}

final class PlayerProgressCalculator {
  const PlayerProgressCalculator();

  PlayerProgressProjection calculate({
    required int playerId,
    required List<PlayerProgressActivity> activities,
    required List<PlayerMasteryMetric> mastery,
    required DateTime fallbackUpdatedAt,
  }) {
    final orderedActivities = [...activities]..sort((left, right) {
        final byTime =
            left.occurredAt.toUtc().compareTo(right.occurredAt.toUtc());
        if (byTime != 0) return byTime;
        final byKind = left.kind.index.compareTo(right.kind.index);
        return byKind != 0 ? byKind : left.sourceId.compareTo(right.sourceId);
      });
    final orderedMastery = [...mastery]
      ..sort((left, right) => left.knowledgeId.compareTo(right.knowledgeId));
    _validate(orderedActivities, orderedMastery);

    final rackCount = _sum(orderedActivities, (item) => item.rackCount);
    final attempts = _sum(orderedActivities, (item) => item.attempts);
    final successes = _sum(orderedActivities, (item) => item.successes);
    final breakAttempts = _sum(orderedActivities, (item) => item.breakAttempts);
    final breakSuccesses =
        _sum(orderedActivities, (item) => item.breakSuccesses);
    final scratches = _sum(orderedActivities, (item) => item.scratches);
    final positionErrors =
        _sum(orderedActivities, (item) => item.positionErrors);
    final safetyErrors = _sum(orderedActivities, (item) => item.safetyErrors);
    final kickJumpErrors = _sum(
      orderedActivities,
      (item) => item.kickErrors + item.jumpErrors,
    );
    final confidenceValues = orderedActivities
        .expand((item) => item.confidenceValues)
        .toList(growable: false);
    final outcomes = orderedActivities.map((item) => item.outcome).toList();

    final masteryScore = orderedMastery.isEmpty
        ? 0.0
        : _score(orderedMastery
                .map((item) => _normalized(item.score))
                .reduce((a, b) => a + b) /
            orderedMastery.length);
    final skills = <PlayerSkillScore>[
      PlayerSkillScore(
        dimension: PlayerSkillDimension.breakSkill,
        value: _score(_rate(breakSuccesses, breakAttempts)),
      ),
      PlayerSkillScore(
        dimension: PlayerSkillDimension.potting,
        value: _score(_rate(successes, attempts)),
      ),
      PlayerSkillScore(
        dimension: PlayerSkillDimension.position,
        value: _quality(successes, positionErrors),
      ),
      PlayerSkillScore(
        dimension: PlayerSkillDimension.safety,
        value: _quality(rackCount, safetyErrors),
      ),
      PlayerSkillScore(
        dimension: PlayerSkillDimension.cueBallControl,
        value: _quality(successes, scratches + positionErrors),
      ),
      PlayerSkillScore(
        dimension: PlayerSkillDimension.kickJump,
        value: _quality(rackCount, kickJumpErrors),
      ),
      PlayerSkillScore(
        dimension: PlayerSkillDimension.mental,
        value: _mental(confidenceValues, outcomes),
      ),
      PlayerSkillScore(
        dimension: PlayerSkillDimension.consistency,
        value: _consistency(outcomes),
      ),
    ];
    final ranked = [...skills]..sort((left, right) {
        final byValue = right.value.compareTo(left.value);
        return byValue != 0
            ? byValue
            : left.dimension.index.compareTo(right.dimension.index);
      });
    final reverseRanked = [...skills]..sort((left, right) {
        final byValue = left.value.compareTo(right.value);
        return byValue != 0
            ? byValue
            : left.dimension.index.compareTo(right.dimension.index);
      });
    final trendPoints = outcomes.length <= 12
        ? outcomes.map(_score).toList()
        : outcomes.skip(outcomes.length - 12).map(_score).toList();
    final sourceConfidence = math.min(
      100.0,
      orderedActivities.length * 10.0 + rackCount * 2.0,
    );
    final masteryConfidence = orderedMastery.isEmpty
        ? sourceConfidence
        : _score(orderedMastery
                .map((item) => _normalized(item.confidence))
                .reduce((a, b) => a + b) /
            orderedMastery.length);
    final confidence = _score(
      orderedMastery.isEmpty
          ? sourceConfidence
          : (sourceConfidence + masteryConfidence) / 2,
    );
    final overall = _score(
      (skills.map((item) => item.value).reduce((a, b) => a + b) +
              masteryScore) /
          (skills.length + 1),
    );
    final latest = <DateTime>[
      fallbackUpdatedAt.toUtc(),
      ...orderedActivities.map((item) => item.occurredAt.toUtc()),
      ...orderedMastery
          .map((item) => item.lastEvidenceAt?.toUtc())
          .whereType<DateTime>(),
    ]..sort();
    final sourcePayload = <String, Object>{
      'playerId': playerId,
      'activities': orderedActivities.map((item) => item.toJson()).toList(),
      'mastery': orderedMastery.map((item) => item.toJson()).toList(),
    };

    return PlayerProgressProjection.create(
      playerId: playerId,
      skills: skills,
      overall: overall,
      confidence: confidence,
      trend: _trend(outcomes),
      mastery: masteryScore,
      strengths: ranked.take(5).map((item) => item.dimension).toList(),
      weaknesses: reverseRanked.take(5).map((item) => item.dimension).toList(),
      trendPoints: trendPoints,
      sourceMatchCount: orderedActivities
          .where((item) => item.kind == PlayerProgressActivityKind.match)
          .length,
      sourceTrainingCount: orderedActivities
          .where((item) => item.kind == PlayerProgressActivityKind.training)
          .length,
      lastUpdated: latest.last,
      sourceDigest: playerProgressDigest(sourcePayload),
    );
  }

  void _validate(
    List<PlayerProgressActivity> activities,
    List<PlayerMasteryMetric> mastery,
  ) {
    final activityIds = <String>{};
    for (final item in activities) {
      if (item.sourceId.trim().isEmpty ||
          !activityIds.add('${item.kind.name}:${item.sourceId}') ||
          item.rackCount < 0 ||
          item.wins < 0 ||
          item.wins > item.rackCount ||
          item.attempts < 0 ||
          item.successes < 0 ||
          item.successes > item.attempts ||
          item.breakAttempts < 0 ||
          item.breakSuccesses < 0 ||
          item.breakSuccesses > item.breakAttempts ||
          item.scratches < 0 ||
          item.positionErrors < 0 ||
          item.safetyErrors < 0 ||
          item.kickErrors < 0 ||
          item.jumpErrors < 0 ||
          item.confidenceValues.any((value) => value < 0 || value > 100)) {
        throw ArgumentError('Player progress activity is invalid.');
      }
    }
    final masteryIds = <String>{};
    if (mastery.any((item) =>
        item.knowledgeId.trim().isEmpty ||
        !masteryIds.add(item.knowledgeId) ||
        !item.score.isFinite ||
        !item.confidence.isFinite ||
        item.score < 0 ||
        item.confidence < 0)) {
      throw ArgumentError('Player progress mastery input is invalid.');
    }
  }
}

int _sum(
  Iterable<PlayerProgressActivity> values,
  int Function(PlayerProgressActivity) select,
) =>
    values.fold(0, (sum, item) => sum + select(item));

double _rate(int numerator, int denominator) =>
    denominator == 0 ? 0 : numerator * 100 / denominator;

double _quality(int positive, int errors) =>
    positive + errors == 0 ? 0 : _score(positive * 100 / (positive + errors));

double _mental(List<int> values, List<double> outcomes) {
  if (values.isNotEmpty) {
    return _score(values.reduce((a, b) => a + b) / values.length);
  }
  return outcomes.isEmpty
      ? 0
      : _score(outcomes.reduce((a, b) => a + b) / outcomes.length);
}

double _consistency(List<double> outcomes) {
  if (outcomes.isEmpty) return 0;
  final mean = outcomes.reduce((a, b) => a + b) / outcomes.length;
  final variance = outcomes
          .map((value) => math.pow(value - mean, 2).toDouble())
          .reduce((a, b) => a + b) /
      outcomes.length;
  return _score(100 - math.sqrt(variance));
}

double _trend(List<double> outcomes) {
  if (outcomes.isEmpty) return 0;
  if (outcomes.length == 1) return 50;
  final split = outcomes.length ~/ 2;
  final earlier = outcomes.take(split).toList();
  final recent = outcomes.skip(split).toList();
  final earlierMean = earlier.reduce((a, b) => a + b) / earlier.length;
  final recentMean = recent.reduce((a, b) => a + b) / recent.length;
  return _score(50 + (recentMean - earlierMean) / 2);
}

double _normalized(double value) => value <= 1 ? value * 100 : value;

double _score(double value) =>
    (value.clamp(0, 100).toDouble() * 100).round() / 100;
