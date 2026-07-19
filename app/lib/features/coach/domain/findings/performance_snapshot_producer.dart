import 'package:pool_os/features/coach/domain/findings/finding.dart';
import 'package:pool_os/features/performance/domain/performance_snapshot.dart';

/// Adapts the Performance read model into fact-only Coach findings.
List<Finding> producePerformanceFindings(PerformanceSnapshot snapshot) {
  return PerformanceDimension.values.map((dimension) {
    final metric = snapshot.metric(dimension);
    return Finding(
      metricId: dimension.metricId,
      source: FindingSource.performance,
      value: metric.score,
      sampleSize: metric.sampleSize,
      observedAt: snapshot.generatedAt,
      data: {
        'dimension': dimension.name,
        'requiredSample': metric.requiredSample,
        'confidence': metric.confidence.name,
        'coachReady': metric.isCoachReady,
        'methodologyId': metric.methodologyId,
        'snapshotVersion': snapshot.version,
      },
    );
  }).toList(growable: false);
}
