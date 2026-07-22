import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/application/product_feature_assembly_planner.dart';
import 'package:pool_os/contracts/runtime_health_diagnostics_projection_contracts.dart';

const runtimeObservabilityIntegrationPlannerVersion = 1;
const runtimeObservabilityIntegrationPlannerPolicyVersion =
    'runtime-observability-integration-planner/1.0.0';

enum RuntimeObservabilityIntegrationLogPhase {
  validateInputs,
  orderFeatures,
  bindHealthProvenance,
  completed,
}

class RuntimeObservabilityIntegrationEntry {
  const RuntimeObservabilityIntegrationEntry._({
    required this.integrationEntryId,
    required this.assemblyEntryId,
    required this.featureId,
    required this.position,
    required this.featureAssemblyPlanDigest,
    required this.healthProjectionDigest,
    required this.digest,
  });

  factory RuntimeObservabilityIntegrationEntry.create({
    required String assemblyEntryId,
    required String featureId,
    required int position,
    required String featureAssemblyPlanDigest,
    required String healthProjectionDigest,
  }) {
    if (assemblyEntryId.isEmpty ||
        featureId.isEmpty ||
        position < 0 ||
        featureAssemblyPlanDigest.isEmpty ||
        healthProjectionDigest.isEmpty) {
      throw ArgumentError(
        'Runtime observability integration entry is incomplete.',
      );
    }
    final integrationEntryId = 'runtime-observability-integration.$featureId';
    final payload = {
      'integrationEntryId': integrationEntryId,
      'assemblyEntryId': assemblyEntryId,
      'featureId': featureId,
      'position': position,
      'featureAssemblyPlanDigest': featureAssemblyPlanDigest,
      'healthProjectionDigest': healthProjectionDigest,
    };
    return RuntimeObservabilityIntegrationEntry._(
      integrationEntryId: integrationEntryId,
      assemblyEntryId: assemblyEntryId,
      featureId: featureId,
      position: position,
      featureAssemblyPlanDigest: featureAssemblyPlanDigest,
      healthProjectionDigest: healthProjectionDigest,
      digest: _digest(payload),
    );
  }

  final String integrationEntryId;
  final String assemblyEntryId;
  final String featureId;
  final int position;
  final String featureAssemblyPlanDigest;
  final String healthProjectionDigest;
  final String digest;

  Map<String, dynamic> toJson() => {
        'integrationEntryId': integrationEntryId,
        'assemblyEntryId': assemblyEntryId,
        'featureId': featureId,
        'position': position,
        'featureAssemblyPlanDigest': featureAssemblyPlanDigest,
        'healthProjectionDigest': healthProjectionDigest,
        'digest': digest,
      };
}

class RuntimeObservabilityIntegrationLogEntry {
  const RuntimeObservabilityIntegrationLogEntry._({
    required this.phase,
    required this.position,
    required this.featureAssemblyPlanDigest,
    required this.healthProjectionDigest,
    required this.integrationSetDigest,
    required this.eventCode,
    required this.digest,
  });

  factory RuntimeObservabilityIntegrationLogEntry.create({
    required RuntimeObservabilityIntegrationLogPhase phase,
    required int position,
    required String featureAssemblyPlanDigest,
    required String healthProjectionDigest,
    required String integrationSetDigest,
  }) {
    if (position < 0 ||
        featureAssemblyPlanDigest.isEmpty ||
        healthProjectionDigest.isEmpty ||
        integrationSetDigest.isEmpty) {
      throw ArgumentError(
          'Runtime observability integration log is incomplete.');
    }
    final eventCode = 'runtime-observability-integration.${phase.name}';
    final payload = {
      'phase': phase.name,
      'position': position,
      'featureAssemblyPlanDigest': featureAssemblyPlanDigest,
      'healthProjectionDigest': healthProjectionDigest,
      'integrationSetDigest': integrationSetDigest,
      'eventCode': eventCode,
    };
    return RuntimeObservabilityIntegrationLogEntry._(
      phase: phase,
      position: position,
      featureAssemblyPlanDigest: featureAssemblyPlanDigest,
      healthProjectionDigest: healthProjectionDigest,
      integrationSetDigest: integrationSetDigest,
      eventCode: eventCode,
      digest: _digest(payload),
    );
  }

  final RuntimeObservabilityIntegrationLogPhase phase;
  final int position;
  final String featureAssemblyPlanDigest;
  final String healthProjectionDigest;
  final String integrationSetDigest;
  final String eventCode;
  final String digest;

  Map<String, dynamic> toJson() => {
        'phase': phase.name,
        'position': position,
        'featureAssemblyPlanDigest': featureAssemblyPlanDigest,
        'healthProjectionDigest': healthProjectionDigest,
        'integrationSetDigest': integrationSetDigest,
        'eventCode': eventCode,
        'digest': digest,
      };
}

class RuntimeObservabilityIntegrationPlan {
  const RuntimeObservabilityIntegrationPlan._({
    required this.id,
    required this.healthProjectionId,
    required this.healthProjectionDigest,
    required this.featureAssemblyPlanId,
    required this.featureAssemblyPlanDigest,
    required this.entries,
    required this.log,
    required this.digest,
  });

  factory RuntimeObservabilityIntegrationPlan.create({
    required RuntimeHealthDiagnosticsProjectionContract healthProjection,
    required ProductFeatureAssemblyPlan featureAssemblyPlan,
    required List<RuntimeObservabilityIntegrationEntry> entries,
    required List<RuntimeObservabilityIntegrationLogEntry> log,
  }) {
    _validateInputs(
      healthProjection: healthProjection,
      featureAssemblyPlan: featureAssemblyPlan,
    );
    if (entries.length != featureAssemblyPlan.entries.length) {
      throw ArgumentError(
        'Runtime observability integration coverage is incomplete.',
      );
    }
    final assemblyByFeature = {
      for (final entry in featureAssemblyPlan.entries) entry.featureId: entry,
    };
    final ordered = [...entries]
      ..sort((left, right) => left.position.compareTo(right.position));
    final integrationIds = <String>{};
    final assemblyIds = <String>{};
    final featureIds = <String>{};
    final positions = <int>{};
    for (var position = 0; position < ordered.length; position++) {
      final entry = ordered[position];
      final assembly = assemblyByFeature[entry.featureId];
      final expected = RuntimeObservabilityIntegrationEntry.create(
        assemblyEntryId: entry.assemblyEntryId,
        featureId: entry.featureId,
        position: position,
        featureAssemblyPlanDigest: featureAssemblyPlan.digest,
        healthProjectionDigest: healthProjection.digest,
      );
      if (assembly == null ||
          entry.position != position ||
          assembly.position != position ||
          entry.assemblyEntryId != assembly.assemblyEntryId ||
          entry.featureAssemblyPlanDigest != featureAssemblyPlan.digest ||
          entry.healthProjectionDigest != healthProjection.digest ||
          entry.integrationEntryId != expected.integrationEntryId ||
          entry.digest != expected.digest ||
          !integrationIds.add(entry.integrationEntryId) ||
          !assemblyIds.add(entry.assemblyEntryId) ||
          !featureIds.add(entry.featureId) ||
          !positions.add(entry.position)) {
        throw ArgumentError(
          'Runtime observability integration provenance is invalid.',
        );
      }
    }

    final integrationSetDigest =
        _digest(ordered.map((entry) => entry.toJson()).toList());
    final orderedLog = [...log]
      ..sort((left, right) => left.position.compareTo(right.position));
    if (orderedLog.length !=
        RuntimeObservabilityIntegrationLogPhase.values.length) {
      throw ArgumentError(
          'Runtime observability integration log is incomplete.');
    }
    for (var position = 0; position < orderedLog.length; position++) {
      final entry = orderedLog[position];
      final expected = RuntimeObservabilityIntegrationLogEntry.create(
        phase: RuntimeObservabilityIntegrationLogPhase.values[position],
        position: position,
        featureAssemblyPlanDigest: featureAssemblyPlan.digest,
        healthProjectionDigest: healthProjection.digest,
        integrationSetDigest: integrationSetDigest,
      );
      if (entry.phase != expected.phase ||
          entry.position != expected.position ||
          entry.featureAssemblyPlanDigest !=
              expected.featureAssemblyPlanDigest ||
          entry.healthProjectionDigest != expected.healthProjectionDigest ||
          entry.integrationSetDigest != expected.integrationSetDigest ||
          entry.eventCode != expected.eventCode ||
          entry.digest != expected.digest) {
        throw ArgumentError(
            'Runtime observability integration log is invalid.');
      }
    }

    final payload = {
      'plannerVersion': runtimeObservabilityIntegrationPlannerVersion,
      'policyVersion': runtimeObservabilityIntegrationPlannerPolicyVersion,
      'healthProjectionId': healthProjection.id,
      'healthProjectionDigest': healthProjection.digest,
      'featureAssemblyPlanId': featureAssemblyPlan.id,
      'featureAssemblyPlanDigest': featureAssemblyPlan.digest,
      'entries': ordered.map((entry) => entry.toJson()).toList(),
      'log': orderedLog.map((entry) => entry.toJson()).toList(),
    };
    final digest = _digest(payload);
    return RuntimeObservabilityIntegrationPlan._(
      id: 'runtime-observability-integration-plan.${digest.substring(0, 16)}',
      healthProjectionId: healthProjection.id,
      healthProjectionDigest: healthProjection.digest,
      featureAssemblyPlanId: featureAssemblyPlan.id,
      featureAssemblyPlanDigest: featureAssemblyPlan.digest,
      entries: List.unmodifiable(ordered),
      log: List.unmodifiable(orderedLog),
      digest: digest,
    );
  }

  final String id;
  final String healthProjectionId;
  final String healthProjectionDigest;
  final String featureAssemblyPlanId;
  final String featureAssemblyPlanDigest;
  final List<RuntimeObservabilityIntegrationEntry> entries;
  final List<RuntimeObservabilityIntegrationLogEntry> log;
  final String digest;

  Map<String, dynamic> toJson() => {
        'plannerVersion': runtimeObservabilityIntegrationPlannerVersion,
        'policyVersion': runtimeObservabilityIntegrationPlannerPolicyVersion,
        'id': id,
        'healthProjectionId': healthProjectionId,
        'healthProjectionDigest': healthProjectionDigest,
        'featureAssemblyPlanId': featureAssemblyPlanId,
        'featureAssemblyPlanDigest': featureAssemblyPlanDigest,
        'entries': entries.map((entry) => entry.toJson()).toList(),
        'log': log.map((entry) => entry.toJson()).toList(),
        'digest': digest,
      };
}

class RuntimeObservabilityIntegrationPlanner {
  const RuntimeObservabilityIntegrationPlanner();

  RuntimeObservabilityIntegrationPlan plan({
    required RuntimeHealthDiagnosticsProjectionContract healthProjection,
    required ProductFeatureAssemblyPlan featureAssemblyPlan,
  }) {
    _validateInputs(
      healthProjection: healthProjection,
      featureAssemblyPlan: featureAssemblyPlan,
    );
    final entries = [
      for (final feature in featureAssemblyPlan.entries)
        RuntimeObservabilityIntegrationEntry.create(
          assemblyEntryId: feature.assemblyEntryId,
          featureId: feature.featureId,
          position: feature.position,
          featureAssemblyPlanDigest: featureAssemblyPlan.digest,
          healthProjectionDigest: healthProjection.digest,
        ),
    ]..sort((left, right) => left.position.compareTo(right.position));
    final integrationSetDigest =
        _digest(entries.map((entry) => entry.toJson()).toList());
    return RuntimeObservabilityIntegrationPlan.create(
      healthProjection: healthProjection,
      featureAssemblyPlan: featureAssemblyPlan,
      entries: entries,
      log: [
        for (var position = 0;
            position < RuntimeObservabilityIntegrationLogPhase.values.length;
            position++)
          RuntimeObservabilityIntegrationLogEntry.create(
            phase: RuntimeObservabilityIntegrationLogPhase.values[position],
            position: position,
            featureAssemblyPlanDigest: featureAssemblyPlan.digest,
            healthProjectionDigest: healthProjection.digest,
            integrationSetDigest: integrationSetDigest,
          ),
      ],
    );
  }
}

void _validateInputs({
  required RuntimeHealthDiagnosticsProjectionContract healthProjection,
  required ProductFeatureAssemblyPlan featureAssemblyPlan,
}) {
  if (healthProjection.entries.isEmpty || featureAssemblyPlan.entries.isEmpty) {
    throw ArgumentError(
        'Runtime observability integration inputs are incomplete.');
  }
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
