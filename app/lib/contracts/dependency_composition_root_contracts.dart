import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/application_bootstrap_contracts.dart';
import 'package:pool_os/contracts/runtime_service_composition_contracts.dart';

const dependencyCompositionRootContractVersion = 1;
const dependencyCompositionRootPolicyVersion =
    'dependency-composition-root/1.0.0';

class DependencyCompositionEntry {
  const DependencyCompositionEntry({
    required this.compositionEntryId,
    required this.serviceId,
    required this.runtimeNodeId,
    required this.bootstrapEntryId,
    required this.position,
    required this.bootstrapDigest,
    required this.runtimeServiceCompositionDigest,
  });

  final String compositionEntryId;
  final String serviceId;
  final String runtimeNodeId;
  final String bootstrapEntryId;
  final int position;
  final String bootstrapDigest;
  final String runtimeServiceCompositionDigest;

  Map<String, dynamic> toJson() => {
        'compositionEntryId': compositionEntryId,
        'serviceId': serviceId,
        'runtimeNodeId': runtimeNodeId,
        'bootstrapEntryId': bootstrapEntryId,
        'position': position,
        'bootstrapDigest': bootstrapDigest,
        'runtimeServiceCompositionDigest': runtimeServiceCompositionDigest,
      };
}

class DependencyCompositionRootContract {
  const DependencyCompositionRootContract._({
    required this.id,
    required this.compositionRootId,
    required this.bootstrapId,
    required this.bootstrapDigest,
    required this.runtimeServiceCompositionId,
    required this.runtimeServiceCompositionDigest,
    required this.entries,
    required this.digest,
  });

  factory DependencyCompositionRootContract.create({
    required ApplicationBootstrapContract bootstrap,
    required RuntimeServiceCompositionContract runtimeServiceComposition,
    required List<DependencyCompositionEntry> entries,
  }) {
    if (bootstrap.entries.isEmpty ||
        runtimeServiceComposition.nodes.isEmpty ||
        bootstrap.entries.length != runtimeServiceComposition.nodes.length ||
        entries.length != runtimeServiceComposition.nodes.length ||
        bootstrap.runtimeCompositionDigest !=
            runtimeServiceComposition.runtimeCompositionDigest) {
      throw ArgumentError(
          'Dependency composition inputs are stale or incomplete.');
    }
    final bootstrapByServiceId = {
      for (final entry in bootstrap.entries) entry.serviceId: entry,
    };
    if (bootstrapByServiceId.length != bootstrap.entries.length) {
      throw ArgumentError(
        'Dependency composition bootstrap references duplicate services.',
      );
    }
    final ordered = [...entries]
      ..sort((left, right) => left.position.compareTo(right.position));
    final positions = <int>{};
    final entryIds = <String>{};
    final serviceIds = <String>{};
    for (var index = 0; index < ordered.length; index++) {
      final entry = ordered[index];
      final service = runtimeServiceComposition.nodes[index];
      final bootstrapEntry = bootstrapByServiceId[service.serviceId];
      if (bootstrapEntry == null ||
          entry.position != index ||
          entry.position != service.position ||
          entry.compositionEntryId !=
              'dependency-composition-entry.${service.serviceId}' ||
          entry.serviceId != service.serviceId ||
          entry.serviceId != bootstrapEntry.serviceId ||
          entry.runtimeNodeId != bootstrapEntry.runtimeNodeId ||
          entry.bootstrapEntryId != bootstrapEntry.bootstrapEntryId ||
          entry.bootstrapDigest != bootstrap.digest ||
          entry.runtimeServiceCompositionDigest !=
              runtimeServiceComposition.digest ||
          !positions.add(entry.position) ||
          !entryIds.add(entry.compositionEntryId) ||
          !serviceIds.add(entry.serviceId)) {
        throw ArgumentError('Dependency composition provenance is invalid.');
      }
    }
    final compositionRootId = 'dependency-composition-root.${bootstrap.id}';
    final payload = {
      'schemaVersion': dependencyCompositionRootContractVersion,
      'policyVersion': dependencyCompositionRootPolicyVersion,
      'compositionRootId': compositionRootId,
      'bootstrapId': bootstrap.id,
      'bootstrapDigest': bootstrap.digest,
      'runtimeServiceCompositionId': runtimeServiceComposition.id,
      'runtimeServiceCompositionDigest': runtimeServiceComposition.digest,
      'entries': ordered.map((entry) => entry.toJson()).toList(),
    };
    final digest = _digest(payload);
    return DependencyCompositionRootContract._(
      id: 'dependency-composition-root-contract.${digest.substring(0, 16)}',
      compositionRootId: compositionRootId,
      bootstrapId: bootstrap.id,
      bootstrapDigest: bootstrap.digest,
      runtimeServiceCompositionId: runtimeServiceComposition.id,
      runtimeServiceCompositionDigest: runtimeServiceComposition.digest,
      entries: List.unmodifiable(ordered),
      digest: digest,
    );
  }

  final String id;
  final String compositionRootId;
  final String bootstrapId;
  final String bootstrapDigest;
  final String runtimeServiceCompositionId;
  final String runtimeServiceCompositionDigest;
  final List<DependencyCompositionEntry> entries;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': dependencyCompositionRootContractVersion,
        'policyVersion': dependencyCompositionRootPolicyVersion,
        'id': id,
        'compositionRootId': compositionRootId,
        'bootstrapId': bootstrapId,
        'bootstrapDigest': bootstrapDigest,
        'runtimeServiceCompositionId': runtimeServiceCompositionId,
        'runtimeServiceCompositionDigest': runtimeServiceCompositionDigest,
        'entries': entries.map((entry) => entry.toJson()).toList(),
        'digest': digest,
      };
}

class DependencyCompositionRootBuilder {
  const DependencyCompositionRootBuilder();

  DependencyCompositionRootContract build({
    required ApplicationBootstrapContract bootstrap,
    required RuntimeServiceCompositionContract runtimeServiceComposition,
  }) {
    final bootstrapByServiceId = {
      for (final entry in bootstrap.entries) entry.serviceId: entry,
    };
    return DependencyCompositionRootContract.create(
      bootstrap: bootstrap,
      runtimeServiceComposition: runtimeServiceComposition,
      entries: [
        for (final service in runtimeServiceComposition.nodes)
          DependencyCompositionEntry(
            compositionEntryId:
                'dependency-composition-entry.${service.serviceId}',
            serviceId: service.serviceId,
            runtimeNodeId:
                bootstrapByServiceId[service.serviceId]?.runtimeNodeId ??
                    (throw ArgumentError(
                      'Dependency composition contains an orphan service.',
                    )),
            bootstrapEntryId:
                bootstrapByServiceId[service.serviceId]?.bootstrapEntryId ??
                    (throw ArgumentError(
                      'Dependency composition contains an orphan service.',
                    )),
            position: service.position,
            bootstrapDigest: bootstrap.digest,
            runtimeServiceCompositionDigest: runtimeServiceComposition.digest,
          ),
      ],
    );
  }
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
