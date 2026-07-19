enum PerformanceDimension {
  execution,
  decision,
  cueBall,
  breakShot,
  safety,
  mental,
  consistency,
}

extension PerformanceDimensionX on PerformanceDimension {
  String get metricId => 'performance.$name';
}

enum PerformanceConfidence { insufficient, low, medium, high }

/// One measured competition-performance fact. A missing score is deliberate:
/// it means the recording pipeline does not yet contain enough valid evidence.
class PerformanceMetric {
  final PerformanceDimension dimension;
  final double? score;
  final int sampleSize;
  final int requiredSample;
  final PerformanceConfidence confidence;
  final String methodologyId;

  const PerformanceMetric({
    required this.dimension,
    required this.score,
    required this.sampleSize,
    required this.requiredSample,
    required this.confidence,
    required this.methodologyId,
  });

  bool get hasScore => score != null;
  bool get isCoachReady =>
      confidence == PerformanceConfidence.medium ||
      confidence == PerformanceConfidence.high;
}

/// Read-only, versioned datasource for Coach. It contains measurements only;
/// it never decides what the player should do next.
class PerformanceSnapshot {
  static const int currentVersion = 1;

  final int version;
  final DateTime generatedAt;
  final int sourceMatches;
  final int sourceRacks;
  final int sourceShots;
  final Map<PerformanceDimension, PerformanceMetric> metrics;

  const PerformanceSnapshot({
    this.version = currentVersion,
    required this.generatedAt,
    required this.sourceMatches,
    required this.sourceRacks,
    required this.sourceShots,
    required this.metrics,
  });

  PerformanceMetric metric(PerformanceDimension dimension) =>
      metrics[dimension] ??
      PerformanceMetric(
        dimension: dimension,
        score: null,
        sampleSize: 0,
        requiredSample: 1,
        confidence: PerformanceConfidence.insufficient,
        methodologyId: 'performance.unavailable.v1',
      );
}
