import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/coach_planning_graph_contracts.dart';
import 'package:pool_os/contracts/player_profile_projection_contracts.dart';

const trainingSessionWorkspaceContractVersion = 1;

class TrainingWorkspaceEntry {
  const TrainingWorkspaceEntry({
    required this.playerId,
    required this.position,
    required this.planningNodeId,
    required this.planningNodeDigest,
    required this.featureId,
    required this.playerProfileDigest,
    required this.trainingPlanDigest,
  });

  final String playerId;
  final int position;
  final String planningNodeId;
  final String planningNodeDigest;
  final String? featureId;
  final String playerProfileDigest;
  final String trainingPlanDigest;

  Map<String, dynamic> toJson() => {
        'playerId': playerId,
        'position': position,
        'planningNodeId': planningNodeId,
        'planningNodeDigest': planningNodeDigest,
        'featureId': featureId,
        'playerProfileDigest': playerProfileDigest,
        'trainingPlanDigest': trainingPlanDigest,
      };
}

class TrainingSessionWorkspaceContract {
  const TrainingSessionWorkspaceContract._({
    required this.id,
    required this.workspaceId,
    required this.playerId,
    required this.playerProfileDigest,
    required this.trainingPlanDigest,
    required this.entries,
    required this.digest,
  });

  factory TrainingSessionWorkspaceContract.create({
    required PlayerProfileProjectionContract profile,
    required CoachPlanningGraphContract trainingPlan,
    required List<TrainingWorkspaceEntry> entries,
  }) {
    if (profile.playerId != trainingPlan.playerId ||
        profile.entries.isEmpty ||
        trainingPlan.nodes.isEmpty) {
      throw ArgumentError('Training workspace inputs are stale or foreign.');
    }
    final ordered = [...entries]
      ..sort((left, right) => left.position.compareTo(right.position));
    final nodesById = {
      for (final node in trainingPlan.nodes) node.id: node,
    };
    final positions = ordered.map((entry) => entry.position).toSet();
    final planningNodeIds =
        ordered.map((entry) => entry.planningNodeId).toSet();
    if (ordered.length != trainingPlan.nodes.length ||
        positions.length != ordered.length ||
        planningNodeIds.length != ordered.length) {
      throw ArgumentError(
          'Training workspace entries are incomplete or duplicate.');
    }
    final profileFeatures = {
      for (final entry in profile.entries) entry.featureId,
    };
    for (var position = 0; position < ordered.length; position++) {
      final entry = ordered[position];
      final node = nodesById[entry.planningNodeId];
      if (node == null ||
          entry.position != position ||
          entry.playerId != profile.playerId ||
          node.playerId != profile.playerId ||
          node.sessionId != trainingPlan.sessionId ||
          entry.planningNodeDigest != node.semanticDigest ||
          entry.playerProfileDigest != profile.digest ||
          entry.trainingPlanDigest != trainingPlan.digest ||
          (entry.featureId != null &&
              !profileFeatures.contains(entry.featureId))) {
        throw ArgumentError('Training workspace provenance is invalid.');
      }
    }
    final payload = {
      'schemaVersion': trainingSessionWorkspaceContractVersion,
      'workspaceId': 'training-workspace.${trainingPlan.sessionId}',
      'playerId': profile.playerId,
      'playerProfileDigest': profile.digest,
      'trainingPlanDigest': trainingPlan.digest,
      'entries': ordered.map((entry) => entry.toJson()).toList(),
    };
    final digest = _digest(payload);
    return TrainingSessionWorkspaceContract._(
      id: 'training-workspace.${digest.substring(0, 16)}',
      workspaceId: 'training-workspace.${trainingPlan.sessionId}',
      playerId: profile.playerId,
      playerProfileDigest: profile.digest,
      trainingPlanDigest: trainingPlan.digest,
      entries: List.unmodifiable(ordered),
      digest: digest,
    );
  }

  final String id;
  final String workspaceId;
  final String playerId;
  final String playerProfileDigest;
  final String trainingPlanDigest;
  final List<TrainingWorkspaceEntry> entries;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': trainingSessionWorkspaceContractVersion,
        'id': id,
        'workspaceId': workspaceId,
        'playerId': playerId,
        'playerProfileDigest': playerProfileDigest,
        'trainingPlanDigest': trainingPlanDigest,
        'entries': entries.map((entry) => entry.toJson()).toList(),
        'digest': digest,
      };
}

class TrainingSessionWorkspaceProjector {
  const TrainingSessionWorkspaceProjector();

  TrainingSessionWorkspaceContract project({
    required PlayerProfileProjectionContract profile,
    required CoachPlanningGraphContract trainingPlan,
  }) {
    final profileFeatures = {
      for (final entry in profile.entries) entry.featureId,
    };
    final nodes = [...trainingPlan.nodes]
      ..sort((left, right) => left.id.compareTo(right.id));
    final entries = [
      for (var position = 0; position < nodes.length; position++)
        TrainingWorkspaceEntry(
          playerId: trainingPlan.playerId,
          position: position,
          planningNodeId: nodes[position].id,
          planningNodeDigest: nodes[position].semanticDigest,
          featureId: profileFeatures.contains(nodes[position].semanticId)
              ? nodes[position].semanticId
              : null,
          playerProfileDigest: profile.digest,
          trainingPlanDigest: trainingPlan.digest,
        ),
    ];
    return TrainingSessionWorkspaceContract.create(
      profile: profile,
      trainingPlan: trainingPlan,
      entries: entries,
    );
  }
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
