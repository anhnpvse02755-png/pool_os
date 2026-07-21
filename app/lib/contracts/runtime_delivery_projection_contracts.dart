import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/runtime_service_exposure_contracts.dart';

const runtimeDeliveryProjectionContractVersion = 1;
const runtimeDeliveryProjectionPolicyVersion =
    'runtime-delivery-projection/1.0.0';

enum RuntimeDeliveryTarget { runtime, application, api, ai }

class RuntimeDeliveryEntry {
  const RuntimeDeliveryEntry({
    required this.deliveryId,
    required this.exposureId,
    required this.serviceId,
    required this.runtimeNodeId,
    required this.exposureScope,
    required this.target,
    required this.exposureDigest,
    required this.position,
  });

  final String deliveryId;
  final String exposureId;
  final String serviceId;
  final String runtimeNodeId;
  final RuntimeExposureScope exposureScope;
  final RuntimeDeliveryTarget target;
  final String exposureDigest;
  final int position;

  Map<String, dynamic> toJson() => {
        'deliveryId': deliveryId,
        'exposureId': exposureId,
        'serviceId': serviceId,
        'runtimeNodeId': runtimeNodeId,
        'exposureScope': exposureScope.name,
        'target': target.name,
        'exposureDigest': exposureDigest,
        'position': position,
      };
}

class RuntimeDeliveryProjectionContract {
  const RuntimeDeliveryProjectionContract._({
    required this.id,
    required this.exposureId,
    required this.exposureDigest,
    required this.entries,
    required this.digest,
  });

  factory RuntimeDeliveryProjectionContract.create({
    required RuntimeServiceExposureContract exposure,
    required List<RuntimeDeliveryEntry> entries,
  }) {
    final ordered = [...entries]
      ..sort((left, right) => left.position.compareTo(right.position));
    if (ordered.length != exposure.entries.length ||
        ordered.map((entry) => entry.deliveryId).toSet().length !=
            ordered.length ||
        ordered.map((entry) => entry.exposureId).toSet().length !=
            ordered.length ||
        ordered.map((entry) => entry.position).toSet().length !=
            ordered.length) {
      throw ArgumentError(
        'Runtime delivery contains duplicate or orphan entries.',
      );
    }
    for (var position = 0; position < ordered.length; position++) {
      final delivery = ordered[position];
      final exposedService = exposure.entries[position];
      if (delivery.position != position ||
          delivery.deliveryId != _deliveryId(exposedService.exposureId) ||
          delivery.exposureId != exposedService.exposureId ||
          delivery.serviceId != exposedService.serviceId ||
          delivery.runtimeNodeId != exposedService.runtimeNodeId ||
          delivery.exposureScope != exposedService.scope ||
          delivery.target != _target(exposedService.scope) ||
          delivery.exposureDigest != exposure.digest) {
        throw ArgumentError(
            'Runtime delivery target or provenance is invalid.');
      }
    }
    final payload = {
      'schemaVersion': runtimeDeliveryProjectionContractVersion,
      'policyVersion': runtimeDeliveryProjectionPolicyVersion,
      'exposureId': exposure.id,
      'exposureDigest': exposure.digest,
      'entries': ordered.map((entry) => entry.toJson()).toList(),
    };
    final digest = _digest(payload);
    return RuntimeDeliveryProjectionContract._(
      id: 'runtime-delivery-projection.${digest.substring(0, 16)}',
      exposureId: exposure.id,
      exposureDigest: exposure.digest,
      entries: List.unmodifiable(ordered),
      digest: digest,
    );
  }

  final String id;
  final String exposureId;
  final String exposureDigest;
  final List<RuntimeDeliveryEntry> entries;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': runtimeDeliveryProjectionContractVersion,
        'policyVersion': runtimeDeliveryProjectionPolicyVersion,
        'id': id,
        'exposureId': exposureId,
        'exposureDigest': exposureDigest,
        'entries': entries.map((entry) => entry.toJson()).toList(),
        'digest': digest,
      };
}

class RuntimeDeliveryProjector {
  const RuntimeDeliveryProjector();

  RuntimeDeliveryProjectionContract project(
    RuntimeServiceExposureContract exposure,
  ) {
    final entries = [
      for (var position = 0; position < exposure.entries.length; position++)
        RuntimeDeliveryEntry(
          deliveryId: _deliveryId(exposure.entries[position].exposureId),
          exposureId: exposure.entries[position].exposureId,
          serviceId: exposure.entries[position].serviceId,
          runtimeNodeId: exposure.entries[position].runtimeNodeId,
          exposureScope: exposure.entries[position].scope,
          target: _target(exposure.entries[position].scope),
          exposureDigest: exposure.digest,
          position: position,
        ),
    ];
    return RuntimeDeliveryProjectionContract.create(
      exposure: exposure,
      entries: entries,
    );
  }
}

RuntimeDeliveryTarget _target(RuntimeExposureScope scope) => switch (scope) {
      RuntimeExposureScope.internal => RuntimeDeliveryTarget.runtime,
      RuntimeExposureScope.application => RuntimeDeliveryTarget.application,
      RuntimeExposureScope.api => RuntimeDeliveryTarget.api,
      RuntimeExposureScope.aiConsumer => RuntimeDeliveryTarget.ai,
    };

String _deliveryId(String exposureId) => 'delivery:$exposureId';

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
