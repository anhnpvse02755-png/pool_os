import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/application/observability_adapter_planner.dart';
import 'package:pool_os/contracts/runtime_activation_delivery_gate_contracts.dart';

const packagingDeploymentAdapterPlannerVersion = 1;
const packagingDeploymentAdapterPlannerPolicyVersion =
    'packaging-deployment-adapter-planner/1.0.0';

enum PackagingDeploymentAdapterLogPhase {
  validateInputs,
  orderFeatures,
  bindDeploymentGateProvenance,
  completed,
}

class PackagingDeploymentAdapterEntry {
  const PackagingDeploymentAdapterEntry._({
    required this.packagingDeploymentAdapterEntryId,
    required this.featureId,
    required this.observabilityAdapterEntryId,
    required this.position,
    required this.observabilityAdapterPlanDigest,
    required this.runtimeActivationDeliveryGateDigest,
    required this.provenanceDigest,
    required this.digest,
  });

  factory PackagingDeploymentAdapterEntry.create({
    required String featureId,
    required String observabilityAdapterEntryId,
    required int position,
    required String observabilityAdapterPlanDigest,
    required String runtimeActivationDeliveryGateDigest,
  }) {
    if (featureId.isEmpty ||
        observabilityAdapterEntryId.isEmpty ||
        position < 0 ||
        observabilityAdapterPlanDigest.isEmpty ||
        runtimeActivationDeliveryGateDigest.isEmpty) {
      throw ArgumentError('Packaging deployment adapter entry is incomplete.');
    }
    final packagingDeploymentAdapterEntryId =
        'packaging-deployment-adapter.$featureId';
    final provenanceDigest = _digest({
      'observabilityAdapterPlanDigest': observabilityAdapterPlanDigest,
      'runtimeActivationDeliveryGateDigest':
          runtimeActivationDeliveryGateDigest,
    });
    final payload = {
      'packagingDeploymentAdapterEntryId': packagingDeploymentAdapterEntryId,
      'featureId': featureId,
      'observabilityAdapterEntryId': observabilityAdapterEntryId,
      'position': position,
      'observabilityAdapterPlanDigest': observabilityAdapterPlanDigest,
      'runtimeActivationDeliveryGateDigest':
          runtimeActivationDeliveryGateDigest,
      'provenanceDigest': provenanceDigest,
    };
    return PackagingDeploymentAdapterEntry._(
      packagingDeploymentAdapterEntryId: packagingDeploymentAdapterEntryId,
      featureId: featureId,
      observabilityAdapterEntryId: observabilityAdapterEntryId,
      position: position,
      observabilityAdapterPlanDigest: observabilityAdapterPlanDigest,
      runtimeActivationDeliveryGateDigest: runtimeActivationDeliveryGateDigest,
      provenanceDigest: provenanceDigest,
      digest: _digest(payload),
    );
  }

  final String packagingDeploymentAdapterEntryId;
  final String featureId;
  final String observabilityAdapterEntryId;
  final int position;
  final String observabilityAdapterPlanDigest;
  final String runtimeActivationDeliveryGateDigest;
  final String provenanceDigest;
  final String digest;

  Map<String, dynamic> toJson() => {
        'packagingDeploymentAdapterEntryId': packagingDeploymentAdapterEntryId,
        'featureId': featureId,
        'observabilityAdapterEntryId': observabilityAdapterEntryId,
        'position': position,
        'observabilityAdapterPlanDigest': observabilityAdapterPlanDigest,
        'runtimeActivationDeliveryGateDigest':
            runtimeActivationDeliveryGateDigest,
        'provenanceDigest': provenanceDigest,
        'digest': digest,
      };
}

class PackagingDeploymentAdapterLogEntry {
  const PackagingDeploymentAdapterLogEntry._({
    required this.phase,
    required this.position,
    required this.observabilityAdapterPlanDigest,
    required this.runtimeActivationDeliveryGateDigest,
    required this.packagingDeploymentAdapterSetDigest,
    required this.eventCode,
    required this.digest,
  });

  factory PackagingDeploymentAdapterLogEntry.create({
    required PackagingDeploymentAdapterLogPhase phase,
    required int position,
    required String observabilityAdapterPlanDigest,
    required String runtimeActivationDeliveryGateDigest,
    required String packagingDeploymentAdapterSetDigest,
  }) {
    if (position < 0 ||
        observabilityAdapterPlanDigest.isEmpty ||
        runtimeActivationDeliveryGateDigest.isEmpty ||
        packagingDeploymentAdapterSetDigest.isEmpty) {
      throw ArgumentError('Packaging deployment adapter log is incomplete.');
    }
    final eventCode = 'packaging-deployment-adapter.${phase.name}';
    final payload = {
      'phase': phase.name,
      'position': position,
      'observabilityAdapterPlanDigest': observabilityAdapterPlanDigest,
      'runtimeActivationDeliveryGateDigest':
          runtimeActivationDeliveryGateDigest,
      'packagingDeploymentAdapterSetDigest':
          packagingDeploymentAdapterSetDigest,
      'eventCode': eventCode,
    };
    return PackagingDeploymentAdapterLogEntry._(
      phase: phase,
      position: position,
      observabilityAdapterPlanDigest: observabilityAdapterPlanDigest,
      runtimeActivationDeliveryGateDigest: runtimeActivationDeliveryGateDigest,
      packagingDeploymentAdapterSetDigest: packagingDeploymentAdapterSetDigest,
      eventCode: eventCode,
      digest: _digest(payload),
    );
  }

  final PackagingDeploymentAdapterLogPhase phase;
  final int position;
  final String observabilityAdapterPlanDigest;
  final String runtimeActivationDeliveryGateDigest;
  final String packagingDeploymentAdapterSetDigest;
  final String eventCode;
  final String digest;

  Map<String, dynamic> toJson() => {
        'phase': phase.name,
        'position': position,
        'observabilityAdapterPlanDigest': observabilityAdapterPlanDigest,
        'runtimeActivationDeliveryGateDigest':
            runtimeActivationDeliveryGateDigest,
        'packagingDeploymentAdapterSetDigest':
            packagingDeploymentAdapterSetDigest,
        'eventCode': eventCode,
        'digest': digest,
      };
}

class PackagingDeploymentAdapterPlan {
  const PackagingDeploymentAdapterPlan._({
    required this.id,
    required this.observabilityAdapterPlanId,
    required this.observabilityAdapterPlanDigest,
    required this.runtimeActivationDeliveryGateId,
    required this.runtimeActivationDeliveryGateDigest,
    required this.entries,
    required this.log,
    required this.digest,
  });

  factory PackagingDeploymentAdapterPlan.create({
    required ObservabilityAdapterPlan observabilityAdapterPlan,
    required RuntimeActivationDeliveryGateContract
        runtimeActivationDeliveryGate,
    required List<PackagingDeploymentAdapterEntry> entries,
    required List<PackagingDeploymentAdapterLogEntry> log,
  }) {
    _validateInputs(
      observabilityAdapterPlan: observabilityAdapterPlan,
      runtimeActivationDeliveryGate: runtimeActivationDeliveryGate,
    );
    if (entries.length != observabilityAdapterPlan.entries.length) {
      throw ArgumentError(
          'Packaging deployment adapter coverage is incomplete.');
    }
    final adapterByFeature = {
      for (final entry in observabilityAdapterPlan.entries)
        entry.featureId: entry,
    };
    final ordered = [...entries]
      ..sort((left, right) => left.position.compareTo(right.position));
    final packagingDeploymentAdapterIds = <String>{};
    final featureIds = <String>{};
    final sourceAdapterIds = <String>{};
    final positions = <int>{};
    for (var position = 0; position < ordered.length; position++) {
      final entry = ordered[position];
      final adapterEntry = adapterByFeature[entry.featureId];
      final expected = PackagingDeploymentAdapterEntry.create(
        featureId: entry.featureId,
        observabilityAdapterEntryId: entry.observabilityAdapterEntryId,
        position: position,
        observabilityAdapterPlanDigest: observabilityAdapterPlan.digest,
        runtimeActivationDeliveryGateDigest:
            runtimeActivationDeliveryGate.digest,
      );
      if (adapterEntry == null ||
          adapterEntry.position != position ||
          entry.position != position ||
          entry.observabilityAdapterEntryId !=
              adapterEntry.observabilityAdapterEntryId ||
          entry.observabilityAdapterPlanDigest !=
              observabilityAdapterPlan.digest ||
          entry.runtimeActivationDeliveryGateDigest !=
              runtimeActivationDeliveryGate.digest ||
          entry.packagingDeploymentAdapterEntryId !=
              expected.packagingDeploymentAdapterEntryId ||
          entry.provenanceDigest != expected.provenanceDigest ||
          entry.digest != expected.digest ||
          !packagingDeploymentAdapterIds
              .add(entry.packagingDeploymentAdapterEntryId) ||
          !featureIds.add(entry.featureId) ||
          !sourceAdapterIds.add(entry.observabilityAdapterEntryId) ||
          !positions.add(entry.position)) {
        throw ArgumentError(
            'Packaging deployment adapter provenance is invalid.');
      }
    }

    final packagingDeploymentAdapterSetDigest =
        _digest(ordered.map((entry) => entry.toJson()).toList());
    final orderedLog = [...log]
      ..sort((left, right) => left.position.compareTo(right.position));
    if (orderedLog.length != PackagingDeploymentAdapterLogPhase.values.length) {
      throw ArgumentError('Packaging deployment adapter log is incomplete.');
    }
    for (var position = 0; position < orderedLog.length; position++) {
      final entry = orderedLog[position];
      final expected = PackagingDeploymentAdapterLogEntry.create(
        phase: PackagingDeploymentAdapterLogPhase.values[position],
        position: position,
        observabilityAdapterPlanDigest: observabilityAdapterPlan.digest,
        runtimeActivationDeliveryGateDigest:
            runtimeActivationDeliveryGate.digest,
        packagingDeploymentAdapterSetDigest:
            packagingDeploymentAdapterSetDigest,
      );
      if (entry.phase != expected.phase ||
          entry.position != expected.position ||
          entry.observabilityAdapterPlanDigest !=
              expected.observabilityAdapterPlanDigest ||
          entry.runtimeActivationDeliveryGateDigest !=
              expected.runtimeActivationDeliveryGateDigest ||
          entry.packagingDeploymentAdapterSetDigest !=
              expected.packagingDeploymentAdapterSetDigest ||
          entry.eventCode != expected.eventCode ||
          entry.digest != expected.digest) {
        throw ArgumentError('Packaging deployment adapter log is invalid.');
      }
    }

    final payload = {
      'plannerVersion': packagingDeploymentAdapterPlannerVersion,
      'policyVersion': packagingDeploymentAdapterPlannerPolicyVersion,
      'observabilityAdapterPlanId': observabilityAdapterPlan.id,
      'observabilityAdapterPlanDigest': observabilityAdapterPlan.digest,
      'runtimeActivationDeliveryGateId': runtimeActivationDeliveryGate.id,
      'runtimeActivationDeliveryGateDigest':
          runtimeActivationDeliveryGate.digest,
      'entries': ordered.map((entry) => entry.toJson()).toList(),
      'log': orderedLog.map((entry) => entry.toJson()).toList(),
    };
    final digest = _digest(payload);
    return PackagingDeploymentAdapterPlan._(
      id: 'packaging-deployment-adapter-plan.${digest.substring(0, 16)}',
      observabilityAdapterPlanId: observabilityAdapterPlan.id,
      observabilityAdapterPlanDigest: observabilityAdapterPlan.digest,
      runtimeActivationDeliveryGateId: runtimeActivationDeliveryGate.id,
      runtimeActivationDeliveryGateDigest: runtimeActivationDeliveryGate.digest,
      entries: List.unmodifiable(ordered),
      log: List.unmodifiable(orderedLog),
      digest: digest,
    );
  }

  final String id;
  final String observabilityAdapterPlanId;
  final String observabilityAdapterPlanDigest;
  final String runtimeActivationDeliveryGateId;
  final String runtimeActivationDeliveryGateDigest;
  final List<PackagingDeploymentAdapterEntry> entries;
  final List<PackagingDeploymentAdapterLogEntry> log;
  final String digest;

  Map<String, dynamic> toJson() => {
        'plannerVersion': packagingDeploymentAdapterPlannerVersion,
        'policyVersion': packagingDeploymentAdapterPlannerPolicyVersion,
        'id': id,
        'observabilityAdapterPlanId': observabilityAdapterPlanId,
        'observabilityAdapterPlanDigest': observabilityAdapterPlanDigest,
        'runtimeActivationDeliveryGateId': runtimeActivationDeliveryGateId,
        'runtimeActivationDeliveryGateDigest':
            runtimeActivationDeliveryGateDigest,
        'entries': entries.map((entry) => entry.toJson()).toList(),
        'log': log.map((entry) => entry.toJson()).toList(),
        'digest': digest,
      };
}

class PackagingDeploymentAdapterPlanner {
  const PackagingDeploymentAdapterPlanner();

  PackagingDeploymentAdapterPlan plan({
    required ObservabilityAdapterPlan observabilityAdapterPlan,
    required RuntimeActivationDeliveryGateContract
        runtimeActivationDeliveryGate,
  }) {
    _validateInputs(
      observabilityAdapterPlan: observabilityAdapterPlan,
      runtimeActivationDeliveryGate: runtimeActivationDeliveryGate,
    );
    final entries = [
      for (final adapterEntry in observabilityAdapterPlan.entries)
        PackagingDeploymentAdapterEntry.create(
          featureId: adapterEntry.featureId,
          observabilityAdapterEntryId: adapterEntry.observabilityAdapterEntryId,
          position: adapterEntry.position,
          observabilityAdapterPlanDigest: observabilityAdapterPlan.digest,
          runtimeActivationDeliveryGateDigest:
              runtimeActivationDeliveryGate.digest,
        ),
    ]..sort((left, right) => left.position.compareTo(right.position));
    final packagingDeploymentAdapterSetDigest =
        _digest(entries.map((entry) => entry.toJson()).toList());
    return PackagingDeploymentAdapterPlan.create(
      observabilityAdapterPlan: observabilityAdapterPlan,
      runtimeActivationDeliveryGate: runtimeActivationDeliveryGate,
      entries: entries,
      log: [
        for (var position = 0;
            position < PackagingDeploymentAdapterLogPhase.values.length;
            position++)
          PackagingDeploymentAdapterLogEntry.create(
            phase: PackagingDeploymentAdapterLogPhase.values[position],
            position: position,
            observabilityAdapterPlanDigest: observabilityAdapterPlan.digest,
            runtimeActivationDeliveryGateDigest:
                runtimeActivationDeliveryGate.digest,
            packagingDeploymentAdapterSetDigest:
                packagingDeploymentAdapterSetDigest,
          ),
      ],
    );
  }
}

void _validateInputs({
  required ObservabilityAdapterPlan observabilityAdapterPlan,
  required RuntimeActivationDeliveryGateContract runtimeActivationDeliveryGate,
}) {
  if (observabilityAdapterPlan.id.isEmpty ||
      observabilityAdapterPlan.digest.isEmpty ||
      observabilityAdapterPlan.entries.isEmpty ||
      runtimeActivationDeliveryGate.id.isEmpty ||
      runtimeActivationDeliveryGate.digest.isEmpty ||
      runtimeActivationDeliveryGate.entries.isEmpty) {
    throw ArgumentError('Packaging deployment adapter inputs are incomplete.');
  }
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
