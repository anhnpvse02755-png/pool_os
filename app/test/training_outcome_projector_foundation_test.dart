import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/coach_context_contracts.dart';
import 'package:pool_os/contracts/coach_planning_graph_contracts.dart';
import 'package:pool_os/contracts/experience_projection_contracts.dart';
import 'package:pool_os/contracts/learning_eligibility_contracts.dart';
import 'package:pool_os/contracts/ordered_recommendation_view_contracts.dart';
import 'package:pool_os/contracts/player_model_contracts.dart';
import 'package:pool_os/contracts/training_outcome_projection_contracts.dart';
import 'package:pool_os/contracts/training_session_execution_contracts.dart';
import 'package:pool_os/features/coach/domain/training_outcome_projector.dart';
import 'package:pool_os/features/coach/domain/session_execution_coordinator.dart';
import 'package:pool_os/features/coach/domain/training_session_builder.dart';

void main() {
  test('pending Session Execution produces pending outcome coverage', () {
    final execution = _sessionExecution();
    final outcome = const TrainingOutcomeProjector().project(
      sessionExecution: execution,
      executions: const [],
    );
    expect(outcome.summary.total, 1);
    expect(outcome.summary.pending, 1);
    expect(outcome.summary.completed, 0);
  });

  test('outcome projection is immutable, provenance-bound, and replayable', () {
    final execution = _sessionExecution();
    const projector = TrainingOutcomeProjector();
    final first =
        projector.project(sessionExecution: execution, executions: const []);
    final replay =
        projector.project(sessionExecution: execution, executions: const []);
    expect(replay.digest, first.digest);
    expect(jsonEncode(replay.toJson()), jsonEncode(first.toJson()));
    expect(replay.sessionExecutionDigest, execution.digest);
    expect(() => replay.items.clear(), throwsUnsupportedError);
  });

  test('invalid coverage fails loudly', () {
    final execution = _sessionExecution();
    expect(
      () => TrainingOutcomeProjectionContract.create(
        sessionExecution: execution,
        items: const [],
      ),
      throwsArgumentError,
    );
  });
}

TrainingSessionExecutionContract _sessionExecution() {
  final context = _context();
  final node = CoachPlanningNodeContract.create(
    playerId: context.profile.playerId,
    sessionId: 'session.outcome',
    kind: CoachPlanningNodeKind.recommendation,
    semanticId: 'recommendation.outcome',
    semanticDigest: 'outcome-recommendation-digest',
  );
  final graph = CoachPlanningGraphContract.create(
      context: context,
      sessionId: 'session.outcome',
      nodes: [node],
      edges: const []);
  final view = OrderedRecommendationViewContract.create(
    context: context,
    items: const [
      RecommendationPriorityItemContract(
        position: 1,
        recommendationId: 'recommendation.outcome',
        recommendationDigest: 'outcome-recommendation-digest',
        band: RecommendationPriorityBand.pendingRecommendation,
        reasons: [RecommendationPriorityReason.noExecutionRecorded],
        executionId: null,
        executionDigest: null,
      )
    ],
  );
  final session = const TrainingSessionBuilder()
      .build(context: context, planningGraph: graph, recommendationView: view);
  return const SessionExecutionCoordinator()
      .project(session: session, executions: const []);
}

CoachContextContract _context() {
  final progress = PlayerProgressSnapshot.create(
    playerId: 'player.outcome',
    knowledgeVersion: 'knowledge.outcome/1',
    knowledgeDigest: 'outcome-digest',
    sourceDecisionReferences: const [],
    state: PlayerModelState(
        mastery: const [],
        mistakes: const [],
        preferences: const [],
        historyReferences: const []),
  );
  final event = ExperienceEventContract(
    eventId: 'outcome.event',
    playerId: progress.playerId,
    sessionId: 'session.outcome',
    occurredAt: DateTime.utc(2026, 7, 21),
    kind: ExperienceEventKind.techniqueProgress,
    knowledgeId: 'technique.outcome',
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
