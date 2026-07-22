import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/runtime_lifecycle_host_projection_contracts.dart';
import 'package:pool_os/contracts/runtime_validation_contracts.dart';

const runtimeHealthDiagnosticsProjectionContractVersion = 1;
const runtimeHealthDiagnosticsProjectionPolicyVersion =
    'runtime-health-diagnostics-projection/1.0.0';

enum RuntimeValidationStatus { passed, failed }

class RuntimeHealthDiagnosticsEntry {
  const RuntimeHealthDiagnosticsEntry({
    required this.runtimeHealthProjectionId,
    required this.runtimeLifecycleHostProjectionDigest,
    required this.runtimeValidationDigest,
    required this.lifecycleHostEntryId,
    required this.runtimeNodeId,
    required this.serviceId,
    required this.validationArtifactDigest,
    required this.validationStatus,
    required this.canonicalPosition,
  });

  final String runtimeHealthProjectionId;
  final String runtimeLifecycleHostProjectionDigest;
  final String runtimeValidationDigest;
  final String lifecycleHostEntryId;
  final String runtimeNodeId;
  final String serviceId;
  final String validationArtifactDigest;
  final RuntimeValidationStatus validationStatus;
  final int canonicalPosition;

  Map<String, dynamic> toJson() => {
        'runtimeHealthProjectionId': runtimeHealthProjectionId,
        'runtimeLifecycleHostProjectionDigest':
            runtimeLifecycleHostProjectionDigest,
        'runtimeValidationDigest': runtimeValidationDigest,
        'lifecycleHostEntryId': lifecycleHostEntryId,
        'runtimeNodeId': runtimeNodeId,
        'serviceId': serviceId,
        'validationArtifactDigest': validationArtifactDigest,
        'validationStatus': validationStatus.name,
        'canonicalPosition': canonicalPosition,
      };
}

class RuntimeHealthDiagnosticsProjectionContract {
  const RuntimeHealthDiagnosticsProjectionContract._({
    required this.id,
    required this.runtimeHealthProjectionId,
    required this.runtimeLifecycleHostProjectionId,
    required this.runtimeLifecycleHostProjectionDigest,
    required this.runtimeValidationId,
    required this.runtimeValidationDigest,
    required this.entries,
    required this.digest,
  });

  factory RuntimeHealthDiagnosticsProjectionContract.create({
    required RuntimeLifecycleHostProjectionContract
        runtimeLifecycleHostProjection,
    required RuntimeValidationContract runtimeValidation,
    required List<RuntimeHealthDiagnosticsEntry> entries,
  }) {
    if (runtimeLifecycleHostProjection.entries.isEmpty ||
        runtimeValidation.digest.trim().isEmpty ||
        entries.length != runtimeLifecycleHostProjection.entries.length) {
      throw ArgumentError('Runtime health projection is incomplete.');
    }
    final runtimeHealthProjectionId =
        'runtime-health.${runtimeLifecycleHostProjection.id}.${runtimeValidation.id}';
    final ordered = [...entries]..sort((left, right) =>
        left.canonicalPosition.compareTo(right.canonicalPosition));
    final hostByPosition = {
      for (final entry in runtimeLifecycleHostProjection.entries)
        entry.canonicalPosition: entry,
    };
    if (hostByPosition.length !=
        runtimeLifecycleHostProjection.entries.length) {
      throw ArgumentError(
          'Runtime lifecycle host contains duplicate positions.');
    }
    final positions = <int>{};
    final hostIds = <String>{};
    for (var index = 0; index < ordered.length; index++) {
      final entry = ordered[index];
      final host = hostByPosition[entry.canonicalPosition];
      final expectedStatus = runtimeValidation.summary.failed == 0
          ? RuntimeValidationStatus.passed
          : RuntimeValidationStatus.failed;
      if (host == null ||
          entry.runtimeHealthProjectionId != runtimeHealthProjectionId ||
          entry.runtimeLifecycleHostProjectionDigest !=
              runtimeLifecycleHostProjection.digest ||
          entry.runtimeValidationDigest != runtimeValidation.digest ||
          entry.validationArtifactDigest != runtimeValidation.digest ||
          entry.lifecycleHostEntryId !=
              'runtime-lifecycle-host-entry.${runtimeLifecycleHostProjection.id}.${host.lifecycleHostProjectionId}.${host.canonicalPosition}' ||
          entry.runtimeNodeId != host.runtimeNodeId ||
          entry.serviceId != host.serviceId ||
          entry.validationStatus != expectedStatus ||
          entry.canonicalPosition != index ||
          !positions.add(entry.canonicalPosition) ||
          !hostIds.add(entry.lifecycleHostEntryId)) {
        throw ArgumentError(
            'Runtime health diagnostics provenance is invalid.');
      }
    }
    final payload = {
      'schemaVersion': runtimeHealthDiagnosticsProjectionContractVersion,
      'policyVersion': runtimeHealthDiagnosticsProjectionPolicyVersion,
      'runtimeHealthProjectionId': runtimeHealthProjectionId,
      'runtimeLifecycleHostProjectionId': runtimeLifecycleHostProjection.id,
      'runtimeLifecycleHostProjectionDigest':
          runtimeLifecycleHostProjection.digest,
      'runtimeValidationId': runtimeValidation.id,
      'runtimeValidationDigest': runtimeValidation.digest,
      'entries': ordered.map((entry) => entry.toJson()).toList(),
    };
    final digest = _digest(payload);
    return RuntimeHealthDiagnosticsProjectionContract._(
      id: 'runtime-health-diagnostics-projection.${digest.substring(0, 16)}',
      runtimeHealthProjectionId: runtimeHealthProjectionId,
      runtimeLifecycleHostProjectionId: runtimeLifecycleHostProjection.id,
      runtimeLifecycleHostProjectionDigest:
          runtimeLifecycleHostProjection.digest,
      runtimeValidationId: runtimeValidation.id,
      runtimeValidationDigest: runtimeValidation.digest,
      entries: List.unmodifiable(ordered),
      digest: digest,
    );
  }

  final String id;
  final String runtimeHealthProjectionId;
  final String runtimeLifecycleHostProjectionId;
  final String runtimeLifecycleHostProjectionDigest;
  final String runtimeValidationId;
  final String runtimeValidationDigest;
  final List<RuntimeHealthDiagnosticsEntry> entries;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': runtimeHealthDiagnosticsProjectionContractVersion,
        'policyVersion': runtimeHealthDiagnosticsProjectionPolicyVersion,
        'id': id,
        'runtimeHealthProjectionId': runtimeHealthProjectionId,
        'runtimeLifecycleHostProjectionId': runtimeLifecycleHostProjectionId,
        'runtimeLifecycleHostProjectionDigest':
            runtimeLifecycleHostProjectionDigest,
        'runtimeValidationId': runtimeValidationId,
        'runtimeValidationDigest': runtimeValidationDigest,
        'entries': entries.map((entry) => entry.toJson()).toList(),
        'digest': digest,
      };
}

class RuntimeHealthDiagnosticsProjector {
  const RuntimeHealthDiagnosticsProjector();

  RuntimeHealthDiagnosticsProjectionContract project({
    required RuntimeLifecycleHostProjectionContract
        runtimeLifecycleHostProjection,
    required RuntimeValidationContract runtimeValidation,
  }) {
    final runtimeHealthProjectionId =
        'runtime-health.${runtimeLifecycleHostProjection.id}.${runtimeValidation.id}';
    final status = runtimeValidation.summary.failed == 0
        ? RuntimeValidationStatus.passed
        : RuntimeValidationStatus.failed;
    return RuntimeHealthDiagnosticsProjectionContract.create(
      runtimeLifecycleHostProjection: runtimeLifecycleHostProjection,
      runtimeValidation: runtimeValidation,
      entries: [
        for (final host in runtimeLifecycleHostProjection.entries)
          RuntimeHealthDiagnosticsEntry(
            runtimeHealthProjectionId: runtimeHealthProjectionId,
            runtimeLifecycleHostProjectionDigest:
                runtimeLifecycleHostProjection.digest,
            runtimeValidationDigest: runtimeValidation.digest,
            lifecycleHostEntryId:
                'runtime-lifecycle-host-entry.${runtimeLifecycleHostProjection.id}.${host.lifecycleHostProjectionId}.${host.canonicalPosition}',
            runtimeNodeId: host.runtimeNodeId,
            serviceId: host.serviceId,
            validationArtifactDigest: runtimeValidation.digest,
            validationStatus: status,
            canonicalPosition: host.canonicalPosition,
          ),
      ],
    );
  }
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
