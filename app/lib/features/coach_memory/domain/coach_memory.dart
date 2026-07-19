enum CoachMemoryKind { weakness, strength, learningGap }

enum CoachMemoryStatus { active, resolved }

class CoachMemory {
  final int? id;
  final String memoryKey;
  final CoachMemoryKind kind;
  final String sourceMetricId;
  final double? latestValue;
  final int sampleSize;
  final double confidence;
  final int occurrenceCount;
  final String evidenceSignature;
  final CoachMemoryStatus status;
  final DateTime firstObservedAt;
  final DateTime lastObservedAt;
  final int revision;

  const CoachMemory({
    this.id,
    required this.memoryKey,
    required this.kind,
    required this.sourceMetricId,
    this.latestValue,
    required this.sampleSize,
    required this.confidence,
    required this.occurrenceCount,
    required this.evidenceSignature,
    required this.status,
    required this.firstObservedAt,
    required this.lastObservedAt,
    required this.revision,
  });
}

class MemoryObservation {
  final String memoryKey;
  final CoachMemoryKind kind;
  final String sourceMetricId;
  final double? latestValue;
  final int sampleSize;
  final double confidence;
  final String evidenceSignature;

  const MemoryObservation({
    required this.memoryKey,
    required this.kind,
    required this.sourceMetricId,
    this.latestValue,
    required this.sampleSize,
    required this.confidence,
    required this.evidenceSignature,
  });
}
