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
import 'package:pool_os/contracts/product_analytics_projection_contracts.dart';
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
  final fixture = _fixture();

  test('projects immutable deterministic analytics references', () {
    final first = fixture.project();
    final second = fixture.project();
    expect(second.toJson(), first.toJson());
    expect(first.entries.single.position, 1);
    expect(
      () => first.entries.add(first.entries.single),
      throwsUnsupportedError,
    );
  });

  test('binds all four approved projection inputs', () {
    final projection = fixture.project();
    final entry = projection.entries.single;
    expect(projection.profileDigest, fixture.profile.digest);
    expect(projection.recommendationDigest, fixture.inbox.digest);
    expect(projection.executionDigest, fixture.outcome.digest);
    expect(projection.interactionDigest, fixture.interaction.digest);
    expect(entry.playerId, fixture.profile.playerId);
    expect(entry.capabilityId, fixture.interaction.capabilityId);
    expect(
        entry.recommendationId, fixture.inbox.entries.single.recommendationId);
    expect(
      entry.executionOutcomeId,
      fixture.outcome.entries.single.executionOutcomeId,
    );
    expect(
        entry.interactionId, fixture.interaction.entries.single.interactionId);
  });

  test('rejects stale analytics provenance', () {
    final source = fixture.project().entries.single;
    final stale = ProductAnalyticsEntry(
      analyticsEntryId: source.analyticsEntryId,
      playerId: source.playerId,
      capabilityId: source.capabilityId,
      position: source.position,
      recommendationId: source.recommendationId,
      executionOutcomeId: source.executionOutcomeId,
      interactionId: source.interactionId,
      profileDigest: source.profileDigest,
      recommendationDigest: 'stale',
      executionDigest: source.executionDigest,
      interactionDigest: source.interactionDigest,
    );
    expect(
      () => ProductAnalyticsProjectionContract.create(
        profile: fixture.profile,
        recommendationInbox: fixture.inbox,
        executionOutcome: fixture.outcome,
        interactionSurface: fixture.interaction,
        entries: [stale],
      ),
      throwsArgumentError,
    );
  });

  test('rejects a foreign player profile', () {
    final foreign = _fixture('player.foreign');
    expect(
      () => const ProductAnalyticsProjector().project(
        profile: foreign.profile,
        recommendationInbox: fixture.inbox,
        executionOutcome: fixture.outcome,
        interactionSurface: fixture.interaction,
      ),
      throwsArgumentError,
    );
  });

  test('does not mutate any source projection', () {
    final profile = fixture.profile.toJson();
    final inbox = fixture.inbox.toJson();
    final outcome = fixture.outcome.toJson();
    final interaction = fixture.interaction.toJson();
    fixture.project();
    expect(fixture.profile.toJson(), profile);
    expect(fixture.inbox.toJson(), inbox);
    expect(fixture.outcome.toJson(), outcome);
    expect(fixture.interaction.toJson(), interaction);
  });
}

class _AnalyticsFixture {
  const _AnalyticsFixture({
    required this.profile,
    required this.inbox,
    required this.outcome,
    required this.interaction,
  });

  final PlayerProfileProjectionContract profile;
  final RecommendationInboxContract inbox;
  final ExecutionOutcomeProjectionContract outcome;
  final AICoachInteractionSurfaceContract interaction;

  ProductAnalyticsProjectionContract project() =>
      const ProductAnalyticsProjector().project(
        profile: profile,
        recommendationInbox: inbox,
        executionOutcome: outcome,
        interactionSurface: interaction,
      );
}

_AnalyticsFixture _fixture([String playerId = 'player.analytics']) {
  final progress = PlayerProgressSnapshot.create(
    playerId: playerId,
    knowledgeVersion: 'knowledge.analytics/1',
    knowledgeDigest: 'knowledge.analytics.digest',
    sourceDecisionReferences: const ['decision.analytics'],
    state: PlayerModelState(
      mastery: const [],
      mistakes: const [],
      preferences: const [],
      historyReferences: const [],
    ),
  );
  final event = ExperienceEventContract(
    eventId: 'event.analytics',
    playerId: playerId,
    sessionId: 'session.analytics',
    occurredAt: DateTime.utc(2026, 7, 22),
    kind: ExperienceEventKind.techniqueProgress,
    knowledgeId: 'training.target',
    state: 'inProgress',
    sourceDecisionReference: 'decision.analytics',
  );
  final context = CoachContextContract.create(
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
            sessionId: event.sessionId, events: [event])
      ],
    ),
    eligibility: LearningEligibilityProjection.create(
      knowledgeVersion: progress.knowledgeVersion,
      knowledgeDigest: progress.knowledgeDigest,
      items: const [],
    ),
  );
  final node = CoachPlanningNodeContract.create(
    playerId: playerId,
    sessionId: event.sessionId,
    kind: CoachPlanningNodeKind.recommendation,
    semanticId: 'recommendation.analytics',
    semanticDigest: 'recommendation.analytics.digest',
  );
  final graph = CoachPlanningGraphContract.create(
    context: context,
    sessionId: event.sessionId,
    nodes: [node],
    edges: const [],
  );
  final recommendationView = OrderedRecommendationViewContract.create(
    context: context,
    items: const [
      RecommendationPriorityItemContract(
        position: 1,
        recommendationId: 'recommendation.analytics',
        recommendationDigest: 'recommendation.analytics.digest',
        band: RecommendationPriorityBand.pendingRecommendation,
        reasons: [RecommendationPriorityReason.noExecutionRecorded],
        executionId: null,
        executionDigest: null,
      ),
    ],
  );
  final workspaceFixture = _workspace(context, graph, node);
  final decisionView = const CoachDecisionViewProjector().project(
    workspace: workspaceFixture.workspace,
    context: context,
  );
  final inbox = const RecommendationInboxProjector().project(
    decisionView: decisionView,
    recommendationView: recommendationView,
  );
  final session = const TrainingSessionBuilder().build(
    context: context,
    planningGraph: graph,
    recommendationView: recommendationView,
  );
  final sessionExecution = const SessionExecutionCoordinator().project(
    session: session,
    executions: const [],
  );
  final trainingOutcome = const TrainingOutcomeProjector().project(
    sessionExecution: sessionExecution,
    executions: const [],
  );
  final outcome = const ExecutionOutcomeProjector().project(
    inbox: inbox,
    executionResult: trainingOutcome,
  );
  final memory = const AIConversationMemoryProjector().project([
    AIResponseProcessingContract.create(
      providerPayloadDigest: 'payload.analytics',
      providerRequestDigest: 'request.analytics',
      providerResultDigest: 'result.analytics',
      capabilityId: 'chat_generation',
      processingMetadata: const {
        'providerId': 'stub/deterministic',
        'status': 'stubbed',
      },
    ),
  ]);
  final interaction = const AICoachInteractionSurfaceProjector().project(
    executionOutcome: outcome,
    conversationMemory: memory,
  );
  return _AnalyticsFixture(
    profile: workspaceFixture.profile,
    inbox: inbox,
    outcome: outcome,
    interaction: interaction,
  );
}

class _WorkspaceFixture {
  const _WorkspaceFixture({required this.profile, required this.workspace});

  final PlayerProfileProjectionContract profile;
  final TrainingSessionWorkspaceContract workspace;
}

_WorkspaceFixture _workspace(
  CoachContextContract context,
  CoachPlanningGraphContract graph,
  CoachPlanningNodeContract node,
) {
  final runtime = const RuntimeCompositionEngine().compose(nodes: const [
    RuntimeNodeContract(
      id: 'analytics',
      kind: RuntimeNodeKind.session,
      sourceContractVersion: 1,
      sourceDigest: 'analytics',
    ),
  ], edges: const []);
  final services = const RuntimeServiceCompositionEngine().compose(runtime);
  final registry = const RuntimeServiceRegistryBuilder().build(services);
  final dependencies = const RuntimeDependencyResolutionBuilder().build(
    registry: registry,
    runtimeComposition: runtime,
  );
  final activation =
      const RuntimeActivationCoordinator().coordinate(dependencies);
  final exposure = const RuntimeServiceExposureProjector().project(
    activationCoordination: activation,
    registry: registry,
  );
  final delivery = const RuntimeDeliveryProjector().project(exposure);
  final policy = ProductNavigationPolicy.create(entries: const [
    ProductNavigationPolicyEntry(
      featureId: 'home',
      category: ProductNavigationCategory.home,
      position: 0,
      visible: true,
    ),
  ]);
  final shell = const ProductShellBuilder().build(
    exposure: exposure,
    delivery: delivery,
    policy: policy,
  );
  final profile = PlayerProfileProjectionContract.create(
    progress: context.progress,
    shell: shell,
    entries: [
      PlayerProfileEntry(
        playerId: context.profile.playerId,
        featureId: 'home',
        position: 0,
        progressDigest: context.progress.digest,
        shellDigest: shell.digest,
      ),
    ],
  );
  final workspace = TrainingSessionWorkspaceContract.create(
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
        trainingPlanDigest: graph.digest,
      ),
    ],
  );
  return _WorkspaceFixture(profile: profile, workspace: workspace);
}
