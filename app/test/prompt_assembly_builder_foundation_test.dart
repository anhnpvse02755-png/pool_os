import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/ai_capability_registry_contracts.dart';
import 'package:pool_os/contracts/ai_session_contracts.dart';
import 'package:pool_os/contracts/coach_adaptation_projection_contracts.dart';
import 'package:pool_os/contracts/coach_context_contracts.dart';
import 'package:pool_os/contracts/coach_planning_graph_contracts.dart';
import 'package:pool_os/contracts/experience_projection_contracts.dart';
import 'package:pool_os/contracts/learning_eligibility_contracts.dart';
import 'package:pool_os/contracts/ordered_recommendation_view_contracts.dart';
import 'package:pool_os/contracts/player_model_contracts.dart';
import 'package:pool_os/contracts/prompt_assembly_contracts.dart';
import 'package:pool_os/contracts/training_outcome_projection_contracts.dart';
import 'package:pool_os/features/coach/application/prompt_assembly_builder.dart';
import 'package:pool_os/features/coach/domain/coach_adaptation_projector.dart';
import 'package:pool_os/features/coach/domain/session_execution_coordinator.dart';
import 'package:pool_os/features/coach/domain/training_session_builder.dart';

void main() {
  test('assembly contains only canonical references and no prose', () {
    final fixture = _fixture();
    final assembly = const PromptAssemblyBuilder().build(
      session: fixture.session,
      context: fixture.context,
      planningGraph: fixture.graph,
      recommendationView: fixture.view,
      adaptation: fixture.adaptation,
      registry: fixture.registry,
      capabilityId: 'chat_generation',
      metadata: const {'locale': 'vi', 'mode': 'structured'},
    );
    expect(assembly.header.capabilityId, 'chat_generation');
    expect(assembly.sessionDigest, fixture.session.digest);
    expect(assembly.planningDigest, fixture.graph.digest);
    expect(assembly.recommendationDigest, fixture.view.digest);
    expect(assembly.adaptationDigest, fixture.adaptation.digest);
    final json = jsonEncode(assembly.toJson());
    expect(json, isNot(contains('promptText')));
    expect(json, isNot(contains('provider')));
    expect(json, isNot(contains('response')));
  });

  test('same references and reordered collections replay to same digest', () {
    final fixture = _fixture();
    final first = const PromptAssemblyBuilder().build(
      session: fixture.session,
      context: fixture.context,
      planningGraph: fixture.graph,
      recommendationView: fixture.view,
      adaptation: fixture.adaptation,
      registry: fixture.registry,
      capabilityId: 'chat_generation',
      metadata: const {'b': '2', 'a': '1'},
    );
    final second = const PromptAssemblyBuilder().build(
      session: fixture.session,
      context: fixture.context,
      planningGraph: fixture.graph,
      recommendationView: fixture.view,
      adaptation: fixture.adaptation,
      registry: fixture.registry,
      capabilityId: 'chat_generation',
      metadata: const {'a': '1', 'b': '2'},
    );
    expect(second.digest, first.digest);
    expect(second.toJson(), first.toJson());
  });

  test('stale, missing, and duplicate references fail loudly', () {
    final fixture = _fixture();
    final other = _fixture(playerId: 'player.other');
    expect(
      () => const PromptAssemblyBuilder().build(
        session: fixture.session,
        context: other.context,
        planningGraph: fixture.graph,
        recommendationView: fixture.view,
        adaptation: fixture.adaptation,
        registry: fixture.registry,
        capabilityId: 'chat_generation',
      ),
      throwsArgumentError,
    );
    expect(
      () => const PromptAssemblyBuilder().build(
        session: fixture.session,
        context: fixture.context,
        planningGraph: fixture.graph,
        recommendationView: fixture.view,
        adaptation: fixture.adaptation,
        registry: fixture.registry,
        capabilityId: 'unknown',
      ),
      throwsStateError,
    );
    expect(
      () => PromptAssemblyContract.create(
        capabilityId: 'chat_generation',
        sessionDigest: 's',
        registryDigest: 'r',
        contextDigest: 'c',
        planningDigest: 'p',
        recommendationDigest: 'q',
        adaptationDigest: 'a',
        contextId: 'c',
        planId: 'p',
        recommendationId: 'r',
        executionId: 'e',
        planningNodeIds: const ['duplicate', 'duplicate'],
        recommendationIds: const ['recommendation'],
        executionIds: const [],
        adaptationIds: const ['recommendation'],
        metadata: const {},
      ),
      throwsArgumentError,
    );
  });

  test('assembly and references are immutable', () {
    final fixture = _fixture();
    final assembly = const PromptAssemblyBuilder().build(
      session: fixture.session,
      context: fixture.context,
      planningGraph: fixture.graph,
      recommendationView: fixture.view,
      adaptation: fixture.adaptation,
      registry: fixture.registry,
      capabilityId: 'chat_generation',
    );
    expect(() => assembly.planningNodeIds.clear(), throwsUnsupportedError);
    expect(() => assembly.metadata.clear(), throwsUnsupportedError);
  });
}

_Fixture _fixture({String playerId = 'player.prompt'}) =>
    _Fixture(playerId: playerId);

class _Fixture {
  _Fixture({String playerId = 'player.prompt'}) {
    context = _context(playerId);
    node = CoachPlanningNodeContract.create(
      playerId: playerId,
      sessionId: 'session.prompt',
      kind: CoachPlanningNodeKind.recommendation,
      semanticId: 'recommendation.prompt',
      semanticDigest: 'recommendation-digest',
    );
    graph = CoachPlanningGraphContract.create(
        context: context,
        sessionId: 'session.prompt',
        nodes: [node],
        edges: const []);
    view = OrderedRecommendationViewContract.create(
      context: context,
      items: const [
        RecommendationPriorityItemContract(
          position: 1,
          recommendationId: 'recommendation.prompt',
          recommendationDigest: 'recommendation-digest',
          band: RecommendationPriorityBand.pendingRecommendation,
          reasons: [RecommendationPriorityReason.noExecutionRecorded],
          executionId: null,
          executionDigest: null,
        )
      ],
    );
    final sessionContract = const TrainingSessionBuilder().build(
        context: context, planningGraph: graph, recommendationView: view);
    final execution = const SessionExecutionCoordinator()
        .project(session: sessionContract, executions: const []);
    final outcome = TrainingOutcomeProjectionContract.create(
      sessionExecution: execution,
      items: const [
        TrainingOutcomeItemContract(
          position: 1,
          recommendationId: 'recommendation.prompt',
          kind: TrainingOutcomeKind.pending,
          executionRecordId: null,
        )
      ],
    );
    adaptation = const CoachAdaptationProjector()
        .project(context: context, outcomeProjection: outcome);
    session = AISessionContract.create(
      contextId: context.digest,
      planId: 'plan.prompt',
      recommendationId: 'recommendation.prompt',
      executionId: 'execution.prompt',
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
        )
      ],
    );
  }
  late CoachContextContract context;
  late CoachPlanningNodeContract node;
  late CoachPlanningGraphContract graph;
  late OrderedRecommendationViewContract view;
  late CoachAdaptationProjectionContract adaptation;
  late AISessionContract session;
  late AICapabilityRegistryContract registry;
}

CoachContextContract _context(String playerId) {
  final progress = PlayerProgressSnapshot.create(
    playerId: playerId,
    knowledgeVersion: 'knowledge.prompt/1',
    knowledgeDigest: 'prompt-knowledge',
    sourceDecisionReferences: const [],
    state: PlayerModelState(
        mastery: const [],
        mistakes: const [],
        preferences: const [],
        historyReferences: const []),
  );
  final event = ExperienceEventContract(
    eventId: 'prompt.event',
    playerId: playerId,
    sessionId: 'session.prompt',
    occurredAt: DateTime.utc(2026, 7, 22),
    kind: ExperienceEventKind.techniqueProgress,
    knowledgeId: 'technique.prompt',
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
