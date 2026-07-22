import 'package:flutter_test/flutter_test.dart';
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
import 'package:pool_os/contracts/training_outcome_projection_contracts.dart';
import 'package:pool_os/contracts/training_session_workspace_contracts.dart';
import 'package:pool_os/features/coach/domain/session_execution_coordinator.dart';
import 'package:pool_os/features/coach/domain/training_outcome_projector.dart';
import 'package:pool_os/features/coach/domain/training_session_builder.dart';

void main() {
  final fixture = _fixture();

  test('projects immutable deterministic execution outcome references', () {
    final first = const ExecutionOutcomeProjector()
        .project(inbox: fixture.inbox, executionResult: fixture.outcome);
    final second = const ExecutionOutcomeProjector()
        .project(inbox: fixture.inbox, executionResult: fixture.outcome);
    expect(second.toJson(), first.toJson());
    expect(first.entries.single.position, 1);
    expect(first.entries.single.executionStatus, TrainingOutcomeKind.pending);
    expect(
        () => first.entries.add(first.entries.single), throwsUnsupportedError);
  });

  test('binds inbox and execution result provenance', () {
    final result = const ExecutionOutcomeProjector()
        .project(inbox: fixture.inbox, executionResult: fixture.outcome);
    expect(result.inboxDigest, fixture.inbox.digest);
    expect(result.executionResultDigest, fixture.outcome.digest);
    expect(result.playerId, fixture.inbox.playerId);
    expect(result.entries.single.recommendationId,
        fixture.inbox.entries.single.recommendationId);
  });

  test('rejects stale provenance', () {
    final source = fixture.outcome.items.single;
    final entry = ExecutionOutcomeEntry(
      executionOutcomeId: 'execution-outcome.stale',
      recommendationId: source.recommendationId,
      inboxDigest: fixture.inbox.digest,
      executionResultDigest: 'stale',
      playerId: fixture.inbox.playerId,
      position: source.position,
      executionStatus: source.kind,
      outcomeReference: source.executionRecordId,
    );
    expect(
        () => ExecutionOutcomeProjectionContract.create(
            inbox: fixture.inbox,
            executionResult: fixture.outcome,
            entries: [entry]),
        throwsArgumentError);
  });

  test('rejects foreign player', () {
    final foreign = _fixture(playerId: 'player.foreign');
    expect(
        () => const ExecutionOutcomeProjector()
            .project(inbox: fixture.inbox, executionResult: foreign.outcome),
        throwsArgumentError);
  });

  test('does not mutate source projections', () {
    final beforeInbox = fixture.inbox.toJson();
    final beforeOutcome = fixture.outcome.toJson();
    const ExecutionOutcomeProjector()
        .project(inbox: fixture.inbox, executionResult: fixture.outcome);
    expect(fixture.inbox.toJson(), beforeInbox);
    expect(fixture.outcome.toJson(), beforeOutcome);
  });
}

_Fixture _fixture({String playerId = 'player.execution-outcome'}) {
  final progress = PlayerProgressSnapshot.create(
    playerId: playerId,
    knowledgeVersion: 'knowledge.execution-outcome/1',
    knowledgeDigest: 'knowledge.execution-outcome.digest',
    sourceDecisionReferences: const ['decision.execution-outcome'],
    state: PlayerModelState(
        mastery: const [],
        mistakes: const [],
        preferences: const [],
        historyReferences: const []),
  );
  final event = ExperienceEventContract(
      eventId: 'event.execution-outcome',
      playerId: playerId,
      sessionId: 'session.execution-outcome',
      occurredAt: DateTime.utc(2026, 7, 22),
      kind: ExperienceEventKind.techniqueProgress,
      knowledgeId: 'training.target',
      state: 'inProgress',
      sourceDecisionReference: 'decision.execution-outcome');
  final context = CoachContextContract.create(
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
        items: const []),
  );
  final node = CoachPlanningNodeContract.create(
      playerId: playerId,
      sessionId: event.sessionId,
      kind: CoachPlanningNodeKind.recommendation,
      semanticId: 'recommendation.execution-outcome',
      semanticDigest: 'recommendation.execution-outcome.digest');
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
        recommendationId: 'recommendation.execution-outcome',
        recommendationDigest: 'recommendation.execution-outcome.digest',
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
  final outcome = const TrainingOutcomeProjector()
      .project(sessionExecution: sessionExecution, executions: const []);
  return _Fixture(inbox, outcome);
}

TrainingSessionWorkspaceContract _workspace(CoachContextContract context,
    CoachPlanningGraphContract graph, CoachPlanningNodeContract node) {
  final runtime = const RuntimeCompositionEngine().compose(nodes: const [
    RuntimeNodeContract(
        id: 'execution-outcome',
        kind: RuntimeNodeKind.session,
        sourceContractVersion: 1,
        sourceDigest: 'execution-outcome')
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

class _Fixture {
  const _Fixture(this.inbox, this.outcome);

  final RecommendationInboxContract inbox;
  final TrainingOutcomeProjectionContract outcome;
}
