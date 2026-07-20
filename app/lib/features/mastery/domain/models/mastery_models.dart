import 'package:billiard_knowledge/billiard_knowledge.dart';

class LearningEvidence {
  final int? id;
  final String entryId;
  final String eventType;
  final ExplanationDepth? depth;
  final String packVersion;
  final String source;
  final DateTime occurredAt;

  const LearningEvidence({
    this.id,
    required this.entryId,
    required this.eventType,
    this.depth,
    required this.packVersion,
    this.source = 'user',
    required this.occurredAt,
  });
}

class LearningEventType {
  static const String depthCompleted = 'depth_completed';
}

enum MasteryStage {
  notStarted,
  learning,
  practicing,
  developing,
  reliable,
  mastered,
}

class EntryMastery {
  final String entryId;
  final MasteryStage stage;
  final double score;
  final double confidence;
  final ExplanationDepth requiredDepth;
  final ExplanationDepth? completedDepth;
  final bool practiceRequired;
  final int attempts;
  final int successes;
  final int practiceRuns;
  final int qualifyingRuns;
  final DateTime? lastEvidenceAt;
  final String methodologyId;

  const EntryMastery({
    required this.entryId,
    required this.stage,
    required this.score,
    required this.confidence,
    required this.requiredDepth,
    this.completedDepth,
    required this.practiceRequired,
    required this.attempts,
    required this.successes,
    required this.practiceRuns,
    required this.qualifyingRuns,
    this.lastEvidenceAt,
    required this.methodologyId,
  });

  double get successRate => attempts == 0 ? 0 : successes / attempts;
  bool get isReliable =>
      stage == MasteryStage.reliable || stage == MasteryStage.mastered;
}

class LearningStepMastery {
  final LearningStep step;
  final EntryMastery mastery;
  final double score;
  final bool complete;
  final bool locked;
  final bool current;

  const LearningStepMastery({
    required this.step,
    required this.mastery,
    required this.score,
    required this.complete,
    required this.locked,
    required this.current,
  });

  bool get depthComplete {
    final completed = mastery.completedDepth;
    return completed != null && completed.index >= step.minimumDepth.index;
  }
}

class LearningPathMastery {
  final LearningPath path;
  final List<LearningStepMastery> steps;
  final double score;
  final int completedSteps;
  final String? nextEntryId;

  const LearningPathMastery({
    required this.path,
    required this.steps,
    required this.score,
    required this.completedSteps,
    this.nextEntryId,
  });

  bool get isComplete => completedSteps == steps.length && steps.isNotEmpty;
}

class MasterySnapshot {
  static const int currentVersion = 1;

  final int version;
  final DateTime generatedAt;
  final Map<String, EntryMastery> entries;
  final List<LearningPathMastery> paths;

  const MasterySnapshot({
    this.version = currentVersion,
    required this.generatedAt,
    required this.entries,
    required this.paths,
  });

  EntryMastery? entry(String entryId) => entries[entryId];
}
