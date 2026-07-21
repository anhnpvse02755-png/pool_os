import 'package:pool_os/contracts/coach_context_contracts.dart';
import 'package:pool_os/contracts/coach_planning_graph_contracts.dart';
import 'package:pool_os/contracts/ordered_recommendation_view_contracts.dart';
import 'package:pool_os/contracts/training_session_contracts.dart';

class TrainingSessionBuilder {
  const TrainingSessionBuilder();

  TrainingSessionContract build({
    required CoachContextContract context,
    required CoachPlanningGraphContract planningGraph,
    required OrderedRecommendationViewContract recommendationView,
  }) {
    final nodes = {
      for (final node in planningGraph.nodes)
        if (node.kind == CoachPlanningNodeKind.recommendation)
          node.semanticId: node,
    };
    final items = <TrainingSessionItemContract>[];
    for (final viewItem in recommendationView.items) {
      final node = nodes[viewItem.recommendationId];
      if (node == null ||
          node.semanticDigest != viewItem.recommendationDigest) {
        throw ArgumentError('Training Session has an orphan Recommendation.');
      }
      items.add(TrainingSessionItemContract(
        position: viewItem.position,
        recommendationId: viewItem.recommendationId,
        recommendationDigest: viewItem.recommendationDigest,
        planningNodeId: node.id,
        contextDigest: context.digest,
      ));
    }
    return TrainingSessionContract.create(
      context: context,
      planningGraph: planningGraph,
      recommendationView: recommendationView,
      items: items,
    );
  }
}
