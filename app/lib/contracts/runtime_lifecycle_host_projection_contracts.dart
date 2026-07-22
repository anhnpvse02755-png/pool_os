import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/runtime_lifecycle_projection_contracts.dart';
import 'package:pool_os/contracts/runtime_service_activation_projection_contracts.dart';

const runtimeLifecycleHostProjectionContractVersion = 1;
const runtimeLifecycleHostProjectionPolicyVersion =
    'runtime-lifecycle-host-projection/1.0.0';

class RuntimeLifecycleHostEntry {
  const RuntimeLifecycleHostEntry({
    required this.lifecycleHostProjectionId,
    required this.runtimeServiceActivationProjectionDigest,
    required this.runtimeLifecycleProjectionDigest,
    required this.activationId,
    required this.lifecycleEntryId,
    required this.serviceId,
    required this.runtimeNodeId,
    required this.lifecyclePhase,
    required this.canonicalPosition,
  });

  final String lifecycleHostProjectionId;
  final String runtimeServiceActivationProjectionDigest;
  final String runtimeLifecycleProjectionDigest;
  final String activationId;
  final String lifecycleEntryId;
  final String serviceId;
  final String runtimeNodeId;
  final RuntimeLifecyclePhase lifecyclePhase;
  final int canonicalPosition;

  Map<String, dynamic> toJson() => {
        'lifecycleHostProjectionId': lifecycleHostProjectionId,
        'runtimeServiceActivationProjectionDigest':
            runtimeServiceActivationProjectionDigest,
        'runtimeLifecycleProjectionDigest': runtimeLifecycleProjectionDigest,
        'activationId': activationId,
        'lifecycleEntryId': lifecycleEntryId,
        'serviceId': serviceId,
        'runtimeNodeId': runtimeNodeId,
        'lifecyclePhase': lifecyclePhase.name,
        'canonicalPosition': canonicalPosition,
      };
}

class RuntimeLifecycleHostProjectionContract {
  const RuntimeLifecycleHostProjectionContract._({
    required this.id,
    required this.lifecycleHostProjectionId,
    required this.runtimeServiceActivationProjectionId,
    required this.runtimeServiceActivationProjectionDigest,
    required this.runtimeLifecycleProjectionId,
    required this.runtimeLifecycleProjectionDigest,
    required this.entries,
    required this.digest,
  });

  factory RuntimeLifecycleHostProjectionContract.create({
    required RuntimeServiceActivationProjectionContract
        runtimeServiceActivationProjection,
    required RuntimeLifecycleProjectionContract runtimeLifecycleProjection,
    required List<RuntimeLifecycleHostEntry> entries,
  }) {
    if (runtimeServiceActivationProjection.entries.isEmpty ||
        runtimeLifecycleProjection.entries.isEmpty ||
        runtimeServiceActivationProjection.entries.length !=
            runtimeLifecycleProjection.entries.length ||
        entries.length != runtimeServiceActivationProjection.entries.length) {
      throw ArgumentError('Runtime lifecycle host projection is incomplete.');
    }
    final lifecycleByNode = {
      for (final entry in runtimeLifecycleProjection.entries)
        entry.runtimeNodeId: entry,
    };
    if (lifecycleByNode.length != runtimeLifecycleProjection.entries.length) {
      throw ArgumentError(
          'Runtime lifecycle projection contains duplicate nodes.');
    }
    final lifecycleHostProjectionId =
        'runtime-lifecycle-host.${runtimeServiceActivationProjection.id}.${runtimeLifecycleProjection.id}';
    final ordered = [...entries]..sort((left, right) =>
        left.canonicalPosition.compareTo(right.canonicalPosition));
    final positions = <int>{};
    final activationIds = <String>{};
    final lifecycleIds = <String>{};
    for (var index = 0; index < ordered.length; index++) {
      final entry = ordered[index];
      final activation = runtimeServiceActivationProjection.entries[index];
      final lifecycle = lifecycleByNode[activation.runtimeNodeId];
      final lifecycleEntryId = lifecycle == null
          ? null
          : 'runtime-lifecycle-entry.${runtimeLifecycleProjection.id}.${lifecycle.activationEntryId}';
      if (lifecycle == null ||
          entry.lifecycleHostProjectionId != lifecycleHostProjectionId ||
          entry.runtimeServiceActivationProjectionDigest !=
              runtimeServiceActivationProjection.digest ||
          entry.runtimeLifecycleProjectionDigest !=
              runtimeLifecycleProjection.digest ||
          entry.activationId != activation.activationId ||
          entry.lifecycleEntryId != lifecycleEntryId ||
          entry.serviceId != activation.serviceId ||
          entry.runtimeNodeId != activation.runtimeNodeId ||
          entry.runtimeNodeId != lifecycle.runtimeNodeId ||
          entry.lifecyclePhase != lifecycle.phase ||
          entry.canonicalPosition != index ||
          !positions.add(entry.canonicalPosition) ||
          !activationIds.add(entry.activationId) ||
          !lifecycleIds.add(entry.lifecycleEntryId)) {
        throw ArgumentError('Runtime lifecycle host provenance is invalid.');
      }
    }
    final payload = {
      'schemaVersion': runtimeLifecycleHostProjectionContractVersion,
      'policyVersion': runtimeLifecycleHostProjectionPolicyVersion,
      'lifecycleHostProjectionId': lifecycleHostProjectionId,
      'runtimeServiceActivationProjectionId':
          runtimeServiceActivationProjection.id,
      'runtimeServiceActivationProjectionDigest':
          runtimeServiceActivationProjection.digest,
      'runtimeLifecycleProjectionId': runtimeLifecycleProjection.id,
      'runtimeLifecycleProjectionDigest': runtimeLifecycleProjection.digest,
      'entries': ordered.map((entry) => entry.toJson()).toList(),
    };
    final digest = _digest(payload);
    return RuntimeLifecycleHostProjectionContract._(
      id: 'runtime-lifecycle-host-projection.${digest.substring(0, 16)}',
      lifecycleHostProjectionId: lifecycleHostProjectionId,
      runtimeServiceActivationProjectionId:
          runtimeServiceActivationProjection.id,
      runtimeServiceActivationProjectionDigest:
          runtimeServiceActivationProjection.digest,
      runtimeLifecycleProjectionId: runtimeLifecycleProjection.id,
      runtimeLifecycleProjectionDigest: runtimeLifecycleProjection.digest,
      entries: List.unmodifiable(ordered),
      digest: digest,
    );
  }

  final String id;
  final String lifecycleHostProjectionId;
  final String runtimeServiceActivationProjectionId;
  final String runtimeServiceActivationProjectionDigest;
  final String runtimeLifecycleProjectionId;
  final String runtimeLifecycleProjectionDigest;
  final List<RuntimeLifecycleHostEntry> entries;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': runtimeLifecycleHostProjectionContractVersion,
        'policyVersion': runtimeLifecycleHostProjectionPolicyVersion,
        'id': id,
        'lifecycleHostProjectionId': lifecycleHostProjectionId,
        'runtimeServiceActivationProjectionId':
            runtimeServiceActivationProjectionId,
        'runtimeServiceActivationProjectionDigest':
            runtimeServiceActivationProjectionDigest,
        'runtimeLifecycleProjectionId': runtimeLifecycleProjectionId,
        'runtimeLifecycleProjectionDigest': runtimeLifecycleProjectionDigest,
        'entries': entries.map((entry) => entry.toJson()).toList(),
        'digest': digest,
      };
}

class RuntimeLifecycleHostProjector {
  const RuntimeLifecycleHostProjector();

  RuntimeLifecycleHostProjectionContract project({
    required RuntimeServiceActivationProjectionContract
        runtimeServiceActivationProjection,
    required RuntimeLifecycleProjectionContract runtimeLifecycleProjection,
  }) {
    final lifecycleByNode = {
      for (final entry in runtimeLifecycleProjection.entries)
        entry.runtimeNodeId: entry,
    };
    final lifecycleHostProjectionId =
        'runtime-lifecycle-host.${runtimeServiceActivationProjection.id}.${runtimeLifecycleProjection.id}';
    return RuntimeLifecycleHostProjectionContract.create(
      runtimeServiceActivationProjection: runtimeServiceActivationProjection,
      runtimeLifecycleProjection: runtimeLifecycleProjection,
      entries: [
        for (final activation in runtimeServiceActivationProjection.entries)
          _hostEntry(
            activation: activation,
            lifecycle: lifecycleByNode[activation.runtimeNodeId],
            lifecycleHostProjectionId: lifecycleHostProjectionId,
            activationProjectionDigest:
                runtimeServiceActivationProjection.digest,
            lifecycleProjection: runtimeLifecycleProjection,
          ),
      ],
    );
  }
}

RuntimeLifecycleHostEntry _hostEntry({
  required RuntimeServiceActivationEntry activation,
  required RuntimeLifecycleEntry? lifecycle,
  required String lifecycleHostProjectionId,
  required String activationProjectionDigest,
  required RuntimeLifecycleProjectionContract lifecycleProjection,
}) {
  if (lifecycle == null) {
    throw ArgumentError(
        'Runtime lifecycle host contains an orphan activation.');
  }
  return RuntimeLifecycleHostEntry(
    lifecycleHostProjectionId: lifecycleHostProjectionId,
    runtimeServiceActivationProjectionDigest: activationProjectionDigest,
    runtimeLifecycleProjectionDigest: lifecycleProjection.digest,
    activationId: activation.activationId,
    lifecycleEntryId:
        'runtime-lifecycle-entry.${lifecycleProjection.id}.${lifecycle.activationEntryId}',
    serviceId: activation.serviceId,
    runtimeNodeId: activation.runtimeNodeId,
    lifecyclePhase: lifecycle.phase,
    canonicalPosition: activation.activationPosition,
  );
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
