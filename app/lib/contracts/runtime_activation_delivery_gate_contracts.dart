import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/production_readiness_validation_contracts.dart';
import 'package:pool_os/contracts/runtime_delivery_projection_contracts.dart';

const runtimeActivationDeliveryGateContractVersion = 1;
const runtimeActivationDeliveryGatePolicyVersion =
    'runtime-activation-delivery-gate/1.0.0';

enum RuntimeActivationDeliveryGateStatus { eligible, blocked }

class RuntimeActivationDeliveryGateEntry {
  const RuntimeActivationDeliveryGateEntry({
    required this.gateProjectionId,
    required this.readinessProjectionDigest,
    required this.runtimeDeliveryProjectionDigest,
    required this.runtimeNodeId,
    required this.serviceId,
    required this.deliveryTarget,
    required this.gateStatus,
    required this.canonicalPosition,
    required this.provenanceDigest,
  });

  final String gateProjectionId;
  final String readinessProjectionDigest;
  final String runtimeDeliveryProjectionDigest;
  final String runtimeNodeId;
  final String serviceId;
  final RuntimeDeliveryTarget deliveryTarget;
  final RuntimeActivationDeliveryGateStatus gateStatus;
  final int canonicalPosition;
  final String provenanceDigest;

  Map<String, dynamic> toJson() => {
        'gateProjectionId': gateProjectionId,
        'readinessProjectionDigest': readinessProjectionDigest,
        'runtimeDeliveryProjectionDigest': runtimeDeliveryProjectionDigest,
        'runtimeNodeId': runtimeNodeId,
        'serviceId': serviceId,
        'deliveryTarget': deliveryTarget.name,
        'gateStatus': gateStatus.name,
        'canonicalPosition': canonicalPosition,
        'provenanceDigest': provenanceDigest,
      };
}

class RuntimeActivationDeliveryGateContract {
  const RuntimeActivationDeliveryGateContract._({
    required this.id,
    required this.gateProjectionId,
    required this.readinessProjectionId,
    required this.readinessProjectionDigest,
    required this.runtimeDeliveryProjectionId,
    required this.runtimeDeliveryProjectionDigest,
    required this.entries,
    required this.digest,
  });

  factory RuntimeActivationDeliveryGateContract.create({
    required ProductionReadinessProjectionContract readiness,
    required RuntimeDeliveryProjectionContract runtimeDelivery,
    required List<RuntimeActivationDeliveryGateEntry> entries,
  }) {
    if (readiness.entries.isEmpty ||
        runtimeDelivery.entries.isEmpty ||
        readiness.entries.length != runtimeDelivery.entries.length ||
        entries.length != runtimeDelivery.entries.length) {
      throw ArgumentError('Runtime activation delivery gate is incomplete.');
    }
    final gateProjectionId =
        'runtime-activation-delivery-gate.${readiness.id}.${runtimeDelivery.id}';
    final ordered = [...entries]
      ..sort((left, right) =>
          left.canonicalPosition.compareTo(right.canonicalPosition));
    final readinessByBinding = <String, ProductionReadinessEntry>{};
    for (final entry in readiness.entries) {
      final binding = _binding(entry.runtimeNodeId, entry.serviceId);
      if (readinessByBinding.putIfAbsent(binding, () => entry) != entry) {
        throw ArgumentError('Runtime readiness binding is duplicated.');
      }
    }
    final positions = <int>{};
    final bindings = <String>{};
    for (var position = 0; position < ordered.length; position++) {
      final entry = ordered[position];
      final delivery = runtimeDelivery.entries[position];
      final binding = _binding(delivery.runtimeNodeId, delivery.serviceId);
      final readinessEntry = readinessByBinding[binding];
      if (readinessEntry == null) {
        throw ArgumentError('Runtime delivery has no readiness binding.');
      }
      final expectedStatus = readinessEntry.readinessStatus ==
              ProductionReadinessStatus.ready
          ? RuntimeActivationDeliveryGateStatus.eligible
          : RuntimeActivationDeliveryGateStatus.blocked;
      final provenance = _provenance(
        readinessDigest: readiness.digest,
        deliveryDigest: runtimeDelivery.digest,
        runtimeNodeId: delivery.runtimeNodeId,
        serviceId: delivery.serviceId,
        target: delivery.target,
        status: expectedStatus,
      );
      if (entry.gateProjectionId != gateProjectionId ||
          entry.readinessProjectionDigest != readiness.digest ||
          entry.runtimeDeliveryProjectionDigest != runtimeDelivery.digest ||
          entry.runtimeNodeId != delivery.runtimeNodeId ||
          entry.serviceId != delivery.serviceId ||
          entry.deliveryTarget != delivery.target ||
          entry.gateStatus != expectedStatus ||
          entry.canonicalPosition != position ||
          entry.canonicalPosition != delivery.position ||
          entry.provenanceDigest != provenance ||
          !positions.add(entry.canonicalPosition) ||
          !bindings.add(binding)) {
        throw ArgumentError(
          'Runtime activation delivery gate provenance is invalid.',
        );
      }
    }
    if (bindings.length != readinessByBinding.length) {
      throw ArgumentError('Runtime readiness contains an orphan binding.');
    }
    final payload = {
      'schemaVersion': runtimeActivationDeliveryGateContractVersion,
      'policyVersion': runtimeActivationDeliveryGatePolicyVersion,
      'gateProjectionId': gateProjectionId,
      'readinessProjectionId': readiness.id,
      'readinessProjectionDigest': readiness.digest,
      'runtimeDeliveryProjectionId': runtimeDelivery.id,
      'runtimeDeliveryProjectionDigest': runtimeDelivery.digest,
      'entries': ordered.map((entry) => entry.toJson()).toList(),
    };
    final digest = _digest(payload);
    return RuntimeActivationDeliveryGateContract._(
      id: 'runtime-activation-delivery-gate.${digest.substring(0, 16)}',
      gateProjectionId: gateProjectionId,
      readinessProjectionId: readiness.id,
      readinessProjectionDigest: readiness.digest,
      runtimeDeliveryProjectionId: runtimeDelivery.id,
      runtimeDeliveryProjectionDigest: runtimeDelivery.digest,
      entries: List.unmodifiable(ordered),
      digest: digest,
    );
  }

  final String id;
  final String gateProjectionId;
  final String readinessProjectionId;
  final String readinessProjectionDigest;
  final String runtimeDeliveryProjectionId;
  final String runtimeDeliveryProjectionDigest;
  final List<RuntimeActivationDeliveryGateEntry> entries;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': runtimeActivationDeliveryGateContractVersion,
        'policyVersion': runtimeActivationDeliveryGatePolicyVersion,
        'id': id,
        'gateProjectionId': gateProjectionId,
        'readinessProjectionId': readinessProjectionId,
        'readinessProjectionDigest': readinessProjectionDigest,
        'runtimeDeliveryProjectionId': runtimeDeliveryProjectionId,
        'runtimeDeliveryProjectionDigest': runtimeDeliveryProjectionDigest,
        'entries': entries.map((entry) => entry.toJson()).toList(),
        'digest': digest,
      };
}

class RuntimeActivationDeliveryGateProjector {
  const RuntimeActivationDeliveryGateProjector();

  RuntimeActivationDeliveryGateContract project({
    required ProductionReadinessProjectionContract readiness,
    required RuntimeDeliveryProjectionContract runtimeDelivery,
  }) {
    final gateProjectionId =
        'runtime-activation-delivery-gate.${readiness.id}.${runtimeDelivery.id}';
    final readinessByBinding = {
      for (final entry in readiness.entries)
        _binding(entry.runtimeNodeId, entry.serviceId): entry,
    };
    return RuntimeActivationDeliveryGateContract.create(
      readiness: readiness,
      runtimeDelivery: runtimeDelivery,
      entries: [
        for (final delivery in runtimeDelivery.entries)
          RuntimeActivationDeliveryGateEntry(
            gateProjectionId: gateProjectionId,
            readinessProjectionDigest: readiness.digest,
            runtimeDeliveryProjectionDigest: runtimeDelivery.digest,
            runtimeNodeId: delivery.runtimeNodeId,
            serviceId: delivery.serviceId,
            deliveryTarget: delivery.target,
            gateStatus: readinessByBinding[_binding(
                          delivery.runtimeNodeId,
                          delivery.serviceId,
                        )]
                        ?.readinessStatus ==
                    ProductionReadinessStatus.ready
                ? RuntimeActivationDeliveryGateStatus.eligible
                : RuntimeActivationDeliveryGateStatus.blocked,
            canonicalPosition: delivery.position,
            provenanceDigest: _provenance(
              readinessDigest: readiness.digest,
              deliveryDigest: runtimeDelivery.digest,
              runtimeNodeId: delivery.runtimeNodeId,
              serviceId: delivery.serviceId,
              target: delivery.target,
              status: readinessByBinding[_binding(
                            delivery.runtimeNodeId,
                            delivery.serviceId,
                          )]
                          ?.readinessStatus ==
                      ProductionReadinessStatus.ready
                  ? RuntimeActivationDeliveryGateStatus.eligible
                  : RuntimeActivationDeliveryGateStatus.blocked,
            ),
          ),
      ],
    );
  }
}

String _binding(String runtimeNodeId, String serviceId) =>
    '$runtimeNodeId:$serviceId';

String _provenance({
  required String readinessDigest,
  required String deliveryDigest,
  required String runtimeNodeId,
  required String serviceId,
  required RuntimeDeliveryTarget target,
  required RuntimeActivationDeliveryGateStatus status,
}) =>
    _digest({
      'readinessDigest': readinessDigest,
      'deliveryDigest': deliveryDigest,
      'runtimeNodeId': runtimeNodeId,
      'serviceId': serviceId,
      'deliveryTarget': target.name,
      'gateStatus': status.name,
    });

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
