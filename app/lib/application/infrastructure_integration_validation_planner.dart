import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/application/packaging_deployment_adapter_planner.dart';
import 'package:pool_os/contracts/production_readiness_validation_contracts.dart';

const infrastructureIntegrationValidationPlannerVersion = 1;
const infrastructureIntegrationValidationPlannerPolicyVersion =
    'infrastructure-integration-validation-planner/1.0.0';

enum InfrastructureIntegrationValidationLogPhase {
  validateInputs,
  orderFeatures,
  bindReadinessProvenance,
  completed,
}

class InfrastructureIntegrationValidationEntry {
  const InfrastructureIntegrationValidationEntry._({
    required this.infrastructureIntegrationValidationEntryId,
    required this.featureId,
    required this.packagingDeploymentAdapterEntryId,
    required this.position,
    required this.packagingDeploymentAdapterPlanDigest,
    required this.productionReadinessProjectionDigest,
    required this.provenanceDigest,
    required this.digest,
  });

  factory InfrastructureIntegrationValidationEntry.create({
    required String featureId,
    required String packagingDeploymentAdapterEntryId,
    required int position,
    required String packagingDeploymentAdapterPlanDigest,
    required String productionReadinessProjectionDigest,
  }) {
    if (featureId.isEmpty ||
        packagingDeploymentAdapterEntryId.isEmpty ||
        position < 0 ||
        packagingDeploymentAdapterPlanDigest.isEmpty ||
        productionReadinessProjectionDigest.isEmpty) {
      throw ArgumentError('Infrastructure validation entry is incomplete.');
    }
    final infrastructureIntegrationValidationEntryId =
        'infrastructure-integration-validation.$featureId';
    final provenanceDigest = _digest({
      'packagingDeploymentAdapterPlanDigest':
          packagingDeploymentAdapterPlanDigest,
      'productionReadinessProjectionDigest':
          productionReadinessProjectionDigest,
    });
    final payload = {
      'infrastructureIntegrationValidationEntryId':
          infrastructureIntegrationValidationEntryId,
      'featureId': featureId,
      'packagingDeploymentAdapterEntryId': packagingDeploymentAdapterEntryId,
      'position': position,
      'packagingDeploymentAdapterPlanDigest':
          packagingDeploymentAdapterPlanDigest,
      'productionReadinessProjectionDigest':
          productionReadinessProjectionDigest,
      'provenanceDigest': provenanceDigest,
    };
    return InfrastructureIntegrationValidationEntry._(
      infrastructureIntegrationValidationEntryId:
          infrastructureIntegrationValidationEntryId,
      featureId: featureId,
      packagingDeploymentAdapterEntryId: packagingDeploymentAdapterEntryId,
      position: position,
      packagingDeploymentAdapterPlanDigest:
          packagingDeploymentAdapterPlanDigest,
      productionReadinessProjectionDigest: productionReadinessProjectionDigest,
      provenanceDigest: provenanceDigest,
      digest: _digest(payload),
    );
  }

  final String infrastructureIntegrationValidationEntryId;
  final String featureId;
  final String packagingDeploymentAdapterEntryId;
  final int position;
  final String packagingDeploymentAdapterPlanDigest;
  final String productionReadinessProjectionDigest;
  final String provenanceDigest;
  final String digest;

  Map<String, dynamic> toJson() => {
        'infrastructureIntegrationValidationEntryId':
            infrastructureIntegrationValidationEntryId,
        'featureId': featureId,
        'packagingDeploymentAdapterEntryId': packagingDeploymentAdapterEntryId,
        'position': position,
        'packagingDeploymentAdapterPlanDigest':
            packagingDeploymentAdapterPlanDigest,
        'productionReadinessProjectionDigest':
            productionReadinessProjectionDigest,
        'provenanceDigest': provenanceDigest,
        'digest': digest,
      };
}

class InfrastructureIntegrationValidationLogEntry {
  const InfrastructureIntegrationValidationLogEntry._({
    required this.phase,
    required this.position,
    required this.packagingDeploymentAdapterPlanDigest,
    required this.productionReadinessProjectionDigest,
    required this.infrastructureIntegrationValidationSetDigest,
    required this.eventCode,
    required this.digest,
  });

  factory InfrastructureIntegrationValidationLogEntry.create({
    required InfrastructureIntegrationValidationLogPhase phase,
    required int position,
    required String packagingDeploymentAdapterPlanDigest,
    required String productionReadinessProjectionDigest,
    required String infrastructureIntegrationValidationSetDigest,
  }) {
    if (position < 0 ||
        packagingDeploymentAdapterPlanDigest.isEmpty ||
        productionReadinessProjectionDigest.isEmpty ||
        infrastructureIntegrationValidationSetDigest.isEmpty) {
      throw ArgumentError('Infrastructure validation log is incomplete.');
    }
    final eventCode = 'infrastructure-integration-validation.${phase.name}';
    final payload = {
      'phase': phase.name,
      'position': position,
      'packagingDeploymentAdapterPlanDigest':
          packagingDeploymentAdapterPlanDigest,
      'productionReadinessProjectionDigest':
          productionReadinessProjectionDigest,
      'infrastructureIntegrationValidationSetDigest':
          infrastructureIntegrationValidationSetDigest,
      'eventCode': eventCode,
    };
    return InfrastructureIntegrationValidationLogEntry._(
      phase: phase,
      position: position,
      packagingDeploymentAdapterPlanDigest:
          packagingDeploymentAdapterPlanDigest,
      productionReadinessProjectionDigest: productionReadinessProjectionDigest,
      infrastructureIntegrationValidationSetDigest:
          infrastructureIntegrationValidationSetDigest,
      eventCode: eventCode,
      digest: _digest(payload),
    );
  }

  final InfrastructureIntegrationValidationLogPhase phase;
  final int position;
  final String packagingDeploymentAdapterPlanDigest;
  final String productionReadinessProjectionDigest;
  final String infrastructureIntegrationValidationSetDigest;
  final String eventCode;
  final String digest;

  Map<String, dynamic> toJson() => {
        'phase': phase.name,
        'position': position,
        'packagingDeploymentAdapterPlanDigest':
            packagingDeploymentAdapterPlanDigest,
        'productionReadinessProjectionDigest':
            productionReadinessProjectionDigest,
        'infrastructureIntegrationValidationSetDigest':
            infrastructureIntegrationValidationSetDigest,
        'eventCode': eventCode,
        'digest': digest,
      };
}

class InfrastructureIntegrationValidationPlan {
  const InfrastructureIntegrationValidationPlan._({
    required this.id,
    required this.packagingDeploymentAdapterPlanId,
    required this.packagingDeploymentAdapterPlanDigest,
    required this.productionReadinessProjectionId,
    required this.productionReadinessProjectionDigest,
    required this.entries,
    required this.log,
    required this.digest,
  });

  factory InfrastructureIntegrationValidationPlan.create({
    required PackagingDeploymentAdapterPlan packagingDeploymentAdapterPlan,
    required ProductionReadinessProjectionContract
        productionReadinessProjection,
    required List<InfrastructureIntegrationValidationEntry> entries,
    required List<InfrastructureIntegrationValidationLogEntry> log,
  }) {
    _validateInputs(
      packagingDeploymentAdapterPlan: packagingDeploymentAdapterPlan,
      productionReadinessProjection: productionReadinessProjection,
    );
    if (entries.length != packagingDeploymentAdapterPlan.entries.length) {
      throw ArgumentError('Infrastructure validation coverage is incomplete.');
    }
    final adapterByFeature = {
      for (final entry in packagingDeploymentAdapterPlan.entries)
        entry.featureId: entry,
    };
    final ordered = [...entries]
      ..sort((left, right) => left.position.compareTo(right.position));
    final infrastructureIntegrationValidationIds = <String>{};
    final featureIds = <String>{};
    final sourceAdapterIds = <String>{};
    final positions = <int>{};
    for (var position = 0; position < ordered.length; position++) {
      final entry = ordered[position];
      final adapterEntry = adapterByFeature[entry.featureId];
      final expected = InfrastructureIntegrationValidationEntry.create(
        featureId: entry.featureId,
        packagingDeploymentAdapterEntryId:
            entry.packagingDeploymentAdapterEntryId,
        position: position,
        packagingDeploymentAdapterPlanDigest:
            packagingDeploymentAdapterPlan.digest,
        productionReadinessProjectionDigest:
            productionReadinessProjection.digest,
      );
      if (adapterEntry == null ||
          adapterEntry.position != position ||
          entry.position != position ||
          entry.packagingDeploymentAdapterEntryId !=
              adapterEntry.packagingDeploymentAdapterEntryId ||
          entry.packagingDeploymentAdapterPlanDigest !=
              packagingDeploymentAdapterPlan.digest ||
          entry.productionReadinessProjectionDigest !=
              productionReadinessProjection.digest ||
          entry.infrastructureIntegrationValidationEntryId !=
              expected.infrastructureIntegrationValidationEntryId ||
          entry.provenanceDigest != expected.provenanceDigest ||
          entry.digest != expected.digest ||
          !infrastructureIntegrationValidationIds
              .add(entry.infrastructureIntegrationValidationEntryId) ||
          !featureIds.add(entry.featureId) ||
          !sourceAdapterIds.add(entry.packagingDeploymentAdapterEntryId) ||
          !positions.add(entry.position)) {
        throw ArgumentError('Infrastructure validation provenance is invalid.');
      }
    }

    final infrastructureIntegrationValidationSetDigest =
        _digest(ordered.map((entry) => entry.toJson()).toList());
    final orderedLog = [...log]
      ..sort((left, right) => left.position.compareTo(right.position));
    if (orderedLog.length !=
        InfrastructureIntegrationValidationLogPhase.values.length) {
      throw ArgumentError('Infrastructure validation log is incomplete.');
    }
    for (var position = 0; position < orderedLog.length; position++) {
      final entry = orderedLog[position];
      final expected = InfrastructureIntegrationValidationLogEntry.create(
        phase: InfrastructureIntegrationValidationLogPhase.values[position],
        position: position,
        packagingDeploymentAdapterPlanDigest:
            packagingDeploymentAdapterPlan.digest,
        productionReadinessProjectionDigest:
            productionReadinessProjection.digest,
        infrastructureIntegrationValidationSetDigest:
            infrastructureIntegrationValidationSetDigest,
      );
      if (entry.phase != expected.phase ||
          entry.position != expected.position ||
          entry.packagingDeploymentAdapterPlanDigest !=
              expected.packagingDeploymentAdapterPlanDigest ||
          entry.productionReadinessProjectionDigest !=
              expected.productionReadinessProjectionDigest ||
          entry.infrastructureIntegrationValidationSetDigest !=
              expected.infrastructureIntegrationValidationSetDigest ||
          entry.eventCode != expected.eventCode ||
          entry.digest != expected.digest) {
        throw ArgumentError('Infrastructure validation log is invalid.');
      }
    }

    final payload = {
      'plannerVersion': infrastructureIntegrationValidationPlannerVersion,
      'policyVersion': infrastructureIntegrationValidationPlannerPolicyVersion,
      'packagingDeploymentAdapterPlanId': packagingDeploymentAdapterPlan.id,
      'packagingDeploymentAdapterPlanDigest':
          packagingDeploymentAdapterPlan.digest,
      'productionReadinessProjectionId': productionReadinessProjection.id,
      'productionReadinessProjectionDigest':
          productionReadinessProjection.digest,
      'entries': ordered.map((entry) => entry.toJson()).toList(),
      'log': orderedLog.map((entry) => entry.toJson()).toList(),
    };
    final digest = _digest(payload);
    return InfrastructureIntegrationValidationPlan._(
      id: 'infrastructure-integration-validation-plan.${digest.substring(0, 16)}',
      packagingDeploymentAdapterPlanId: packagingDeploymentAdapterPlan.id,
      packagingDeploymentAdapterPlanDigest:
          packagingDeploymentAdapterPlan.digest,
      productionReadinessProjectionId: productionReadinessProjection.id,
      productionReadinessProjectionDigest: productionReadinessProjection.digest,
      entries: List.unmodifiable(ordered),
      log: List.unmodifiable(orderedLog),
      digest: digest,
    );
  }

  final String id;
  final String packagingDeploymentAdapterPlanId;
  final String packagingDeploymentAdapterPlanDigest;
  final String productionReadinessProjectionId;
  final String productionReadinessProjectionDigest;
  final List<InfrastructureIntegrationValidationEntry> entries;
  final List<InfrastructureIntegrationValidationLogEntry> log;
  final String digest;

  Map<String, dynamic> toJson() => {
        'plannerVersion': infrastructureIntegrationValidationPlannerVersion,
        'policyVersion':
            infrastructureIntegrationValidationPlannerPolicyVersion,
        'id': id,
        'packagingDeploymentAdapterPlanId': packagingDeploymentAdapterPlanId,
        'packagingDeploymentAdapterPlanDigest':
            packagingDeploymentAdapterPlanDigest,
        'productionReadinessProjectionId': productionReadinessProjectionId,
        'productionReadinessProjectionDigest':
            productionReadinessProjectionDigest,
        'entries': entries.map((entry) => entry.toJson()).toList(),
        'log': log.map((entry) => entry.toJson()).toList(),
        'digest': digest,
      };
}

class InfrastructureIntegrationValidationPlanner {
  const InfrastructureIntegrationValidationPlanner();

  InfrastructureIntegrationValidationPlan plan({
    required PackagingDeploymentAdapterPlan packagingDeploymentAdapterPlan,
    required ProductionReadinessProjectionContract
        productionReadinessProjection,
  }) {
    _validateInputs(
      packagingDeploymentAdapterPlan: packagingDeploymentAdapterPlan,
      productionReadinessProjection: productionReadinessProjection,
    );
    final entries = [
      for (final adapterEntry in packagingDeploymentAdapterPlan.entries)
        InfrastructureIntegrationValidationEntry.create(
          featureId: adapterEntry.featureId,
          packagingDeploymentAdapterEntryId:
              adapterEntry.packagingDeploymentAdapterEntryId,
          position: adapterEntry.position,
          packagingDeploymentAdapterPlanDigest:
              packagingDeploymentAdapterPlan.digest,
          productionReadinessProjectionDigest:
              productionReadinessProjection.digest,
        ),
    ]..sort((left, right) => left.position.compareTo(right.position));
    final infrastructureIntegrationValidationSetDigest =
        _digest(entries.map((entry) => entry.toJson()).toList());
    return InfrastructureIntegrationValidationPlan.create(
      packagingDeploymentAdapterPlan: packagingDeploymentAdapterPlan,
      productionReadinessProjection: productionReadinessProjection,
      entries: entries,
      log: [
        for (var position = 0;
            position <
                InfrastructureIntegrationValidationLogPhase.values.length;
            position++)
          InfrastructureIntegrationValidationLogEntry.create(
            phase: InfrastructureIntegrationValidationLogPhase.values[position],
            position: position,
            packagingDeploymentAdapterPlanDigest:
                packagingDeploymentAdapterPlan.digest,
            productionReadinessProjectionDigest:
                productionReadinessProjection.digest,
            infrastructureIntegrationValidationSetDigest:
                infrastructureIntegrationValidationSetDigest,
          ),
      ],
    );
  }
}

void _validateInputs({
  required PackagingDeploymentAdapterPlan packagingDeploymentAdapterPlan,
  required ProductionReadinessProjectionContract productionReadinessProjection,
}) {
  if (packagingDeploymentAdapterPlan.id.isEmpty ||
      packagingDeploymentAdapterPlan.digest.isEmpty ||
      packagingDeploymentAdapterPlan.entries.isEmpty ||
      productionReadinessProjection.id.isEmpty ||
      productionReadinessProjection.digest.isEmpty ||
      productionReadinessProjection.entries.isEmpty) {
    throw ArgumentError('Infrastructure validation inputs are incomplete.');
  }
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
