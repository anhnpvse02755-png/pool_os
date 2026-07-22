import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/application/application_bootstrap_host.dart';
import 'package:pool_os/contracts/runtime_activation_delivery_gate_contracts.dart';

const productionStartupValidationPlannerVersion = 1;
const productionStartupValidationPlannerPolicyVersion =
    'production-startup-validation-planner/1.0.0';

enum ProductionStartupGateEligibility { eligible, blocked }

enum ProductionStartupValidationLogPhase {
  validateInputs,
  orderLifecycle,
  bindAggregateGate,
  completed,
}

class ProductionStartupValidationEntry {
  const ProductionStartupValidationEntry._({
    required this.validationEntryId,
    required this.lifecyclePhase,
    required this.lifecycleEventCode,
    required this.position,
    required this.lifecycleEntryDigest,
    required this.bootstrapHostRunDigest,
    required this.activationDeliveryGateDigest,
    required this.gateEligibility,
    required this.digest,
  });

  factory ProductionStartupValidationEntry.create({
    required String lifecyclePhase,
    required String lifecycleEventCode,
    required int position,
    required String lifecycleEntryDigest,
    required String bootstrapHostRunDigest,
    required String activationDeliveryGateDigest,
    required ProductionStartupGateEligibility gateEligibility,
  }) {
    if (lifecyclePhase.isEmpty ||
        lifecycleEventCode.isEmpty ||
        position < 0 ||
        lifecycleEntryDigest.isEmpty ||
        bootstrapHostRunDigest.isEmpty ||
        activationDeliveryGateDigest.isEmpty) {
      throw ArgumentError('Production startup validation entry is incomplete.');
    }
    final validationEntryId = 'production-startup-validation.$lifecyclePhase';
    final payload = {
      'validationEntryId': validationEntryId,
      'lifecyclePhase': lifecyclePhase,
      'lifecycleEventCode': lifecycleEventCode,
      'position': position,
      'lifecycleEntryDigest': lifecycleEntryDigest,
      'bootstrapHostRunDigest': bootstrapHostRunDigest,
      'activationDeliveryGateDigest': activationDeliveryGateDigest,
      'gateEligibility': gateEligibility.name,
    };
    return ProductionStartupValidationEntry._(
      validationEntryId: validationEntryId,
      lifecyclePhase: lifecyclePhase,
      lifecycleEventCode: lifecycleEventCode,
      position: position,
      lifecycleEntryDigest: lifecycleEntryDigest,
      bootstrapHostRunDigest: bootstrapHostRunDigest,
      activationDeliveryGateDigest: activationDeliveryGateDigest,
      gateEligibility: gateEligibility,
      digest: _digest(payload),
    );
  }

  final String validationEntryId;
  final String lifecyclePhase;
  final String lifecycleEventCode;
  final int position;
  final String lifecycleEntryDigest;
  final String bootstrapHostRunDigest;
  final String activationDeliveryGateDigest;
  final ProductionStartupGateEligibility gateEligibility;
  final String digest;

  Map<String, dynamic> toJson() => {
        'validationEntryId': validationEntryId,
        'lifecyclePhase': lifecyclePhase,
        'lifecycleEventCode': lifecycleEventCode,
        'position': position,
        'lifecycleEntryDigest': lifecycleEntryDigest,
        'bootstrapHostRunDigest': bootstrapHostRunDigest,
        'activationDeliveryGateDigest': activationDeliveryGateDigest,
        'gateEligibility': gateEligibility.name,
        'digest': digest,
      };
}

class ProductionStartupValidationLogEntry {
  const ProductionStartupValidationLogEntry._({
    required this.phase,
    required this.position,
    required this.bootstrapHostRunDigest,
    required this.activationDeliveryGateDigest,
    required this.validationSetDigest,
    required this.eventCode,
    required this.digest,
  });

  factory ProductionStartupValidationLogEntry.create({
    required ProductionStartupValidationLogPhase phase,
    required int position,
    required String bootstrapHostRunDigest,
    required String activationDeliveryGateDigest,
    required String validationSetDigest,
  }) {
    if (position < 0 ||
        bootstrapHostRunDigest.isEmpty ||
        activationDeliveryGateDigest.isEmpty ||
        validationSetDigest.isEmpty) {
      throw ArgumentError('Production startup validation log is incomplete.');
    }
    final eventCode = 'production-startup-validation.${phase.name}';
    final payload = {
      'phase': phase.name,
      'position': position,
      'bootstrapHostRunDigest': bootstrapHostRunDigest,
      'activationDeliveryGateDigest': activationDeliveryGateDigest,
      'validationSetDigest': validationSetDigest,
      'eventCode': eventCode,
    };
    return ProductionStartupValidationLogEntry._(
      phase: phase,
      position: position,
      bootstrapHostRunDigest: bootstrapHostRunDigest,
      activationDeliveryGateDigest: activationDeliveryGateDigest,
      validationSetDigest: validationSetDigest,
      eventCode: eventCode,
      digest: _digest(payload),
    );
  }

  final ProductionStartupValidationLogPhase phase;
  final int position;
  final String bootstrapHostRunDigest;
  final String activationDeliveryGateDigest;
  final String validationSetDigest;
  final String eventCode;
  final String digest;

  Map<String, dynamic> toJson() => {
        'phase': phase.name,
        'position': position,
        'bootstrapHostRunDigest': bootstrapHostRunDigest,
        'activationDeliveryGateDigest': activationDeliveryGateDigest,
        'validationSetDigest': validationSetDigest,
        'eventCode': eventCode,
        'digest': digest,
      };
}

class ProductionStartupValidationPlan {
  const ProductionStartupValidationPlan._({
    required this.id,
    required this.bootstrapHostRunId,
    required this.bootstrapHostRunDigest,
    required this.activationDeliveryGateId,
    required this.activationDeliveryGateDigest,
    required this.gateEligibility,
    required this.entries,
    required this.log,
    required this.digest,
  });

  factory ProductionStartupValidationPlan.create({
    required ApplicationBootstrapHostRun bootstrapHostRun,
    required RuntimeActivationDeliveryGateContract activationDeliveryGate,
    required List<ProductionStartupValidationEntry> entries,
    required List<ProductionStartupValidationLogEntry> log,
  }) {
    final eligibility = _validateInputs(
      bootstrapHostRun: bootstrapHostRun,
      activationDeliveryGate: activationDeliveryGate,
    );
    if (entries.length != bootstrapHostRun.lifecycle.length) {
      throw ArgumentError(
          'Production startup validation coverage is incomplete.');
    }
    final ordered = [...entries]
      ..sort((left, right) => left.position.compareTo(right.position));
    final validationIds = <String>{};
    final lifecyclePhases = <String>{};
    final positions = <int>{};
    for (var position = 0; position < ordered.length; position++) {
      final entry = ordered[position];
      final lifecycle = bootstrapHostRun.lifecycle[position];
      final expectedLifecycleDigest = _digest({
        'phase': lifecycle.phase.name,
        'position': position,
        'configurationDigest': bootstrapHostRun.configuration.digest,
        'eventCode': 'application-bootstrap.${lifecycle.phase.name}',
      });
      final expected = ProductionStartupValidationEntry.create(
        lifecyclePhase: lifecycle.phase.name,
        lifecycleEventCode: lifecycle.eventCode,
        position: position,
        lifecycleEntryDigest: lifecycle.digest,
        bootstrapHostRunDigest: bootstrapHostRun.digest,
        activationDeliveryGateDigest: activationDeliveryGate.digest,
        gateEligibility: eligibility,
      );
      if (entry.position != position ||
          lifecycle.position != position ||
          entry.lifecyclePhase != lifecycle.phase.name ||
          entry.lifecycleEventCode !=
              'application-bootstrap.${lifecycle.phase.name}' ||
          lifecycle.eventCode != entry.lifecycleEventCode ||
          lifecycle.digest != expectedLifecycleDigest ||
          entry.lifecycleEntryDigest != lifecycle.digest ||
          entry.bootstrapHostRunDigest != bootstrapHostRun.digest ||
          entry.activationDeliveryGateDigest != activationDeliveryGate.digest ||
          entry.gateEligibility != eligibility ||
          entry.validationEntryId != expected.validationEntryId ||
          entry.digest != expected.digest ||
          !validationIds.add(entry.validationEntryId) ||
          !lifecyclePhases.add(entry.lifecyclePhase) ||
          !positions.add(entry.position)) {
        throw ArgumentError(
            'Production startup validation provenance is invalid.');
      }
    }

    final validationSetDigest =
        _digest(ordered.map((entry) => entry.toJson()).toList());
    final orderedLog = [...log]
      ..sort((left, right) => left.position.compareTo(right.position));
    if (orderedLog.length !=
        ProductionStartupValidationLogPhase.values.length) {
      throw ArgumentError('Production startup validation log is incomplete.');
    }
    for (var position = 0; position < orderedLog.length; position++) {
      final entry = orderedLog[position];
      final expected = ProductionStartupValidationLogEntry.create(
        phase: ProductionStartupValidationLogPhase.values[position],
        position: position,
        bootstrapHostRunDigest: bootstrapHostRun.digest,
        activationDeliveryGateDigest: activationDeliveryGate.digest,
        validationSetDigest: validationSetDigest,
      );
      if (entry.phase != expected.phase ||
          entry.position != expected.position ||
          entry.bootstrapHostRunDigest != expected.bootstrapHostRunDigest ||
          entry.activationDeliveryGateDigest !=
              expected.activationDeliveryGateDigest ||
          entry.validationSetDigest != expected.validationSetDigest ||
          entry.eventCode != expected.eventCode ||
          entry.digest != expected.digest) {
        throw ArgumentError('Production startup validation log is invalid.');
      }
    }

    final payload = {
      'plannerVersion': productionStartupValidationPlannerVersion,
      'policyVersion': productionStartupValidationPlannerPolicyVersion,
      'bootstrapHostRunId': bootstrapHostRun.id,
      'bootstrapHostRunDigest': bootstrapHostRun.digest,
      'activationDeliveryGateId': activationDeliveryGate.id,
      'activationDeliveryGateDigest': activationDeliveryGate.digest,
      'gateEligibility': eligibility.name,
      'entries': ordered.map((entry) => entry.toJson()).toList(),
      'log': orderedLog.map((entry) => entry.toJson()).toList(),
    };
    final digest = _digest(payload);
    return ProductionStartupValidationPlan._(
      id: 'production-startup-validation-plan.${digest.substring(0, 16)}',
      bootstrapHostRunId: bootstrapHostRun.id,
      bootstrapHostRunDigest: bootstrapHostRun.digest,
      activationDeliveryGateId: activationDeliveryGate.id,
      activationDeliveryGateDigest: activationDeliveryGate.digest,
      gateEligibility: eligibility,
      entries: List.unmodifiable(ordered),
      log: List.unmodifiable(orderedLog),
      digest: digest,
    );
  }

  final String id;
  final String bootstrapHostRunId;
  final String bootstrapHostRunDigest;
  final String activationDeliveryGateId;
  final String activationDeliveryGateDigest;
  final ProductionStartupGateEligibility gateEligibility;
  final List<ProductionStartupValidationEntry> entries;
  final List<ProductionStartupValidationLogEntry> log;
  final String digest;

  Map<String, dynamic> toJson() => {
        'plannerVersion': productionStartupValidationPlannerVersion,
        'policyVersion': productionStartupValidationPlannerPolicyVersion,
        'id': id,
        'bootstrapHostRunId': bootstrapHostRunId,
        'bootstrapHostRunDigest': bootstrapHostRunDigest,
        'activationDeliveryGateId': activationDeliveryGateId,
        'activationDeliveryGateDigest': activationDeliveryGateDigest,
        'gateEligibility': gateEligibility.name,
        'entries': entries.map((entry) => entry.toJson()).toList(),
        'log': log.map((entry) => entry.toJson()).toList(),
        'digest': digest,
      };
}

class ProductionStartupValidationPlanner {
  const ProductionStartupValidationPlanner();

  ProductionStartupValidationPlan plan({
    required ApplicationBootstrapHostRun bootstrapHostRun,
    required RuntimeActivationDeliveryGateContract activationDeliveryGate,
  }) {
    final eligibility = _validateInputs(
      bootstrapHostRun: bootstrapHostRun,
      activationDeliveryGate: activationDeliveryGate,
    );
    final entries = [
      for (final lifecycle in bootstrapHostRun.lifecycle)
        ProductionStartupValidationEntry.create(
          lifecyclePhase: lifecycle.phase.name,
          lifecycleEventCode: lifecycle.eventCode,
          position: lifecycle.position,
          lifecycleEntryDigest: lifecycle.digest,
          bootstrapHostRunDigest: bootstrapHostRun.digest,
          activationDeliveryGateDigest: activationDeliveryGate.digest,
          gateEligibility: eligibility,
        ),
    ]..sort((left, right) => left.position.compareTo(right.position));
    final validationSetDigest =
        _digest(entries.map((entry) => entry.toJson()).toList());
    return ProductionStartupValidationPlan.create(
      bootstrapHostRun: bootstrapHostRun,
      activationDeliveryGate: activationDeliveryGate,
      entries: entries,
      log: [
        for (var position = 0;
            position < ProductionStartupValidationLogPhase.values.length;
            position++)
          ProductionStartupValidationLogEntry.create(
            phase: ProductionStartupValidationLogPhase.values[position],
            position: position,
            bootstrapHostRunDigest: bootstrapHostRun.digest,
            activationDeliveryGateDigest: activationDeliveryGate.digest,
            validationSetDigest: validationSetDigest,
          ),
      ],
    );
  }
}

ProductionStartupGateEligibility _validateInputs({
  required ApplicationBootstrapHostRun bootstrapHostRun,
  required RuntimeActivationDeliveryGateContract activationDeliveryGate,
}) {
  if (bootstrapHostRun.lifecycle.length !=
          ApplicationBootstrapPhase.values.length ||
      activationDeliveryGate.entries.isEmpty) {
    throw ArgumentError('Production startup validation inputs are incomplete.');
  }
  return activationDeliveryGate.entries.every(
    (entry) => entry.gateStatus == RuntimeActivationDeliveryGateStatus.eligible,
  )
      ? ProductionStartupGateEligibility.eligible
      : ProductionStartupGateEligibility.blocked;
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
