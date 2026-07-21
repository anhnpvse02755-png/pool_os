import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/runtime_activation_coordination_contracts.dart';
import 'package:pool_os/contracts/runtime_service_composition_contracts.dart';
import 'package:pool_os/contracts/runtime_service_registry_contracts.dart';

const runtimeServiceExposureContractVersion = 1;
const runtimeServiceExposurePolicyVersion = 'runtime-service-exposure/1.0.0';

enum RuntimeExposureScope { internal, application, aiConsumer, api }

class RuntimeServiceExposureEntry {
  const RuntimeServiceExposureEntry({
    required this.exposureId,
    required this.activationCoordinationDigest,
    required this.runtimeServiceRegistryDigest,
    required this.serviceId,
    required this.runtimeNodeId,
    required this.serviceType,
    required this.scope,
    required this.position,
  });

  final String exposureId;
  final String activationCoordinationDigest;
  final String runtimeServiceRegistryDigest;
  final String serviceId;
  final String runtimeNodeId;
  final RuntimeServiceType serviceType;
  final RuntimeExposureScope scope;
  final int position;

  Map<String, dynamic> toJson() => {
        'exposureId': exposureId,
        'activationCoordinationDigest': activationCoordinationDigest,
        'runtimeServiceRegistryDigest': runtimeServiceRegistryDigest,
        'serviceId': serviceId,
        'runtimeNodeId': runtimeNodeId,
        'serviceType': serviceType.name,
        'scope': scope.name,
        'position': position,
      };
}

class RuntimeServiceExposureContract {
  const RuntimeServiceExposureContract._({
    required this.id,
    required this.activationCoordinationDigest,
    required this.runtimeServiceRegistryDigest,
    required this.entries,
    required this.digest,
  });

  factory RuntimeServiceExposureContract.create({
    required RuntimeActivationCoordinationContract activationCoordination,
    required RuntimeServiceRegistryContract registry,
    required List<RuntimeServiceExposureEntry> entries,
  }) {
    final ordered = [...entries]
      ..sort((left, right) => left.position.compareTo(right.position));
    final activationIds =
        activationCoordination.entries.map((entry) => entry.serviceId).toSet();
    final registryIds =
        registry.entries.map((entry) => entry.serviceId).toSet();
    if (activationIds.length != activationCoordination.entries.length ||
        registryIds.length != registry.entries.length ||
        activationIds.length != registryIds.length ||
        !activationIds.containsAll(registryIds) ||
        ordered.length != activationIds.length ||
        ordered.map((entry) => entry.exposureId).toSet().length !=
            ordered.length ||
        ordered.map((entry) => entry.serviceId).toSet().length !=
            ordered.length ||
        ordered.map((entry) => entry.position).toSet().length !=
            ordered.length) {
      throw ArgumentError(
        'Service exposure contains duplicate, orphan, or mismatched entries.',
      );
    }
    final registryByService = {
      for (final entry in registry.entries) entry.serviceId: entry,
    };
    for (var position = 0; position < ordered.length; position++) {
      final exposure = ordered[position];
      final activation = activationCoordination.entries[position];
      final service = registryByService[activation.serviceId];
      if (service == null ||
          exposure.position != position ||
          exposure.exposureId != _exposureId(activation.serviceId) ||
          exposure.activationCoordinationDigest !=
              activationCoordination.digest ||
          exposure.runtimeServiceRegistryDigest != registry.digest ||
          exposure.serviceId != activation.serviceId ||
          exposure.runtimeNodeId != activation.runtimeNodeId ||
          exposure.serviceType != service.type ||
          exposure.scope != _scope(service.type)) {
        throw ArgumentError('Service exposure provenance or scope is invalid.');
      }
    }
    final payload = {
      'schemaVersion': runtimeServiceExposureContractVersion,
      'policyVersion': runtimeServiceExposurePolicyVersion,
      'activationCoordinationDigest': activationCoordination.digest,
      'runtimeServiceRegistryDigest': registry.digest,
      'entries': ordered.map((entry) => entry.toJson()).toList(),
    };
    final digest = _digest(payload);
    return RuntimeServiceExposureContract._(
      id: 'runtime-service-exposure.${digest.substring(0, 16)}',
      activationCoordinationDigest: activationCoordination.digest,
      runtimeServiceRegistryDigest: registry.digest,
      entries: List.unmodifiable(ordered),
      digest: digest,
    );
  }

  final String id;
  final String activationCoordinationDigest;
  final String runtimeServiceRegistryDigest;
  final List<RuntimeServiceExposureEntry> entries;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': runtimeServiceExposureContractVersion,
        'policyVersion': runtimeServiceExposurePolicyVersion,
        'id': id,
        'activationCoordinationDigest': activationCoordinationDigest,
        'runtimeServiceRegistryDigest': runtimeServiceRegistryDigest,
        'entries': entries.map((entry) => entry.toJson()).toList(),
        'digest': digest,
      };
}

class RuntimeServiceExposureProjector {
  const RuntimeServiceExposureProjector();

  RuntimeServiceExposureContract project({
    required RuntimeActivationCoordinationContract activationCoordination,
    required RuntimeServiceRegistryContract registry,
  }) {
    final registryByService = {
      for (final entry in registry.entries) entry.serviceId: entry,
    };
    final activationServiceIds =
        activationCoordination.entries.map((entry) => entry.serviceId).toList();
    if (activationServiceIds.toSet().length != activationServiceIds.length ||
        registryByService.length != activationServiceIds.length ||
        activationServiceIds.any(
          (serviceId) => !registryByService.containsKey(serviceId),
        )) {
      throw ArgumentError('Activation and registry service identities differ.');
    }
    final entries = [
      for (var position = 0;
          position < activationCoordination.entries.length;
          position++)
        RuntimeServiceExposureEntry(
          exposureId:
              _exposureId(activationCoordination.entries[position].serviceId),
          activationCoordinationDigest: activationCoordination.digest,
          runtimeServiceRegistryDigest: registry.digest,
          serviceId: activationCoordination.entries[position].serviceId,
          runtimeNodeId: activationCoordination.entries[position].runtimeNodeId,
          serviceType: registryByService[
                  activationCoordination.entries[position].serviceId]!
              .type,
          scope: _scope(registryByService[
                  activationCoordination.entries[position].serviceId]!
              .type),
          position: position,
        ),
    ];
    return RuntimeServiceExposureContract.create(
      activationCoordination: activationCoordination,
      registry: registry,
      entries: entries,
    );
  }
}

RuntimeExposureScope _scope(RuntimeServiceType type) => switch (type) {
      RuntimeServiceType.core => RuntimeExposureScope.internal,
      RuntimeServiceType.coordinator ||
      RuntimeServiceType.registry =>
        RuntimeExposureScope.application,
      RuntimeServiceType.projection => RuntimeExposureScope.aiConsumer,
      RuntimeServiceType.adapter => RuntimeExposureScope.api,
    };

String _exposureId(String serviceId) => 'exposure:$serviceId';

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
