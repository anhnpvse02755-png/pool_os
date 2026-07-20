import 'dart:math' as math;

import 'package:billiard_knowledge/billiard_knowledge.dart';
import 'package:pool_os/features/mastery/domain/models/mastery_models.dart';
import 'package:pool_os/features/training_center/domain/models/training_center_models.dart';

/// Derives Mastery from immutable evidence. No score is persisted, so a future
/// methodology can rebuild the complete state without rewriting user history.
class MasteryEngine {
  static const String methodologyId = 'mastery.evidence.v1';
  static const int requiredAttempts = 25;
  static const int qualifyingRunAttempts = 10;

  MasterySnapshot build({
    required KnowledgeCatalog catalog,
    required List<LearningEvidence> learningEvidence,
    required List<DrillRun> drillRuns,
    DateTime? now,
  }) {
    final requirements = _requirements(catalog);
    final uniqueLegacyDrills = _uniqueLegacyDrills(catalog);
    final entries = <String, EntryMastery>{};
    for (final entry in catalog.entries) {
      entries[entry.id] = _entryMastery(
        entry: entry,
        requiredDepth: requirements[entry.id] ?? ExplanationDepth.result,
        evidence: learningEvidence
            .where((item) => item.entryId == entry.id)
            .toList(growable: false),
        runs: _runsForEntry(entry, drillRuns, uniqueLegacyDrills),
      );
    }

    final paths = catalog.paths
        .map((path) => _pathMastery(path, entries))
        .toList(growable: false)
      ..sort((a, b) {
        final byLevel = a.path.level.index.compareTo(b.path.level.index);
        if (byLevel != 0) return byLevel;
        return catalog.paths
            .indexOf(a.path)
            .compareTo(catalog.paths.indexOf(b.path));
      });

    return MasterySnapshot(
      generatedAt: now ?? DateTime.now(),
      entries: Map.unmodifiable(entries),
      paths: List.unmodifiable(paths),
    );
  }

  Set<String> _uniqueLegacyDrills(KnowledgeCatalog catalog) {
    final counts = <String, int>{};
    for (final entry in catalog.entries) {
      for (final drillRef in entry.drillRefs.toSet()) {
        counts.update(drillRef, (count) => count + 1, ifAbsent: () => 1);
      }
    }
    return counts.entries
        .where((item) => item.value == 1)
        .map((item) => item.key)
        .toSet();
  }

  Map<String, ExplanationDepth> _requirements(KnowledgeCatalog catalog) {
    final result = <String, ExplanationDepth>{};
    for (final path in catalog.paths) {
      for (final step in path.steps) {
        final current = result[step.entryId];
        if (current == null || step.minimumDepth.index < current.index) {
          result[step.entryId] = step.minimumDepth;
        }
      }
    }
    return result;
  }

  List<DrillRun> _runsForEntry(
    KnowledgeEntry entry,
    List<DrillRun> runs,
    Set<String> uniqueLegacyDrills,
  ) {
    return runs.where((run) {
      if (run.knowledgeEntryId == entry.id) return true;
      // Legacy fallback is intentionally exact-code only. Category refs are
      // ambiguous and must not grant Mastery to several unrelated lessons.
      return run.knowledgeEntryId == null &&
          run.drillCode != null &&
          uniqueLegacyDrills.contains(run.drillCode) &&
          entry.drillRefs.contains(run.drillCode);
    }).toList(growable: false)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  EntryMastery _entryMastery({
    required KnowledgeEntry entry,
    required ExplanationDepth requiredDepth,
    required List<LearningEvidence> evidence,
    required List<DrillRun> runs,
  }) {
    final completedDepth = _deepestCompleted(evidence);
    final theoryComplete =
        completedDepth != null && completedDepth.index >= requiredDepth.index;
    final practiceRequired = _requiresPractice(entry);
    final attempts = runs.fold<int>(0, (sum, run) => sum + run.attempts);
    final successes = runs.fold<int>(0, (sum, run) => sum + run.successes);
    final rate = attempts == 0 ? 0.0 : successes / attempts;
    final qualifying = runs
        .where((run) => run.attempts >= qualifyingRunAttempts)
        .toList(growable: false);

    double score;
    if (!practiceRequired) {
      score = theoryComplete ? 100 : 0;
    } else {
      final theoryPoints = theoryComplete ? 20.0 : 0.0;
      final volumePoints = 20 * (attempts / requiredAttempts).clamp(0.0, 1.0);
      final accuracyEvidence =
          (attempts / qualifyingRunAttempts).clamp(0.0, 1.0);
      final accuracyPoints = 40 * rate * accuracyEvidence;
      final consistencyPoints = _consistencyPoints(qualifying);
      score = theoryPoints + volumePoints + accuracyPoints + consistencyPoints;
    }
    score = _round(score.clamp(0.0, 100.0));

    final stage = _stage(
      score: score,
      theoryComplete: theoryComplete,
      practiceRequired: practiceRequired,
      attempts: attempts,
      qualifyingRuns: qualifying,
    );
    final confidence = practiceRequired
        ? _round((0.7 * (attempts / 50).clamp(0.0, 1.0) +
                0.3 * (qualifying.length / 3).clamp(0.0, 1.0))
            .clamp(0.0, 1.0))
        : (theoryComplete ? 1.0 : 0.0);

    final dates = <DateTime>[
      ...evidence.map((item) => item.occurredAt),
      ...runs.map((run) => run.createdAt),
    ]..sort();

    return EntryMastery(
      entryId: entry.id,
      stage: stage,
      score: score,
      confidence: confidence,
      requiredDepth: requiredDepth,
      completedDepth: completedDepth,
      practiceRequired: practiceRequired,
      attempts: attempts,
      successes: successes,
      practiceRuns: runs.length,
      qualifyingRuns: qualifying.length,
      lastEvidenceAt: dates.isEmpty ? null : dates.last,
      methodologyId: methodologyId,
    );
  }

  bool _requiresPractice(KnowledgeEntry entry) => switch (entry.kind) {
        KnowledgeKind.technique ||
        KnowledgeKind.commonMistake ||
        KnowledgeKind.strategy ||
        KnowledgeKind.mental =>
          true,
        _ => false,
      };

  ExplanationDepth? _deepestCompleted(List<LearningEvidence> evidence) {
    ExplanationDepth? deepest;
    for (final item in evidence) {
      if (item.eventType != LearningEventType.depthCompleted ||
          item.depth == null) {
        continue;
      }
      if (deepest == null || item.depth!.index > deepest.index) {
        deepest = item.depth;
      }
    }
    return deepest;
  }

  double _consistencyPoints(List<DrillRun> qualifying) {
    if (qualifying.isEmpty) return 0;
    final recent = qualifying.length <= 3
        ? qualifying
        : qualifying.sublist(qualifying.length - 3);
    final rates = recent.map((run) => run.successRate).toList(growable: false);
    final mean = rates.reduce((a, b) => a + b) / rates.length;
    final variance = rates
            .map((value) => math.pow(value - mean, 2).toDouble())
            .reduce((a, b) => a + b) /
        rates.length;
    final stability = (mean - math.sqrt(variance)).clamp(0.0, 1.0);
    final coverage = (recent.length / 3).clamp(0.0, 1.0);
    return 20 * stability * coverage;
  }

  MasteryStage _stage({
    required double score,
    required bool theoryComplete,
    required bool practiceRequired,
    required int attempts,
    required List<DrillRun> qualifyingRuns,
  }) {
    if (!theoryComplete && attempts == 0) return MasteryStage.notStarted;
    if (!theoryComplete) return MasteryStage.learning;
    if (!practiceRequired) return MasteryStage.mastered;
    if (attempts < requiredAttempts) return MasteryStage.practicing;

    final recent = qualifyingRuns.length <= 3
        ? qualifyingRuns
        : qualifyingRuns.sublist(qualifyingRuns.length - 3);
    final allRecentReliable =
        recent.isNotEmpty && recent.every((run) => run.successRate >= 0.75);
    if (score >= 85 && recent.length >= 3 && allRecentReliable) {
      return MasteryStage.mastered;
    }
    if (score >= 70 && recent.length >= 2 && allRecentReliable) {
      return MasteryStage.reliable;
    }
    return score >= 50 ? MasteryStage.developing : MasteryStage.practicing;
  }

  LearningPathMastery _pathMastery(
    LearningPath path,
    Map<String, EntryMastery> entries,
  ) {
    var completed = 0;
    String? nextEntryId;
    final steps = <LearningStepMastery>[];
    var priorComplete = true;
    for (final step in path.steps) {
      final mastery = entries[step.entryId]!;
      final completedDepth = mastery.completedDepth;
      final depthSatisfied = completedDepth != null &&
          completedDepth.index >= step.minimumDepth.index;
      final practiceSatisfied = mastery.practiceRequired
          ? mastery.isReliable
          : mastery.stage == MasteryStage.mastered;
      final passed = depthSatisfied && practiceSatisfied;
      final stepScore = depthSatisfied
          ? mastery.score
          : mastery.practiceRequired
              ? math.max(0, mastery.score - 20).toDouble()
              : 0.0;
      final current = priorComplete && !passed && nextEntryId == null;
      if (current) nextEntryId = step.entryId;
      steps.add(LearningStepMastery(
        step: step,
        mastery: mastery,
        score: _round(stepScore),
        complete: passed,
        locked: !priorComplete,
        current: current,
      ));
      if (passed) completed++;
      priorComplete = priorComplete && passed;
    }
    final score = steps.isEmpty
        ? 0.0
        : steps.fold<double>(0, (sum, step) => sum + step.score) / steps.length;
    return LearningPathMastery(
      path: path,
      steps: List.unmodifiable(steps),
      score: _round(score),
      completedSteps: completed,
      nextEntryId: nextEntryId,
    );
  }

  double _round(double value) => (value * 10).round() / 10;
}
