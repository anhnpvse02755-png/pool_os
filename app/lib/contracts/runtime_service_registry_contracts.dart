import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/runtime_service_composition_contracts.dart';

const runtimeServiceRegistryContractVersion = 1;
const runtimeServiceRegistryPolicyVersion = 'runtime-service-registry/1.0.0';

class RuntimeServiceRegistryEntry {
  const RuntimeServiceRegistryEntry({
    required this.serviceId,
    required this.serviceKey,
    required this.type,
    required this.compositionDigest,
    required this.position,
    required this.metadata,
  });

  final String serviceId;
  final String serviceKey;
  final RuntimeServiceType type;
  final String compositionDigest;
  final int position;
  final String metadata;

  Map<String, dynamic> toJson() => {
        'serviceId': serviceId,
        'serviceKey': serviceKey,
        'type': type.name,
        'compositionDigest': compositionDigest,
        'position': position,
        'metadata': metadata,
      };
}

class RuntimeServiceRegistryContract {
  const RuntimeServiceRegistryContract._({
    required this.id,
    required this.compositionId,
    required this.compositionDigest,
    required this.entries,
    required this.digest,
  });

  factory RuntimeServiceRegistryContract.create({
    required RuntimeServiceCompositionContract composition,
    required List<RuntimeServiceRegistryEntry> entries,
  }) {
    final ordered = [...entries]
      ..sort((left, right) => left.position.compareTo(right.position));
    if (ordered.length != composition.nodes.length ||
        ordered.map((entry) => entry.serviceId).toSet().length !=
            ordered.length ||
        ordered.map((entry) => entry.serviceKey).toSet().length !=
            ordered.length ||
        ordered.map((entry) => entry.position).toSet().length !=
            ordered.length) {
      throw ArgumentError(
        'Runtime service registry contains duplicate or orphan entries.',
      );
    }
    for (var position = 0; position < ordered.length; position++) {
      final entry = ordered[position];
      final service = composition.nodes[position];
      if (entry.position != position ||
          entry.serviceId != service.serviceId ||
          entry.serviceKey != service.serviceKey ||
          entry.type != service.type ||
          entry.compositionDigest != composition.digest ||
          entry.metadata != composition.runtimeCompositionId) {
        throw ArgumentError(
          'Runtime service registry contains stale or broken provenance.',
        );
      }
    }
    final payload = {
      'schemaVersion': runtimeServiceRegistryContractVersion,
      'policyVersion': runtimeServiceRegistryPolicyVersion,
      'compositionId': composition.runtimeCompositionId,
      'compositionDigest': composition.digest,
      'entries': ordered.map((entry) => entry.toJson()).toList(),
    };
    final digest = _digest(payload);
    return RuntimeServiceRegistryContract._(
      id: 'runtime-service-registry.${digest.substring(0, 16)}',
      compositionId: composition.runtimeCompositionId,
      compositionDigest: composition.digest,
      entries: List.unmodifiable(ordered),
      digest: digest,
    );
  }

  final String id;
  final String compositionId;
  final String compositionDigest;
  final List<RuntimeServiceRegistryEntry> entries;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': runtimeServiceRegistryContractVersion,
        'policyVersion': runtimeServiceRegistryPolicyVersion,
        'id': id,
        'compositionId': compositionId,
        'compositionDigest': compositionDigest,
        'entries': entries.map((entry) => entry.toJson()).toList(),
        'digest': digest,
      };
}

class RuntimeServiceRegistryBuilder {
  const RuntimeServiceRegistryBuilder();

  RuntimeServiceRegistryContract build(
    RuntimeServiceCompositionContract composition,
  ) {
    final entries = [
      for (var position = 0; position < composition.nodes.length; position++)
        RuntimeServiceRegistryEntry(
          serviceId: composition.nodes[position].serviceId,
          serviceKey: composition.nodes[position].serviceKey,
          type: composition.nodes[position].type,
          compositionDigest: composition.digest,
          position: position,
          metadata: composition.runtimeCompositionId,
        ),
    ];
    return RuntimeServiceRegistryContract.create(
      composition: composition,
      entries: entries,
    );
  }
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
