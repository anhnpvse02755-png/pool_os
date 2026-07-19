import 'package:pool_os/features/coach/domain/findings/finding.dart';
import 'package:pool_os/features/coach_memory/domain/coach_memory.dart';

List<Finding> produceCoachMemoryFindings(List<CoachMemory> memories) {
  return memories
      .where((memory) => memory.status == CoachMemoryStatus.active)
      .map((memory) => Finding(
            metricId: memory.sourceMetricId,
            source: FindingSource.memory,
            value: memory.latestValue,
            sampleSize: memory.sampleSize,
            observedAt: memory.lastObservedAt,
            data: {
              'memoryKey': memory.memoryKey,
              'kind': memory.kind.name,
              'confidence': memory.confidence,
              'occurrences': memory.occurrenceCount,
              'firstObservedAt': memory.firstObservedAt.toIso8601String(),
              'revision': memory.revision,
            },
          ))
      .toList(growable: false);
}
