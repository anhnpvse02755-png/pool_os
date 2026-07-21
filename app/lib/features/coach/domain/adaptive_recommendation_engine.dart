import 'package:pool_os/contracts/coach_context_contracts.dart';
import 'package:pool_os/contracts/coach_execution_contracts.dart';
import 'package:pool_os/contracts/coach_recommendation_contracts.dart';
import 'package:pool_os/contracts/ordered_recommendation_view_contracts.dart';

class AdaptiveRecommendationEngine {
  const AdaptiveRecommendationEngine();

  OrderedRecommendationViewContract order({
    required CoachContextContract context,
    required List<CoachRecommendationContract> recommendations,
    required List<CoachExecutionRecordContract> executions,
  }) {
    if (recommendations.isEmpty) {
      throw ArgumentError('Adaptive Recommendation requires recommendations.');
    }
    final recommendationIds = <String>{};
    for (final recommendation in recommendations) {
      if (!recommendationIds.add(recommendation.id)) {
        throw ArgumentError('Adaptive Recommendation has a duplicate input.');
      }
      if (recommendation.versions.contextDigest != context.digest) {
        throw ArgumentError('Adaptive Recommendation context is stale.');
      }
    }

    final executionsByRecommendation = <String, CoachExecutionRecordContract>{};
    for (final execution in executions) {
      final recommendation = recommendations.where(
        (item) => item.id == execution.recommendationId,
      );
      if (recommendation.length != 1 ||
          recommendation.single.digest != execution.recommendationDigest ||
          executionsByRecommendation.containsKey(execution.recommendationId)) {
        throw ArgumentError(
            'Adaptive Recommendation Execution is inconsistent.');
      }
      executionsByRecommendation[execution.recommendationId] = execution;
    }

    final candidates = recommendations.map((recommendation) {
      final execution = executionsByRecommendation[recommendation.id];
      final result = _classify(context, recommendation, execution);
      return _Candidate(
        recommendation: recommendation,
        execution: execution,
        band: result.band,
        reasons: result.reasons,
      );
    }).toList()
      ..sort((left, right) {
        final byBand = left.band.index.compareTo(right.band.index);
        return byBand != 0
            ? byBand
            : left.recommendation.id.compareTo(right.recommendation.id);
      });

    final items = <RecommendationPriorityItemContract>[];
    for (var index = 0; index < candidates.length; index++) {
      final candidate = candidates[index];
      final reasons = [...candidate.reasons];
      if (candidates.where((item) => item.band == candidate.band).length > 1) {
        reasons.add(RecommendationPriorityReason.canonicalIdTieBreak);
      }
      items.add(RecommendationPriorityItemContract(
        position: index + 1,
        recommendationId: candidate.recommendation.id,
        recommendationDigest: candidate.recommendation.digest,
        band: candidate.band,
        reasons: List.unmodifiable(reasons),
        executionId: candidate.execution?.id,
        executionDigest: candidate.execution?.digest,
      ));
    }
    return OrderedRecommendationViewContract.create(
      context: context,
      items: items,
    );
  }
}

_Priority _classify(
  CoachContextContract context,
  CoachRecommendationContract recommendation,
  CoachExecutionRecordContract? execution,
) {
  if (execution?.state == CoachExecutionState.accepted) {
    return const _Priority(
      RecommendationPriorityBand.continueAcceptedExecution,
      [RecommendationPriorityReason.acceptedExecutionMustContinue],
    );
  }
  if (execution?.state == CoachExecutionState.deferred) {
    return const _Priority(
      RecommendationPriorityBand.retryDeferredExecution,
      [RecommendationPriorityReason.deferredExecutionMayResume],
    );
  }
  if (execution != null) {
    return const _Priority(
      RecommendationPriorityBand.terminalExecution,
      [RecommendationPriorityReason.executionIsTerminal],
    );
  }
  final target = recommendation.targetKnowledgeId;
  if (target != null &&
      context.progress.state.mistakes.any(
        (item) => item.knowledgeId == target && item.state == 'persistent',
      )) {
    return const _Priority(
      RecommendationPriorityBand.correctPersistentMistake,
      [RecommendationPriorityReason.persistentMistakeNeedsCorrection],
    );
  }
  if (target != null &&
      context.experience.timeline.events
          .any((item) => item.knowledgeId == target)) {
    return const _Priority(
      RecommendationPriorityBand.continueRecentExperience,
      [RecommendationPriorityReason.targetAppearsInExperience],
    );
  }
  if (target != null &&
      context.progress.state.mastery.any(
        (item) => item.knowledgeId == target && !item.mastered,
      )) {
    return const _Priority(
      RecommendationPriorityBand.practiceUnmasteredTechnique,
      [RecommendationPriorityReason.targetIsNotMastered],
    );
  }
  return const _Priority(
    RecommendationPriorityBand.pendingRecommendation,
    [RecommendationPriorityReason.noExecutionRecorded],
  );
}

class _Priority {
  const _Priority(this.band, this.reasons);

  final RecommendationPriorityBand band;
  final List<RecommendationPriorityReason> reasons;
}

class _Candidate {
  const _Candidate({
    required this.recommendation,
    required this.execution,
    required this.band,
    required this.reasons,
  });

  final CoachRecommendationContract recommendation;
  final CoachExecutionRecordContract? execution;
  final RecommendationPriorityBand band;
  final List<RecommendationPriorityReason> reasons;
}
