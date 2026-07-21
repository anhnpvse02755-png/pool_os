import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/coach_context_contracts.dart';
import 'package:pool_os/contracts/coach_decision_view_contracts.dart';
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
  final workspace = _workspace(context);

  test('decision view is immutable, canonical, and deterministic', () {
    final first = const CoachDecisionViewProjector()
        .project(workspace: workspace, context: context);
    final second = const CoachDecisionViewProjector()
        .project(workspace: workspace, context: context);
    expect(second.toJson(), first.toJson());
    expect(
        () => first.entries.add(first.entries.first), throwsUnsupportedError);
  });

  test('view binds workspace and context provenance', () {
    final result = const CoachDecisionViewProjector()
        .project(workspace: workspace, context: context);
    expect(result.workspaceDigest, workspace.digest);
    expect(result.coachContextDigest, context.digest);
    expect(result.playerId, context.profile.playerId);
  });

  test('canonical ordering follows workspace positions', () {
    final result = const CoachDecisionViewProjector()
        .project(workspace: workspace, context: context);
    expect(result.entries.single.planningNodeId,
        workspace.entries.single.planningNodeId);
    expect(result.entries.single.position, 0);
  });

  test('stale workspace or context fails closed', () {
    final result = const CoachDecisionViewProjector()
        .project(workspace: workspace, context: context);
    final entry = CoachDecisionViewEntry(
      playerId: result.playerId,
      position: 0,
      planningNodeId: result.entries.single.planningNodeId,
      workspaceDigest: 'stale-workspace',
      coachContextDigest: 'stale-context',
    );
    expect(
      () => CoachDecisionViewContract.create(
          workspace: workspace, context: context, entries: [entry]),
      throwsArgumentError,
    );
  });

  test('foreign player fails closed', () {
    expect(
      () => const CoachDecisionViewProjector().project(
          workspace: workspace, context: _context(playerId: 'foreign')),
      throwsArgumentError,
    );
  });

  test('duplicate position or workspace node fails closed', () {
    final result = const CoachDecisionViewProjector()
        .project(workspace: workspace, context: context);
    final entry = CoachDecisionViewEntry(
      playerId: result.playerId,
      position: 0,
      planningNodeId: 'missing-node',
      workspaceDigest: result.workspaceDigest,
      coachContextDigest: result.coachContextDigest,
    );
    expect(
      () => CoachDecisionViewContract.create(
          workspace: workspace, context: context, entries: [entry]),
      throwsArgumentError,
    );
  });

  test('projector does not mutate workspace or context', () {
    final beforeWorkspace = workspace.toJson();
    final beforeContext = context.toJson();
    const CoachDecisionViewProjector()
        .project(workspace: workspace, context: context);
    expect(workspace.toJson(), beforeWorkspace);
    expect(context.toJson(), beforeContext);
  });
}

CoachContextContract _context({String playerId = 'player.view'}) {
  final progress = PlayerProgressSnapshot.create(
    playerId: playerId,
    knowledgeVersion: 'knowledge.view/1',
    knowledgeDigest: 'knowledge.view.digest',
    sourceDecisionReferences: const ['decision.source'],
    state: PlayerModelState(
        mastery: const [],
        mistakes: const [],
        preferences: const [],
        historyReferences: const []),
  );
  final event = ExperienceEventContract(
      eventId: 'event.view',
      playerId: playerId,
      sessionId: 'session.view',
      occurredAt: DateTime.utc(2026, 7, 22),
      kind: ExperienceEventKind.techniqueProgress,
      knowledgeId: 'training.target',
      state: 'inProgress',
      sourceDecisionReference: 'decision.source');
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
        items: const []),
  );
}

TrainingSessionWorkspaceContract _workspace(CoachContextContract context) {
  final node = CoachPlanningNodeContract.create(
      playerId: context.profile.playerId,
      sessionId: 'session.view',
      kind: CoachPlanningNodeKind.decision,
      semanticId: 'decision.view',
      semanticDigest: 'decision.digest');
  final graph = CoachPlanningGraphContract.create(
      context: context,
      sessionId: 'session.view',
      nodes: [node],
      edges: const []);
  final runtime = const RuntimeCompositionEngine().compose(
    nodes: const [
      RuntimeNodeContract(
          id: 'a',
          kind: RuntimeNodeKind.session,
          sourceContractVersion: 1,
          sourceDigest: 'a')
    ],
    edges: const [],
  );
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
