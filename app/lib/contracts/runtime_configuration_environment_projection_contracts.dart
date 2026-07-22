import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/runtime_delivery_projection_contracts.dart';
import 'package:pool_os/contracts/runtime_health_diagnostics_projection_contracts.dart';

const runtimeConfigurationEnvironmentProjectionContractVersion = 1;
const runtimeConfigurationEnvironmentProjectionPolicyVersion =
    'runtime-configuration-environment-projection/1.0.0';

class RuntimeConfigurationEnvironmentEntry {
  const RuntimeConfigurationEnvironmentEntry({
    required this.configurationEntryId,
    required this.configurationId,
    required this.environmentId,
    required this.runtimeNodeId,
    required this.serviceId,
    required this.deliveryId,
    required this.deliveryTarget,
    required this.runtimeHealthProjectionDigest,
    required this.runtimeDeliveryProjectionDigest,
    required this.configurationProvenanceDigest,
    required this.canonicalPosition,
  });

  final String configurationEntryId;
  final String configurationId;
  final String environmentId;
  final String runtimeNodeId;
  final String serviceId;
  final String deliveryId;
  final RuntimeDeliveryTarget deliveryTarget;
  final String runtimeHealthProjectionDigest;
  final String runtimeDeliveryProjectionDigest;
  final String configurationProvenanceDigest;
  final int canonicalPosition;

  Map<String, dynamic> toJson() => {
        'configurationEntryId': configurationEntryId,
        'configurationId': configurationId,
        'environmentId': environmentId,
        'runtimeNodeId': runtimeNodeId,
        'serviceId': serviceId,
        'deliveryId': deliveryId,
        'deliveryTarget': deliveryTarget.name,
        'runtimeHealthProjectionDigest': runtimeHealthProjectionDigest,
        'runtimeDeliveryProjectionDigest': runtimeDeliveryProjectionDigest,
        'configurationProvenanceDigest': configurationProvenanceDigest,
        'canonicalPosition': canonicalPosition,
      };
}

class RuntimeConfigurationEnvironmentProjectionContract {
  const RuntimeConfigurationEnvironmentProjectionContract._({
    required this.id,
    required this.configurationProjectionId,
    required this.runtimeHealthProjectionId,
    required this.runtimeHealthProjectionDigest,
    required this.runtimeDeliveryProjectionId,
    required this.runtimeDeliveryProjectionDigest,
    required this.entries,
    required this.digest,
  });

  factory RuntimeConfigurationEnvironmentProjectionContract.create({
    required RuntimeHealthDiagnosticsProjectionContract runtimeHealth,
    required RuntimeDeliveryProjectionContract runtimeDelivery,
    required List<RuntimeConfigurationEnvironmentEntry> entries,
  }) {
    if (runtimeHealth.entries.isEmpty ||
        runtimeDelivery.entries.isEmpty ||
        runtimeHealth.entries.length != runtimeDelivery.entries.length ||
        entries.length != runtimeDelivery.entries.length) {
      throw ArgumentError('Runtime configuration projection is incomplete.');
    }
    final healthByNode = {
      for (final entry in runtimeHealth.entries) entry.runtimeNodeId: entry,
    };
    if (healthByNode.length != runtimeHealth.entries.length) {
      throw ArgumentError(
          'Runtime health projection contains duplicate nodes.');
    }
    final configurationProjectionId =
        'runtime-configuration.${runtimeHealth.id}.${runtimeDelivery.id}';
    final ordered = [...entries]..sort((left, right) =>
        left.canonicalPosition.compareTo(right.canonicalPosition));
    final positions = <int>{};
    final entryIds = <String>{};
    final deliveryIds = <String>{};
    for (var index = 0; index < ordered.length; index++) {
      final entry = ordered[index];
      final delivery = runtimeDelivery.entries[index];
      final health = healthByNode[delivery.runtimeNodeId];
      final provenance = _configurationProvenance(
        runtimeHealthDigest: runtimeHealth.digest,
        runtimeDeliveryDigest: runtimeDelivery.digest,
        runtimeNodeId: delivery.runtimeNodeId,
        serviceId: delivery.serviceId,
        deliveryId: delivery.deliveryId,
      );
      if (health == null ||
          health.serviceId != delivery.serviceId ||
          entry.configurationEntryId !=
              'runtime-configuration-entry.${delivery.deliveryId}' ||
          entry.configurationId !=
              'runtime-configuration.${delivery.serviceId}' ||
          entry.environmentId !=
              'runtime-environment.${delivery.target.name}' ||
          entry.runtimeNodeId != delivery.runtimeNodeId ||
          entry.serviceId != delivery.serviceId ||
          entry.deliveryId != delivery.deliveryId ||
          entry.deliveryTarget != delivery.target ||
          entry.runtimeHealthProjectionDigest != runtimeHealth.digest ||
          entry.runtimeDeliveryProjectionDigest != runtimeDelivery.digest ||
          entry.configurationProvenanceDigest != provenance ||
          entry.canonicalPosition != index ||
          entry.canonicalPosition != delivery.position ||
          !positions.add(entry.canonicalPosition) ||
          !entryIds.add(entry.configurationEntryId) ||
          !deliveryIds.add(entry.deliveryId)) {
        throw ArgumentError('Runtime configuration provenance is invalid.');
      }
    }
    final payload = {
      'schemaVersion': runtimeConfigurationEnvironmentProjectionContractVersion,
      'policyVersion': runtimeConfigurationEnvironmentProjectionPolicyVersion,
      'configurationProjectionId': configurationProjectionId,
      'runtimeHealthProjectionId': runtimeHealth.id,
      'runtimeHealthProjectionDigest': runtimeHealth.digest,
      'runtimeDeliveryProjectionId': runtimeDelivery.id,
      'runtimeDeliveryProjectionDigest': runtimeDelivery.digest,
      'entries': ordered.map((entry) => entry.toJson()).toList(),
    };
    final digest = _digest(payload);
    return RuntimeConfigurationEnvironmentProjectionContract._(
      id: 'runtime-configuration-environment.${digest.substring(0, 16)}',
      configurationProjectionId: configurationProjectionId,
      runtimeHealthProjectionId: runtimeHealth.id,
      runtimeHealthProjectionDigest: runtimeHealth.digest,
      runtimeDeliveryProjectionId: runtimeDelivery.id,
      runtimeDeliveryProjectionDigest: runtimeDelivery.digest,
      entries: List.unmodifiable(ordered),
      digest: digest,
    );
  }

  final String id;
  final String configurationProjectionId;
  final String runtimeHealthProjectionId;
  final String runtimeHealthProjectionDigest;
  final String runtimeDeliveryProjectionId;
  final String runtimeDeliveryProjectionDigest;
  final List<RuntimeConfigurationEnvironmentEntry> entries;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion':
            runtimeConfigurationEnvironmentProjectionContractVersion,
        'policyVersion': runtimeConfigurationEnvironmentProjectionPolicyVersion,
        'id': id,
        'configurationProjectionId': configurationProjectionId,
        'runtimeHealthProjectionId': runtimeHealthProjectionId,
        'runtimeHealthProjectionDigest': runtimeHealthProjectionDigest,
        'runtimeDeliveryProjectionId': runtimeDeliveryProjectionId,
        'runtimeDeliveryProjectionDigest': runtimeDeliveryProjectionDigest,
        'entries': entries.map((entry) => entry.toJson()).toList(),
        'digest': digest,
      };
}

class RuntimeConfigurationEnvironmentProjector {
  const RuntimeConfigurationEnvironmentProjector();

  RuntimeConfigurationEnvironmentProjectionContract project({
    required RuntimeHealthDiagnosticsProjectionContract runtimeHealth,
    required RuntimeDeliveryProjectionContract runtimeDelivery,
  }) =>
      RuntimeConfigurationEnvironmentProjectionContract.create(
        runtimeHealth: runtimeHealth,
        runtimeDelivery: runtimeDelivery,
        entries: [
          for (final delivery in runtimeDelivery.entries)
            RuntimeConfigurationEnvironmentEntry(
              configurationEntryId:
                  'runtime-configuration-entry.${delivery.deliveryId}',
              configurationId: 'runtime-configuration.${delivery.serviceId}',
              environmentId: 'runtime-environment.${delivery.target.name}',
              runtimeNodeId: delivery.runtimeNodeId,
              serviceId: delivery.serviceId,
              deliveryId: delivery.deliveryId,
              deliveryTarget: delivery.target,
              runtimeHealthProjectionDigest: runtimeHealth.digest,
              runtimeDeliveryProjectionDigest: runtimeDelivery.digest,
              configurationProvenanceDigest: _configurationProvenance(
                runtimeHealthDigest: runtimeHealth.digest,
                runtimeDeliveryDigest: runtimeDelivery.digest,
                runtimeNodeId: delivery.runtimeNodeId,
                serviceId: delivery.serviceId,
                deliveryId: delivery.deliveryId,
              ),
              canonicalPosition: delivery.position,
            ),
        ],
      );
}

String _configurationProvenance({
  required String runtimeHealthDigest,
  required String runtimeDeliveryDigest,
  required String runtimeNodeId,
  required String serviceId,
  required String deliveryId,
}) =>
    _digest({
      'runtimeHealthDigest': runtimeHealthDigest,
      'runtimeDeliveryDigest': runtimeDeliveryDigest,
      'runtimeNodeId': runtimeNodeId,
      'serviceId': serviceId,
      'deliveryId': deliveryId,
    });

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
