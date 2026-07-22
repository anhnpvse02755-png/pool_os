import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/runtime_configuration_environment_projection_contracts.dart';
import 'package:pool_os/contracts/runtime_validation_contracts.dart';

const productionReadinessProjectionContractVersion = 1;
const productionReadinessProjectionPolicyVersion =
    'production-readiness-projection/1.0.0';

enum ProductionReadinessStatus { ready, blocked }

class ProductionReadinessEntry {
  const ProductionReadinessEntry({
    required this.readinessProjectionId,
    required this.runtimeConfigurationEnvironmentProjectionDigest,
    required this.runtimeValidationDigest,
    required this.runtimeNodeId,
    required this.serviceId,
    required this.readinessStatus,
    required this.canonicalPosition,
    required this.provenanceDigest,
  });

  final String readinessProjectionId;
  final String runtimeConfigurationEnvironmentProjectionDigest;
  final String runtimeValidationDigest;
  final String runtimeNodeId;
  final String serviceId;
  final ProductionReadinessStatus readinessStatus;
  final int canonicalPosition;
  final String provenanceDigest;

  Map<String, dynamic> toJson() => {
        'readinessProjectionId': readinessProjectionId,
        'runtimeConfigurationEnvironmentProjectionDigest':
            runtimeConfigurationEnvironmentProjectionDigest,
        'runtimeValidationDigest': runtimeValidationDigest,
        'runtimeNodeId': runtimeNodeId,
        'serviceId': serviceId,
        'readinessStatus': readinessStatus.name,
        'canonicalPosition': canonicalPosition,
        'provenanceDigest': provenanceDigest,
      };
}

class ProductionReadinessProjectionContract {
  const ProductionReadinessProjectionContract._({
    required this.id,
    required this.readinessProjectionId,
    required this.runtimeConfigurationEnvironmentProjectionId,
    required this.runtimeConfigurationEnvironmentProjectionDigest,
    required this.runtimeValidationId,
    required this.runtimeValidationDigest,
    required this.entries,
    required this.digest,
  });

  factory ProductionReadinessProjectionContract.create({
    required RuntimeConfigurationEnvironmentProjectionContract configuration,
    required RuntimeValidationContract runtimeValidation,
    required List<ProductionReadinessEntry> entries,
  }) {
    if (configuration.entries.isEmpty ||
        runtimeValidation.digest.trim().isEmpty ||
        entries.length != configuration.entries.length) {
      throw ArgumentError('Production readiness projection is incomplete.');
    }
    final readinessProjectionId =
        'production-readiness.${configuration.id}.${runtimeValidation.id}';
    final ordered = [...entries]..sort((left, right) =>
        left.canonicalPosition.compareTo(right.canonicalPosition));
    final positions = <int>{};
    final bindings = <String>{};
    final expectedStatus = runtimeValidation.summary.failed == 0
        ? ProductionReadinessStatus.ready
        : ProductionReadinessStatus.blocked;
    for (var index = 0; index < ordered.length; index++) {
      final entry = ordered[index];
      final configurationEntry = configuration.entries[index];
      final provenance = _provenance(
        configurationDigest: configuration.digest,
        validationDigest: runtimeValidation.digest,
        runtimeNodeId: configurationEntry.runtimeNodeId,
        serviceId: configurationEntry.serviceId,
        status: expectedStatus,
      );
      if (entry.readinessProjectionId != readinessProjectionId ||
          entry.runtimeConfigurationEnvironmentProjectionDigest !=
              configuration.digest ||
          entry.runtimeValidationDigest != runtimeValidation.digest ||
          entry.runtimeNodeId != configurationEntry.runtimeNodeId ||
          entry.serviceId != configurationEntry.serviceId ||
          entry.readinessStatus != expectedStatus ||
          entry.canonicalPosition != index ||
          entry.canonicalPosition != configurationEntry.canonicalPosition ||
          entry.provenanceDigest != provenance ||
          !positions.add(entry.canonicalPosition) ||
          !bindings.add('${entry.runtimeNodeId}:${entry.serviceId}')) {
        throw ArgumentError('Production readiness provenance is invalid.');
      }
    }
    final payload = {
      'schemaVersion': productionReadinessProjectionContractVersion,
      'policyVersion': productionReadinessProjectionPolicyVersion,
      'readinessProjectionId': readinessProjectionId,
      'runtimeConfigurationEnvironmentProjectionId': configuration.id,
      'runtimeConfigurationEnvironmentProjectionDigest': configuration.digest,
      'runtimeValidationId': runtimeValidation.id,
      'runtimeValidationDigest': runtimeValidation.digest,
      'entries': ordered.map((entry) => entry.toJson()).toList(),
    };
    final digest = _digest(payload);
    return ProductionReadinessProjectionContract._(
      id: 'production-readiness-projection.${digest.substring(0, 16)}',
      readinessProjectionId: readinessProjectionId,
      runtimeConfigurationEnvironmentProjectionId: configuration.id,
      runtimeConfigurationEnvironmentProjectionDigest: configuration.digest,
      runtimeValidationId: runtimeValidation.id,
      runtimeValidationDigest: runtimeValidation.digest,
      entries: List.unmodifiable(ordered),
      digest: digest,
    );
  }

  final String id;
  final String readinessProjectionId;
  final String runtimeConfigurationEnvironmentProjectionId;
  final String runtimeConfigurationEnvironmentProjectionDigest;
  final String runtimeValidationId;
  final String runtimeValidationDigest;
  final List<ProductionReadinessEntry> entries;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': productionReadinessProjectionContractVersion,
        'policyVersion': productionReadinessProjectionPolicyVersion,
        'id': id,
        'readinessProjectionId': readinessProjectionId,
        'runtimeConfigurationEnvironmentProjectionId':
            runtimeConfigurationEnvironmentProjectionId,
        'runtimeConfigurationEnvironmentProjectionDigest':
            runtimeConfigurationEnvironmentProjectionDigest,
        'runtimeValidationId': runtimeValidationId,
        'runtimeValidationDigest': runtimeValidationDigest,
        'entries': entries.map((entry) => entry.toJson()).toList(),
        'digest': digest,
      };
}

class ProductionReadinessProjector {
  const ProductionReadinessProjector();

  ProductionReadinessProjectionContract project({
    required RuntimeConfigurationEnvironmentProjectionContract configuration,
    required RuntimeValidationContract runtimeValidation,
  }) {
    final readinessProjectionId =
        'production-readiness.${configuration.id}.${runtimeValidation.id}';
    final status = runtimeValidation.summary.failed == 0
        ? ProductionReadinessStatus.ready
        : ProductionReadinessStatus.blocked;
    return ProductionReadinessProjectionContract.create(
      configuration: configuration,
      runtimeValidation: runtimeValidation,
      entries: [
        for (final entry in configuration.entries)
          ProductionReadinessEntry(
            readinessProjectionId: readinessProjectionId,
            runtimeConfigurationEnvironmentProjectionDigest:
                configuration.digest,
            runtimeValidationDigest: runtimeValidation.digest,
            runtimeNodeId: entry.runtimeNodeId,
            serviceId: entry.serviceId,
            readinessStatus: status,
            canonicalPosition: entry.canonicalPosition,
            provenanceDigest: _provenance(
              configurationDigest: configuration.digest,
              validationDigest: runtimeValidation.digest,
              runtimeNodeId: entry.runtimeNodeId,
              serviceId: entry.serviceId,
              status: status,
            ),
          ),
      ],
    );
  }
}

String _provenance({
  required String configurationDigest,
  required String validationDigest,
  required String runtimeNodeId,
  required String serviceId,
  required ProductionReadinessStatus status,
}) =>
    _digest({
      'configurationDigest': configurationDigest,
      'validationDigest': validationDigest,
      'runtimeNodeId': runtimeNodeId,
      'serviceId': serviceId,
      'status': status.name,
    });

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
