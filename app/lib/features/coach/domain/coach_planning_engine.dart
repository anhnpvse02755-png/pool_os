import 'package:pool_os/contracts/coach_context_contracts.dart';
import 'package:pool_os/contracts/coach_decision_contracts.dart';
import 'package:pool_os/contracts/coach_execution_contracts.dart';
import 'package:pool_os/contracts/coach_planning_graph_contracts.dart';
import 'package:pool_os/contracts/coach_recommendation_contracts.dart';

class CoachPlanningEngine {
  const CoachPlanningEngine();

  CoachPlanningGraphContract build({
    required CoachContextContract context,
    required String sessionId,
    required List<CoachDecisionContract> decisions,
    required List<CoachRecommendationContract> recommendations,
    required List<CoachExecutionRecordContract> executions,
  }) {
    if (!context.experience.sessions
        .any((item) => item.sessionId == sessionId)) {
      throw ArgumentError('Coach Planning session is not in Experience.');
    }
    for (final decision in decisions) {
      if (decision.versions.contextDigest != context.digest) {
        throw ArgumentError('Coach Planning Decision is stale.');
      }
    }
    for (final recommendation in recommendations) {
      if (recommendation.versions.contextDigest != context.digest) {
        throw ArgumentError('Coach Planning Recommendation is stale.');
      }
    }

    final playerId = context.profile.playerId;
    final nodes = <CoachPlanningNodeContract>[];
    final decisionNodes = <String, CoachPlanningNodeContract>{};
    final recommendationNodes = <String, CoachPlanningNodeContract>{};
    for (final decision in decisions) {
      final node = CoachPlanningNodeContract.create(
        playerId: playerId,
        sessionId: sessionId,
        kind: CoachPlanningNodeKind.decision,
        semanticId: decision.id,
        semanticDigest: decision.digest,
      );
      nodes.add(node);
      decisionNodes.putIfAbsent(decision.id, () => node);
    }
    for (final recommendation in recommendations) {
      final node = CoachPlanningNodeContract.create(
        playerId: playerId,
        sessionId: sessionId,
        kind: CoachPlanningNodeKind.recommendation,
        semanticId: recommendation.id,
        semanticDigest: recommendation.digest,
      );
      nodes.add(node);
      recommendationNodes.putIfAbsent(recommendation.id, () => node);
    }
    final executionNodes =
        <CoachExecutionRecordContract, CoachPlanningNodeContract>{};
    for (final execution in executions) {
      final recommendation = recommendations.where(
        (item) => item.id == execution.recommendationId,
      );
      if (recommendation.length != 1 ||
          recommendation.single.digest != execution.recommendationDigest) {
        throw ArgumentError('Coach Planning Execution is stale or orphaned.');
      }
      final node = CoachPlanningNodeContract.create(
        playerId: playerId,
        sessionId: sessionId,
        kind: CoachPlanningNodeKind.execution,
        semanticId: execution.id,
        semanticDigest: execution.digest,
      );
      nodes.add(node);
      executionNodes[execution] = node;
    }

    final edges = <CoachPlanningEdgeContract>[];
    for (final recommendation in recommendations) {
      if (recommendation.decisionId == null) continue;
      final decision = decisions.where(
        (item) => item.id == recommendation.decisionId,
      );
      if (decision.length != 1 ||
          decision.single.digest != recommendation.decisionDigest) {
        throw ArgumentError('Coach Planning Recommendation is orphaned.');
      }
      edges.add(CoachPlanningEdgeContract.create(
        kind: CoachPlanningEdgeKind.recommendationDependency,
        fromNodeId: decisionNodes[decision.single.id]!.id,
        toNodeId: recommendationNodes[recommendation.id]!.id,
      ));
    }
    for (final entry in executionNodes.entries) {
      edges.add(CoachPlanningEdgeContract.create(
        kind: CoachPlanningEdgeKind.executionDependency,
        fromNodeId: recommendationNodes[entry.key.recommendationId]!.id,
        toNodeId: entry.value.id,
      ));
    }
    return CoachPlanningGraphContract.create(
      context: context,
      sessionId: sessionId,
      nodes: nodes,
      edges: edges,
    );
  }
}
