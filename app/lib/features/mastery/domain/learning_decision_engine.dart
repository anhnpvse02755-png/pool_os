import 'package:billiard_knowledge/billiard_knowledge.dart';
import 'package:pool_os/contracts/stop_shot_contracts.dart';

const learningDecisionPolicyVersion = 'learning-decision/0.6.0';
const techniqueMasteryPolicyVersion = 'technique-mastery/1.1.0';
const mistakeCorrectionPolicyVersion = 'mistake-correction/1.1.0';
const mistakeLifecyclePolicyVersion = 'mistake-lifecycle/1.1.0';

sealed class LearningEntryEvaluation {
  const LearningEntryEvaluation();

  DecisionRecord get decision;
}

class LearningEvaluation extends LearningEntryEvaluation {
  const LearningEvaluation({required this.mastery, required this.decision});

  final MasteryAssessment mastery;
  @override
  final DecisionRecord decision;
}

class LearningDecisionEngine {
  const LearningDecisionEngine();

  LearningEntryEvaluation evaluateEntry(
    ExecutableKnowledgePack pack,
    ExecutableKnowledgeEntry entry,
    List<LearningEvidenceBatch> evidence,
  ) {
    final payload = entry.payload;
    if (payload is TechniquePayload &&
        entry.capabilities.contains('mastery_policy')) {
      return evaluate(pack, entry, payload, evidence);
    }
    if (payload is MistakePayload &&
        entry.capabilities.contains('correction_policy')) {
      return evaluateMistake(pack, entry, payload, evidence);
    }
    throw ExecutableKnowledgeException(
      '${entry.id} does not resolve to a supported versioned learning policy.',
    );
  }

  LearningEvaluation evaluate(
    ExecutableKnowledgePack pack,
    ExecutableKnowledgeEntry techniqueEntry,
    TechniquePayload technique,
    List<StopShotEvidenceBatch> evidence,
  ) {
    final activeCorrectionCategories = _activeCorrectionCategories(
      pack,
      evidence,
    );
    final techniqueResult = const TechniqueMasteryPolicy().evaluate(
      pack,
      techniqueEntry,
      technique,
      evidence,
      activeCorrectionCategories,
    );
    final correctionResult = const MistakeCorrectionPolicy().evaluate(
      pack,
      techniqueEntry,
      techniqueResult.mastery,
      evidence,
    );
    final candidates = <RecommendationCandidate>[
      ...techniqueResult.candidates,
      ...correctionResult.candidates,
    ]..sort(_compareRecommendationCandidates);
    final selected = candidates.firstWhere((candidate) => candidate.available);
    final relevantEvidence = evidence
        .where((batch) =>
            batch.attempt?.knowledgeId == techniqueEntry.id &&
            batch.measurement != null)
        .toList();
    final latest = relevantEvidence.isEmpty ? null : relevantEvidence.last;
    final reasons = <DecisionReason>[
      ...techniqueResult.reasons,
      ...correctionResult.reasons,
      DecisionReason(
        code: DecisionReasonCodes.recommendationSelected,
        parameters: {'recommendationId': selected.id, 'score': selected.score},
        policyVersion: learningDecisionPolicyVersion,
      ),
    ];

    return LearningEvaluation(
      mastery: techniqueResult.mastery,
      decision: DecisionRecord(
        id: latest == null
            ? 'decision.initial'
            : 'decision.${latest.commandId}',
        createdAt: latest?.measurement?.occurredAt ?? pack.generatedAt,
        recommendations: RecommendationSet(
          selected: selected,
          alternatives: candidates
              .where((candidate) => candidate.id != selected.id)
              .toList(growable: false),
        ),
        trace: reasons,
        knowledgeVersion: pack.knowledgeVersion,
        knowledgeDigest: pack.contentDigest,
        policyVersion: learningDecisionPolicyVersion,
      ),
    );
  }

  Set<MasteryCategory> _activeCorrectionCategories(
    ExecutableKnowledgePack pack,
    List<LearningEvidenceBatch> evidence,
  ) {
    final active = <MasteryCategory>{};
    for (final entry in pack.entries) {
      final payload = entry.payload;
      if (payload is! MistakePayload) continue;
      final assessment = const MistakeLifecyclePolicy().assess(
        entry,
        payload,
        evidence,
      );
      if (assessment.state == MistakeLifecycleState.persistent) {
        active.add(payload.masteryCategory);
      }
    }
    return active;
  }

  MistakeEvaluation evaluateMistake(
    ExecutableKnowledgePack pack,
    ExecutableKnowledgeEntry mistakeEntry,
    MistakePayload mistake,
    List<LearningEvidenceBatch> evidence,
  ) {
    return const MistakeLifecyclePolicy().evaluate(
      pack,
      mistakeEntry,
      mistake,
      evidence,
    );
  }
}

class TechniqueMasteryPolicy {
  const TechniqueMasteryPolicy();

  TechniquePolicyResult evaluate(
    ExecutableKnowledgePack pack,
    ExecutableKnowledgeEntry entry,
    TechniquePayload technique,
    List<StopShotEvidenceBatch> evidence,
    Set<MasteryCategory> activeCorrectionCategories,
  ) {
    final measurements = evidence
        .where((batch) =>
            batch.attempt?.knowledgeId == entry.id && batch.measurement != null)
        .map((batch) => batch.measurement!)
        .toList()
      ..sort((a, b) => a.occurredAt.compareTo(b.occurredAt));
    final latest = measurements.isEmpty ? null : measurements.last;
    final successes = latest?.successes ?? 0;
    final attempts = latest?.attempts ?? technique.measurement.attempts;
    final policy = pack.masteryPolicy(technique.masteryCategory);
    final requiredSuccesses = policy.requiredSuccessesFor(attempts);
    final mastered = successes >= requiredSuccesses &&
        attempts == technique.measurement.attempts;
    final blockedCategory =
        technique.nextRecommendation.blockedByActiveCorrectionCategory;
    final blocked = blockedCategory != null &&
        activeCorrectionCategories.contains(blockedCategory);
    final mastery = MasteryAssessment(
      knowledgeId: entry.id,
      successes: successes,
      attempts: attempts,
      score: attempts == 0 ? 0 : successes / attempts * 100,
      mastered: mastered,
      evidenceCount: measurements.length,
    );
    final current = RecommendationCandidate(
      id: entry.id,
      title: entry.title,
      score: mastered ? 40 : 100,
      available: true,
    );
    final next = RecommendationCandidate(
      id: technique.nextRecommendation.id,
      title: technique.nextRecommendation.title,
      score: mastered ? 100 : 0,
      available: mastered && !blocked,
    );
    return TechniquePolicyResult(
      mastery: mastery,
      candidates: [current, next],
      reasons: [
        DecisionReason(
          code: DecisionReasonCodes.outcomeMeasured,
          parameters: {'successes': successes, 'attempts': attempts},
          policyVersion: techniqueMasteryPolicyVersion,
        ),
        DecisionReason(
          code: mastered
              ? DecisionReasonCodes.outcomeAchieved
              : DecisionReasonCodes.belowMasteryThreshold,
          parameters: {
            'requiredSuccesses': requiredSuccesses,
            'requiredAttempts': technique.measurement.attempts,
            'masteryCategory': technique.masteryCategory.name,
            'masteryPolicyVersion': pack.masteryPolicyVersion,
          },
          policyVersion: techniqueMasteryPolicyVersion,
        ),
        if (blocked)
          DecisionReason(
            code: DecisionReasonCodes.activeCorrectionBlocksUnlock,
            parameters: {
              'category': blockedCategory.name,
              'recommendationId': technique.nextRecommendation.id,
            },
            policyVersion: techniqueMasteryPolicyVersion,
          ),
      ],
    );
  }
}

enum MistakeLifecycleState { unobserved, persistent, resolved }

class MistakeAssessment {
  const MistakeAssessment({
    required this.mistakeId,
    required this.state,
    required this.observationCount,
    required this.confidence,
    required this.cleanObservationStreak,
    this.lastObservedAt,
  });

  final String mistakeId;
  final MistakeLifecycleState state;
  final int observationCount;
  final double confidence;
  final int cleanObservationStreak;
  final DateTime? lastObservedAt;
}

class MistakeEvaluation extends LearningEntryEvaluation {
  const MistakeEvaluation({required this.assessment, required this.decision});

  final MistakeAssessment assessment;
  @override
  final DecisionRecord decision;
}

class MistakeLifecyclePolicy {
  const MistakeLifecyclePolicy();

  MistakeEvaluation evaluate(
    ExecutableKnowledgePack pack,
    ExecutableKnowledgeEntry entry,
    MistakePayload mistake,
    List<LearningEvidenceBatch> evidence,
  ) {
    final assessment = assess(entry, mistake, evidence);
    final observations = _observations(entry, evidence);
    final latest = observations.isEmpty ? null : observations.last;
    final state = assessment.state;
    final correction = RecommendationCandidate(
      id: entry.id,
      title: mistake.correction,
      score: state == MistakeLifecycleState.persistent ? 100 : 0,
      available: state == MistakeLifecycleState.persistent,
    );
    const noCorrection = RecommendationCandidate(
      id: 'status.no_correction_required',
      title: 'Không cần correction lúc này',
      score: 100,
      available: true,
    );
    final selected =
        state == MistakeLifecycleState.persistent ? correction : noCorrection;
    final stateReason = switch (state) {
      MistakeLifecycleState.unobserved => DecisionReasonCodes.mistakeObserved,
      MistakeLifecycleState.persistent => DecisionReasonCodes.mistakePersistent,
      MistakeLifecycleState.resolved => DecisionReasonCodes.mistakeResolved,
    };
    return MistakeEvaluation(
      assessment: assessment,
      decision: DecisionRecord(
        id: latest == null
            ? 'decision.mistake.initial.${entry.id}'
            : 'decision.${latest.commandId}',
        createdAt: latest?.capturedAt ?? pack.generatedAt,
        recommendations: RecommendationSet(
          selected: selected,
          alternatives: selected.id == correction.id
              ? const [noCorrection]
              : [correction],
        ),
        trace: [
          DecisionReason(
            code: stateReason,
            parameters: {
              'mistakeId': entry.id,
              'observationCount': observations.length,
              'confidence': assessment.confidence,
              'cleanObservationStreak': assessment.cleanObservationStreak,
              'requiredConsecutiveClean':
                  mistake.resolutionPolicy.requiredConsecutiveClean,
            },
            policyVersion: mistakeLifecyclePolicyVersion,
          ),
          DecisionReason(
            code: DecisionReasonCodes.recommendationSelected,
            parameters: {'recommendationId': selected.id},
            policyVersion: mistakeLifecyclePolicyVersion,
          ),
        ],
        knowledgeVersion: pack.knowledgeVersion,
        knowledgeDigest: pack.contentDigest,
        policyVersion: mistakeLifecyclePolicyVersion,
      ),
    );
  }

  MistakeAssessment assess(
    ExecutableKnowledgeEntry entry,
    MistakePayload mistake,
    List<LearningEvidenceBatch> evidence,
  ) {
    final observations = _observations(entry, evidence);
    final latest = observations.isEmpty ? null : observations.last;
    final lastDetected = observations.lastIndexWhere(
      (observation) => observation.observationType == 'mistake.detected',
    );
    var cleanStreak = 0;
    if (lastDetected >= 0) {
      for (var index = lastDetected + 1; index < observations.length; index++) {
        if (observations[index].observationType != 'mistake.resolved') break;
        cleanStreak++;
      }
    }
    final state = lastDetected < 0
        ? MistakeLifecycleState.unobserved
        : cleanStreak >= mistake.resolutionPolicy.requiredConsecutiveClean
            ? MistakeLifecycleState.resolved
            : MistakeLifecycleState.persistent;
    return MistakeAssessment(
      mistakeId: entry.id,
      state: state,
      observationCount: observations.length,
      confidence: latest?.confidence ?? 0,
      cleanObservationStreak: cleanStreak,
      lastObservedAt: latest?.capturedAt,
    );
  }

  List<ObservationRecorded> _observations(
    ExecutableKnowledgeEntry entry,
    List<LearningEvidenceBatch> evidence,
  ) {
    return evidence
        .map((batch) => batch.observation)
        .whereType<ObservationRecorded>()
        .where((observation) =>
            observation.subjectId == entry.id &&
            (observation.observationType == 'mistake.detected' ||
                observation.observationType == 'mistake.resolved'))
        .toList()
      ..sort((a, b) => a.capturedAt.compareTo(b.capturedAt));
  }
}

class MistakeCorrectionPolicy {
  const MistakeCorrectionPolicy();

  CorrectionPolicyResult evaluate(
    ExecutableKnowledgePack pack,
    ExecutableKnowledgeEntry technique,
    MasteryAssessment mastery,
    List<LearningEvidenceBatch> evidence,
  ) {
    final relatedMistakes = pack.entries.where(
      (entry) =>
          entry.payload is MistakePayload &&
          entry.capabilities.contains('correction_policy') &&
          entry.relations.contains(technique.id) &&
          const MistakeLifecyclePolicy()
                  .assess(
                    entry,
                    entry.payload as MistakePayload,
                    evidence,
                  )
                  .state ==
              MistakeLifecycleState.persistent,
    );
    final candidates = [
      for (final mistake in relatedMistakes)
        RecommendationCandidate(
          id: mistake.id,
          title: mistake.title,
          score: 75,
          available: true,
        ),
    ];
    final reasons = [
      for (final candidate in candidates)
        DecisionReason(
          code: DecisionReasonCodes.correctionCandidate,
          parameters: {
            'recommendationId': candidate.id,
            'relatedTechniqueId': technique.id,
          },
          policyVersion: mistakeCorrectionPolicyVersion,
        ),
    ];
    return CorrectionPolicyResult(candidates, reasons);
  }
}

class TechniquePolicyResult {
  const TechniquePolicyResult({
    required this.mastery,
    required this.candidates,
    required this.reasons,
  });

  final MasteryAssessment mastery;
  final List<RecommendationCandidate> candidates;
  final List<DecisionReason> reasons;
}

class CorrectionPolicyResult {
  const CorrectionPolicyResult(this.candidates, this.reasons);

  final List<RecommendationCandidate> candidates;
  final List<DecisionReason> reasons;
}

int _compareRecommendationCandidates(
  RecommendationCandidate left,
  RecommendationCandidate right,
) {
  final byPolicyScore = right.score.compareTo(left.score);
  if (byPolicyScore != 0) return byPolicyScore;
  return left.id.compareTo(right.id);
}
