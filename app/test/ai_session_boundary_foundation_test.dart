import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/ai_session_contracts.dart';
import 'package:pool_os/contracts/coach_context_contracts.dart';
import 'package:pool_os/contracts/coach_decision_contracts.dart';
import 'package:pool_os/contracts/coach_decision_lifecycle_contracts.dart';
import 'package:pool_os/contracts/coach_execution_contracts.dart';
import 'package:pool_os/contracts/coach_plan_contracts.dart';
import 'package:pool_os/contracts/coach_recommendation_contracts.dart';
import 'package:pool_os/contracts/experience_projection_contracts.dart';
import 'package:pool_os/contracts/learning_eligibility_contracts.dart';
import 'package:pool_os/contracts/player_model_contracts.dart';
import 'package:pool_os/features/coach/application/ai_session_builder.dart';
import 'package:pool_os/features/coach/domain/coach_decision_lifecycle_projector.dart';
import 'package:pool_os/features/coach/domain/coach_execution_projector.dart';

void main() {
  late _Bundle bundle;
  setUp(() => bundle = _bundle());

  test('AISession contains only versioned references and provenance', () {
    final session = const AISessionBuilder().build(
      context: bundle.context,
      plan: bundle.plan,
      recommendation: bundle.recommendation,
      execution: bundle.execution,
    );
    final encoded = jsonEncode(session.toJson());
    expect(session.toJson()['schemaVersion'], aiSessionContractVersion);
    expect(session.contextDigest, bundle.context.digest);
    expect(session.planDigest, bundle.plan.digest);
    expect(session.recommendationDigest, bundle.recommendation.digest);
    expect(session.executionDigest, bundle.execution.digest);
    expect(session.requiredRuntimeContracts, requiredAISessionRuntimeContracts);
    expect(encoded, isNot(contains('rawEvidence')));
    expect(encoded, isNot(contains('eventLog')));
    expect(encoded, isNot(contains('learningRuntime')));
    expect(encoded, isNot(contains('progress')));
    expect(encoded, isNot(contains('transitions')));
  });

  test('same inputs and reordered compatibility map produce same digest', () {
    final reversed = Map.fromEntries(
      requiredAISessionRuntimeContracts.entries.toList().reversed,
    );
    final first = const AISessionBuilder().build(
      context: bundle.context,
      plan: bundle.plan,
      recommendation: bundle.recommendation,
      execution: bundle.execution,
    );
    final second = AISessionBuilder(requiredRuntimeContracts: reversed).build(
      context: bundle.context,
      plan: bundle.plan,
      recommendation: bundle.recommendation,
      execution: bundle.execution,
    );
    expect(second.digest, first.digest);
    expect(second.toJson(), first.toJson());
  });

  test('builder rejects stale Plan and mixed player/context inputs', () {
    final other = _bundle(suffix: '.other');
    expect(
      () => const AISessionBuilder().build(
        context: other.context,
        plan: bundle.plan,
        recommendation: bundle.recommendation,
        execution: bundle.execution,
      ),
      throwsArgumentError,
    );
  });

  test('builder rejects stale Recommendation and stale Execution', () {
    final other = _bundle(suffix: '.other');
    expect(
      () => const AISessionBuilder().build(
        context: bundle.context,
        plan: bundle.plan,
        recommendation: other.recommendation,
        execution: other.execution,
      ),
      throwsArgumentError,
    );
    expect(
      () => const AISessionBuilder().build(
        context: bundle.context,
        plan: bundle.plan,
        recommendation: bundle.recommendation,
        execution: other.execution,
      ),
      throwsArgumentError,
    );
  });

  test('compatibility gate rejects unsupported AI version and runtime set', () {
    expect(
      () => const AISessionBuilder(minimumAIContractVersion: 'ai-session/2.0.0')
          .build(
        context: bundle.context,
        plan: bundle.plan,
        recommendation: bundle.recommendation,
        execution: bundle.execution,
      ),
      throwsArgumentError,
    );
    expect(
      () => const AISessionBuilder(
        requiredRuntimeContracts: {
          ...requiredAISessionRuntimeContracts,
          'unknownContract': 1,
        },
      ).build(
        context: bundle.context,
        plan: bundle.plan,
        recommendation: bundle.recommendation,
        execution: bundle.execution,
      ),
      throwsArgumentError,
    );
  });

  test('contract rejects provenance mismatch and accepts canonical references',
      () {
    final provenance = AISessionProvenance(
      knowledgeVersion: bundle.context.versions.knowledgeVersion,
      knowledgeDigest: bundle.context.versions.knowledgeDigest,
      contextDigest: 'wrong',
      planDigest: bundle.plan.digest,
      recommendationDigest: bundle.recommendation.digest,
      executionDigest: bundle.execution.digest,
    );
    expect(
      () => AISessionContract.create(
        contextId: bundle.context.digest,
        planId: bundle.plan.id,
        recommendationId: bundle.recommendation.id,
        executionId: bundle.execution.id,
        knowledgeVersion: bundle.context.versions.knowledgeVersion,
        knowledgeDigest: bundle.context.versions.knowledgeDigest,
        contextDigest: bundle.context.digest,
        planDigest: bundle.plan.digest,
        recommendationDigest: bundle.recommendation.digest,
        executionDigest: bundle.execution.digest,
        provenance: provenance,
        requiredRuntimeContracts: requiredAISessionRuntimeContracts,
        minimumAIContractVersion: minimumAIContractVersion,
      ),
      throwsArgumentError,
    );
    final validProvenance = AISessionProvenance(
      knowledgeVersion: bundle.context.versions.knowledgeVersion,
      knowledgeDigest: bundle.context.versions.knowledgeDigest,
      contextDigest: bundle.context.digest,
      planDigest: bundle.plan.digest,
      recommendationDigest: bundle.recommendation.digest,
      executionDigest: bundle.execution.digest,
    );
    expect(
      () => AISessionContract.create(
        contextId: bundle.context.digest,
        planId: bundle.context.digest,
        recommendationId: bundle.recommendation.id,
        executionId: bundle.execution.id,
        knowledgeVersion: bundle.context.versions.knowledgeVersion,
        knowledgeDigest: bundle.context.versions.knowledgeDigest,
        contextDigest: bundle.context.digest,
        planDigest: bundle.plan.digest,
        recommendationDigest: bundle.recommendation.digest,
        executionDigest: bundle.execution.digest,
        provenance: validProvenance,
        requiredRuntimeContracts: requiredAISessionRuntimeContracts,
        minimumAIContractVersion: minimumAIContractVersion,
      ),
      throwsArgumentError,
    );
  });

  test('builder is pure and leaves all deterministic inputs unchanged', () {
    final before = [
      jsonEncode(bundle.context.toJson()),
      jsonEncode(bundle.plan.toJson()),
      jsonEncode(bundle.recommendation.toJson()),
      jsonEncode(bundle.execution.toJson()),
    ];
    const AISessionBuilder().build(
      context: bundle.context,
      plan: bundle.plan,
      recommendation: bundle.recommendation,
      execution: bundle.execution,
    );
    expect(
      [
        jsonEncode(bundle.context.toJson()),
        jsonEncode(bundle.plan.toJson()),
        jsonEncode(bundle.recommendation.toJson()),
        jsonEncode(bundle.execution.toJson()),
      ],
      before,
    );
  });
}

class _Bundle {
  const _Bundle({
    required this.context,
    required this.plan,
    required this.recommendation,
    required this.execution,
  });
  final CoachContextContract context;
  final CoachPlanContract plan;
  final CoachRecommendationContract recommendation;
  final CoachExecutionRecordContract execution;
}

_Bundle _bundle({String suffix = ''}) {
  final context = _context(suffix: suffix);
  final decision = _decision(context, suffix: suffix);
  const lifecycle = CoachDecisionLifecycleProjector();
  final history = CoachDecisionHistoryProjection.create([
    lifecycle.complete(
      decision: decision,
      lifecycle: lifecycle.issue(decision),
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
  final recommendation = CoachRecommendationContract.create(
    context: context,
    history: history,
    plan: plan,
    kind: CoachRecommendationKind.practiceTechnique,
    reason: CoachRecommendationReasonCode.resolvedLearningEligibility,
    decisionId: null,
    decisionDigest: null,
    sourceKnowledgeId: 'technique.ai_boundary$suffix',
    targetKnowledgeId: 'technique.ai_boundary$suffix',
  );
  final execution = const CoachExecutionProjector().accept(
    recommendation: recommendation,
    occurredAt: DateTime.utc(2026, 7, 21, 20),
  );
  return _Bundle(
    context: context,
    plan: plan,
    recommendation: recommendation,
    execution: execution,
  );
}

CoachContextContract _context({String suffix = ''}) {
  final profile = PlayerProfileContract(
    playerId: 'player.ai_boundary$suffix',
    dominantHand: 'right',
    locale: 'vi',
  );
  final progress = PlayerProgressSnapshot.create(
    playerId: profile.playerId,
    knowledgeVersion: 'knowledge.ai_boundary/1',
    knowledgeDigest: 'knowledge-ai-boundary$suffix',
    sourceDecisionReferences: const ['decision.ai-boundary-source'],
    state: PlayerModelState(
      mastery: const [],
      mistakes: const [],
      preferences: const [],
      historyReferences: const [],
    ),
  );
  final event = ExperienceEventContract(
    eventId: 'event.ai_boundary$suffix',
    playerId: profile.playerId,
    sessionId: 'session.ai_boundary$suffix',
    occurredAt: DateTime.utc(2026, 7, 21, 18),
    kind: ExperienceEventKind.techniqueProgress,
    knowledgeId: 'technique.ai_boundary$suffix',
    state: 'inProgress',
    sourceDecisionReference: 'decision.ai-boundary-source',
  );
  final timeline = ExperienceTimelineProjection.create([event]);
  final experience = ExperienceSnapshot.create(
    playerId: profile.playerId,
    playerProgressDigest: progress.digest,
    knowledgeVersion: progress.knowledgeVersion,
    knowledgeDigest: progress.knowledgeDigest,
    timeline: timeline,
    sessions: [
      SessionSummaryProjection.create(
        sessionId: event.sessionId,
        events: [event],
      ),
    ],
  );
  return CoachContextContract.create(
    profile: profile,
    progress: progress,
    experience: experience,
    eligibility: LearningEligibilityProjection.create(
      knowledgeVersion: progress.knowledgeVersion,
      knowledgeDigest: progress.knowledgeDigest,
      items: [
        LearningEligibilityItem(
          sourceKnowledgeId: 'technique.ai_boundary$suffix',
          resolvedKnowledgeId: 'technique.ai_boundary$suffix',
          sourceAvailable: true,
          sourceDecisionId: 'decision.ai-boundary-source',
          sourceDecisionPolicyVersion: 'learning-policy/1.0.0',
          blockers: const [],
        ),
      ],
    ),
  );
}

CoachDecisionContract _decision(
  CoachContextContract context, {
  required String suffix,
}) =>
    CoachDecisionContract.create(
      effectiveAt: DateTime.utc(2026, 7, 21, 18),
      action: CoachDecisionAction.practiceTechnique,
      targetKnowledgeId: 'technique.ai_boundary$suffix',
      reasons: const [
        CoachDecisionReason(
          code: CoachDecisionReasonCode.masteryBelowThreshold,
          knowledgeId: 'technique.ai_boundary',
        ),
      ],
      trace: const [
        CoachDecisionTraceStep(
          sequence: 1,
          stage: CoachDecisionTraceStage.decision,
          outcomeCode: 'PRACTICE_TECHNIQUE',
          knowledgeId: 'technique.ai_boundary',
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
