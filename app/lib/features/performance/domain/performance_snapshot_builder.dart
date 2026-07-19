import 'dart:math' as math;

import 'package:pool_os/features/match/domain/models/match.dart';
import 'package:pool_os/features/match/domain/models/match_context.dart';
import 'package:pool_os/features/performance/domain/performance_snapshot.dart';
import 'package:pool_os/features/rack/domain/models/rack.dart';
import 'package:pool_os/features/shot/domain/models/shot.dart';

class PerformanceMatchSample {
  final Match match;
  final List<Rack> racks;
  final List<Shot> shots;
  final MatchContext? context;

  const PerformanceMatchSample({
    required this.match,
    this.racks = const [],
    this.shots = const [],
    this.context,
  });
}

/// Builds a recent competition snapshot from persisted facts only.
///
/// The window is intentionally bounded so the snapshot describes current form,
/// while every formula has a stable methodology id for auditability.
class PerformanceSnapshotBuilder {
  static const int maxMatches = 12;

  PerformanceSnapshot build(
    List<PerformanceMatchSample> input, {
    DateTime? now,
  }) {
    final samples = input.where(_isCompletedCompetition).toList()
      ..sort((a, b) => _endedAt(b).compareTo(_endedAt(a)));
    final window = samples.take(maxMatches).toList(growable: false);
    final racks = window.expand((s) => s.racks).toList(growable: false);
    final shots = window.expand((s) => s.shots).toList(growable: false);

    final metrics = <PerformanceDimension, PerformanceMetric>{
      PerformanceDimension.execution: _execution(shots),
      PerformanceDimension.decision: _decision(shots),
      PerformanceDimension.cueBall: _cueBall(shots),
      PerformanceDimension.breakShot: _break(racks),
      PerformanceDimension.safety: _safety(shots),
      PerformanceDimension.mental: _mental(window),
      PerformanceDimension.consistency: _consistency(window),
    };

    return PerformanceSnapshot(
      generatedAt: now ?? DateTime.now(),
      sourceMatches: window.length,
      sourceRacks: racks.length,
      sourceShots: shots.length,
      metrics: Map.unmodifiable(metrics),
    );
  }

  bool _isCompletedCompetition(PerformanceMatchSample sample) {
    if (sample.match.endTime == null) return false;
    return !{
      GameTypes.warmUp,
      GameTypes.ghostChallenge,
      GameTypes.practiceMatch,
      GameTypes.drill,
    }.contains(sample.match.gameType);
  }

  DateTime _endedAt(PerformanceMatchSample sample) =>
      sample.match.endTime ?? sample.match.startTime ?? sample.match.createdAt;

  PerformanceMetric _execution(List<Shot> shots) {
    final attempts = shots.where((shot) => !_isBreak(shot) && !_isSafety(shot));
    final values = attempts.map((shot) => shot.isMade ? 100.0 : 0.0).toList();
    return _metric(
      dimension: PerformanceDimension.execution,
      values: values,
      minimum: 8,
      medium: 20,
      high: 50,
      methodologyId: 'performance.execution.outcome.v1',
    );
  }

  PerformanceMetric _decision(List<Shot> shots) {
    final values = shots
        .map((shot) => _decisionScore(shot.decision))
        .whereType<double>()
        .toList();
    return _metric(
      dimension: PerformanceDimension.decision,
      values: values,
      minimum: 4,
      medium: 8,
      high: 20,
      methodologyId: 'performance.decision.explicit_rating.v1',
    );
  }

  PerformanceMetric _cueBall(List<Shot> shots) {
    final values = shots
        .map((shot) => _positionScore(shot.positionQuality))
        .whereType<double>()
        .toList();
    return _metric(
      dimension: PerformanceDimension.cueBall,
      values: values,
      minimum: 5,
      medium: 10,
      high: 25,
      methodologyId: 'performance.cue_ball.position_rating.v1',
    );
  }

  PerformanceMetric _break(List<Rack> racks) {
    final values = racks
        .map((rack) =>
            rack.breakSuccess && !rack.breakScratch && !rack.breakFoul
                ? 100.0
                : 0.0)
        .toList();
    return _metric(
      dimension: PerformanceDimension.breakShot,
      values: values,
      minimum: 4,
      medium: 8,
      high: 20,
      methodologyId: 'performance.break.legal_success.v1',
    );
  }

  PerformanceMetric _safety(List<Shot> shots) {
    // The current recorder stores pot outcome for a safety intent, not whether
    // the safety achieved its tactical objective. Keep this unavailable until
    // a dedicated safety outcome is persisted.
    return _metric(
      dimension: PerformanceDimension.safety,
      values: const [],
      minimum: 4,
      medium: 8,
      high: 20,
      methodologyId: 'performance.safety.explicit_outcome.v1',
    );
  }

  PerformanceMetric _mental(List<PerformanceMatchSample> samples) {
    final values = samples
        .map((sample) => _mentalScore(sample.context?.mentalState))
        .whereType<double>()
        .toList();
    return _metric(
      dimension: PerformanceDimension.mental,
      values: values,
      minimum: 2,
      medium: 4,
      high: 8,
      methodologyId: 'performance.mental.self_report.v1',
    );
  }

  PerformanceMetric _consistency(List<PerformanceMatchSample> samples) {
    final matchRates = <double>[];
    for (final sample in samples) {
      final attempts = sample.shots
          .where((shot) => !_isBreak(shot) && !_isSafety(shot))
          .toList();
      if (attempts.length < 5) continue;
      final made = attempts.where((shot) => shot.isMade).length;
      matchRates.add(made / attempts.length * 100);
    }

    if (matchRates.length < 3) {
      return _metric(
        dimension: PerformanceDimension.consistency,
        values: const [],
        reportedSample: matchRates.length,
        minimum: 3,
        medium: 5,
        high: 10,
        methodologyId: 'performance.consistency.execution_sd.v1',
      );
    }

    final mean = matchRates.reduce((a, b) => a + b) / matchRates.length;
    final variance = matchRates
            .map((value) => math.pow(value - mean, 2).toDouble())
            .reduce((a, b) => a + b) /
        matchRates.length;
    final score = (100 - 2 * math.sqrt(variance)).clamp(0.0, 100.0);
    return _metric(
      dimension: PerformanceDimension.consistency,
      values: [score],
      reportedSample: matchRates.length,
      minimum: 3,
      medium: 5,
      high: 10,
      methodologyId: 'performance.consistency.execution_sd.v1',
    );
  }

  PerformanceMetric _metric({
    required PerformanceDimension dimension,
    required List<double> values,
    required int minimum,
    required int medium,
    required int high,
    required String methodologyId,
    int? reportedSample,
  }) {
    final sample = reportedSample ?? values.length;
    final confidence = sample >= high
        ? PerformanceConfidence.high
        : sample >= medium
            ? PerformanceConfidence.medium
            : sample >= minimum
                ? PerformanceConfidence.low
                : PerformanceConfidence.insufficient;
    final score = sample < minimum || values.isEmpty
        ? null
        : values.reduce((a, b) => a + b) / values.length;
    return PerformanceMetric(
      dimension: dimension,
      score: score == null ? null : _round(score),
      sampleSize: sample,
      requiredSample: minimum,
      confidence: confidence,
      methodologyId: methodologyId,
    );
  }

  bool _isBreak(Shot shot) =>
      shot.shotType == ShotTypes.breakShot || shot.intent == 'break';

  bool _isSafety(Shot shot) =>
      shot.shotType == ShotTypes.safetyShot || shot.intent == 'safety';

  double? _decisionScore(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'correct':
      case 'good':
      case 'optimal':
        return 100;
      case 'acceptable':
      case 'neutral':
        return 60;
      case 'poor':
      case 'bad':
      case 'wrong':
        return 0;
      default:
        return null;
    }
  }

  double? _positionScore(String? value) {
    switch (value) {
      case PositionQuality.perfect:
        return 100;
      case PositionQuality.good:
        return 80;
      case PositionQuality.playable:
        return 60;
      case PositionQuality.recovery:
        return 35;
      case PositionQuality.bad:
        return 0;
      default:
        return null;
    }
  }

  double? _mentalScore(String? value) {
    switch (value) {
      case MentalState.veryConfident:
        return 100;
      case MentalState.ok:
        return 80;
      case MentalState.normal:
        return 65;
      case MentalState.unsure:
        return 40;
      case MentalState.pressure:
        return 25;
      default:
        return null;
    }
  }

  double _round(double value) => (value * 10).round() / 10;
}
