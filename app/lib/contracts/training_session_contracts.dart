import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/coach_context_contracts.dart';
import 'package:pool_os/contracts/coach_planning_graph_contracts.dart';
import 'package:pool_os/contracts/ordered_recommendation_view_contracts.dart';

const trainingSessionContractVersion = 1;
const trainingSessionItemContractVersion = 1;
const trainingSessionPolicyVersion = 'training-session-builder/1.0.0';

class TrainingSessionItemContract {
  const TrainingSessionItemContract({
    required this.position,
    required this.recommendationId,
    required this.recommendationDigest,
    required this.planningNodeId,
    required this.contextDigest,
  });

  final int position;
  final String recommendationId;
  final String recommendationDigest;
  final String planningNodeId;
  final String contextDigest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': trainingSessionItemContractVersion,
        'position': position,
        'recommendationId': recommendationId,
        'recommendationDigest': recommendationDigest,
        'planningNodeId': planningNodeId,
        'contextDigest': contextDigest,
      };
}

class TrainingSessionContract {
  const TrainingSessionContract._({
    required this.id,
    required this.playerId,
    required this.sessionId,
    required this.items,
    required this.contextDigest,
    required this.planningGraphDigest,
    required this.recommendationViewDigest,
    required this.digest,
  });

  factory TrainingSessionContract.create({
    required CoachContextContract context,
    required CoachPlanningGraphContract planningGraph,
    required OrderedRecommendationViewContract recommendationView,
    required List<TrainingSessionItemContract> items,
  }) {
    if (planningGraph.playerId != context.profile.playerId ||
        planningGraph.versions.contextDigest != context.digest ||
        recommendationView.playerId != context.profile.playerId ||
        recommendationView.contextDigest != context.digest ||
        items.length != recommendationView.items.length) {
      throw ArgumentError('Training Session inputs are stale or foreign.');
    }
    final nodes = {
      for (final node in planningGraph.nodes)
        if (node.kind == CoachPlanningNodeKind.recommendation)
          node.semanticId: node,
    };
    final ordered = [...items]
      ..sort((a, b) => a.position.compareTo(b.position));
    final seen = <String>{};
    for (var index = 0; index < ordered.length; index++) {
      final item = ordered[index];
      final node = nodes[item.recommendationId];
      final viewItem = recommendationView.items[index];
      if (item.position != index + 1 ||
          node == null ||
          item.recommendationId != viewItem.recommendationId ||
          item.recommendationDigest != viewItem.recommendationDigest ||
          item.planningNodeId != node.id ||
          item.contextDigest != context.digest ||
          !seen.add(item.recommendationId)) {
        throw ArgumentError('Training Session item provenance is invalid.');
      }
    }
    final payload = {
      'schemaVersion': trainingSessionContractVersion,
      'playerId': context.profile.playerId,
      'sessionId': planningGraph.sessionId,
      'items': ordered.map((item) => item.toJson()).toList(),
      'contextDigest': context.digest,
      'planningGraphDigest': planningGraph.digest,
      'recommendationViewDigest': recommendationView.digest,
      'policyVersion': trainingSessionPolicyVersion,
    };
    final digest = _digest(payload);
    return TrainingSessionContract._(
      id: 'training-session.${digest.substring(0, 16)}',
      playerId: context.profile.playerId,
      sessionId: planningGraph.sessionId,
      items: List.unmodifiable(ordered),
      contextDigest: context.digest,
      planningGraphDigest: planningGraph.digest,
      recommendationViewDigest: recommendationView.digest,
      digest: digest,
    );
  }

  final String id;
  final String playerId;
  final String sessionId;
  final List<TrainingSessionItemContract> items;
  final String contextDigest;
  final String planningGraphDigest;
  final String recommendationViewDigest;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': trainingSessionContractVersion,
        'id': id,
        'playerId': playerId,
        'sessionId': sessionId,
        'items': items.map((item) => item.toJson()).toList(),
        'contextDigest': contextDigest,
        'planningGraphDigest': planningGraphDigest,
        'recommendationViewDigest': recommendationViewDigest,
        'policyVersion': trainingSessionPolicyVersion,
        'digest': digest,
      };
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
