import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/ai_coach_interaction_surface_contracts.dart';
import 'package:pool_os/contracts/ai_conversation_memory_contracts.dart';
import 'package:pool_os/contracts/ai_response_processing_contracts.dart';
import 'package:pool_os/contracts/coach_context_contracts.dart';
import 'package:pool_os/contracts/coach_decision_view_contracts.dart';
import 'package:pool_os/contracts/coach_planning_graph_contracts.dart';
import 'package:pool_os/contracts/execution_outcome_projection_contracts.dart';
import 'package:pool_os/contracts/experience_projection_contracts.dart';
import 'package:pool_os/contracts/learning_eligibility_contracts.dart';
import 'package:pool_os/contracts/ordered_recommendation_view_contracts.dart';
import 'package:pool_os/contracts/player_model_contracts.dart';
import 'package:pool_os/contracts/player_profile_projection_contracts.dart';
import 'package:pool_os/contracts/product_shell_contracts.dart';
import 'package:pool_os/contracts/recommendation_inbox_contracts.dart';
import 'package:pool_os/contracts/runtime_activation_coordination_contracts.dart';
import 'package:pool_os/contracts/runtime_composition_contracts.dart';
import 'package:pool_os/contracts/runtime_delivery_projection_contracts.dart';
import 'package:pool_os/contracts/runtime_dependency_resolution_contracts.dart';
import 'package:pool_os/contracts/runtime_service_composition_contracts.dart';
import 'package:pool_os/contracts/runtime_service_exposure_contracts.dart';
import 'package:pool_os/contracts/runtime_service_registry_contracts.dart';
import 'package:pool_os/contracts/training_session_workspace_contracts.dart';
import 'package:pool_os/features/coach/domain/session_execution_coordinator.dart';
import 'package:pool_os/features/coach/domain/training_outcome_projector.dart';
import 'package:pool_os/features/coach/domain/training_session_builder.dart';

void main() {
  final outcome = _executionOutcome();
  final memory = const AIConversationMemoryProjector().project([_processing()]);

  test('projects immutable deterministic interaction references', () {
    final first = const AICoachInteractionSurfaceProjector()
        .project(executionOutcome: outcome, conversationMemory: memory);
    final second = const AICoachInteractionSurfaceProjector()
        .project(executionOutcome: outcome, conversationMemory: memory);
    expect(second.toJson(), first.toJson());
    expect(first.entries.single.position, 1);
    expect(first.entries.single.playerId, outcome.playerId);
    expect(
        () => first.entries.add(first.entries.single), throwsUnsupportedError);
  });

  test('binds complete execution and memory provenance', () {
    final surface = const AICoachInteractionSurfaceProjector()
        .project(executionOutcome: outcome, conversationMemory: memory);
    final entry = surface.entries.single;
    expect(entry.executionOutcomeDigest, outcome.digest);
    expect(entry.conversationMemoryDigest, memory.digest);
    expect(entry.capabilityId, memory.capabilityId);
    expect(entry.processingDigest, memory.entries.single.processingDigest);
  });

  test('rejects stale digest binding', () {
    final source = memory.entries.single;
    final entry = AICoachInteractionEntry(
      interactionId: 'ai-coach-interaction.${source.id}',
      playerId: outcome.playerId,
      executionOutcomeDigest: outcome.digest,
      conversationMemoryDigest: 'stale',
      capabilityId: memory.capabilityId,
      position: source.position,
      processingDigest: source.processingDigest,
    );
    expect(
        () => AICoachInteractionSurfaceContract.create(
            executionOutcome: outcome,
            conversationMemory: memory,
            entries: [entry]),
        throwsArgumentError);
  });

  test('rejects count mismatch instead of inferring ownership', () {
    final twoInteractions = const AIConversationMemoryProjector()
        .project([_processing('a'), _processing('b')]);
    expect(
        () => const AICoachInteractionSurfaceProjector().project(
            executionOutcome: outcome, conversationMemory: twoInteractions),
        throwsArgumentError);
  });

  test('does not mutate source projections', () {
    final beforeOutcome = outcome.toJson();
    final beforeMemory = memory.toJson();
    const AICoachInteractionSurfaceProjector()
        .project(executionOutcome: outcome, conversationMemory: memory);
    expect(outcome.toJson(), beforeOutcome);
    expect(memory.toJson(), beforeMemory);
  });
}

AIResponseProcessingContract _processing([String suffix = 'single']) =>
    AIResponseProcessingContract.create(
      providerPayloadDigest: 'payload.$suffix',
      providerRequestDigest: 'request.$suffix',
      providerResultDigest: 'result.$suffix',
      capabilityId: 'chat_generation',
      processingMetadata: const {
        'providerId': 'stub/deterministic',
        'status': 'stubbed',
      },
    );

ExecutionOutcomeProjectionContract _executionOutcome() {
  final progress = PlayerProgressSnapshot.create(
    playerId: 'player.ai-surface',
    knowledgeVersion: 'knowledge.ai-surface/1',
    knowledgeDigest: 'knowledge.ai-surface.digest',
    sourceDecisionReferences: const ['decision.ai-surface'],
    state: PlayerModelState(
        mastery: const [],
        mistakes: const [],
        preferences: const [],
        historyReferences: const []),
  );
  final event = ExperienceEventContract(
      eventId: 'event.ai-surface',
      playerId: progress.playerId,
      sessionId: 'session.ai-surface',
      occurredAt: DateTime.utc(2026, 7, 22),
      kind: ExperienceEventKind.techniqueProgress,
      knowledgeId: 'training.target',
      state: 'inProgress',
      sourceDecisionReference: 'decision.ai-surface');
  final context = CoachContextContract.create(
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
        items: const []),
  );
  final node = CoachPlanningNodeContract.create(
      playerId: progress.playerId,
      sessionId: event.sessionId,
      kind: CoachPlanningNodeKind.recommendation,
      semanticId: 'recommendation.ai-surface',
      semanticDigest: 'recommendation.ai-surface.digest');
  final graph = CoachPlanningGraphContract.create(
      context: context,
      sessionId: event.sessionId,
      nodes: [node],
      edges: const []);
  final recommendationView = OrderedRecommendationViewContract.create(
    context: context,
    items: const [
      RecommendationPriorityItemContract(
        position: 1,
        recommendationId: 'recommendation.ai-surface',
        recommendationDigest: 'recommendation.ai-surface.digest',
        band: RecommendationPriorityBand.pendingRecommendation,
        reasons: [RecommendationPriorityReason.noExecutionRecorded],
        executionId: null,
        executionDigest: null,
      )
    ],
  );
  final workspace = _workspace(context, graph, node);
  final decisionView = const CoachDecisionViewProjector()
      .project(workspace: workspace, context: context);
  final inbox = const RecommendationInboxProjector().project(
      decisionView: decisionView, recommendationView: recommendationView);
  final session = const TrainingSessionBuilder().build(
      context: context,
      planningGraph: graph,
      recommendationView: recommendationView);
  final sessionExecution = const SessionExecutionCoordinator()
      .project(session: session, executions: const []);
  final trainingOutcome = const TrainingOutcomeProjector()
      .project(sessionExecution: sessionExecution, executions: const []);
  return const ExecutionOutcomeProjector()
      .project(inbox: inbox, executionResult: trainingOutcome);
}

TrainingSessionWorkspaceContract _workspace(CoachContextContract context,
    CoachPlanningGraphContract graph, CoachPlanningNodeContract node) {
  final runtime = const RuntimeCompositionEngine().compose(nodes: const [
    RuntimeNodeContract(
        id: 'ai-surface',
        kind: RuntimeNodeKind.session,
        sourceContractVersion: 1,
        sourceDigest: 'ai-surface')
  ], edges: const []);
  final services = const RuntimeServiceCompositionEngine().compose(runtime);
  final registry = const RuntimeServiceRegistryBuilder().build(services);
  final deps = const RuntimeDependencyResolutionBuilder()
      .build(registry: registry, runtimeComposition: runtime);
  final activation = const RuntimeActivationCoordinator().coordinate(deps);
  final exposure = const RuntimeServiceExposureProjector()
      .project(activationCoordination: activation, registry: registry);
  final delivery = const RuntimeDeliveryProjector().project(exposure);
  final policy = ProductNavigationPolicy.create(entries: const [
    ProductNavigationPolicyEntry(
        featureId: 'home',
        category: ProductNavigationCategory.home,
        position: 0,
        visible: true)
  ]);
  final shell = const ProductShellBuilder()
      .build(exposure: exposure, delivery: delivery, policy: policy);
  final profile = PlayerProfileProjectionContract.create(
    progress: context.progress,
    shell: shell,
    entries: [
      PlayerProfileEntry(
          playerId: context.profile.playerId,
          featureId: 'home',
          position: 0,
          progressDigest: context.progress.digest,
          shellDigest: shell.digest)
    ],
  );
  return TrainingSessionWorkspaceContract.create(
    profile: profile,
    trainingPlan: graph,
    entries: [
      TrainingWorkspaceEntry(
          playerId: context.profile.playerId,
          position: 0,
          planningNodeId: node.id,
          planningNodeDigest: node.semanticDigest,
          featureId: null,
          playerProfileDigest: profile.digest,
          trainingPlanDigest: graph.digest)
    ],
  );
}
