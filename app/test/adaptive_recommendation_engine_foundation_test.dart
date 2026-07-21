import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/coach_context_contracts.dart';
import 'package:pool_os/contracts/coach_decision_contracts.dart';
import 'package:pool_os/contracts/coach_decision_lifecycle_contracts.dart';
import 'package:pool_os/contracts/coach_execution_contracts.dart';
import 'package:pool_os/contracts/coach_plan_contracts.dart';
import 'package:pool_os/contracts/coach_recommendation_contracts.dart';
import 'package:pool_os/contracts/experience_projection_contracts.dart';
import 'package:pool_os/contracts/learning_eligibility_contracts.dart';
import 'package:pool_os/contracts/ordered_recommendation_view_contracts.dart';
import 'package:pool_os/contracts/player_model_contracts.dart';
import 'package:pool_os/features/coach/domain/adaptive_recommendation_engine.dart';
import 'package:pool_os/features/coach/domain/coach_decision_lifecycle_projector.dart';
import 'package:pool_os/features/coach/domain/coach_execution_projector.dart';

void main() {
  const engine = AdaptiveRecommendationEngine();

  test('accepted execution is ordered before pending recommendation', () {
    final fixture = _fixture();
    final view = engine.order(
      context: fixture.context,
      recommendations: [fixture.pending, fixture.acceptedRecommendation],
      executions: [fixture.acceptedExecution],
    );

    expect(
        view.items.first.recommendationId, fixture.acceptedRecommendation.id);
    expect(view.items.first.band,
        RecommendationPriorityBand.continueAcceptedExecution);
    expect(view.items.first.reasons,
        contains(RecommendationPriorityReason.acceptedExecutionMustContinue));
  });

  test('input order does not change ordered view digest', () {
    final fixture = _fixture();
    final first = engine.order(
      context: fixture.context,
      recommendations: [fixture.pending, fixture.acceptedRecommendation],
      executions: [fixture.acceptedExecution],
    );
    final replay = engine.order(
      context: fixture.context,
      recommendations: [fixture.acceptedRecommendation, fixture.pending],
      executions: [fixture.acceptedExecution],
    );

    expect(replay.digest, first.digest);
    expect(jsonEncode(replay.toJson()), jsonEncode(first.toJson()));
  });

  test('priority is explainable and contains no numeric score or AI fields',
      () {
    final fixture = _fixture();
    final view = engine.order(
      context: fixture.context,
      recommendations: [fixture.pending, fixture.acceptedRecommendation],
      executions: [fixture.acceptedExecution],
    );
    final json = jsonEncode(view.toJson());

    expect(json, contains('acceptedExecutionMustContinue'));
    expect(json, isNot(contains('score')));
    expect(json, isNot(contains('probability')));
    expect(json, isNot(contains('prompt')));
    expect(json, isNot(contains('llm')));
  });

  test('ordering leaves Recommendation contracts unchanged', () {
    final fixture = _fixture();
    final before = jsonEncode(fixture.pending.toJson());
    engine.order(
      context: fixture.context,
      recommendations: [fixture.pending, fixture.acceptedRecommendation],
      executions: [fixture.acceptedExecution],
    );

    expect(jsonEncode(fixture.pending.toJson()), before);
  });

  test('duplicate Recommendation fails loudly', () {
    final fixture = _fixture();
    expect(
      () => engine.order(
        context: fixture.context,
        recommendations: [fixture.pending, fixture.pending],
        executions: const [],
      ),
      throwsArgumentError,
    );
  });

  test('stale Recommendation fails loudly', () {
    final fixture = _fixture();
    final stale = _fixture(suffix: '.stale');
    expect(
      () => engine.order(
        context: fixture.context,
        recommendations: [stale.pending],
        executions: const [],
      ),
      throwsArgumentError,
    );
  });

  test('inconsistent Execution binding fails loudly', () {
    final fixture = _fixture();
    final stale = _fixture(suffix: '.stale');
    expect(
      () => engine.order(
        context: fixture.context,
        recommendations: [fixture.pending],
        executions: [stale.acceptedExecution],
      ),
      throwsArgumentError,
    );
  });

  test('ordered view items are immutable', () {
    final fixture = _fixture();
    final view = engine.order(
      context: fixture.context,
      recommendations: [fixture.pending],
      executions: const [],
    );
    expect(() => view.items.clear(), throwsUnsupportedError);
  });
}

class _Fixture {
  _Fixture(String suffix)
      : context = _context(suffix),
        pending = _recommendation(_context(suffix), 'technique.pending$suffix'),
        acceptedRecommendation = _recommendation(
          _context(suffix),
          'technique.accepted$suffix',
        ) {
    acceptedExecution = const CoachExecutionProjector().accept(
      recommendation: acceptedRecommendation,
      occurredAt: DateTime.utc(2026, 7, 21, 19),
    );
  }

  final CoachContextContract context;
  final CoachRecommendationContract pending;
  final CoachRecommendationContract acceptedRecommendation;
  late final CoachExecutionRecordContract acceptedExecution;
}

_Fixture _fixture({String suffix = ''}) => _Fixture(suffix);

CoachRecommendationContract _recommendation(
  CoachContextContract context,
  String target,
) {
  final decision = CoachDecisionContract.create(
    effectiveAt: DateTime.utc(2026, 7, 21, 16),
    action: CoachDecisionAction.practiceTechnique,
    targetKnowledgeId: target,
    reasons: [
      CoachDecisionReason(
        code: CoachDecisionReasonCode.masteryBelowThreshold,
        knowledgeId: target,
      ),
    ],
    trace: [
      CoachDecisionTraceStep(
        sequence: 1,
        stage: CoachDecisionTraceStage.decision,
        outcomeCode: 'PRACTICE_TECHNIQUE',
        knowledgeId: target,
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
  const projector = CoachDecisionLifecycleProjector();
  final history = CoachDecisionHistoryProjection.create([
    projector.complete(
      decision: decision,
      lifecycle: projector.issue(decision),
      occurredAt: DateTime.utc(2026, 7, 21, 17),
    ),
  ]);
  final plan = CoachPlanContract.create(
    context: context,
    history: history,
    step: CoachPlanStepKind.requestNextDecision,
    decisionId: null,
    decisionDigest: null,
  );
  return CoachRecommendationContract.create(
    context: context,
    history: history,
    plan: plan,
    kind: CoachRecommendationKind.practiceTechnique,
    reason: CoachRecommendationReasonCode.resolvedLearningEligibility,
    decisionId: null,
    decisionDigest: null,
    sourceKnowledgeId: target,
    targetKnowledgeId: target,
  );
}

CoachContextContract _context(String suffix) {
  final player = 'player.adaptive$suffix';
  final progress = PlayerProgressSnapshot.create(
    playerId: player,
    knowledgeVersion: 'knowledge.adaptive/1',
    knowledgeDigest: 'adaptive-digest$suffix',
    sourceDecisionReferences: const [],
    state: PlayerModelState(
      mastery: const [],
      mistakes: const [],
      preferences: const [],
      historyReferences: const [],
    ),
  );
  final event = ExperienceEventContract(
    eventId: 'adaptive-event$suffix',
    playerId: player,
    sessionId: 'adaptive-session$suffix',
    occurredAt: DateTime.utc(2026, 7, 21, 18),
    kind: ExperienceEventKind.techniqueProgress,
    knowledgeId: 'technique.pending$suffix',
    state: 'inProgress',
    sourceDecisionReference: 'source',
  );
  return CoachContextContract.create(
    profile: PlayerProfileContract(
      playerId: player,
      dominantHand: 'right',
      locale: 'vi',
    ),
    progress: progress,
    experience: ExperienceSnapshot.create(
      playerId: player,
      playerProgressDigest: progress.digest,
      knowledgeVersion: progress.knowledgeVersion,
      knowledgeDigest: progress.knowledgeDigest,
      timeline: ExperienceTimelineProjection.create([event]),
      sessions: [
        SessionSummaryProjection.create(
          sessionId: event.sessionId,
          events: [event],
        ),
      ],
    ),
    eligibility: LearningEligibilityProjection.create(
      knowledgeVersion: progress.knowledgeVersion,
      knowledgeDigest: progress.knowledgeDigest,
      items: [
        for (final target in [
          'technique.pending$suffix',
          'technique.accepted$suffix',
        ])
          LearningEligibilityItem(
            sourceKnowledgeId: target,
            resolvedKnowledgeId: target,
            sourceAvailable: true,
            sourceDecisionId: 'source',
            sourceDecisionPolicyVersion: 'learning-policy/1.0.0',
            blockers: const [],
          ),
      ],
    ),
  );
}
