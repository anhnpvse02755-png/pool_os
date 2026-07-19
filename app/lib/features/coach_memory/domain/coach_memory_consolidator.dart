import 'package:pool_os/features/coach_memory/domain/coach_memory.dart';
import 'package:pool_os/features/mastery/domain/models/mastery_models.dart';
import 'package:pool_os/features/performance/domain/performance_snapshot.dart';

/// Converts versioned snapshots into stable evidence patterns. The output has
/// no wording, priority, route, or recommendation; those remain Brain-owned.
class CoachMemoryConsolidator {
  static const String methodologyId = 'coach_memory.pattern.v1';

  List<MemoryObservation> evaluate({
    required PerformanceSnapshot performance,
    required MasterySnapshot mastery,
  }) {
    return [
      ..._performance(performance),
      ..._mastery(mastery),
    ];
  }

  List<MemoryObservation> _performance(PerformanceSnapshot snapshot) {
    final result = <MemoryObservation>[];
    for (final dimension in PerformanceDimension.values) {
      final metric = snapshot.metric(dimension);
      if (!metric.isCoachReady || metric.score == null) continue;
      final kind = metric.score! < 60
          ? CoachMemoryKind.weakness
          : metric.score! >= 80
              ? CoachMemoryKind.strength
              : null;
      if (kind == null) continue;
      final key = 'performance.${kind.name}.${dimension.name}';
      result.add(MemoryObservation(
        memoryKey: key,
        kind: kind,
        sourceMetricId: dimension.metricId,
        latestValue: metric.score,
        sampleSize: metric.sampleSize,
        confidence: _performanceConfidence(metric.confidence),
        evidenceSignature: _signature(
          metricId: dimension.metricId,
          value: metric.score!,
          sampleSize: metric.sampleSize,
          methodology: metric.methodologyId,
        ),
      ));
    }
    return result;
  }

  List<MemoryObservation> _mastery(MasterySnapshot snapshot) {
    final result = <MemoryObservation>[];
    for (final path in snapshot.paths) {
      final entryId = path.nextEntryId;
      if (entryId == null) continue;
      final step = path.steps.where((item) => item.current).firstOrNull;
      if (step == null || step.score >= 70) continue;
      final entry = step.mastery;
      final metricId = 'mastery.entry.$entryId';
      result.add(MemoryObservation(
        memoryKey: 'mastery.learningGap.${path.path.id}',
        kind: CoachMemoryKind.learningGap,
        sourceMetricId: metricId,
        latestValue: step.score,
        sampleSize: entry.attempts + (entry.completedDepth == null ? 0 : 1),
        confidence: entry.confidence,
        evidenceSignature: _signature(
          metricId: metricId,
          value: step.score,
          sampleSize: entry.attempts,
          methodology: entry.methodologyId,
        ),
      ));
    }
    return result;
  }

  double _performanceConfidence(PerformanceConfidence confidence) =>
      switch (confidence) {
        PerformanceConfidence.insufficient => 0,
        PerformanceConfidence.low => 0.33,
        PerformanceConfidence.medium => 0.67,
        PerformanceConfidence.high => 1,
      };

  String _signature({
    required String metricId,
    required double value,
    required int sampleSize,
    required String methodology,
  }) =>
      '$methodologyId|$methodology|$metricId|${value.toStringAsFixed(1)}|$sampleSize';
}
