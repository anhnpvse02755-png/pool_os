import 'package:pool_os/contracts/coach_context_contracts.dart';
import 'package:pool_os/contracts/coach_decision_lifecycle_contracts.dart';
import 'package:pool_os/contracts/coach_plan_contracts.dart';
import 'package:pool_os/contracts/coach_recommendation_contracts.dart';

class CoachRecommendationBuilder {
  const CoachRecommendationBuilder();

  CoachRecommendationContract build({
    required CoachContextContract context,
    required CoachDecisionHistoryProjection history,
    required CoachPlanContract plan,
  }) {
    if (plan.step == CoachPlanStepKind.continueActiveDecision) {
      return CoachRecommendationContract.create(
        context: context,
        history: history,
        plan: plan,
        kind: CoachRecommendationKind.continueActiveDecision,
        reason: CoachRecommendationReasonCode.activeDecisionMustContinue,
        decisionId: plan.decisionId,
        decisionDigest: plan.decisionDigest,
        sourceKnowledgeId: null,
        targetKnowledgeId: null,
      );
    }

    final mistakes = context.progress.state.mistakes
        .where((item) => item.state == 'persistent')
        .toList()
      ..sort((a, b) => a.knowledgeId.compareTo(b.knowledgeId));
    if (mistakes.isNotEmpty) {
      final selected = mistakes.first.knowledgeId;
      return CoachRecommendationContract.create(
        context: context,
        history: history,
        plan: plan,
        kind: CoachRecommendationKind.correctMistake,
        reason:
            CoachRecommendationReasonCode.persistentMistakeRequiresCorrection,
        decisionId: null,
        decisionDigest: null,
        sourceKnowledgeId: selected,
        targetKnowledgeId: selected,
      );
    }

    final candidates = [...context.eligibility.items]..sort((a, b) {
        final byTarget = a.resolvedKnowledgeId.compareTo(b.resolvedKnowledgeId);
        return byTarget != 0
            ? byTarget
            : a.sourceKnowledgeId.compareTo(b.sourceKnowledgeId);
      });
    if (candidates.isEmpty) {
      throw StateError('Coach Recommendation has no resolved candidate.');
    }
    final selected = candidates.first;
    return CoachRecommendationContract.create(
      context: context,
      history: history,
      plan: plan,
      kind: CoachRecommendationKind.practiceTechnique,
      reason: CoachRecommendationReasonCode.resolvedLearningEligibility,
      decisionId: null,
      decisionDigest: null,
      sourceKnowledgeId: selected.sourceKnowledgeId,
      targetKnowledgeId: selected.resolvedKnowledgeId,
    );
  }
}
