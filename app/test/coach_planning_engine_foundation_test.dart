import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/coach_context_contracts.dart';
import 'package:pool_os/contracts/coach_decision_contracts.dart';
import 'package:pool_os/contracts/coach_decision_lifecycle_contracts.dart';
import 'package:pool_os/contracts/coach_execution_contracts.dart';
import 'package:pool_os/contracts/coach_plan_contracts.dart';
import 'package:pool_os/contracts/coach_planning_graph_contracts.dart';
import 'package:pool_os/contracts/coach_recommendation_contracts.dart';
import 'package:pool_os/contracts/experience_projection_contracts.dart';
import 'package:pool_os/contracts/learning_eligibility_contracts.dart';
import 'package:pool_os/contracts/player_model_contracts.dart';
import 'package:pool_os/features/coach/domain/coach_decision_lifecycle_projector.dart';
import 'package:pool_os/features/coach/domain/coach_execution_projector.dart';
import 'package:pool_os/features/coach/domain/coach_planning_engine.dart';

void main() {
  const engine = CoachPlanningEngine();

  test('builds Decision to Recommendation to Execution structure', () {
    final fixture = _fixture();

    final graph = engine.build(
      context: fixture.context,
      sessionId: fixture.sessionId,
      decisions: [fixture.decision],
      recommendations: [fixture.recommendation],
      executions: [fixture.execution],
    );

    expect(graph.nodes, hasLength(3));
    expect(graph.edges, hasLength(2));
    expect(
      graph.edges.map((item) => item.kind),
      containsAll(CoachPlanningEdgeKind.values),
    );
    expect(graph.versions.contextDigest, fixture.context.digest);
    expect(
        graph.versions.playerProgressDigest, fixture.context.progress.digest);
    expect(graph.versions.experienceDigest, fixture.context.experience.digest);
  });

  test('same input replays to the same JSON and digest', () {
    final fixture = _fixture();
    CoachPlanningGraphContract build() => engine.build(
          context: fixture.context,
          sessionId: fixture.sessionId,
          decisions: [fixture.decision],
          recommendations: [fixture.recommendation],
          executions: [fixture.execution],
        );

    final first = build();
    final replay = build();

    expect(replay.digest, first.digest);
    expect(jsonEncode(replay.toJson()), jsonEncode(first.toJson()));
  });

  test('graph collections are immutable and contain no AI fields', () {
    final fixture = _fixture();
    final graph = engine.build(
      context: fixture.context,
      sessionId: fixture.sessionId,
      decisions: [fixture.decision],
      recommendations: [fixture.recommendation],
      executions: [fixture.execution],
    );

    expect(() => graph.nodes.add(graph.nodes[0]), throwsUnsupportedError);
    expect(() => graph.edges.clear(), throwsUnsupportedError);
    final json = jsonEncode(graph.toJson());
    expect(json, isNot(contains('prompt')));
    expect(json, isNot(contains('prose')));
    expect(json, isNot(contains('score')));
  });

  test('duplicate semantic node fails loudly', () {
    final fixture = _fixture();
    final node = _node(fixture);

    expect(
      () => CoachPlanningGraphContract.create(
        context: fixture.context,
        sessionId: fixture.sessionId,
        nodes: [node, node],
        edges: const [],
      ),
      throwsArgumentError,
    );
  });

  test('mixed player or session fails loudly', () {
    final fixture = _fixture();
    final mixed = CoachPlanningNodeContract.create(
      playerId: fixture.context.profile.playerId,
      sessionId: 'session.other',
      kind: CoachPlanningNodeKind.decision,
      semanticId: fixture.decision.id,
      semanticDigest: fixture.decision.digest,
    );

    expect(
      () => CoachPlanningGraphContract.create(
        context: fixture.context,
        sessionId: fixture.sessionId,
        nodes: [mixed],
        edges: const [],
      ),
      throwsArgumentError,
    );
  });

  test('orphan edge fails loudly', () {
    final fixture = _fixture();
    final node = _node(fixture);
    final edge = CoachPlanningEdgeContract.create(
      kind: CoachPlanningEdgeKind.recommendationDependency,
      fromNodeId: node.id,
      toNodeId: 'missing.node',
    );

    expect(
      () => CoachPlanningGraphContract.create(
        context: fixture.context,
        sessionId: fixture.sessionId,
        nodes: [node],
        edges: [edge],
      ),
      throwsArgumentError,
    );
  });

  test('cyclic or reversed dependency shape fails loudly', () {
    final fixture = _fixture();
    final decision = _node(fixture);
    final recommendation = CoachPlanningNodeContract.create(
      playerId: fixture.context.profile.playerId,
      sessionId: fixture.sessionId,
      kind: CoachPlanningNodeKind.recommendation,
      semanticId: fixture.recommendation.id,
      semanticDigest: fixture.recommendation.digest,
    );
    final reverse = CoachPlanningEdgeContract.create(
      kind: CoachPlanningEdgeKind.recommendationDependency,
      fromNodeId: recommendation.id,
      toNodeId: decision.id,
    );

    expect(
      () => CoachPlanningGraphContract.create(
        context: fixture.context,
        sessionId: fixture.sessionId,
        nodes: [decision, recommendation],
        edges: [reverse],
      ),
      throwsArgumentError,
    );
  });

  test('stale Recommendation fails instead of falling back', () {
    final fixture = _fixture();
    final stale = _fixture(suffix: '.stale');

    expect(
      () => engine.build(
        context: fixture.context,
        sessionId: fixture.sessionId,
        decisions: [fixture.decision],
        recommendations: [stale.recommendation],
        executions: const [],
      ),
      throwsArgumentError,
    );
  });

  test('stale Execution binding fails instead of falling back', () {
    final fixture = _fixture();
    final stale = _fixture(suffix: '.stale');

    expect(
      () => engine.build(
        context: fixture.context,
        sessionId: fixture.sessionId,
        decisions: [fixture.decision],
        recommendations: [fixture.recommendation],
        executions: [stale.execution],
      ),
      throwsArgumentError,
    );
  });
}

CoachPlanningNodeContract _node(_Fixture fixture) =>
    CoachPlanningNodeContract.create(
      playerId: fixture.context.profile.playerId,
      sessionId: fixture.sessionId,
      kind: CoachPlanningNodeKind.decision,
      semanticId: fixture.decision.id,
      semanticDigest: fixture.decision.digest,
    );

_Fixture _fixture({String suffix = ''}) {
  final context = _context(suffix);
  final decision = CoachDecisionContract.create(
    effectiveAt: DateTime.utc(2026, 7, 21, 18),
    action: CoachDecisionAction.practiceTechnique,
    targetKnowledgeId: 'technique.target$suffix',
    reasons: [
      CoachDecisionReason(
        code: CoachDecisionReasonCode.masteryBelowThreshold,
        knowledgeId: 'technique.target$suffix',
      ),
    ],
    trace: [
      CoachDecisionTraceStep(
        sequence: 1,
        stage: CoachDecisionTraceStage.decision,
        outcomeCode: 'PRACTICE_TECHNIQUE',
        knowledgeId: 'technique.target$suffix',
      ),
    ],
    alternatives: const [],
    versions: CoachDecisionVersionBinding(
      contextContractVersion: coachContextContractVersion,
      contextDigest: context.digest,
      knowledgeVersion: context.versions.knowledgeVersion,
      knowledgeDigest: context.versions.knowledgeDigest,
      policyVersion: coachDecisionPolicyVersion,
    ),
  );
  const lifecycleProjector = CoachDecisionLifecycleProjector();
  final history = CoachDecisionHistoryProjection.create([
    lifecycleProjector.issue(decision),
  ]);
  final plan = CoachPlanContract.create(
    context: context,
    history: history,
    step: CoachPlanStepKind.continueActiveDecision,
    decisionId: decision.id,
    decisionDigest: decision.digest,
  );
  final recommendation = CoachRecommendationContract.create(
    context: context,
    history: history,
    plan: plan,
    kind: CoachRecommendationKind.continueActiveDecision,
    reason: CoachRecommendationReasonCode.activeDecisionMustContinue,
    decisionId: decision.id,
    decisionDigest: decision.digest,
    sourceKnowledgeId: null,
    targetKnowledgeId: null,
  );
  final execution = const CoachExecutionProjector().accept(
    recommendation: recommendation,
    occurredAt: DateTime.utc(2026, 7, 21, 19),
  );
  return _Fixture(
    context: context,
    sessionId: 'session.planning$suffix',
    decision: decision,
    recommendation: recommendation,
    execution: execution,
  );
}

CoachContextContract _context(String suffix) {
  final playerId = 'player.planning$suffix';
  final profile = PlayerProfileContract(
    playerId: playerId,
    dominantHand: 'right',
    locale: 'vi',
  );
  final progress = PlayerProgressSnapshot.create(
    playerId: playerId,
    knowledgeVersion: 'knowledge.planning/1',
    knowledgeDigest: 'knowledge-planning-digest$suffix',
    sourceDecisionReferences: const ['decision.source'],
    state: PlayerModelState(
      mastery: const [],
      mistakes: const [],
      preferences: const [],
      historyReferences: const [],
    ),
  );
  final event = ExperienceEventContract(
    eventId: 'event.planning$suffix',
    playerId: playerId,
    sessionId: 'session.planning$suffix',
    occurredAt: DateTime.utc(2026, 7, 21, 17),
    kind: ExperienceEventKind.techniqueProgress,
    knowledgeId: 'technique.target$suffix',
    state: 'inProgress',
    sourceDecisionReference: 'decision.source',
  );
  final experience = ExperienceSnapshot.create(
    playerId: playerId,
    playerProgressDigest: progress.digest,
    knowledgeVersion: progress.knowledgeVersion,
    knowledgeDigest: progress.knowledgeDigest,
    timeline: ExperienceTimelineProjection.create([event]),
    sessions: [
      SessionSummaryProjection.create(
          sessionId: event.sessionId, events: [event]),
    ],
  );
  return CoachContextContract.create(
    profile: profile,
    progress: progress,
    experience: experience,
    eligibility: LearningEligibilityProjection.create(
      knowledgeVersion: progress.knowledgeVersion,
      knowledgeDigest: progress.knowledgeDigest,
      items: const [],
    ),
  );
}

class _Fixture {
  const _Fixture({
    required this.context,
    required this.sessionId,
    required this.decision,
    required this.recommendation,
    required this.execution,
  });

  final CoachContextContract context;
  final String sessionId;
  final CoachDecisionContract decision;
  final CoachRecommendationContract recommendation;
  final CoachExecutionRecordContract execution;
}
