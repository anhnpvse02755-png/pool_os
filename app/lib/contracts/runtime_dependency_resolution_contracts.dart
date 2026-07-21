import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/runtime_composition_contracts.dart';
import 'package:pool_os/contracts/runtime_service_registry_contracts.dart';

const runtimeDependencyResolutionContractVersion = 1;
const runtimeDependencyResolutionPolicyVersion =
    'runtime-dependency-resolution/1.0.0';

class RuntimeDependencyNode {
  const RuntimeDependencyNode({
    required this.serviceId,
    required this.runtimeNodeId,
    required this.registryDigest,
    required this.runtimeCompositionDigest,
    required this.position,
    required this.metadata,
  });

  final String serviceId;
  final String runtimeNodeId;
  final String registryDigest;
  final String runtimeCompositionDigest;
  final int position;
  final String metadata;

  Map<String, dynamic> toJson() => {
        'serviceId': serviceId,
        'runtimeNodeId': runtimeNodeId,
        'registryDigest': registryDigest,
        'runtimeCompositionDigest': runtimeCompositionDigest,
        'position': position,
        'metadata': metadata,
      };
}

class RuntimeDependencyEdge {
  const RuntimeDependencyEdge({
    required this.edgeId,
    required this.fromServiceId,
    required this.toServiceId,
    required this.runtimeEdgeId,
    required this.registryDigest,
    required this.runtimeCompositionDigest,
    required this.position,
  });

  final String edgeId;
  final String fromServiceId;
  final String toServiceId;
  final String runtimeEdgeId;
  final String registryDigest;
  final String runtimeCompositionDigest;
  final int position;

  Map<String, dynamic> toJson() => {
        'edgeId': edgeId,
        'fromServiceId': fromServiceId,
        'toServiceId': toServiceId,
        'runtimeEdgeId': runtimeEdgeId,
        'registryDigest': registryDigest,
        'runtimeCompositionDigest': runtimeCompositionDigest,
        'position': position,
      };
}

class RuntimeDependencyResolutionContract {
  const RuntimeDependencyResolutionContract._({
    required this.id,
    required this.registryDigest,
    required this.runtimeCompositionDigest,
    required this.nodes,
    required this.edges,
    required this.digest,
  });

  factory RuntimeDependencyResolutionContract.create({
    required RuntimeServiceRegistryContract registry,
    required RuntimeCompositionContract runtimeComposition,
    required List<RuntimeDependencyNode> nodes,
    required List<RuntimeDependencyEdge> edges,
  }) {
    if (registry.compositionId != runtimeComposition.id) {
      throw ArgumentError('Registry and runtime composition bindings differ.');
    }
    final orderedNodes = [...nodes]
      ..sort((left, right) => left.position.compareTo(right.position));
    final orderedEdges = [...edges]
      ..sort((left, right) => left.edgeId.compareTo(right.edgeId));
    if (orderedNodes.length != runtimeComposition.nodes.length ||
        orderedNodes.map((node) => node.serviceId).toSet().length !=
            orderedNodes.length ||
        orderedNodes.map((node) => node.runtimeNodeId).toSet().length !=
            orderedNodes.length ||
        orderedNodes.map((node) => node.position).toSet().length !=
            orderedNodes.length ||
        orderedEdges.map((edge) => edge.edgeId).toSet().length !=
            orderedEdges.length ||
        orderedEdges.map((edge) => edge.runtimeEdgeId).toSet().length !=
            orderedEdges.length) {
      throw ArgumentError('Dependency projection contains duplicate entries.');
    }
    final serviceIds = registry.entries.map((entry) => entry.serviceId).toSet();
    final nodeIds = runtimeComposition.nodes.map((node) => node.id).toSet();
    for (var position = 0; position < orderedNodes.length; position++) {
      final node = orderedNodes[position];
      final runtimeNode = runtimeComposition.nodes[position];
      final registryEntry = registry.entries[position];
      if (node.position != position ||
          node.runtimeNodeId != runtimeNode.id ||
          node.serviceId != registryEntry.serviceId ||
          node.registryDigest != registry.digest ||
          node.runtimeCompositionDigest != runtimeComposition.digest ||
          node.metadata != runtimeNode.sourceDigest) {
        throw ArgumentError('Dependency node provenance is stale or broken.');
      }
    }
    final seenEdges = <String>{};
    final outgoing = <String, List<String>>{
      for (final serviceId in serviceIds) serviceId: <String>[],
    };
    for (var position = 0; position < orderedEdges.length; position++) {
      final edge = orderedEdges[position];
      final runtimeEdge = runtimeComposition.edges.firstWhere(
        (candidate) => _runtimeEdgeId(candidate) == edge.runtimeEdgeId,
        orElse: () => throw ArgumentError('Dependency edge lacks provenance.'),
      );
      final fromServiceId = _serviceId(runtimeComposition, runtimeEdge.fromId);
      final toServiceId = _serviceId(runtimeComposition, runtimeEdge.toId);
      final key = '${runtimeEdge.fromId}->${runtimeEdge.toId}';
      if (edge.position != position ||
          edge.edgeId != _dependencyEdgeId(runtimeEdge) ||
          edge.fromServiceId != fromServiceId ||
          edge.toServiceId != toServiceId ||
          edge.registryDigest != registry.digest ||
          edge.runtimeCompositionDigest != runtimeComposition.digest ||
          !nodeIds.contains(runtimeEdge.fromId) ||
          !nodeIds.contains(runtimeEdge.toId) ||
          !seenEdges.add(key)) {
        throw ArgumentError('Dependency edge provenance is stale or broken.');
      }
      outgoing[fromServiceId]!.add(toServiceId);
    }
    final indegree = <String, int>{
      for (final serviceId in serviceIds) serviceId: 0,
    };
    for (final targets in outgoing.values) {
      for (final target in targets) {
        indegree[target] = indegree[target]! + 1;
      }
    }
    final queue = indegree.entries
        .where((entry) => entry.value == 0)
        .map((entry) => entry.key)
        .toList();
    var visited = 0;
    while (queue.isNotEmpty) {
      final serviceId = queue.removeAt(0);
      visited++;
      for (final target in outgoing[serviceId]!) {
        indegree[target] = indegree[target]! - 1;
        if (indegree[target] == 0) queue.add(target);
      }
    }
    if (visited != serviceIds.length) {
      throw ArgumentError('Dependency projection contains a cycle.');
    }
    final payload = {
      'schemaVersion': runtimeDependencyResolutionContractVersion,
      'policyVersion': runtimeDependencyResolutionPolicyVersion,
      'registryDigest': registry.digest,
      'runtimeCompositionDigest': runtimeComposition.digest,
      'nodes': orderedNodes.map((node) => node.toJson()).toList(),
      'edges': orderedEdges.map((edge) => edge.toJson()).toList(),
    };
    final digest = _digest(payload);
    return RuntimeDependencyResolutionContract._(
      id: 'runtime-dependency-resolution.${digest.substring(0, 16)}',
      registryDigest: registry.digest,
      runtimeCompositionDigest: runtimeComposition.digest,
      nodes: List.unmodifiable(orderedNodes),
      edges: List.unmodifiable(orderedEdges),
      digest: digest,
    );
  }

  final String id;
  final String registryDigest;
  final String runtimeCompositionDigest;
  final List<RuntimeDependencyNode> nodes;
  final List<RuntimeDependencyEdge> edges;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': runtimeDependencyResolutionContractVersion,
        'policyVersion': runtimeDependencyResolutionPolicyVersion,
        'id': id,
        'registryDigest': registryDigest,
        'runtimeCompositionDigest': runtimeCompositionDigest,
        'nodes': nodes.map((node) => node.toJson()).toList(),
        'edges': edges.map((edge) => edge.toJson()).toList(),
        'digest': digest,
      };
}

class RuntimeDependencyResolutionBuilder {
  const RuntimeDependencyResolutionBuilder();

  RuntimeDependencyResolutionContract build({
    required RuntimeServiceRegistryContract registry,
    required RuntimeCompositionContract runtimeComposition,
  }) {
    final nodes = [
      for (var position = 0;
          position < runtimeComposition.nodes.length;
          position++)
        RuntimeDependencyNode(
          serviceId: registry.entries[position].serviceId,
          runtimeNodeId: runtimeComposition.nodes[position].id,
          registryDigest: registry.digest,
          runtimeCompositionDigest: runtimeComposition.digest,
          position: position,
          metadata: runtimeComposition.nodes[position].sourceDigest,
        ),
    ];
    final edges = [
      for (var position = 0;
          position < runtimeComposition.edges.length;
          position++)
        RuntimeDependencyEdge(
          edgeId: _dependencyEdgeId(runtimeComposition.edges[position]),
          fromServiceId: _serviceId(
              runtimeComposition, runtimeComposition.edges[position].fromId),
          toServiceId: _serviceId(
              runtimeComposition, runtimeComposition.edges[position].toId),
          runtimeEdgeId: _runtimeEdgeId(runtimeComposition.edges[position]),
          registryDigest: registry.digest,
          runtimeCompositionDigest: runtimeComposition.digest,
          position: position,
        ),
    ];
    return RuntimeDependencyResolutionContract.create(
      registry: registry,
      runtimeComposition: runtimeComposition,
      nodes: nodes,
      edges: edges,
    );
  }
}

String _serviceId(
        RuntimeCompositionContract composition, String runtimeNodeId) =>
    '${composition.id}:service:$runtimeNodeId';

String _runtimeEdgeId(RuntimeEdgeContract edge) =>
    'runtime-edge.${edge.fromId}->${edge.toId}';

String _dependencyEdgeId(RuntimeEdgeContract edge) =>
    'dependency-edge.${edge.fromId}->${edge.toId}';

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
