import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/coach_context_contracts.dart';
import 'package:pool_os/contracts/coach_decision_view_contracts.dart';
import 'package:pool_os/contracts/coach_planning_graph_contracts.dart';
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

void main() {
  final context = _context();
  final decisionView = const CoachDecisionViewProjector()
      .project(workspace: _workspace(context), context: context);
  final recommendationView = _recommendationView(context);

  test('projects immutable deterministic inbox references', () {
    final first = const RecommendationInboxProjector().project(
        decisionView: decisionView, recommendationView: recommendationView);
    final second = const RecommendationInboxProjector().project(
        decisionView: decisionView, recommendationView: recommendationView);
    expect(second.toJson(), first.toJson());
    expect(first.entries.single.position, 1);
    expect(first.entries.single.planningNodeId,
        decisionView.entries.single.planningNodeId);
    expect(
        () => first.entries.add(first.entries.single), throwsUnsupportedError);
  });

  test('preserves recommendation metadata and provenance', () {
    final result = const RecommendationInboxProjector().project(
        decisionView: decisionView, recommendationView: recommendationView);
    final entry = result.entries.single;
    expect(entry.recommendationId,
        recommendationView.items.single.recommendationId);
    expect(entry.recommendationDigest,
        recommendationView.items.single.recommendationDigest);
    expect(entry.decisionViewDigest, decisionView.digest);
    expect(entry.recommendationViewDigest, recommendationView.digest);
    expect(
        entry.priorityBand, RecommendationPriorityBand.pendingRecommendation);
  });

  test('rejects stale recommendation view provenance', () {
    final item = recommendationView.items.single;
    final entry = RecommendationInboxEntry(
      inboxEntryId: 'entry',
      recommendationId: item.recommendationId,
      recommendationDigest: item.recommendationDigest,
      decisionViewDigest: decisionView.digest,
      recommendationViewDigest: 'stale',
      playerId: context.profile.playerId,
      position: item.position,
      planningNodeId: decisionView.entries.single.planningNodeId,
      priorityBand: item.band,
      executionId: item.executionId,
      executionDigest: item.executionDigest,
    );
    expect(
        () => RecommendationInboxContract.create(
            decisionView: decisionView,
            recommendationView: recommendationView,
            entries: [entry]),
        throwsArgumentError);
  });

  test('rejects orphan recommendation position', () {
    final orphan = OrderedRecommendationViewContract.create(
      context: context,
      items: [
        const RecommendationPriorityItemContract(
          position: 1,
          recommendationId: 'recommendation-1',
          recommendationDigest: 'recommendation-1-digest',
          band: RecommendationPriorityBand.pendingRecommendation,
          reasons: [RecommendationPriorityReason.noExecutionRecorded],
          executionId: null,
          executionDigest: null,
        ),
        const RecommendationPriorityItemContract(
          position: 2,
          recommendationId: 'recommendation-2',
          recommendationDigest: 'recommendation-2-digest',
          band: RecommendationPriorityBand.pendingRecommendation,
          reasons: [RecommendationPriorityReason.noExecutionRecorded],
          executionId: null,
          executionDigest: null,
        ),
      ],
    );
    expect(
        () => const RecommendationInboxProjector()
            .project(decisionView: decisionView, recommendationView: orphan),
        throwsArgumentError);
  });

  test('does not mutate source projections', () {
    final beforeDecision = decisionView.toJson();
    final beforeRecommendation = recommendationView.toJson();
    const RecommendationInboxProjector().project(
        decisionView: decisionView, recommendationView: recommendationView);
    expect(decisionView.toJson(), beforeDecision);
    expect(recommendationView.toJson(), beforeRecommendation);
  });
}

CoachContextContract _context() {
  final progress = PlayerProgressSnapshot.create(
    playerId: 'player.inbox',
    knowledgeVersion: 'knowledge.inbox/1',
    knowledgeDigest: 'knowledge.inbox.digest',
    sourceDecisionReferences: const ['decision.inbox'],
    state: PlayerModelState(
        mastery: const [],
        mistakes: const [],
        preferences: const [],
        historyReferences: const []),
  );
  final event = ExperienceEventContract(
      eventId: 'event.inbox',
      playerId: 'player.inbox',
      sessionId: 'session.inbox',
      occurredAt: DateTime.utc(2026, 7, 22),
      kind: ExperienceEventKind.techniqueProgress,
      knowledgeId: 'training.target',
      state: 'inProgress',
      sourceDecisionReference: 'decision.inbox');
  return CoachContextContract.create(
    profile: PlayerProfileContract(
        playerId: 'player.inbox', dominantHand: 'right', locale: 'vi'),
    progress: progress,
    experience: ExperienceSnapshot.create(
      playerId: 'player.inbox',
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
}

OrderedRecommendationViewContract _recommendationView(
        CoachContextContract context) =>
    OrderedRecommendationViewContract.create(
      context: context,
      items: [
        const RecommendationPriorityItemContract(
          position: 1,
          recommendationId: 'recommendation.inbox',
          recommendationDigest: 'recommendation.inbox.digest',
          band: RecommendationPriorityBand.pendingRecommendation,
          reasons: [RecommendationPriorityReason.noExecutionRecorded],
          executionId: null,
          executionDigest: null,
        ),
      ],
    );

TrainingSessionWorkspaceContract _workspace(CoachContextContract context) {
  final node = CoachPlanningNodeContract.create(
      playerId: context.profile.playerId,
      sessionId: 'session.inbox',
      kind: CoachPlanningNodeKind.decision,
      semanticId: 'decision.inbox',
      semanticDigest: 'decision.inbox.digest');
  final graph = CoachPlanningGraphContract.create(
      context: context,
      sessionId: 'session.inbox',
      nodes: [node],
      edges: const []);
  final runtime = const RuntimeCompositionEngine().compose(nodes: const [
    RuntimeNodeContract(
        id: 'inbox',
        kind: RuntimeNodeKind.session,
        sourceContractVersion: 1,
        sourceDigest: 'inbox')
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
