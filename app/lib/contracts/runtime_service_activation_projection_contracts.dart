import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/dependency_composition_root_contracts.dart';
import 'package:pool_os/contracts/runtime_activation_coordination_contracts.dart';

const runtimeServiceActivationProjectionContractVersion = 1;
const runtimeServiceActivationProjectionPolicyVersion =
    'runtime-service-activation-projection/1.0.0';

class RuntimeServiceActivationEntry {
  const RuntimeServiceActivationEntry({
    required this.activationProjectionId,
    required this.dependencyCompositionRootDigest,
    required this.runtimeActivationCoordinationDigest,
    required this.activationId,
    required this.serviceId,
    required this.runtimeNodeId,
    required this.compositionEntryId,
    required this.activationPosition,
  });

  final String activationProjectionId;
  final String dependencyCompositionRootDigest;
  final String runtimeActivationCoordinationDigest;
  final String activationId;
  final String serviceId;
  final String runtimeNodeId;
  final String compositionEntryId;
  final int activationPosition;

  Map<String, dynamic> toJson() => {
        'activationProjectionId': activationProjectionId,
        'dependencyCompositionRootDigest': dependencyCompositionRootDigest,
        'runtimeActivationCoordinationDigest':
            runtimeActivationCoordinationDigest,
        'activationId': activationId,
        'serviceId': serviceId,
        'runtimeNodeId': runtimeNodeId,
        'compositionEntryId': compositionEntryId,
        'activationPosition': activationPosition,
      };
}

class RuntimeServiceActivationProjectionContract {
  const RuntimeServiceActivationProjectionContract._({
    required this.id,
    required this.activationProjectionId,
    required this.dependencyCompositionRootId,
    required this.dependencyCompositionRootDigest,
    required this.runtimeActivationCoordinationId,
    required this.runtimeActivationCoordinationDigest,
    required this.entries,
    required this.digest,
  });

  factory RuntimeServiceActivationProjectionContract.create({
    required DependencyCompositionRootContract dependencyCompositionRoot,
    required RuntimeActivationCoordinationContract
        runtimeActivationCoordination,
    required List<RuntimeServiceActivationEntry> entries,
  }) {
    if (dependencyCompositionRoot.entries.isEmpty ||
        runtimeActivationCoordination.entries.isEmpty ||
        dependencyCompositionRoot.entries.length !=
            runtimeActivationCoordination.entries.length ||
        entries.length != runtimeActivationCoordination.entries.length) {
      throw ArgumentError('Runtime activation projection is incomplete.');
    }
    final compositionByService = {
      for (final entry in dependencyCompositionRoot.entries)
        entry.serviceId: entry,
    };
    if (compositionByService.length !=
        dependencyCompositionRoot.entries.length) {
      throw ArgumentError(
          'Runtime activation composition contains duplicates.');
    }
    final activationProjectionId =
        'runtime-service-activation.${dependencyCompositionRoot.id}.${runtimeActivationCoordination.id}';
    final ordered = [...entries]..sort((left, right) =>
        left.activationPosition.compareTo(right.activationPosition));
    final positions = <int>{};
    final activationIds = <String>{};
    final serviceIds = <String>{};
    for (var index = 0; index < ordered.length; index++) {
      final entry = ordered[index];
      final activation = runtimeActivationCoordination.entries[index];
      final composition = compositionByService[activation.serviceId];
      if (composition == null ||
          entry.activationProjectionId != activationProjectionId ||
          entry.dependencyCompositionRootDigest !=
              dependencyCompositionRoot.digest ||
          entry.runtimeActivationCoordinationDigest !=
              runtimeActivationCoordination.digest ||
          entry.activationId != activation.activationId ||
          entry.serviceId != activation.serviceId ||
          entry.runtimeNodeId != activation.runtimeNodeId ||
          entry.runtimeNodeId != composition.runtimeNodeId ||
          entry.compositionEntryId != composition.compositionEntryId ||
          entry.activationPosition != index ||
          entry.activationPosition != activation.position ||
          !positions.add(entry.activationPosition) ||
          !activationIds.add(entry.activationId) ||
          !serviceIds.add(entry.serviceId)) {
        throw ArgumentError(
            'Runtime activation projection provenance is invalid.');
      }
    }
    final payload = {
      'schemaVersion': runtimeServiceActivationProjectionContractVersion,
      'policyVersion': runtimeServiceActivationProjectionPolicyVersion,
      'activationProjectionId': activationProjectionId,
      'dependencyCompositionRootId': dependencyCompositionRoot.id,
      'dependencyCompositionRootDigest': dependencyCompositionRoot.digest,
      'runtimeActivationCoordinationId': runtimeActivationCoordination.id,
      'runtimeActivationCoordinationDigest':
          runtimeActivationCoordination.digest,
      'entries': ordered.map((entry) => entry.toJson()).toList(),
    };
    final digest = _digest(payload);
    return RuntimeServiceActivationProjectionContract._(
      id: 'runtime-service-activation-projection.${digest.substring(0, 16)}',
      activationProjectionId: activationProjectionId,
      dependencyCompositionRootId: dependencyCompositionRoot.id,
      dependencyCompositionRootDigest: dependencyCompositionRoot.digest,
      runtimeActivationCoordinationId: runtimeActivationCoordination.id,
      runtimeActivationCoordinationDigest: runtimeActivationCoordination.digest,
      entries: List.unmodifiable(ordered),
      digest: digest,
    );
  }

  final String id;
  final String activationProjectionId;
  final String dependencyCompositionRootId;
  final String dependencyCompositionRootDigest;
  final String runtimeActivationCoordinationId;
  final String runtimeActivationCoordinationDigest;
  final List<RuntimeServiceActivationEntry> entries;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': runtimeServiceActivationProjectionContractVersion,
        'policyVersion': runtimeServiceActivationProjectionPolicyVersion,
        'id': id,
        'activationProjectionId': activationProjectionId,
        'dependencyCompositionRootId': dependencyCompositionRootId,
        'dependencyCompositionRootDigest': dependencyCompositionRootDigest,
        'runtimeActivationCoordinationId': runtimeActivationCoordinationId,
        'runtimeActivationCoordinationDigest':
            runtimeActivationCoordinationDigest,
        'entries': entries.map((entry) => entry.toJson()).toList(),
        'digest': digest,
      };
}

class RuntimeServiceActivationProjector {
  const RuntimeServiceActivationProjector();

  RuntimeServiceActivationProjectionContract project({
    required DependencyCompositionRootContract dependencyCompositionRoot,
    required RuntimeActivationCoordinationContract
        runtimeActivationCoordination,
  }) {
    final compositionByService = {
      for (final entry in dependencyCompositionRoot.entries)
        entry.serviceId: entry,
    };
    final activationProjectionId =
        'runtime-service-activation.${dependencyCompositionRoot.id}.${runtimeActivationCoordination.id}';
    return RuntimeServiceActivationProjectionContract.create(
      dependencyCompositionRoot: dependencyCompositionRoot,
      runtimeActivationCoordination: runtimeActivationCoordination,
      entries: [
        for (final activation in runtimeActivationCoordination.entries)
          RuntimeServiceActivationEntry(
            activationProjectionId: activationProjectionId,
            dependencyCompositionRootDigest: dependencyCompositionRoot.digest,
            runtimeActivationCoordinationDigest:
                runtimeActivationCoordination.digest,
            activationId: activation.activationId,
            serviceId: activation.serviceId,
            runtimeNodeId: activation.runtimeNodeId,
            compositionEntryId: compositionByService[activation.serviceId]
                    ?.compositionEntryId ??
                (throw ArgumentError(
                  'Runtime activation contains an orphan service.',
                )),
            activationPosition: activation.position,
          ),
      ],
    );
  }
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
