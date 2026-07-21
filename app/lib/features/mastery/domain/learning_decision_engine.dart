import 'package:billiard_knowledge/billiard_knowledge.dart';
import 'package:pool_os/contracts/stop_shot_contracts.dart';

const learningDecisionPolicyVersion = 'learning-decision/0.6.0';
const techniqueMasteryPolicyVersion = 'technique-mastery/1.1.0';
const mistakeCorrectionPolicyVersion = 'mistake-correction/1.1.0';
const mistakeLifecyclePolicyVersion = 'mistake-lifecycle/1.1.0';
const learningDependencyPolicyVersion = 'learning-dependency/1.0.0';
const unlockExpressionPolicyVersion = 'unlock-expression/1.0.0';

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
  const LearningDecisionEngine({
    this.pipeline = const PolicyDrivenLearningDecisionPipeline(),
  });

  final PolicyDrivenLearningDecisionPipeline pipeline;

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
    return pipeline.evaluateTechnique(
      pack,
      techniqueEntry,
      technique,
      evidence,
    );
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

class PolicyDrivenLearningDecisionPipeline {
  const PolicyDrivenLearningDecisionPipeline({
    this.availabilityResolver = const LearningAvailabilityResolver(),
    this.masteryPolicy = const TechniqueMasteryPolicy(),
    this.recommendationResolver = const LearningRecommendationResolver(),
    this.correctionResolver = const CorrectionResolver(),
  });

  final LearningAvailabilityResolver availabilityResolver;
  final TechniqueMasteryPolicy masteryPolicy;
  final LearningRecommendationResolver recommendationResolver;
  final CorrectionResolver correctionResolver;

  LearningEvaluation evaluateTechnique(
    ExecutableKnowledgePack pack,
    ExecutableKnowledgeEntry techniqueEntry,
    TechniquePayload technique,
    List<LearningEvidenceBatch> evidence,
  ) {
    final availability = availabilityResolver.resolve(
      pack,
      techniqueEntry,
      evidence,
    );
    final activeCorrectionCategories = _activeCorrectionCategories(
      pack,
      evidence,
    );
    final masteryResult = masteryPolicy.assess(
      pack,
      techniqueEntry,
      technique,
      evidence,
    );
    final recommendationResult = recommendationResolver.resolve(
      techniqueEntry,
      technique,
      masteryResult.mastery,
      availability,
      activeCorrectionCategories,
    );
    final correctionResult = correctionResolver.resolve(
      pack,
      techniqueEntry,
      evidence,
    );
    final candidates = <RecommendationCandidate>[
      ...recommendationResult.candidates,
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
      ...masteryResult.reasons,
      ...recommendationResult.reasons,
      ...availability.reasons,
      ...correctionResult.reasons,
      DecisionReason(
        code: DecisionReasonCodes.recommendationSelected,
        parameters: {'recommendationId': selected.id, 'score': selected.score},
        policyVersion: learningDecisionPolicyVersion,
      ),
    ];

    return LearningEvaluation(
      mastery: masteryResult.mastery,
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
}

class TechniqueMasteryPolicy {
  const TechniqueMasteryPolicy();

  TechniqueMasteryResult assess(
    ExecutableKnowledgePack pack,
    ExecutableKnowledgeEntry entry,
    TechniquePayload technique,
    List<StopShotEvidenceBatch> evidence,
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
    final mastery = MasteryAssessment(
      knowledgeId: entry.id,
      successes: successes,
      attempts: attempts,
      score: attempts == 0 ? 0 : successes / attempts * 100,
      mastered: mastered,
      evidenceCount: measurements.length,
    );
    return TechniqueMasteryResult(
      mastery: mastery,
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

class CorrectionResolver {
  const CorrectionResolver();

  CorrectionResolution resolve(
    ExecutableKnowledgePack pack,
    ExecutableKnowledgeEntry technique,
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
    return CorrectionResolution(candidates, reasons);
  }
}

enum LearningAvailabilityReasonCode {
  prerequisiteUnsatisfied,
  prerequisiteSatisfied,
  notMastered,
  policyBlocked,
}

class LearningAvailabilityResolver {
  const LearningAvailabilityResolver({
    this.masteryPolicy = const TechniqueMasteryPolicy(),
  });

  final TechniqueMasteryPolicy masteryPolicy;

  LearningAvailabilityResolution resolve(
    ExecutableKnowledgePack pack,
    ExecutableKnowledgeEntry technique,
    List<LearningEvidenceBatch> evidence,
  ) {
    final expression = technique.unlockExpression;
    if (expression != null) {
      final result = _evaluateExpression(pack, expression, evidence);
      return LearningAvailabilityResolution(
        available: result.satisfied,
        blockers: List.unmodifiable(result.blockers),
        reasons: List.unmodifiable(result.reasons),
      );
    }
    final dependencyIds = [...technique.dependencies]..sort();
    final blockers = <LearningAvailabilityBlocker>[];
    final reasons = <DecisionReason>[];
    for (final dependencyId in dependencyIds) {
      final result = _evaluateDependency(pack, dependencyId, evidence);
      reasons.add(result.reason);
      if (result.blocker != null) blockers.add(result.blocker!);
    }
    return LearningAvailabilityResolution(
      available: blockers.isEmpty,
      blockers: List.unmodifiable(blockers),
      reasons: List.unmodifiable(reasons),
    );
  }

  _AvailabilityNodeEvaluation _evaluateExpression(
    ExecutableKnowledgePack pack,
    UnlockExpression expression,
    List<LearningEvidenceBatch> evidence,
  ) {
    return switch (expression) {
      UnlockDependencyExpression value => () {
          final dependency = _evaluateDependency(
            pack,
            value.dependencyId,
            evidence,
            expressionNodeId: value.nodeId,
          );
          return _AvailabilityNodeEvaluation(
            nodeId: value.nodeId,
            satisfied: dependency.blocker == null,
            blockers: [if (dependency.blocker != null) dependency.blocker!],
            reasons: [dependency.reason],
          );
        }(),
      UnlockAllOfExpression value => () {
          final children = value.children
              .map((child) => _evaluateExpression(pack, child, evidence))
              .toList(growable: false);
          final failed = children
              .where((child) => !child.satisfied)
              .map((child) => child.nodeId)
              .toList(growable: false);
          return _AvailabilityNodeEvaluation(
            nodeId: value.nodeId,
            satisfied: failed.isEmpty,
            blockers: [for (final child in children) ...child.blockers],
            reasons: [
              for (final child in children) ...child.reasons,
              DecisionReason(
                code: failed.isEmpty
                    ? DecisionReasonCodes.unlockExpressionSatisfied
                    : DecisionReasonCodes.unlockExpressionUnsatisfied,
                parameters: {
                  'expressionNodeId': value.nodeId,
                  'operator': 'allOf',
                  'failedChildNodeIds': failed,
                },
                policyVersion: unlockExpressionPolicyVersion,
              ),
            ],
          );
        }(),
    };
  }

  _DependencyAvailabilityEvaluation _evaluateDependency(
    ExecutableKnowledgePack pack,
    String dependencyId,
    List<LearningEvidenceBatch> evidence, {
    String? expressionNodeId,
  }) {
    final dependency = pack.byId(dependencyId);
    if (dependency == null ||
        dependency.payload is! TechniquePayload ||
        !dependency.capabilities.contains('mastery_policy')) {
      throw ExecutableKnowledgeException(
        '$dependencyId does not resolve to a measurable deterministic '
        'Technique.',
      );
    }
    final dependencyPayload = dependency.payload as TechniquePayload;
    final dependencyPolicy = pack.masteryPolicy(
      dependencyPayload.masteryCategory,
    );
    if (dependencyPolicy.evaluation != MasteryEvaluation.deterministic) {
      throw ExecutableKnowledgeException(
        '$dependencyId does not resolve to a measurable deterministic '
        'Technique.',
      );
    }
    final evaluation = masteryPolicy.assess(
      pack,
      dependency,
      dependencyPayload,
      evidence,
    );
    final mastered = evaluation.mastery.mastered;
    return _DependencyAvailabilityEvaluation(
      blocker: mastered
          ? null
          : LearningAvailabilityBlocker(
              entryId: dependency.id,
              title: dependency.title,
              reasonCode: LearningAvailabilityReasonCode.notMastered,
            ),
      reason: DecisionReason(
        code: mastered
            ? DecisionReasonCodes.prerequisiteSatisfied
            : DecisionReasonCodes.prerequisiteUnsatisfied,
        parameters: {
          'dependencyId': dependencyId,
          if (expressionNodeId != null) 'expressionNodeId': expressionNodeId,
          'evidence': {
            'successes': evaluation.mastery.successes,
            'attempts': evaluation.mastery.attempts,
            'mastered': mastered,
            'evidenceCount': evaluation.mastery.evidenceCount,
          },
        },
        policyVersion: expressionNodeId == null
            ? learningDependencyPolicyVersion
            : unlockExpressionPolicyVersion,
      ),
    );
  }
}

class LearningRecommendationResolver {
  const LearningRecommendationResolver();

  RecommendationResolution resolve(
    ExecutableKnowledgeEntry entry,
    TechniquePayload technique,
    MasteryAssessment mastery,
    LearningAvailabilityResolution availability,
    Set<MasteryCategory> activeCorrectionCategories,
  ) {
    final blockedCategory =
        technique.nextRecommendation.blockedByActiveCorrectionCategory;
    final policyBlocked = blockedCategory != null &&
        activeCorrectionCategories.contains(blockedCategory);
    final candidates = <RecommendationCandidate>[
      RecommendationCandidate(
        id: entry.id,
        title: entry.title,
        score: mastery.mastered ? 40 : 100,
        available: availability.available,
      ),
      RecommendationCandidate(
        id: technique.nextRecommendation.id,
        title: technique.nextRecommendation.title,
        score: mastery.mastered ? 100 : 0,
        available: availability.available && mastery.mastered && !policyBlocked,
      ),
      for (final blocker in availability.blockers)
        RecommendationCandidate(
          id: blocker.entryId,
          title: blocker.title,
          score: 110,
          available: true,
        ),
    ];
    return RecommendationResolution(
      candidates: List.unmodifiable(candidates),
      reasons: [
        if (policyBlocked)
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

class TechniqueMasteryResult {
  const TechniqueMasteryResult({
    required this.mastery,
    required this.reasons,
  });

  final MasteryAssessment mastery;
  final List<DecisionReason> reasons;
}

class RecommendationResolution {
  const RecommendationResolution({
    required this.candidates,
    required this.reasons,
  });

  final List<RecommendationCandidate> candidates;
  final List<DecisionReason> reasons;
}

class CorrectionResolution {
  const CorrectionResolution(this.candidates, this.reasons);

  final List<RecommendationCandidate> candidates;
  final List<DecisionReason> reasons;
}

class LearningAvailabilityBlocker {
  const LearningAvailabilityBlocker({
    required this.entryId,
    required this.title,
    required this.reasonCode,
  });

  final String entryId;
  final String title;
  final LearningAvailabilityReasonCode reasonCode;
}

class LearningAvailabilityResolution {
  const LearningAvailabilityResolution({
    required this.available,
    required this.blockers,
    required this.reasons,
  });

  final bool available;
  final List<LearningAvailabilityBlocker> blockers;
  final List<DecisionReason> reasons;
}

class _DependencyAvailabilityEvaluation {
  const _DependencyAvailabilityEvaluation({
    required this.blocker,
    required this.reason,
  });

  final LearningAvailabilityBlocker? blocker;
  final DecisionReason reason;
}

class _AvailabilityNodeEvaluation {
  const _AvailabilityNodeEvaluation({
    required this.nodeId,
    required this.satisfied,
    required this.blockers,
    required this.reasons,
  });

  final String nodeId;
  final bool satisfied;
  final List<LearningAvailabilityBlocker> blockers;
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
