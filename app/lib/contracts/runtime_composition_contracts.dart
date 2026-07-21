import 'dart:convert';

import 'package:crypto/crypto.dart';

const runtimeCompositionContractVersion = 1;
const runtimeCompositionPolicyVersion = 'runtime-composition/1.0.0';

enum RuntimeNodeKind {
  session,
  promptAssembly,
  promptRendering,
  toolInvocation,
  providerRequest,
  providerResult,
  responseProcessing,
  conversationMemory,
  toolResultProjection,
  observability,
  activation,
}

class RuntimeNodeContract {
  const RuntimeNodeContract({
    required this.id,
    required this.kind,
    required this.sourceContractVersion,
    required this.sourceDigest,
  });

  final String id;
  final RuntimeNodeKind kind;
  final int sourceContractVersion;
  final String sourceDigest;

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.name,
        'sourceContractVersion': sourceContractVersion,
        'sourceDigest': sourceDigest,
      };
}

class RuntimeEdgeContract {
  const RuntimeEdgeContract({required this.fromId, required this.toId});

  final String fromId;
  final String toId;

  Map<String, dynamic> toJson() => {'fromId': fromId, 'toId': toId};
}

class RuntimeCompositionContract {
  const RuntimeCompositionContract._({
    required this.id,
    required this.nodes,
    required this.edges,
    required this.digest,
  });

  factory RuntimeCompositionContract.create({
    required List<RuntimeNodeContract> nodes,
    required List<RuntimeEdgeContract> edges,
  }) {
    if (nodes.isEmpty) throw ArgumentError('Runtime composition is empty.');
    final orderedNodes = [...nodes]..sort((a, b) => a.id.compareTo(b.id));
    final ids = orderedNodes.map((node) => node.id).toList();
    if (ids.any((id) => id.trim().isEmpty) || ids.toSet().length != ids.length) {
      throw ArgumentError('Runtime composition contains duplicate or empty nodes.');
    }
    if (orderedNodes.any((node) => node.sourceContractVersion != 1 || node.sourceDigest.trim().isEmpty)) {
      throw ArgumentError('Runtime composition contains incompatible nodes.');
    }
    final orderedEdges = [...edges]
      ..sort((a, b) => '${a.fromId}:${a.toId}'.compareTo('${b.fromId}:${b.toId}'));
    final edgeKeys = orderedEdges.map((edge) => '${edge.fromId}->${edge.toId}').toList();
    if (edgeKeys.toSet().length != edgeKeys.length || orderedEdges.any((edge) => edge.fromId == edge.toId || !ids.contains(edge.fromId) || !ids.contains(edge.toId))) {
      throw ArgumentError('Runtime composition contains stale or duplicate edges.');
    }
    final outgoing = {for (final id in ids) id: <String>[]};
    final incoming = {for (final id in ids) id: <String>[]};
    for (final edge in orderedEdges) {
      outgoing[edge.fromId]!.add(edge.toId);
      incoming[edge.toId]!.add(edge.fromId);
    }
    if (ids.length > 1 && (ids.any((id) => outgoing[id]!.isEmpty && incoming[id]!.isEmpty))) {
      throw ArgumentError('Runtime composition contains an orphan node.');
    }
    final indegree = {for (final id in ids) id: incoming[id]!.length};
    final queue = ids.where((id) => indegree[id] == 0).toList();
    var visited = 0;
    while (queue.isNotEmpty) {
      final id = queue.removeAt(0);
      visited++;
      for (final next in outgoing[id]!) {
        indegree[next] = indegree[next]! - 1;
        if (indegree[next] == 0) queue.add(next);
      }
    }
    if (visited != ids.length) throw ArgumentError('Runtime composition contains a cycle.');
    final payload = {
      'schemaVersion': runtimeCompositionContractVersion,
      'policyVersion': runtimeCompositionPolicyVersion,
      'nodes': orderedNodes.map((node) => node.toJson()).toList(),
      'edges': orderedEdges.map((edge) => edge.toJson()).toList(),
    };
    final digest = _digest(payload);
    return RuntimeCompositionContract._(
      id: 'runtime-composition.${digest.substring(0, 16)}',
      nodes: List.unmodifiable(orderedNodes),
      edges: List.unmodifiable(orderedEdges),
      digest: digest,
    );
  }

  final String id;
  final List<RuntimeNodeContract> nodes;
  final List<RuntimeEdgeContract> edges;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': runtimeCompositionContractVersion,
        'policyVersion': runtimeCompositionPolicyVersion,
        'id': id,
        'nodes': nodes.map((node) => node.toJson()).toList(),
        'edges': edges.map((edge) => edge.toJson()).toList(),
        'digest': digest,
      };
}

class RuntimeCompositionEngine {
  const RuntimeCompositionEngine();

  RuntimeCompositionContract compose({
    required List<RuntimeNodeContract> nodes,
    required List<RuntimeEdgeContract> edges,
  }) => RuntimeCompositionContract.create(nodes: nodes, edges: edges);
}

String _digest(Object value) => sha256.convert(utf8.encode(jsonEncode(value))).toString();
