import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/runtime_dependency_resolution_contracts.dart';

const runtimeActivationCoordinationContractVersion = 1;
const runtimeActivationCoordinationPolicyVersion =
    'runtime-activation-coordination/1.0.0';

class RuntimeActivationCoordinationEntry {
  const RuntimeActivationCoordinationEntry({
    required this.activationId,
    required this.serviceId,
    required this.runtimeNodeId,
    required this.dependencyResolutionDigest,
    required this.position,
    required this.metadata,
  });

  final String activationId;
  final String serviceId;
  final String runtimeNodeId;
  final String dependencyResolutionDigest;
  final int position;
  final String metadata;

  Map<String, dynamic> toJson() => {
        'activationId': activationId,
        'serviceId': serviceId,
        'runtimeNodeId': runtimeNodeId,
        'dependencyResolutionDigest': dependencyResolutionDigest,
        'position': position,
        'metadata': metadata,
      };
}

class RuntimeActivationCoordinationContract {
  const RuntimeActivationCoordinationContract._({
    required this.id,
    required this.dependencyResolutionId,
    required this.dependencyResolutionDigest,
    required this.entries,
    required this.digest,
  });

  factory RuntimeActivationCoordinationContract.create({
    required RuntimeDependencyResolutionContract dependencyResolution,
    required List<RuntimeActivationCoordinationEntry> entries,
  }) {
    final ordered = [...entries]
      ..sort((left, right) => left.position.compareTo(right.position));
    if (ordered.length != dependencyResolution.nodes.length ||
        ordered.map((entry) => entry.activationId).toSet().length !=
            ordered.length ||
        ordered.map((entry) => entry.serviceId).toSet().length !=
            ordered.length ||
        ordered.map((entry) => entry.position).toSet().length !=
            ordered.length) {
      throw ArgumentError(
        'Activation coordination contains duplicate or orphan entries.',
      );
    }
    final expectedOrder = _canonicalServiceOrder(dependencyResolution);
    final nodesByService = {
      for (final node in dependencyResolution.nodes) node.serviceId: node,
    };
    for (var position = 0; position < ordered.length; position++) {
      final entry = ordered[position];
      final expectedServiceId = expectedOrder[position];
      final node = nodesByService[expectedServiceId];
      if (node == null ||
          entry.position != position ||
          entry.activationId != _activationId(expectedServiceId) ||
          entry.serviceId != expectedServiceId ||
          entry.runtimeNodeId != node.runtimeNodeId ||
          entry.dependencyResolutionDigest != dependencyResolution.digest ||
          entry.metadata != node.metadata) {
        throw ArgumentError(
          'Activation coordination topology or provenance is invalid.',
        );
      }
    }
    final payload = {
      'schemaVersion': runtimeActivationCoordinationContractVersion,
      'policyVersion': runtimeActivationCoordinationPolicyVersion,
      'dependencyResolutionId': dependencyResolution.id,
      'dependencyResolutionDigest': dependencyResolution.digest,
      'entries': ordered.map((entry) => entry.toJson()).toList(),
    };
    final digest = _digest(payload);
    return RuntimeActivationCoordinationContract._(
      id: 'runtime-activation-coordination.${digest.substring(0, 16)}',
      dependencyResolutionId: dependencyResolution.id,
      dependencyResolutionDigest: dependencyResolution.digest,
      entries: List.unmodifiable(ordered),
      digest: digest,
    );
  }

  final String id;
  final String dependencyResolutionId;
  final String dependencyResolutionDigest;
  final List<RuntimeActivationCoordinationEntry> entries;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': runtimeActivationCoordinationContractVersion,
        'policyVersion': runtimeActivationCoordinationPolicyVersion,
        'id': id,
        'dependencyResolutionId': dependencyResolutionId,
        'dependencyResolutionDigest': dependencyResolutionDigest,
        'entries': entries.map((entry) => entry.toJson()).toList(),
        'digest': digest,
      };
}

class RuntimeActivationCoordinator {
  const RuntimeActivationCoordinator();

  RuntimeActivationCoordinationContract coordinate(
    RuntimeDependencyResolutionContract dependencyResolution,
  ) {
    final nodesByService = {
      for (final node in dependencyResolution.nodes) node.serviceId: node,
    };
    final serviceOrder = _canonicalServiceOrder(dependencyResolution);
    final entries = [
      for (var position = 0; position < serviceOrder.length; position++)
        RuntimeActivationCoordinationEntry(
          activationId: _activationId(serviceOrder[position]),
          serviceId: serviceOrder[position],
          runtimeNodeId: nodesByService[serviceOrder[position]]!.runtimeNodeId,
          dependencyResolutionDigest: dependencyResolution.digest,
          position: position,
          metadata: nodesByService[serviceOrder[position]]!.metadata,
        ),
    ];
    return RuntimeActivationCoordinationContract.create(
      dependencyResolution: dependencyResolution,
      entries: entries,
    );
  }
}

List<String> _canonicalServiceOrder(
  RuntimeDependencyResolutionContract dependencyResolution,
) {
  final sourcePosition = {
    for (final node in dependencyResolution.nodes)
      node.serviceId: node.position,
  };
  final outgoing = {
    for (final node in dependencyResolution.nodes) node.serviceId: <String>[],
  };
  final indegree = {
    for (final node in dependencyResolution.nodes) node.serviceId: 0,
  };
  for (final edge in dependencyResolution.edges) {
    final targets = outgoing[edge.fromServiceId];
    if (targets == null || !indegree.containsKey(edge.toServiceId)) {
      throw ArgumentError(
          'Activation coordination contains orphan dependency.');
    }
    targets.add(edge.toServiceId);
    indegree[edge.toServiceId] = indegree[edge.toServiceId]! + 1;
  }
  final ready = indegree.entries
      .where((entry) => entry.value == 0)
      .map((entry) => entry.key)
      .toList()
    ..sort((left, right) =>
        sourcePosition[left]!.compareTo(sourcePosition[right]!));
  final order = <String>[];
  while (ready.isNotEmpty) {
    final serviceId = ready.removeAt(0);
    order.add(serviceId);
    for (final target in outgoing[serviceId]!) {
      indegree[target] = indegree[target]! - 1;
      if (indegree[target] == 0) {
        ready.add(target);
        ready.sort(
          (left, right) =>
              sourcePosition[left]!.compareTo(sourcePosition[right]!),
        );
      }
    }
  }
  if (order.length != dependencyResolution.nodes.length) {
    throw ArgumentError('Activation coordination topology is cyclic.');
  }
  return order;
}

String _activationId(String serviceId) => 'activation:$serviceId';

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
