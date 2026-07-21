import 'package:pool_os/contracts/learning_eligibility_contracts.dart';
import 'package:pool_os/contracts/stop_shot_contracts.dart';
import 'package:pool_os/features/coach/application/learning_runtime.dart';

class LearningEligibilityProjector {
  const LearningEligibilityProjector();

  LearningEligibilityProjection project(
    List<LearningSnapshot> snapshots,
  ) {
    if (snapshots.isEmpty) {
      throw ArgumentError('Learning eligibility requires snapshots.');
    }
    final pack = snapshots.first.pack;
    if (snapshots.any(
      (snapshot) =>
          snapshot.pack.knowledgeVersion != pack.knowledgeVersion ||
          snapshot.pack.contentDigest != pack.contentDigest,
    )) {
      throw ArgumentError(
        'Learning eligibility snapshots must use one Knowledge pack.',
      );
    }
    final items = <LearningEligibilityItem>[];
    for (final snapshot in snapshots.whereType<TechniqueSnapshot>()) {
      final selected = snapshot.decision.recommendations.selected;
      final source = [
        selected,
        ...snapshot.decision.recommendations.alternatives,
      ].singleWhere(
        (candidate) => candidate.id == snapshot.entry.id,
        orElse: () => throw StateError(
          'Learning Decision omitted source eligibility for ${snapshot.entry.id}.',
        ),
      );
      final blockers = snapshot.decision.trace
          .where((reason) => _isBlocker(reason.code))
          .map(_reason)
          .toList(growable: false);
      items.add(
        LearningEligibilityItem(
          sourceKnowledgeId: snapshot.entry.id,
          resolvedKnowledgeId: selected.id,
          sourceAvailable: source.available,
          sourceDecisionId: snapshot.decision.id,
          sourceDecisionPolicyVersion: snapshot.decision.policyVersion,
          blockers: blockers,
        ),
      );
    }
    return LearningEligibilityProjection.create(
      knowledgeVersion: pack.knowledgeVersion,
      knowledgeDigest: pack.contentDigest,
      items: items,
    );
  }

  bool _isBlocker(String code) => {
        DecisionReasonCodes.prerequisiteUnsatisfied,
        DecisionReasonCodes.unlockExpressionUnsatisfied,
        DecisionReasonCodes.activeCorrectionBlocksUnlock,
      }.contains(code);

  LearningEligibilityReasonContract _reason(DecisionReason reason) =>
      LearningEligibilityReasonContract(
        code: reason.code,
        policyVersion: reason.policyVersion,
        dependencyId: reason.parameters['dependencyId'] as String?,
        expressionNodeId: reason.parameters['expressionNodeId'] as String?,
      );
}
