import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/coach_context_contracts.dart';
import 'package:pool_os/contracts/coach_planning_graph_contracts.dart';
import 'package:pool_os/contracts/experience_projection_contracts.dart';
import 'package:pool_os/contracts/learning_eligibility_contracts.dart';
import 'package:pool_os/contracts/ordered_recommendation_view_contracts.dart';
import 'package:pool_os/contracts/player_model_contracts.dart';
import 'package:pool_os/features/coach/domain/training_session_builder.dart';

void main() {
  const builder = TrainingSessionBuilder();

  test('builds a provenance-bound immutable session without reordering', () {
    final context = _context();
    final graph = _graph(context);
    final view = _view(context);
    final session = builder.build(
      context: context,
      planningGraph: graph,
      recommendationView: view,
    );

    expect(session.items.single.position, 1);
    expect(session.items.single.planningNodeId, graph.nodes.single.id);
    expect(session.contextDigest, context.digest);
    expect(session.planningGraphDigest, graph.digest);
    expect(() => session.items.clear(), throwsUnsupportedError);
    final json = jsonEncode(session.toJson());
    expect(json, isNot(contains('prompt')));
    expect(json, isNot(contains('score')));
  });

  test('same inputs replay to the same session digest', () {
    final context = _context();
    final graph = _graph(context);
    final view = _view(context);
    final first = builder.build(
      context: context,
      planningGraph: graph,
      recommendationView: view,
    );
    final replay = builder.build(
      context: context,
      planningGraph: graph,
      recommendationView: view,
    );

    expect(replay.digest, first.digest);
    expect(jsonEncode(replay.toJson()), jsonEncode(first.toJson()));
  });

  test('orphan Recommendation fails loudly', () {
    final context = _context();
    final graph = _graph(context, recommendationId: 'different');
    expect(
      () => builder.build(
        context: context,
        planningGraph: graph,
        recommendationView: _view(context),
      ),
      throwsArgumentError,
    );
  });

  test('stale planning graph fails loudly', () {
    final context = _context();
    final foreign = _context(suffix: '.foreign');
    expect(
      () => builder.build(
        context: context,
        planningGraph: _graph(foreign),
        recommendationView: _view(context),
      ),
      throwsArgumentError,
    );
  });

  test('builder does not mutate the ordered view', () {
    final context = _context();
    final graph = _graph(context);
    final view = _view(context);
    final before = jsonEncode(view.toJson());
    builder.build(
        context: context, planningGraph: graph, recommendationView: view);
    expect(jsonEncode(view.toJson()), before);
  });
}

CoachPlanningGraphContract _graph(
  CoachContextContract context, {
  String recommendationId = 'recommendation.1',
}) {
  final node = CoachPlanningNodeContract.create(
    playerId: context.profile.playerId,
    sessionId: 'session.builder',
    kind: CoachPlanningNodeKind.recommendation,
    semanticId: recommendationId,
    semanticDigest: 'recommendation-digest',
  );
  return CoachPlanningGraphContract.create(
    context: context,
    sessionId: 'session.builder',
    nodes: [node],
    edges: const [],
  );
}

OrderedRecommendationViewContract _view(CoachContextContract context) =>
    OrderedRecommendationViewContract.create(
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

CoachContextContract _context({String suffix = ''}) {
  final progress = PlayerProgressSnapshot.create(
    playerId: 'player.session$suffix',
    knowledgeVersion: 'knowledge.session/1',
    knowledgeDigest: 'session-digest$suffix',
    sourceDecisionReferences: const [],
    state: PlayerModelState(
      mastery: const [],
      mistakes: const [],
      preferences: const [],
      historyReferences: const [],
    ),
  );
  final event = ExperienceEventContract(
    eventId: 'session.event$suffix',
    playerId: progress.playerId,
    sessionId: 'session.builder',
    occurredAt: DateTime.utc(2026, 7, 21),
    kind: ExperienceEventKind.techniqueProgress,
    knowledgeId: 'technique.session',
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
