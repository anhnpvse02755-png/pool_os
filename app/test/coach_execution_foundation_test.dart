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
import 'package:pool_os/contracts/player_model_contracts.dart';
import 'package:pool_os/features/coach/domain/coach_decision_lifecycle_projector.dart';
import 'package:pool_os/features/coach/domain/coach_execution_projector.dart';

void main() {
  late CoachRecommendationContract recommendation;
  const executionProjector = CoachExecutionProjector();

  setUp(() {
    recommendation = _recommendation();
  });

  test('accept creates an immutable Execution Record bound to Recommendation',
      () {
    final record = executionProjector.accept(
      recommendation: recommendation,
      occurredAt: DateTime.utc(2026, 7, 21, 20),
    );

    expect(record.state, CoachExecutionState.accepted);
    expect(record.recommendationId, recommendation.id);
    expect(record.recommendationDigest, recommendation.digest);
    expect(record.transitions, hasLength(1));
    expect(record.versions.recommendationContractVersion,
        coachRecommendationContractVersion);
    expect(record.versions.policyVersion, coachExecutionPolicyVersion);
  });

  test('initial outcomes are exclusive and only Accepted can complete', () {
    final accepted = executionProjector.accept(
      recommendation: recommendation,
      occurredAt: DateTime.utc(2026, 7, 21, 20),
    );
    final records = [
      executionProjector.reject(
        recommendation: recommendation,
        occurredAt: DateTime.utc(2026, 7, 21, 21),
      ),
      executionProjector.defer(
        recommendation: recommendation,
        occurredAt: DateTime.utc(2026, 7, 21, 21),
      ),
      executionProjector.expire(
        recommendation: recommendation,
        occurredAt: DateTime.utc(2026, 7, 21, 21),
      ),
      executionProjector.complete(
        recommendation: recommendation,
        record: accepted,
        occurredAt: DateTime.utc(2026, 7, 21, 21),
      ),
    ];

    expect(
      records.map((record) => record.state),
      containsAll(<CoachExecutionState>[
        CoachExecutionState.rejected,
        CoachExecutionState.deferred,
        CoachExecutionState.expired,
        CoachExecutionState.completed,
      ]),
    );
    expect(records.take(3).every((record) => record.transitions.length == 1),
        isTrue);
    expect(records.last.transitions, hasLength(2));
  });

  test('replay is deterministic from reordered append-only transitions', () {
    final accepted = executionProjector.accept(
      recommendation: recommendation,
      occurredAt: DateTime.utc(2026, 7, 21, 20),
    );
    final completed = executionProjector.complete(
      recommendation: recommendation,
      record: accepted,
      occurredAt: DateTime.utc(2026, 7, 21, 21),
    );
    final replayed = executionProjector.replay(
      recommendation: recommendation,
      transitions: completed.transitions.reversed.toList(),
    );

    expect(replayed.digest, completed.digest);
    expect(replayed.toJson(), completed.toJson());
  });

  test('terminal Execution cannot be changed or appended', () {
    final accepted = executionProjector.accept(
      recommendation: recommendation,
      occurredAt: DateTime.utc(2026, 7, 21, 20),
    );
    final completed = executionProjector.complete(
      recommendation: recommendation,
      record: accepted,
      occurredAt: DateTime.utc(2026, 7, 21, 21),
    );

    expect(
      () => executionProjector.complete(
        recommendation: recommendation,
        record: completed,
        occurredAt: DateTime.utc(2026, 7, 21, 22),
      ),
      throwsStateError,
    );
    expect(completed.state, CoachExecutionState.completed);
    expect(completed.transitions, hasLength(2));
  });

  test(
      'replay rejects Completed first, gaps, foreign Recommendation, and time reversal',
      () {
    expect(
      () => executionProjector.replay(
        recommendation: recommendation,
        transitions: const [],
      ),
      throwsArgumentError,
    );
    final completedFirst = CoachExecutionTransitionContract.completed(
      sequence: 1,
      recommendation: recommendation,
      occurredAt: DateTime.utc(2026, 7, 21, 21),
    );
    expect(
      () => executionProjector.replay(
        recommendation: recommendation,
        transitions: [completedFirst],
      ),
      throwsArgumentError,
    );

    final accepted = executionProjector.accept(
      recommendation: recommendation,
      occurredAt: DateTime.utc(2026, 7, 21, 20),
    );
    final completed = CoachExecutionTransitionContract.completed(
      sequence: 3,
      recommendation: recommendation,
      occurredAt: DateTime.utc(2026, 7, 21, 21),
    );
    expect(
      () => executionProjector.replay(
        recommendation: recommendation,
        transitions: [accepted.transitions.single, completed],
      ),
      throwsArgumentError,
    );
    expect(
      () => executionProjector.replay(
        recommendation: _recommendation(suffix: 'other'),
        transitions: [accepted.transitions.single],
      ),
      throwsArgumentError,
    );
    final reversedTime = CoachExecutionTransitionContract.completed(
      sequence: 2,
      recommendation: recommendation,
      occurredAt: DateTime.utc(2026, 7, 21, 19),
    );
    expect(
      () => executionProjector.replay(
        recommendation: recommendation,
        transitions: [accepted.transitions.single, reversedTime],
      ),
      throwsArgumentError,
    );
  });

  test('Execution rejects a record bound to another Recommendation', () {
    final accepted = executionProjector.accept(
      recommendation: recommendation,
      occurredAt: DateTime.utc(2026, 7, 21, 20),
    );

    expect(
      () => executionProjector.complete(
        recommendation: _recommendation(suffix: 'other'),
        record: accepted,
        occurredAt: DateTime.utc(2026, 7, 21, 21),
      ),
      throwsArgumentError,
    );
  });

  test('Execution is pure and does not mutate Recommendation or Record inputs',
      () {
    final accepted = executionProjector.accept(
      recommendation: recommendation,
      occurredAt: DateTime.utc(2026, 7, 21, 20),
    );
    final recommendationJson = jsonEncode(recommendation.toJson());
    final acceptedJson = jsonEncode(accepted.toJson());

    final completed = executionProjector.complete(
      recommendation: recommendation,
      record: accepted,
      occurredAt: DateTime.utc(2026, 7, 21, 21),
    );

    expect(jsonEncode(recommendation.toJson()), recommendationJson);
    expect(jsonEncode(accepted.toJson()), acceptedJson);
    expect(completed.transitions, hasLength(2));
  });
}

CoachRecommendationContract _recommendation({String suffix = ''}) {
  final context = _context(suffix: suffix);
  final decision = _decision(context);
  const lifecycleProjector = CoachDecisionLifecycleProjector();
  final history = CoachDecisionHistoryProjection.create([
    lifecycleProjector.complete(
      decision: decision,
      lifecycle: lifecycleProjector.issue(decision),
      occurredAt: DateTime.utc(2026, 7, 21, 19),
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
    sourceKnowledgeId: 'technique.execution_target$suffix',
    targetKnowledgeId: 'technique.execution_target$suffix',
  );
}

CoachContextContract _context({String suffix = ''}) {
  final profile = PlayerProfileContract(
    playerId: 'player.execution$suffix',
    dominantHand: 'right',
    locale: 'vi',
  );
  final progress = PlayerProgressSnapshot.create(
    playerId: profile.playerId,
    knowledgeVersion: 'knowledge.execution/1',
    knowledgeDigest: 'knowledge-execution-digest$suffix',
    sourceDecisionReferences: const ['decision.execution-source'],
    state: PlayerModelState(
      mastery: const [],
      mistakes: const [],
      preferences: const [],
      historyReferences: const [],
    ),
  );
  final event = ExperienceEventContract(
    eventId: 'event.execution$suffix',
    playerId: profile.playerId,
    sessionId: 'session.execution$suffix',
    occurredAt: DateTime.utc(2026, 7, 21, 18),
    kind: ExperienceEventKind.techniqueProgress,
    knowledgeId: 'technique.execution_target$suffix',
    state: 'inProgress',
    sourceDecisionReference: 'decision.execution-source',
  );
  final timeline = ExperienceTimelineProjection.create([event]);
  final summary = SessionSummaryProjection.create(
    sessionId: event.sessionId,
    events: [event],
  );
  final experience = ExperienceSnapshot.create(
    playerId: profile.playerId,
    playerProgressDigest: progress.digest,
    knowledgeVersion: progress.knowledgeVersion,
    knowledgeDigest: progress.knowledgeDigest,
    timeline: timeline,
    sessions: [summary],
  );
  final eligibility = LearningEligibilityProjection.create(
    knowledgeVersion: progress.knowledgeVersion,
    knowledgeDigest: progress.knowledgeDigest,
    items: [
      LearningEligibilityItem(
        sourceKnowledgeId: 'technique.execution_target$suffix',
        resolvedKnowledgeId: 'technique.execution_target$suffix',
        sourceAvailable: true,
        sourceDecisionId: 'decision.execution-source',
        sourceDecisionPolicyVersion: 'learning-policy/1.0.0',
        blockers: const [],
      ),
    ],
  );
  return CoachContextContract.create(
    profile: profile,
    progress: progress,
    experience: experience,
    eligibility: eligibility,
  );
}

CoachDecisionContract _decision(CoachContextContract context) =>
    CoachDecisionContract.create(
      effectiveAt: DateTime.utc(2026, 7, 21, 18),
      action: CoachDecisionAction.practiceTechnique,
      targetKnowledgeId: 'technique.execution_target',
      reasons: const [
        CoachDecisionReason(
          code: CoachDecisionReasonCode.masteryBelowThreshold,
          knowledgeId: 'technique.execution_target',
        ),
      ],
      trace: const [
        CoachDecisionTraceStep(
          sequence: 1,
          stage: CoachDecisionTraceStage.decision,
          outcomeCode: 'PRACTICE_TECHNIQUE',
          knowledgeId: 'technique.execution_target',
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
