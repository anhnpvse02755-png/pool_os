import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/runtime_composition_contracts.dart';

const runtimeServiceCompositionContractVersion = 1;
const runtimeServiceCompositionPolicyVersion =
    'runtime-service-composition/1.0.0';

enum RuntimeServiceType { core, coordinator, registry, projection, adapter }

class RuntimeServiceNode {
  const RuntimeServiceNode({
    required this.serviceId,
    required this.runtimeCompositionId,
    required this.serviceKey,
    required this.type,
    required this.position,
    required this.metadata,
  });

  final String serviceId;
  final String runtimeCompositionId;
  final String serviceKey;
  final RuntimeServiceType type;
  final int position;
  final String metadata;

  Map<String, dynamic> toJson() => {
        'serviceId': serviceId,
        'runtimeCompositionId': runtimeCompositionId,
        'serviceKey': serviceKey,
        'type': type.name,
        'position': position,
        'metadata': metadata,
      };
}

class RuntimeServiceCompositionContract {
  const RuntimeServiceCompositionContract._({
    required this.id,
    required this.runtimeCompositionId,
    required this.runtimeCompositionDigest,
    required this.nodes,
    required this.digest,
  });

  factory RuntimeServiceCompositionContract.create({
    required RuntimeCompositionContract composition,
    required List<RuntimeServiceNode> nodes,
  }) {
    final ordered = [...nodes]
      ..sort((left, right) => left.position.compareTo(right.position));
    if (ordered.length != composition.nodes.length ||
        ordered.map((node) => node.serviceId).toSet().length !=
            ordered.length ||
        ordered.map((node) => node.serviceKey).toSet().length !=
            ordered.length ||
        ordered.map((node) => node.position).toSet().length != ordered.length) {
      throw ArgumentError(
        'Runtime service composition contains duplicate or orphan nodes.',
      );
    }
    for (var position = 0; position < ordered.length; position++) {
      final service = ordered[position];
      final runtimeNode = composition.nodes[position];
      if (service.position != position ||
          service.runtimeCompositionId != composition.id ||
          service.serviceId != _serviceId(composition, runtimeNode) ||
          service.serviceKey != _serviceKey(runtimeNode) ||
          service.type != _serviceType(runtimeNode.kind) ||
          service.metadata != composition.digest) {
        throw ArgumentError(
          'Runtime service composition contains stale or broken provenance.',
        );
      }
    }
    final payload = {
      'schemaVersion': runtimeServiceCompositionContractVersion,
      'policyVersion': runtimeServiceCompositionPolicyVersion,
      'runtimeCompositionId': composition.id,
      'runtimeCompositionDigest': composition.digest,
      'nodes': ordered.map((node) => node.toJson()).toList(),
    };
    final digest = _digest(payload);
    return RuntimeServiceCompositionContract._(
      id: 'runtime-service-composition.${digest.substring(0, 16)}',
      runtimeCompositionId: composition.id,
      runtimeCompositionDigest: composition.digest,
      nodes: List.unmodifiable(ordered),
      digest: digest,
    );
  }

  final String id;
  final String runtimeCompositionId;
  final String runtimeCompositionDigest;
  final List<RuntimeServiceNode> nodes;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': runtimeServiceCompositionContractVersion,
        'policyVersion': runtimeServiceCompositionPolicyVersion,
        'id': id,
        'runtimeCompositionId': runtimeCompositionId,
        'runtimeCompositionDigest': runtimeCompositionDigest,
        'nodes': nodes.map((node) => node.toJson()).toList(),
        'digest': digest,
      };
}

class RuntimeServiceCompositionEngine {
  const RuntimeServiceCompositionEngine();

  RuntimeServiceCompositionContract compose(
    RuntimeCompositionContract composition,
  ) {
    final nodes = [
      for (var position = 0; position < composition.nodes.length; position++)
        RuntimeServiceNode(
          serviceId: _serviceId(composition, composition.nodes[position]),
          runtimeCompositionId: composition.id,
          serviceKey: _serviceKey(composition.nodes[position]),
          type: _serviceType(composition.nodes[position].kind),
          position: position,
          metadata: composition.digest,
        ),
    ];
    return RuntimeServiceCompositionContract.create(
      composition: composition,
      nodes: nodes,
    );
  }
}

String _serviceId(
  RuntimeCompositionContract composition,
  RuntimeNodeContract node,
) =>
    '${composition.id}:service:${node.id}';

String _serviceKey(RuntimeNodeContract node) => '${node.kind.name}:${node.id}';

RuntimeServiceType _serviceType(RuntimeNodeKind kind) => switch (kind) {
      RuntimeNodeKind.session => RuntimeServiceType.core,
      RuntimeNodeKind.toolInvocation => RuntimeServiceType.coordinator,
      RuntimeNodeKind.conversationMemory => RuntimeServiceType.registry,
      RuntimeNodeKind.providerRequest ||
      RuntimeNodeKind.providerResult =>
        RuntimeServiceType.adapter,
      _ => RuntimeServiceType.projection,
    };

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
