import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/coach_context_contracts.dart';
import 'package:pool_os/contracts/coach_adaptation_projection_contracts.dart';
import 'package:pool_os/contracts/coach_planning_graph_contracts.dart';
import 'package:pool_os/contracts/experience_projection_contracts.dart';
import 'package:pool_os/contracts/learning_eligibility_contracts.dart';
import 'package:pool_os/contracts/ordered_recommendation_view_contracts.dart';
import 'package:pool_os/contracts/player_model_contracts.dart';
import 'package:pool_os/contracts/training_outcome_projection_contracts.dart';
import 'package:pool_os/contracts/training_session_execution_contracts.dart';
import 'package:pool_os/features/coach/domain/coach_adaptation_projector.dart';
import 'package:pool_os/features/coach/domain/session_execution_coordinator.dart';
import 'package:pool_os/features/coach/domain/training_session_builder.dart';

void main() {
  test('all Outcome states have an explicit deterministic policy', () {
    expect(
      {
        for (final outcome in TrainingOutcomeKind.values)
          outcome: coachAdaptationActionFor(outcome),
      },
      {
        TrainingOutcomeKind.completed: CoachAdaptationAction.continueAction,
        TrainingOutcomeKind.pending: CoachAdaptationAction.continueAction,
        TrainingOutcomeKind.deferred: CoachAdaptationAction.repeat,
        TrainingOutcomeKind.rejected: CoachAdaptationAction.escalate,
        TrainingOutcomeKind.expired: CoachAdaptationAction.stop,
      },
    );
  });

  test('outcome states map to deterministic adaptation actions', () {
    final context = _context();
    final outcome = _outcome(context);
    final projection = const CoachAdaptationProjector().project(
      context: context,
      outcomeProjection: outcome,
    );
    expect(
        projection.items.single.action, CoachAdaptationAction.continueAction);
    expect(projection.items.single.toJson()['action'], 'continue');
    expect(projection.summary.continueCount, 1);
  });

  test('adaptation projection is immutable, provenance-bound, and replayable',
      () {
    final context = _context();
    final outcome = _outcome(context);
    const projector = CoachAdaptationProjector();
    final first =
        projector.project(context: context, outcomeProjection: outcome);
    final replay =
        projector.project(context: context, outcomeProjection: outcome);
    expect(replay.digest, first.digest);
    expect(jsonEncode(replay.toJson()), jsonEncode(first.toJson()));
    expect(replay.contextDigest, context.digest);
    expect(replay.outcomeProjectionDigest, outcome.digest);
    expect(() => replay.items.clear(), throwsUnsupportedError);
  });

  test('mixed player and stale session fail loudly', () {
    final context = _context();
    final outcome = _outcome(context);
    final other = _context(playerId: 'player.other');
    expect(
      () => const CoachAdaptationProjector().project(
        context: other,
        outcomeProjection: outcome,
      ),
      throwsArgumentError,
    );
    final stale = _outcome(context, sessionId: 'session.missing');
    expect(
      () => const CoachAdaptationProjector().project(
        context: context,
        outcomeProjection: stale,
      ),
      throwsArgumentError,
    );
  });

  test('direct construction rejects an action that contradicts Outcome', () {
    final context = _context();
    final outcome = _outcome(context);
    expect(
      () => CoachAdaptationProjectionContract.create(
        context: context,
        outcomeProjection: outcome,
        items: const [
          CoachAdaptationItemContract(
            position: 1,
            recommendationId: 'recommendation.adaptation',
            outcome: TrainingOutcomeKind.pending,
            action: CoachAdaptationAction.stop,
          ),
        ],
      ),
      throwsArgumentError,
    );
  });
}

CoachContextContract _context({String playerId = 'player.adaptation'}) {
  final progress = PlayerProgressSnapshot.create(
    playerId: playerId,
    knowledgeVersion: 'knowledge.adaptation/1',
    knowledgeDigest: 'adaptation-digest',
    sourceDecisionReferences: const [],
    state: PlayerModelState(
        mastery: const [],
        mistakes: const [],
        preferences: const [],
        historyReferences: const []),
  );
  final event = ExperienceEventContract(
    eventId: 'adaptation.event',
    playerId: playerId,
    sessionId: 'session.adaptation',
    occurredAt: DateTime.utc(2026, 7, 21),
    kind: ExperienceEventKind.techniqueProgress,
    knowledgeId: 'technique.adaptation',
    state: 'inProgress',
    sourceDecisionReference: 'source',
  );
  return CoachContextContract.create(
    profile: PlayerProfileContract(
        playerId: playerId, dominantHand: 'right', locale: 'vi'),
    progress: progress,
    experience: ExperienceSnapshot.create(
      playerId: playerId,
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

TrainingOutcomeProjectionContract _outcome(CoachContextContract context,
    {String sessionId = 'session.adaptation'}) {
  final execution = _sessionExecution(context: context, sessionId: sessionId);
  return TrainingOutcomeProjectionContract.create(
    sessionExecution: execution,
    items: const [
      TrainingOutcomeItemContract(
        position: 1,
        recommendationId: 'recommendation.adaptation',
        kind: TrainingOutcomeKind.pending,
        executionRecordId: null,
      ),
    ],
  );
}

TrainingSessionExecutionContract _sessionExecution({
  required CoachContextContract context,
  required String sessionId,
}) {
  final node = CoachPlanningNodeContract.create(
    playerId: context.profile.playerId,
    sessionId: sessionId,
    kind: CoachPlanningNodeKind.recommendation,
    semanticId: 'recommendation.adaptation',
    semanticDigest: 'adaptation-recommendation-digest',
  );
  final graph = CoachPlanningGraphContract.create(
    context: context,
    sessionId: sessionId,
    nodes: [node],
    edges: const [],
  );
  final view = OrderedRecommendationViewContract.create(
    context: context,
    items: const [
      RecommendationPriorityItemContract(
        position: 1,
        recommendationId: 'recommendation.adaptation',
        recommendationDigest: 'adaptation-recommendation-digest',
        band: RecommendationPriorityBand.pendingRecommendation,
        reasons: [RecommendationPriorityReason.noExecutionRecorded],
        executionId: null,
        executionDigest: null,
      ),
    ],
  );
  final session = const TrainingSessionBuilder().build(
    context: context,
    planningGraph: graph,
    recommendationView: view,
  );
  return const SessionExecutionCoordinator().project(
    session: session,
    executions: const [],
  );
}
