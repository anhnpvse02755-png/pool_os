import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/ai_capability_registry_contracts.dart';
import 'package:pool_os/contracts/ai_runtime_activation_gate_contracts.dart';
import 'package:pool_os/contracts/ai_session_contracts.dart';
import 'package:pool_os/contracts/coach_adaptation_projection_contracts.dart';
import 'package:pool_os/contracts/coach_context_contracts.dart';
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
  late _Fixture fixture;

  setUp(() => fixture = _Fixture());

  test('valid inputs activate deterministically without AI invocation', () {
    const gate = AIRuntimeActivationGate();
    final first = gate.evaluate(
      session: fixture.session,
      adaptation: fixture.adaptation,
      registry: fixture.registry,
      capabilityId: 'chat_generation',
    );
    final replay = gate.evaluate(
      session: fixture.session,
      adaptation: fixture.adaptation,
      registry: fixture.registry,
      capabilityId: 'chat_generation',
    );
    expect(first.decision, AIRuntimeActivationDecision.activated);
    expect(first.reason, AIRuntimeActivationReason.activated);
    expect(replay.digest, first.digest);
    expect(jsonEncode(replay.toJson()), jsonEncode(first.toJson()));
    expect(first.toJson(), isNot(contains('prompt')));
    expect(first.toJson(), isNot(contains('response')));
  });

  test('unavailable capability fails closed', () {
    final result = const AIRuntimeActivationGate().evaluate(
      session: fixture.session,
      adaptation: fixture.adaptation,
      registry: fixture.registry,
      capabilityId: 'vision',
    );
    expect(result.decision, AIRuntimeActivationDecision.notActivated);
    expect(result.reason, AIRuntimeActivationReason.capabilityUnavailable);
  });

  test('stale context and incompatible registry fail closed', () {
    final other = _Fixture(playerId: 'player.other');
    final stale = const AIRuntimeActivationGate().evaluate(
      session: fixture.session,
      adaptation: other.adaptation,
      registry: fixture.registry,
      capabilityId: 'chat_generation',
    );
    expect(stale.decision, AIRuntimeActivationDecision.notActivated);
    expect(stale.reason, AIRuntimeActivationReason.staleContext);

    final incompatible = AICapabilityRegistryContract.create(
      aiContractVersion: aiSessionContractVersion,
      minimumSupportedAIContractVersion: 'ai-session/9.0.0',
      capabilities: const [
        AICapabilityDefinition(
          capabilityId: 'chat_generation',
          capabilityContractVersion: 1,
          minimumAIContractVersion: 'ai-session/9.0.0',
          requiredRuntimeContracts: requiredAISessionRuntimeContracts,
          compatibilityRules: {},
        ),
      ],
    );
    final rejected = const AIRuntimeActivationGate().evaluate(
      session: fixture.session,
      adaptation: fixture.adaptation,
      registry: incompatible,
      capabilityId: 'chat_generation',
    );
    expect(rejected.decision, AIRuntimeActivationDecision.notActivated);
    expect(rejected.reason, AIRuntimeActivationReason.contractMismatch);
  });

  test('duplicate activation and invalid direct decision fail closed', () {
    const gate = AIRuntimeActivationGate();
    final first = gate.evaluate(
      session: fixture.session,
      adaptation: fixture.adaptation,
      registry: fixture.registry,
      capabilityId: 'chat_generation',
    );
    final duplicate = gate.evaluate(
      session: fixture.session,
      adaptation: fixture.adaptation,
      registry: fixture.registry,
      capabilityId: 'chat_generation',
      priorActivationKeys: [first.activationKey],
    );
    expect(duplicate.reason, AIRuntimeActivationReason.duplicateActivation);
    expect(
      () => AIRuntimeActivationGateContract.create(
        decision: AIRuntimeActivationDecision.activated,
        reason: AIRuntimeActivationReason.contractMismatch,
        sessionDigest: 'session',
        adaptationDigest: 'adaptation',
        registryDigest: 'registry',
        capabilityId: 'chat_generation',
        activationKey: 'key',
      ),
      throwsArgumentError,
    );
  });
}

class _Fixture {
  _Fixture({String playerId = 'player.activation'}) {
    context = _context(playerId: playerId);
    adaptation = _adaptation(context);
    session = AISessionContract.create(
      contextId: context.digest,
      planId: 'plan.activation',
      recommendationId: 'recommendation.activation',
      executionId: 'execution.activation',
      knowledgeVersion: context.versions.knowledgeVersion,
      knowledgeDigest: context.versions.knowledgeDigest,
      contextDigest: context.digest,
      planDigest: 'plan-digest',
      recommendationDigest: 'recommendation-digest',
      executionDigest: 'execution-digest',
      provenance: AISessionProvenance(
        knowledgeVersion: context.versions.knowledgeVersion,
        knowledgeDigest: context.versions.knowledgeDigest,
        contextDigest: context.digest,
        planDigest: 'plan-digest',
        recommendationDigest: 'recommendation-digest',
        executionDigest: 'execution-digest',
      ),
      requiredRuntimeContracts: requiredAISessionRuntimeContracts,
      minimumAIContractVersion: minimumAIContractVersion,
    );
    registry = AICapabilityRegistryContract.create(
      aiContractVersion: aiSessionContractVersion,
      minimumSupportedAIContractVersion: minimumAIContractVersion,
      capabilities: const [
        AICapabilityDefinition(
          capabilityId: 'chat_generation',
          capabilityContractVersion: 1,
          minimumAIContractVersion: minimumAIContractVersion,
          requiredRuntimeContracts: requiredAISessionRuntimeContracts,
          compatibilityRules: {},
        ),
      ],
    );
  }

  late CoachContextContract context;
  late CoachAdaptationProjectionContract adaptation;
  late AISessionContract session;
  late AICapabilityRegistryContract registry;
}

CoachAdaptationProjectionContract _adaptation(CoachContextContract context) {
  final execution = _sessionExecution(context);
  final outcome = TrainingOutcomeProjectionContract.create(
    sessionExecution: execution,
    items: const [
      TrainingOutcomeItemContract(
        position: 1,
        recommendationId: 'recommendation.activation',
        kind: TrainingOutcomeKind.pending,
        executionRecordId: null,
      ),
    ],
  );
  return const CoachAdaptationProjector().project(
    context: context,
    outcomeProjection: outcome,
  );
}

TrainingSessionExecutionContract _sessionExecution(
    CoachContextContract context) {
  final node = CoachPlanningNodeContract.create(
    playerId: context.profile.playerId,
    sessionId: 'session.activation',
    kind: CoachPlanningNodeKind.recommendation,
    semanticId: 'recommendation.activation',
    semanticDigest: 'recommendation-digest',
  );
  final graph = CoachPlanningGraphContract.create(
    context: context,
    sessionId: 'session.activation',
    nodes: [node],
    edges: const [],
  );
  final view = OrderedRecommendationViewContract.create(
    context: context,
    items: const [
      RecommendationPriorityItemContract(
        position: 1,
        recommendationId: 'recommendation.activation',
        recommendationDigest: 'recommendation-digest',
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

CoachContextContract _context({String playerId = 'player.activation'}) {
  final progress = PlayerProgressSnapshot.create(
    playerId: playerId,
    knowledgeVersion: 'knowledge.activation/1',
    knowledgeDigest: 'activation-digest',
    sourceDecisionReferences: const [],
    state: PlayerModelState(
      mastery: const [],
      mistakes: const [],
      preferences: const [],
      historyReferences: const [],
    ),
  );
  final event = ExperienceEventContract(
    eventId: 'activation.event',
    playerId: playerId,
    sessionId: 'session.activation',
    occurredAt: DateTime.utc(2026, 7, 21),
    kind: ExperienceEventKind.techniqueProgress,
    knowledgeId: 'technique.activation',
    state: 'inProgress',
    sourceDecisionReference: 'source',
  );
  return CoachContextContract.create(
    profile: PlayerProfileContract(
      playerId: playerId,
      dominantHand: 'right',
      locale: 'vi',
    ),
    progress: progress,
    experience: ExperienceSnapshot.create(
      playerId: playerId,
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
      items: const [],
    ),
  );
}
