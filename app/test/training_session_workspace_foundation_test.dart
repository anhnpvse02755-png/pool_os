import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/coach_context_contracts.dart';
import 'package:pool_os/contracts/coach_planning_graph_contracts.dart';
import 'package:pool_os/contracts/experience_projection_contracts.dart';
import 'package:pool_os/contracts/learning_eligibility_contracts.dart';
import 'package:pool_os/contracts/player_model_contracts.dart';
import 'package:pool_os/contracts/player_profile_projection_contracts.dart';
import 'package:pool_os/contracts/product_shell_contracts.dart';
import 'package:pool_os/contracts/runtime_activation_coordination_contracts.dart';
import 'package:pool_os/contracts/runtime_composition_contracts.dart';
import 'package:pool_os/contracts/runtime_delivery_projection_contracts.dart';
import 'package:pool_os/contracts/runtime_dependency_resolution_contracts.dart';
import 'package:pool_os/contracts/runtime_service_composition_contracts.dart';
import 'package:pool_os/contracts/runtime_service_exposure_contracts.dart';
import 'package:pool_os/contracts/runtime_service_registry_contracts.dart';
import 'package:pool_os/contracts/training_session_workspace_contracts.dart';

void main() {
  final context = _context();
  final graph = _graph(context);
  final profile = _profileProjection();

  test('workspace projection is immutable, canonical, and deterministic', () {
    final first = const TrainingSessionWorkspaceProjector()
        .project(profile: profile, trainingPlan: graph);
    final second = const TrainingSessionWorkspaceProjector()
        .project(profile: profile, trainingPlan: graph);
    expect(second.toJson(), first.toJson());
    expect(first.entries.map((entry) => entry.position), [0, 1, 2]);
    expect(() => first.entries.clear(), throwsUnsupportedError);
  });

  test('workspace binds player profile and training plan provenance', () {
    final result = const TrainingSessionWorkspaceProjector()
        .project(profile: profile, trainingPlan: graph);
    expect(result.playerId, profile.playerId);
    expect(result.playerProfileDigest, profile.digest);
    expect(result.trainingPlanDigest, graph.digest);
    expect(result.entries.every((entry) => entry.playerId == profile.playerId),
        isTrue);
  });

  test('workspace preserves canonical planning node order', () {
    final result = const TrainingSessionWorkspaceProjector()
        .project(profile: profile, trainingPlan: graph);
    final ids = [...graph.nodes.map((node) => node.id)]..sort();
    expect(result.entries.map((entry) => entry.planningNodeId), ids);
  });

  test('stale profile or plan fails closed', () {
    final result = const TrainingSessionWorkspaceProjector()
        .project(profile: profile, trainingPlan: graph);
    final entries = [...result.entries];
    entries[0] = TrainingWorkspaceEntry(
      playerId: entries[0].playerId,
      position: entries[0].position,
      planningNodeId: entries[0].planningNodeId,
      planningNodeDigest: entries[0].planningNodeDigest,
      featureId: entries[0].featureId,
      playerProfileDigest: 'stale-profile',
      trainingPlanDigest: 'stale-plan',
    );
    expect(
      () => TrainingSessionWorkspaceContract.create(
          profile: profile, trainingPlan: graph, entries: entries),
      throwsArgumentError,
    );
  });

  test('foreign player fails closed', () {
    final otherProfile = _profileProjection(playerId: 'foreign');
    expect(
      () => const TrainingSessionWorkspaceProjector()
          .project(profile: otherProfile, trainingPlan: graph),
      throwsArgumentError,
    );
  });

  test('duplicate workspace position or node fails closed', () {
    final result = const TrainingSessionWorkspaceProjector()
        .project(profile: profile, trainingPlan: graph);
    final entries = [...result.entries];
    entries[1] = TrainingWorkspaceEntry(
      playerId: entries[1].playerId,
      position: entries[0].position,
      planningNodeId: entries[0].planningNodeId,
      planningNodeDigest: entries[1].planningNodeDigest,
      featureId: entries[1].featureId,
      playerProfileDigest: entries[1].playerProfileDigest,
      trainingPlanDigest: entries[1].trainingPlanDigest,
    );
    expect(
      () => TrainingSessionWorkspaceContract.create(
          profile: profile, trainingPlan: graph, entries: entries),
      throwsArgumentError,
    );
  });

  test('orphan training item fails closed', () {
    final result = const TrainingSessionWorkspaceProjector()
        .project(profile: profile, trainingPlan: graph);
    final entries = [...result.entries];
    entries[2] = TrainingWorkspaceEntry(
      playerId: entries[2].playerId,
      position: entries[2].position,
      planningNodeId: 'missing-node',
      planningNodeDigest: entries[2].planningNodeDigest,
      featureId: entries[2].featureId,
      playerProfileDigest: entries[2].playerProfileDigest,
      trainingPlanDigest: entries[2].trainingPlanDigest,
    );
    expect(
      () => TrainingSessionWorkspaceContract.create(
          profile: profile, trainingPlan: graph, entries: entries),
      throwsArgumentError,
    );
  });

  test('projector leaves profile and plan unchanged', () {
    final beforeProfile = profile.toJson();
    final beforeGraph = graph.toJson();
    const TrainingSessionWorkspaceProjector()
        .project(profile: profile, trainingPlan: graph);
    expect(profile.toJson(), beforeProfile);
    expect(graph.toJson(), beforeGraph);
  });
}

CoachContextContract _context() {
  const playerId = 'player.workspace';
  final progress = PlayerProgressSnapshot.create(
    playerId: playerId,
    knowledgeVersion: 'knowledge.workspace/1',
    knowledgeDigest: 'knowledge.workspace.digest',
    sourceDecisionReferences: const ['decision.source'],
    state: PlayerModelState(
      mastery: const [],
      mistakes: const [],
      preferences: const [],
      historyReferences: const [],
    ),
  );
  final event = ExperienceEventContract(
    eventId: 'event.workspace',
    playerId: playerId,
    sessionId: 'session.workspace',
    occurredAt: DateTime.utc(2026, 7, 22, 10),
    kind: ExperienceEventKind.techniqueProgress,
    knowledgeId: 'training.target',
    state: 'inProgress',
    sourceDecisionReference: 'decision.source',
  );
  final experience = ExperienceSnapshot.create(
    playerId: playerId,
    playerProgressDigest: progress.digest,
    knowledgeVersion: progress.knowledgeVersion,
    knowledgeDigest: progress.knowledgeDigest,
    timeline: ExperienceTimelineProjection.create([event]),
    sessions: [
      SessionSummaryProjection.create(
          sessionId: event.sessionId, events: [event])
    ],
  );
  return CoachContextContract.create(
    profile: PlayerProfileContract(
        playerId: playerId, dominantHand: 'right', locale: 'vi'),
    progress: progress,
    experience: experience,
    eligibility: LearningEligibilityProjection.create(
      knowledgeVersion: progress.knowledgeVersion,
      knowledgeDigest: progress.knowledgeDigest,
      items: const [],
    ),
  );
}

CoachPlanningGraphContract _graph(CoachContextContract context) {
  final nodes = [
    CoachPlanningNodeContract.create(
      playerId: context.profile.playerId,
      sessionId: 'session.workspace',
      kind: CoachPlanningNodeKind.decision,
      semanticId: 'decision.workspace',
      semanticDigest: 'decision.digest',
    ),
    CoachPlanningNodeContract.create(
      playerId: context.profile.playerId,
      sessionId: 'session.workspace',
      kind: CoachPlanningNodeKind.recommendation,
      semanticId: 'recommendation.workspace',
      semanticDigest: 'recommendation.digest',
    ),
    CoachPlanningNodeContract.create(
      playerId: context.profile.playerId,
      sessionId: 'session.workspace',
      kind: CoachPlanningNodeKind.execution,
      semanticId: 'execution.workspace',
      semanticDigest: 'execution.digest',
    ),
  ];
  return CoachPlanningGraphContract.create(
    context: context,
    sessionId: 'session.workspace',
    nodes: nodes,
    edges: [
      CoachPlanningEdgeContract.create(
        kind: CoachPlanningEdgeKind.recommendationDependency,
        fromNodeId: nodes[0].id,
        toNodeId: nodes[1].id,
      ),
      CoachPlanningEdgeContract.create(
        kind: CoachPlanningEdgeKind.executionDependency,
        fromNodeId: nodes[1].id,
        toNodeId: nodes[2].id,
      ),
    ],
  );
}

PlayerProfileProjectionContract _profileProjection(
    {String playerId = 'player.workspace'}) {
  final progress = PlayerProgressSnapshot.create(
    playerId: playerId,
    knowledgeVersion: 'knowledge.workspace/1',
    knowledgeDigest: 'knowledge.workspace.digest',
    sourceDecisionReferences: const ['decision.source'],
    state: PlayerModelState(
      mastery: const [],
      mistakes: const [],
      preferences: const [],
      historyReferences: const [],
    ),
  );
  final shell = ProductShellContractTestFactory.shell();
  return PlayerProfileProjectionContract.create(
    progress: progress,
    shell: shell,
    entries: [
      for (final node in shell.nodes)
        PlayerProfileEntry(
          playerId: playerId,
          featureId: node.featureId,
          position: node.position,
          progressDigest: progress.digest,
          shellDigest: shell.digest,
        ),
    ],
  );
}

class ProductShellContractTestFactory {
  static ProductShellContract shell() {
    final policy = ProductNavigationPolicy.create(entries: const [
      ProductNavigationPolicyEntry(
          featureId: 'home',
          category: ProductNavigationCategory.home,
          position: 0,
          visible: true),
      ProductNavigationPolicyEntry(
          featureId: 'training',
          category: ProductNavigationCategory.training,
          position: 1,
          visible: true),
      ProductNavigationPolicyEntry(
          featureId: 'coach',
          category: ProductNavigationCategory.coach,
          position: 2,
          visible: true),
    ]);
    final runtime = const RuntimeCompositionEngine().compose(
      nodes: const [
        RuntimeNodeContract(
            id: 'a',
            kind: RuntimeNodeKind.session,
            sourceContractVersion: 1,
            sourceDigest: 'a'),
        RuntimeNodeContract(
            id: 'b',
            kind: RuntimeNodeKind.toolInvocation,
            sourceContractVersion: 1,
            sourceDigest: 'b'),
        RuntimeNodeContract(
            id: 'c',
            kind: RuntimeNodeKind.promptAssembly,
            sourceContractVersion: 1,
            sourceDigest: 'c'),
      ],
      edges: const [
        RuntimeEdgeContract(fromId: 'a', toId: 'b'),
        RuntimeEdgeContract(fromId: 'b', toId: 'c'),
      ],
    );
    final services = const RuntimeServiceCompositionEngine().compose(runtime);
    final registry = const RuntimeServiceRegistryBuilder().build(services);
    final dependencies = const RuntimeDependencyResolutionBuilder()
        .build(registry: registry, runtimeComposition: runtime);
    final activation =
        const RuntimeActivationCoordinator().coordinate(dependencies);
    final exposure = const RuntimeServiceExposureProjector()
        .project(activationCoordination: activation, registry: registry);
    final delivery = const RuntimeDeliveryProjector().project(exposure);
    return const ProductShellBuilder().build(
      exposure: exposure,
      delivery: delivery,
      policy: policy,
    );
  }
}
