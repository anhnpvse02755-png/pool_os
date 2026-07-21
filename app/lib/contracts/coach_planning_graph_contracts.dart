import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/coach_context_contracts.dart';

const coachPlanningGraphContractVersion = 1;
const coachPlanningNodeContractVersion = 1;
const coachPlanningEdgeContractVersion = 1;
const coachPlanningEnginePolicyVersion = 'coach-planning-engine/1.0.0';

enum CoachPlanningNodeKind { decision, recommendation, execution }

enum CoachPlanningEdgeKind {
  recommendationDependency,
  executionDependency,
}

class CoachPlanningNodeContract {
  CoachPlanningNodeContract.create({
    required this.playerId,
    required this.sessionId,
    required this.kind,
    required this.semanticId,
    required this.semanticDigest,
  }) : id = _nodeId(playerId, sessionId, kind, semanticId, semanticDigest) {
    if (playerId.trim().isEmpty ||
        sessionId.trim().isEmpty ||
        semanticId.trim().isEmpty ||
        semanticDigest.trim().isEmpty) {
      throw ArgumentError('Coach Planning node fields must not be empty.');
    }
  }

  final String id;
  final String playerId;
  final String sessionId;
  final CoachPlanningNodeKind kind;
  final String semanticId;
  final String semanticDigest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': coachPlanningNodeContractVersion,
        'id': id,
        'playerId': playerId,
        'sessionId': sessionId,
        'kind': kind.name,
        'semanticId': semanticId,
        'semanticDigest': semanticDigest,
      };
}

class CoachPlanningEdgeContract {
  CoachPlanningEdgeContract.create({
    required this.kind,
    required this.fromNodeId,
    required this.toNodeId,
  }) : id = _edgeId(kind, fromNodeId, toNodeId) {
    if (fromNodeId.trim().isEmpty || toNodeId.trim().isEmpty) {
      throw ArgumentError('Coach Planning edge endpoints must not be empty.');
    }
  }

  final String id;
  final CoachPlanningEdgeKind kind;
  final String fromNodeId;
  final String toNodeId;

  Map<String, dynamic> toJson() => {
        'schemaVersion': coachPlanningEdgeContractVersion,
        'id': id,
        'kind': kind.name,
        'fromNodeId': fromNodeId,
        'toNodeId': toNodeId,
      };
}

class CoachPlanningGraphVersionBinding {
  const CoachPlanningGraphVersionBinding({
    required this.contextContractVersion,
    required this.contextDigest,
    required this.playerProgressDigest,
    required this.experienceDigest,
    required this.policyVersion,
  });

  final int contextContractVersion;
  final String contextDigest;
  final String playerProgressDigest;
  final String experienceDigest;
  final String policyVersion;

  Map<String, dynamic> toJson() => {
        'contextContractVersion': contextContractVersion,
        'contextDigest': contextDigest,
        'playerProgressDigest': playerProgressDigest,
        'experienceDigest': experienceDigest,
        'policyVersion': policyVersion,
      };
}

class CoachPlanningGraphContract {
  const CoachPlanningGraphContract._({
    required this.id,
    required this.playerId,
    required this.sessionId,
    required this.nodes,
    required this.edges,
    required this.versions,
    required this.digest,
  });

  factory CoachPlanningGraphContract.create({
    required CoachContextContract context,
    required String sessionId,
    required List<CoachPlanningNodeContract> nodes,
    required List<CoachPlanningEdgeContract> edges,
  }) {
    if (sessionId.trim().isEmpty || nodes.isEmpty) {
      throw ArgumentError('Coach Planning graph requires a session and nodes.');
    }
    final playerId = context.profile.playerId;
    final orderedNodes = [...nodes]..sort(_compareNodes);
    final byId = <String, CoachPlanningNodeContract>{};
    final semanticKeys = <String>{};
    for (final node in orderedNodes) {
      if (node.playerId != playerId || node.sessionId != sessionId) {
        throw ArgumentError('Coach Planning graph mixes player or session.');
      }
      if (byId.containsKey(node.id) ||
          !semanticKeys.add('${node.kind.name}:${node.semanticId}')) {
        throw ArgumentError('Coach Planning graph has a duplicate node.');
      }
      byId[node.id] = node;
    }

    final orderedEdges = [...edges]..sort((a, b) => a.id.compareTo(b.id));
    final edgeIds = <String>{};
    for (final edge in orderedEdges) {
      final from = byId[edge.fromNodeId];
      final to = byId[edge.toNodeId];
      if (from == null || to == null) {
        throw ArgumentError('Coach Planning graph has an orphan edge.');
      }
      if (!edgeIds.add(edge.id)) {
        throw ArgumentError('Coach Planning graph has a duplicate edge.');
      }
      final validShape = switch (edge.kind) {
        CoachPlanningEdgeKind.recommendationDependency =>
          from.kind == CoachPlanningNodeKind.decision &&
              to.kind == CoachPlanningNodeKind.recommendation,
        CoachPlanningEdgeKind.executionDependency =>
          from.kind == CoachPlanningNodeKind.recommendation &&
              to.kind == CoachPlanningNodeKind.execution,
      };
      if (!validShape) {
        throw ArgumentError('Coach Planning edge dependency is invalid.');
      }
    }
    _rejectCycles(byId.keys, orderedEdges);

    final versions = CoachPlanningGraphVersionBinding(
      contextContractVersion: coachContextContractVersion,
      contextDigest: context.digest,
      playerProgressDigest: context.progress.digest,
      experienceDigest: context.experience.digest,
      policyVersion: coachPlanningEnginePolicyVersion,
    );
    final payload = {
      'schemaVersion': coachPlanningGraphContractVersion,
      'playerId': playerId,
      'sessionId': sessionId,
      'nodes': orderedNodes.map((item) => item.toJson()).toList(),
      'edges': orderedEdges.map((item) => item.toJson()).toList(),
      'versions': versions.toJson(),
    };
    final digest = _digest(payload);
    return CoachPlanningGraphContract._(
      id: 'coach-planning-graph.${digest.substring(0, 16)}',
      playerId: playerId,
      sessionId: sessionId,
      nodes: List.unmodifiable(orderedNodes),
      edges: List.unmodifiable(orderedEdges),
      versions: versions,
      digest: digest,
    );
  }

  final String id;
  final String playerId;
  final String sessionId;
  final List<CoachPlanningNodeContract> nodes;
  final List<CoachPlanningEdgeContract> edges;
  final CoachPlanningGraphVersionBinding versions;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': coachPlanningGraphContractVersion,
        'id': id,
        'playerId': playerId,
        'sessionId': sessionId,
        'nodes': nodes.map((item) => item.toJson()).toList(),
        'edges': edges.map((item) => item.toJson()).toList(),
        'versions': versions.toJson(),
        'digest': digest,
      };
}

int _compareNodes(
  CoachPlanningNodeContract left,
  CoachPlanningNodeContract right,
) {
  final byKind = left.kind.index.compareTo(right.kind.index);
  return byKind != 0 ? byKind : left.semanticId.compareTo(right.semanticId);
}

void _rejectCycles(
  Iterable<String> nodeIds,
  List<CoachPlanningEdgeContract> edges,
) {
  final incoming = {for (final id in nodeIds) id: 0};
  final outgoing = <String, List<String>>{};
  for (final edge in edges) {
    incoming[edge.toNodeId] = incoming[edge.toNodeId]! + 1;
    outgoing.putIfAbsent(edge.fromNodeId, () => []).add(edge.toNodeId);
  }
  final queue = incoming.entries
      .where((entry) => entry.value == 0)
      .map((entry) => entry.key)
      .toList();
  var visited = 0;
  while (queue.isNotEmpty) {
    final id = queue.removeLast();
    visited++;
    for (final target in outgoing[id] ?? const <String>[]) {
      incoming[target] = incoming[target]! - 1;
      if (incoming[target] == 0) queue.add(target);
    }
  }
  if (visited != incoming.length) {
    throw ArgumentError('Coach Planning graph must be acyclic.');
  }
}

String _nodeId(
  String playerId,
  String sessionId,
  CoachPlanningNodeKind kind,
  String semanticId,
  String semanticDigest,
) =>
    'coach-planning-node.${_digest({
          'playerId': playerId,
          'sessionId': sessionId,
          'kind': kind.name,
          'semanticId': semanticId,
          'semanticDigest': semanticDigest,
        }).substring(0, 16)}';

String _edgeId(
  CoachPlanningEdgeKind kind,
  String fromNodeId,
  String toNodeId,
) =>
    'coach-planning-edge.${_digest({
          'kind': kind.name,
          'fromNodeId': fromNodeId,
          'toNodeId': toNodeId,
        }).substring(0, 16)}';

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
