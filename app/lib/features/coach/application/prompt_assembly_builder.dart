import 'package:pool_os/contracts/ai_capability_registry_contracts.dart';
import 'package:pool_os/contracts/ai_session_contracts.dart';
import 'package:pool_os/contracts/coach_adaptation_projection_contracts.dart';
import 'package:pool_os/contracts/coach_context_contracts.dart';
import 'package:pool_os/contracts/coach_planning_graph_contracts.dart';
import 'package:pool_os/contracts/ordered_recommendation_view_contracts.dart';
import 'package:pool_os/contracts/prompt_assembly_contracts.dart';

class PromptAssemblyBuilder {
  const PromptAssemblyBuilder();

  PromptAssemblyContract build({
    required AISessionContract session,
    required CoachContextContract context,
    required CoachPlanningGraphContract planningGraph,
    required OrderedRecommendationViewContract recommendationView,
    required CoachAdaptationProjectionContract adaptation,
    required AICapabilityRegistryContract registry,
    required String capabilityId,
    Map<String, String> metadata = const {},
  }) {
    if (session.contextDigest != context.digest ||
        planningGraph.versions.contextDigest != context.digest ||
        recommendationView.contextDigest != context.digest ||
        adaptation.contextDigest != context.digest ||
        planningGraph.playerId != context.profile.playerId ||
        recommendationView.playerId != context.profile.playerId ||
        adaptation.playerId != context.profile.playerId) {
      throw ArgumentError('Prompt Assembly inputs are stale or mixed.');
    }
    final binding = registry.resolveForSession(
      session: session,
      capabilityId: capabilityId,
    );
    final nodeIds = planningGraph.nodes.map((node) => node.id).toList();
    final recommendationIds =
        recommendationView.items.map((item) => item.recommendationId).toList();
    final executionIds = recommendationView.items
        .map((item) => item.executionId)
        .whereType<String>()
        .toList();
    final adaptationIds =
        adaptation.items.map((item) => item.recommendationId).toList();
    if (nodeIds.any((id) => id.trim().isEmpty) ||
        recommendationIds.isEmpty ||
        recommendationIds.length != adaptationIds.length ||
        !recommendationIds.toSet().containsAll(adaptationIds)) {
      throw ArgumentError('Prompt Assembly references are incomplete.');
    }
    return PromptAssemblyContract.create(
      capabilityId: binding.capabilityId,
      sessionDigest: session.digest,
      registryDigest: binding.registryDigest,
      contextDigest: context.digest,
      planningDigest: planningGraph.digest,
      recommendationDigest: recommendationView.digest,
      adaptationDigest: adaptation.digest,
      contextId: session.contextId,
      planId: session.planId,
      recommendationId: session.recommendationId,
      executionId: session.executionId,
      planningNodeIds: nodeIds,
      recommendationIds: recommendationIds,
      executionIds: executionIds,
      adaptationIds: adaptationIds,
      metadata: metadata,
    );
  }
}
