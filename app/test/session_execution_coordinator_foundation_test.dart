import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/coach_context_contracts.dart';
import 'package:pool_os/contracts/coach_execution_contracts.dart';
import 'package:pool_os/contracts/coach_planning_graph_contracts.dart';
import 'package:pool_os/contracts/experience_projection_contracts.dart';
import 'package:pool_os/contracts/learning_eligibility_contracts.dart';
import 'package:pool_os/contracts/ordered_recommendation_view_contracts.dart';
import 'package:pool_os/contracts/player_model_contracts.dart';
import 'package:pool_os/contracts/training_session_contracts.dart';
import 'package:pool_os/contracts/training_session_execution_contracts.dart';
import 'package:pool_os/features/coach/domain/session_execution_coordinator.dart';
import 'package:pool_os/features/coach/domain/training_session_builder.dart';

void main() {
  test('no Execution Records projects an immutable pending session', () {
    final session = _session();
    final projection = const SessionExecutionCoordinator().project(
      session: session,
      executions: const [],
    );
    expect(projection.state, TrainingSessionExecutionState.pending);
    expect(projection.items.single.executionRecordId, isNull);
    expect(() => projection.items.clear(), throwsUnsupportedError);
  });

  test('accepted Execution produces in-progress lifecycle state', () {
    final session = _session();
    final projection = TrainingSessionExecutionContract.create(
      session: session,
      state: TrainingSessionExecutionState.inProgress,
      items: [_item(session, CoachExecutionState.accepted)],
    );
    expect(projection.state, TrainingSessionExecutionState.inProgress);
  });

  test('terminal Execution produces completed lifecycle state', () {
    final session = _session();
    final projection = TrainingSessionExecutionContract.create(
      session: session,
      state: TrainingSessionExecutionState.completed,
      items: [_item(session, CoachExecutionState.completed)],
    );
    expect(projection.state, TrainingSessionExecutionState.completed);
  });

  test('invalid lifecycle transition state fails loudly', () {
    final session = _session();
    expect(
      () => TrainingSessionExecutionContract.create(
        session: session,
        state: TrainingSessionExecutionState.completed,
        items: [_item(session, CoachExecutionState.accepted)],
      ),
      throwsArgumentError,
    );
  });

  test('same Session and records replay to the same digest', () {
    final session = _session();
    const coordinator = SessionExecutionCoordinator();
    final before = jsonEncode(session.toJson());
    final first = coordinator.project(session: session, executions: const []);
    final replay = coordinator.project(session: session, executions: const []);
    expect(replay.digest, first.digest);
    expect(jsonEncode(replay.toJson()), jsonEncode(first.toJson()));
    expect(jsonEncode(session.toJson()), before);
  });
}

TrainingSessionExecutionItemContract _item(
  TrainingSessionContract session,
  CoachExecutionState state,
) =>
    TrainingSessionExecutionItemContract(
      position: 1,
      recommendationId: session.items.single.recommendationId,
      sessionItemPlanningNodeId: session.items.single.planningNodeId,
      executionRecordId: 'execution.1',
      executionRecordDigest: 'execution-digest',
      executionState: state,
    );

TrainingSessionContract _session() {
  final context = _context();
  final node = CoachPlanningNodeContract.create(
    playerId: context.profile.playerId,
    sessionId: 'session.execution',
    kind: CoachPlanningNodeKind.recommendation,
    semanticId: 'recommendation.1',
    semanticDigest: 'recommendation-digest',
  );
  final graph = CoachPlanningGraphContract.create(
    context: context,
    sessionId: 'session.execution',
    nodes: [node],
    edges: const [],
  );
  final view = OrderedRecommendationViewContract.create(
    context: context,
    items: const [
      RecommendationPriorityItemContract(
        position: 1,
        recommendationId: 'recommendation.1',
        recommendationDigest: 'recommendation-digest',
        band: RecommendationPriorityBand.pendingRecommendation,
        reasons: [RecommendationPriorityReason.noExecutionRecorded],
        executionId: null,
        executionDigest: null,
      )
    ],
  );
  return const TrainingSessionBuilder().build(
    context: context,
    planningGraph: graph,
    recommendationView: view,
  );
}

CoachContextContract _context() {
  final progress = PlayerProgressSnapshot.create(
    playerId: 'player.execution-session',
    knowledgeVersion: 'knowledge.execution-session/1',
    knowledgeDigest: 'execution-session-digest',
    sourceDecisionReferences: const [],
    state: PlayerModelState(
      mastery: const [],
      mistakes: const [],
      preferences: const [],
      historyReferences: const [],
    ),
  );
  final event = ExperienceEventContract(
    eventId: 'session.execution.event',
    playerId: progress.playerId,
    sessionId: 'session.execution',
    occurredAt: DateTime.utc(2026, 7, 21),
    kind: ExperienceEventKind.techniqueProgress,
    knowledgeId: 'technique.1',
    state: 'inProgress',
    sourceDecisionReference: 'source',
  );
  return CoachContextContract.create(
    profile: PlayerProfileContract(
        playerId: progress.playerId, dominantHand: 'right', locale: 'vi'),
    progress: progress,
    experience: ExperienceSnapshot.create(
      playerId: progress.playerId,
      playerProgressDigest: progress.digest,
      knowledgeVersion: progress.knowledgeVersion,
      knowledgeDigest: progress.knowledgeDigest,
      timeline: ExperienceTimelineProjection.create([event]),
      sessions: [
        SessionSummaryProjection.create(
            sessionId: event.sessionId, events: [event])
      ],
    ),
    eligibility: LearningEligibilityProjection.create(
      knowledgeVersion: progress.knowledgeVersion,
      knowledgeDigest: progress.knowledgeDigest,
      items: const [],
    ),
  );
}
