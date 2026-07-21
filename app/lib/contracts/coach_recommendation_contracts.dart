import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/coach_context_contracts.dart';
import 'package:pool_os/contracts/coach_decision_lifecycle_contracts.dart';
import 'package:pool_os/contracts/coach_plan_contracts.dart';
import 'package:pool_os/contracts/learning_eligibility_contracts.dart';

const coachRecommendationContractVersion = 1;
const coachRecommendationPolicyVersion = 'coach-recommendation/1.0.0';

enum CoachRecommendationKind {
  continueActiveDecision,
  practiceTechnique,
  correctMistake,
}

enum CoachRecommendationReasonCode {
  activeDecisionMustContinue,
  resolvedLearningEligibility,
  persistentMistakeRequiresCorrection,
}

class CoachRecommendationVersionBinding {
  const CoachRecommendationVersionBinding({
    required this.contextContractVersion,
    required this.contextDigest,
    required this.historyProjectionVersion,
    required this.historyDigest,
    required this.planContractVersion,
    required this.planDigest,
    required this.eligibilityProjectionVersion,
    required this.eligibilityDigest,
    required this.knowledgeVersion,
    required this.knowledgeDigest,
    required this.policyVersion,
  });

  final int contextContractVersion;
  final String contextDigest;
  final int historyProjectionVersion;
  final String historyDigest;
  final int planContractVersion;
  final String planDigest;
  final int eligibilityProjectionVersion;
  final String eligibilityDigest;
  final String knowledgeVersion;
  final String knowledgeDigest;
  final String policyVersion;

  Map<String, dynamic> toJson() => {
        'contextContractVersion': contextContractVersion,
        'contextDigest': contextDigest,
        'historyProjectionVersion': historyProjectionVersion,
        'historyDigest': historyDigest,
        'planContractVersion': planContractVersion,
        'planDigest': planDigest,
        'eligibilityProjectionVersion': eligibilityProjectionVersion,
        'eligibilityDigest': eligibilityDigest,
        'knowledgeVersion': knowledgeVersion,
        'knowledgeDigest': knowledgeDigest,
        'policyVersion': policyVersion,
      };
}

class CoachRecommendationContract {
  const CoachRecommendationContract._({
    required this.id,
    required this.kind,
    required this.reason,
    required this.decisionId,
    required this.decisionDigest,
    required this.sourceKnowledgeId,
    required this.targetKnowledgeId,
    required this.versions,
    required this.digest,
  });

  factory CoachRecommendationContract.create({
    required CoachContextContract context,
    required CoachDecisionHistoryProjection history,
    required CoachPlanContract plan,
    required CoachRecommendationKind kind,
    required CoachRecommendationReasonCode reason,
    required String? decisionId,
    required String? decisionDigest,
    required String? sourceKnowledgeId,
    required String? targetKnowledgeId,
  }) {
    _validatePlanBinding(context, history, plan);
    switch (kind) {
      case CoachRecommendationKind.continueActiveDecision:
        if (plan.step != CoachPlanStepKind.continueActiveDecision ||
            decisionId != plan.decisionId ||
            decisionDigest != plan.decisionDigest ||
            sourceKnowledgeId != null ||
            targetKnowledgeId != null ||
            reason !=
                CoachRecommendationReasonCode.activeDecisionMustContinue) {
          throw ArgumentError('Active Decision recommendation is invalid.');
        }
      case CoachRecommendationKind.practiceTechnique:
        final matchesEligibility = context.eligibility.items.any(
          (item) =>
              item.sourceKnowledgeId == sourceKnowledgeId &&
              item.resolvedKnowledgeId == targetKnowledgeId,
        );
        if (plan.step != CoachPlanStepKind.requestNextDecision ||
            decisionId != null ||
            decisionDigest != null ||
            !matchesEligibility ||
            reason !=
                CoachRecommendationReasonCode.resolvedLearningEligibility) {
          throw ArgumentError('Technique recommendation is not eligible.');
        }
      case CoachRecommendationKind.correctMistake:
        final persistent = context.progress.state.mistakes.any(
          (item) =>
              item.knowledgeId == targetKnowledgeId &&
              item.state == 'persistent',
        );
        if (plan.step != CoachPlanStepKind.requestNextDecision ||
            decisionId != null ||
            decisionDigest != null ||
            sourceKnowledgeId != targetKnowledgeId ||
            !persistent ||
            reason !=
                CoachRecommendationReasonCode
                    .persistentMistakeRequiresCorrection) {
          throw ArgumentError('Mistake recommendation is not eligible.');
        }
    }

    final versions = CoachRecommendationVersionBinding(
      contextContractVersion: coachContextContractVersion,
      contextDigest: context.digest,
      historyProjectionVersion: coachDecisionHistoryProjectionVersion,
      historyDigest: history.digest,
      planContractVersion: coachPlanContractVersion,
      planDigest: plan.digest,
      eligibilityProjectionVersion: learningEligibilityProjectionVersion,
      eligibilityDigest: context.eligibility.digest,
      knowledgeVersion: context.versions.knowledgeVersion,
      knowledgeDigest: context.versions.knowledgeDigest,
      policyVersion: coachRecommendationPolicyVersion,
    );
    final payload = {
      'schemaVersion': coachRecommendationContractVersion,
      'kind': kind.name,
      'reason': reason.name,
      if (decisionId != null) 'decisionId': decisionId,
      if (decisionDigest != null) 'decisionDigest': decisionDigest,
      if (sourceKnowledgeId != null) 'sourceKnowledgeId': sourceKnowledgeId,
      if (targetKnowledgeId != null) 'targetKnowledgeId': targetKnowledgeId,
      'versions': versions.toJson(),
    };
    final digest = _digest(payload);
    return CoachRecommendationContract._(
      id: 'coach-recommendation.${digest.substring(0, 16)}',
      kind: kind,
      reason: reason,
      decisionId: decisionId,
      decisionDigest: decisionDigest,
      sourceKnowledgeId: sourceKnowledgeId,
      targetKnowledgeId: targetKnowledgeId,
      versions: versions,
      digest: digest,
    );
  }

  final String id;
  final CoachRecommendationKind kind;
  final CoachRecommendationReasonCode reason;
  final String? decisionId;
  final String? decisionDigest;
  final String? sourceKnowledgeId;
  final String? targetKnowledgeId;
  final CoachRecommendationVersionBinding versions;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': coachRecommendationContractVersion,
        'id': id,
        'kind': kind.name,
        'reason': reason.name,
        if (decisionId != null) 'decisionId': decisionId,
        if (decisionDigest != null) 'decisionDigest': decisionDigest,
        if (sourceKnowledgeId != null) 'sourceKnowledgeId': sourceKnowledgeId,
        if (targetKnowledgeId != null) 'targetKnowledgeId': targetKnowledgeId,
        'versions': versions.toJson(),
        'digest': digest,
      };
}

void _validatePlanBinding(
  CoachContextContract context,
  CoachDecisionHistoryProjection history,
  CoachPlanContract plan,
) {
  if (plan.versions.contextDigest != context.digest ||
      plan.versions.historyDigest != history.digest ||
      plan.versions.knowledgeVersion != context.versions.knowledgeVersion ||
      plan.versions.knowledgeDigest != context.versions.knowledgeDigest) {
    throw ArgumentError('Coach Recommendation inputs are not bound together.');
  }
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
