import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/application/observability_adapter_planner.dart';
import 'package:pool_os/application/transport_adapter_planner.dart';
import 'package:pool_os/application/application_bootstrap_host.dart';
import 'package:pool_os/application/application_service_wiring_planner.dart';
import 'package:pool_os/application/configuration_adapter_planner.dart';
import 'package:pool_os/application/end_to_end_application_composition_planner.dart';
import 'package:pool_os/application/flutter_application_adapter_planner.dart';
import 'package:pool_os/application/persistence_adapter_planner.dart';
import 'package:pool_os/application/product_feature_assembly_planner.dart';
import 'package:pool_os/application/production_startup_validation_planner.dart';
import 'package:pool_os/application/runtime_host_initializer.dart';
import 'package:pool_os/application/runtime_observability_integration_planner.dart';
import 'package:pool_os/application/ai_provider_adapter_planner.dart';
import 'package:pool_os/contracts/ai_coach_interaction_surface_contracts.dart';
import 'package:pool_os/contracts/ai_conversation_memory_contracts.dart';
import 'package:pool_os/contracts/ai_response_processing_contracts.dart';
import 'package:pool_os/contracts/application_bootstrap_contracts.dart';
import 'package:pool_os/contracts/coach_context_contracts.dart';
import 'package:pool_os/contracts/coach_decision_view_contracts.dart';
import 'package:pool_os/contracts/coach_planning_graph_contracts.dart';
import 'package:pool_os/contracts/dependency_composition_root_contracts.dart';
import 'package:pool_os/contracts/execution_outcome_projection_contracts.dart';
import 'package:pool_os/contracts/experience_projection_contracts.dart';
import 'package:pool_os/contracts/learning_eligibility_contracts.dart';
import 'package:pool_os/contracts/ordered_recommendation_view_contracts.dart';
import 'package:pool_os/contracts/player_model_contracts.dart';
import 'package:pool_os/contracts/player_profile_projection_contracts.dart';
import 'package:pool_os/contracts/product_shell_contracts.dart';
import 'package:pool_os/contracts/production_readiness_validation_contracts.dart';
import 'package:pool_os/contracts/recommendation_inbox_contracts.dart';
import 'package:pool_os/contracts/runtime_activation_coordination_contracts.dart';
import 'package:pool_os/contracts/runtime_activation_delivery_gate_contracts.dart';
import 'package:pool_os/contracts/runtime_activation_projection_contracts.dart';
import 'package:pool_os/contracts/runtime_composition_contracts.dart';
import 'package:pool_os/contracts/runtime_composition_coordination_contracts.dart';
import 'package:pool_os/contracts/runtime_configuration_environment_projection_contracts.dart';
import 'package:pool_os/contracts/runtime_delivery_projection_contracts.dart';
import 'package:pool_os/contracts/runtime_dependency_resolution_contracts.dart';
import 'package:pool_os/contracts/runtime_dispatch_contracts.dart';
import 'package:pool_os/contracts/runtime_health_diagnostics_projection_contracts.dart';
import 'package:pool_os/contracts/runtime_lifecycle_host_projection_contracts.dart';
import 'package:pool_os/contracts/runtime_lifecycle_projection_contracts.dart';
import 'package:pool_os/contracts/runtime_pipeline_contracts.dart';
import 'package:pool_os/contracts/runtime_service_activation_projection_contracts.dart';
import 'package:pool_os/contracts/runtime_service_composition_contracts.dart';
import 'package:pool_os/contracts/runtime_service_exposure_contracts.dart';
import 'package:pool_os/contracts/runtime_service_registry_contracts.dart';
import 'package:pool_os/contracts/runtime_validation_contracts.dart';
import 'package:pool_os/contracts/training_session_workspace_contracts.dart';
import 'package:pool_os/features/coach/domain/session_execution_coordinator.dart';
import 'package:pool_os/features/coach/domain/training_outcome_projector.dart';
import 'package:pool_os/features/coach/domain/training_session_builder.dart';

void main() {
  final fixture = _fixture('primary');

  test('observability adapter is deterministic and replay-safe', () {
    final first = fixture.plan();
    final second = fixture.plan();
    expect(second.toJson(), first.toJson());
    expect(first.digest, hasLength(64));
  });

  test('entries bind exact AI provider and health provenance', () {
    final plan = fixture.plan();
    expect(plan.aiProviderAdapterPlanId, fixture.aiProviderAdapterPlan.id);
    expect(
      plan.aiProviderAdapterPlanDigest,
      fixture.aiProviderAdapterPlan.digest,
    );
    expect(
        plan.runtimeHealthDiagnosticsProjectionId, fixture.healthProjection.id);
    expect(
      plan.runtimeHealthDiagnosticsProjectionDigest,
      fixture.healthProjection.digest,
    );
    for (var position = 0; position < plan.entries.length; position++) {
      final entry = plan.entries[position];
      final sourceEntry = fixture.aiProviderAdapterPlan.entries[position];
      expect(entry.featureId, sourceEntry.featureId);
      expect(
        entry.aiProviderAdapterEntryId,
        sourceEntry.aiProviderAdapterEntryId,
      );
      expect(entry.position, position);
      expect(
        entry.aiProviderAdapterPlanDigest,
        fixture.aiProviderAdapterPlan.digest,
      );
      expect(entry.runtimeHealthDiagnosticsProjectionDigest,
          fixture.healthProjection.digest);
      expect(entry.provenanceDigest, hasLength(64));
    }
  });

  test('canonical order ignores supplied collection order', () {
    final source = fixture.plan();
    final replay = ObservabilityAdapterPlan.create(
      aiProviderAdapterPlan: fixture.aiProviderAdapterPlan,
      runtimeHealthDiagnosticsProjection: fixture.healthProjection,
      entries: source.entries.reversed.toList(),
      log: source.log.reversed.toList(),
    );
    expect(replay.toJson(), source.toJson());
  });

  test('entries and exact structural log are immutable', () {
    final plan = fixture.plan();
    expect(() => plan.entries.add(plan.entries.first), throwsUnsupportedError);
    expect(() => plan.log.add(plan.log.first), throwsUnsupportedError);
    expect(
      plan.log.map((entry) => entry.phase),
      ObservabilityAdapterLogPhase.values,
    );
  });

  test('stale AI provider and health bindings fail closed', () {
    final source = fixture.plan();
    final staleAIProvider = ObservabilityAdapterEntry.create(
      featureId: source.entries.first.featureId,
      aiProviderAdapterEntryId: source.entries.first.aiProviderAdapterEntryId,
      position: source.entries.first.position,
      aiProviderAdapterPlanDigest: 'stale',
      runtimeHealthDiagnosticsProjectionDigest: fixture.healthProjection.digest,
    );
    final staleHealth = ObservabilityAdapterEntry.create(
      featureId: source.entries.first.featureId,
      aiProviderAdapterEntryId: source.entries.first.aiProviderAdapterEntryId,
      position: source.entries.first.position,
      aiProviderAdapterPlanDigest: fixture.aiProviderAdapterPlan.digest,
      runtimeHealthDiagnosticsProjectionDigest: 'stale',
    );
    for (final stale in [staleAIProvider, staleHealth]) {
      expect(
        () => ObservabilityAdapterPlan.create(
          aiProviderAdapterPlan: fixture.aiProviderAdapterPlan,
          runtimeHealthDiagnosticsProjection: fixture.healthProjection,
          entries: [stale, source.entries.last],
          log: source.log,
        ),
        throwsArgumentError,
      );
    }
  });

  test('duplicate, orphan, and incomplete feature coverage fail closed', () {
    final source = fixture.plan();
    expect(
      () => ObservabilityAdapterPlan.create(
        aiProviderAdapterPlan: fixture.aiProviderAdapterPlan,
        runtimeHealthDiagnosticsProjection: fixture.healthProjection,
        entries: [source.entries.first, source.entries.first],
        log: source.log,
      ),
      throwsArgumentError,
    );
    final orphan = ObservabilityAdapterEntry.create(
      featureId: source.entries.first.featureId,
      aiProviderAdapterEntryId: 'orphan-ai-provider-adapter',
      position: source.entries.first.position,
      aiProviderAdapterPlanDigest: fixture.aiProviderAdapterPlan.digest,
      runtimeHealthDiagnosticsProjectionDigest: fixture.healthProjection.digest,
    );
    expect(
      () => ObservabilityAdapterPlan.create(
        aiProviderAdapterPlan: fixture.aiProviderAdapterPlan,
        runtimeHealthDiagnosticsProjection: fixture.healthProjection,
        entries: [orphan, source.entries.last],
        log: source.log,
      ),
      throwsArgumentError,
    );
    expect(
      () => ObservabilityAdapterPlan.create(
        aiProviderAdapterPlan: fixture.aiProviderAdapterPlan,
        runtimeHealthDiagnosticsProjection: fixture.healthProjection,
        entries: [source.entries.first],
        log: source.log,
      ),
      throwsArgumentError,
    );
  });

  test('malformed structural log fails closed', () {
    final source = fixture.plan();
    expect(
      () => ObservabilityAdapterPlan.create(
        aiProviderAdapterPlan: fixture.aiProviderAdapterPlan,
        runtimeHealthDiagnosticsProjection: fixture.healthProjection,
        entries: source.entries,
        log: List.filled(
          ObservabilityAdapterLogPhase.values.length,
          source.log.first,
        ),
      ),
      throwsArgumentError,
    );
  });

  test('output excludes observability mappings and inputs stay unchanged', () {
    final aiProvider = fixture.aiProviderAdapterPlan.toJson();
    final health = fixture.healthProjection.toJson();
    final json = fixture.plan().toJson().toString();
    expect(fixture.aiProviderAdapterPlan.toJson(), aiProvider);
    expect(fixture.healthProjection.toJson(), health);
    for (final forbidden in [
      'runtimeServiceId',
      'diagnosticsEntryId',
      'metricId',
      'traceId',
      'telemetryId',
      'capabilityId',
      'providerId',
      'prompt',
      'model',
    ]) {
      expect(json, isNot(contains(forbidden)));
    }
  });
}

class _Fixture {
  const _Fixture({
    required this.aiProviderAdapterPlan,
    required this.healthProjection,
  });

  final AIProviderAdapterPlan aiProviderAdapterPlan;
  final RuntimeHealthDiagnosticsProjectionContract healthProjection;

  ObservabilityAdapterPlan plan() => const ObservabilityAdapterPlanner().plan(
        aiProviderAdapterPlan: aiProviderAdapterPlan,
        runtimeHealthDiagnosticsProjection: healthProjection,
      );
}

_Fixture _fixture(String suffix) {
  final composition = const RuntimeCompositionEngine().compose(
    nodes: [
      RuntimeNodeContract(
        id: 'a.$suffix',
        kind: RuntimeNodeKind.session,
        sourceContractVersion: 1,
        sourceDigest: 'a.$suffix',
      ),
      RuntimeNodeContract(
        id: 'b.$suffix',
        kind: RuntimeNodeKind.activation,
        sourceContractVersion: 1,
        sourceDigest: 'b.$suffix',
      ),
    ],
    edges: [RuntimeEdgeContract(fromId: 'a.$suffix', toId: 'b.$suffix')],
  );
  final pipeline = const RuntimePipelineEngine().build(
    composition: composition,
    stages: [
      PipelineStage(id: 'first.$suffix', runtimeNodeId: 'a.$suffix'),
      PipelineStage(id: 'second.$suffix', runtimeNodeId: 'b.$suffix'),
    ],
    transitions: [
      PipelineTransition(
        fromStageId: 'first.$suffix',
        toStageId: 'second.$suffix',
      ),
    ],
  );
  final coordination = const RuntimeCompositionCoordinator().coordinate(
    composition: composition,
    pipeline: pipeline,
    mappings: [
      RuntimeCoordinationMapping(
        runtimeNodeId: 'a.$suffix',
        pipelineStageId: 'first.$suffix',
      ),
      RuntimeCoordinationMapping(
        runtimeNodeId: 'b.$suffix',
        pipelineStageId: 'second.$suffix',
      ),
    ],
  );
  final dispatch = const RuntimeDispatcher().project(coordination);
  final activationProjection =
      const RuntimeActivationProjector().project(dispatch);
  final lifecycle =
      const RuntimeLifecycleProjector().project(activationProjection);
  final services = const RuntimeServiceCompositionEngine().compose(composition);
  final registry = const RuntimeServiceRegistryBuilder().build(services);
  final dependencies = const RuntimeDependencyResolutionBuilder().build(
    registry: registry,
    runtimeComposition: composition,
  );
  final activation =
      const RuntimeActivationCoordinator().coordinate(dependencies);
  final exposure = const RuntimeServiceExposureProjector().project(
    activationCoordination: activation,
    registry: registry,
  );
  final delivery = const RuntimeDeliveryProjector().project(exposure);
  final validation = const RuntimeValidator().validate(
    artifactDigests: {
      'composition': composition.digest,
      'delivery': delivery.digest,
      'graph': 'g',
      'state': 's',
      'transition': 't',
    },
  );
  final bootstrap = const ApplicationBootstrapBuilder().build(
    runtimeComposition: composition,
    runtimeValidation: validation,
    runtimeDelivery: delivery,
  );
  final root = const DependencyCompositionRootBuilder().build(
    bootstrap: bootstrap,
    runtimeServiceComposition: services,
  );
  final bootstrapHostRun = const ApplicationBootstrapHost().start(
    bootstrap: bootstrap,
    compositionRoot: root,
  );
  final serviceActivation = const RuntimeServiceActivationProjector().project(
    dependencyCompositionRoot: root,
    runtimeActivationCoordination: activation,
  );
  final host = const RuntimeLifecycleHostProjector().project(
    runtimeServiceActivationProjection: serviceActivation,
    runtimeLifecycleProjection: lifecycle,
  );
  final health = const RuntimeHealthDiagnosticsProjector().project(
    runtimeLifecycleHostProjection: host,
    runtimeValidation: validation,
  );
  final configuration =
      const RuntimeConfigurationEnvironmentProjector().project(
    runtimeHealth: health,
    runtimeDelivery: delivery,
  );
  final readiness = const ProductionReadinessProjector().project(
    configuration: configuration,
    runtimeValidation: validation,
  );
  final gate = const RuntimeActivationDeliveryGateProjector().project(
    readiness: readiness,
    runtimeDelivery: delivery,
  );
  final startup = const ProductionStartupValidationPlanner().plan(
    bootstrapHostRun: bootstrapHostRun,
    activationDeliveryGate: gate,
  );
  final initialization = const RuntimeHostInitializer().plan(
    activationProjection: serviceActivation,
    lifecycleHostProjection: host,
  );
  final wiring = const ApplicationServiceWiringPlanner().plan(
    initializationPlan: initialization,
    serviceComposition: services,
  );
  final shell = const ProductShellBuilder().build(
    exposure: exposure,
    delivery: delivery,
    policy: ProductNavigationPolicy.create(
      entries: [
        ProductNavigationPolicyEntry(
          featureId: 'home.$suffix',
          category: ProductNavigationCategory.home,
          position: 0,
          visible: true,
        ),
        ProductNavigationPolicyEntry(
          featureId: 'training.$suffix',
          category: ProductNavigationCategory.training,
          position: 1,
          visible: true,
          parentFeatureId: 'home.$suffix',
        ),
      ],
    ),
  );
  final assembly = const ProductFeatureAssemblyPlanner().plan(
    wiringPlan: wiring,
    productShell: shell,
  );
  final observability = const RuntimeObservabilityIntegrationPlanner().plan(
    healthProjection: health,
    featureAssemblyPlan: assembly,
  );
  final compositionPlan = const EndToEndApplicationCompositionPlanner().plan(
    startupValidationPlan: startup,
    observabilityIntegrationPlan: observability,
  );
  final flutterPlan = const FlutterApplicationAdapterPlanner().plan(
    applicationCompositionPlan: compositionPlan,
    bootstrapHostRun: bootstrapHostRun,
  );
  final configurationAdapterPlan = const ConfigurationAdapterPlanner().plan(
    configurationProjection: configuration,
    flutterApplicationAdapterPlan: flutterPlan,
  );
  final persistenceAdapterPlan = const PersistenceAdapterPlanner().plan(
    configurationAdapterPlan: configurationAdapterPlan,
    runtimeDeliveryProjection: delivery,
  );
  final transportAdapterPlan = const TransportAdapterPlanner().plan(
    persistenceAdapterPlan: persistenceAdapterPlan,
    runtimeServiceExposure: exposure,
  );
  final memory = const AIConversationMemoryProjector().project([_processing()]);
  final interactionSurface = const AICoachInteractionSurfaceProjector().project(
    executionOutcome: _executionOutcome(),
    conversationMemory: memory,
  );
  final aiProviderAdapterPlan = const AIProviderAdapterPlanner().plan(
    transportAdapterPlan: transportAdapterPlan,
    aiCoachInteractionSurface: interactionSurface,
  );
  return _Fixture(
    aiProviderAdapterPlan: aiProviderAdapterPlan,
    healthProjection: health,
  );
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
