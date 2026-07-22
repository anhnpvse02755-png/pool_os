import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/application/runtime_host_initializer.dart';
import 'package:pool_os/contracts/runtime_service_composition_contracts.dart';

const applicationServiceWiringPlannerVersion = 1;
const applicationServiceWiringPlannerPolicyVersion =
    'application-service-wiring-planner/1.0.0';

enum ApplicationServiceWiringLogPhase {
  validateInputs,
  orderWiring,
  bindServices,
  completed,
}

class ApplicationServiceWiringEntry {
  const ApplicationServiceWiringEntry._({
    required this.wiringEntryId,
    required this.initializationEntryId,
    required this.serviceId,
    required this.runtimeNodeId,
    required this.serviceKey,
    required this.serviceType,
    required this.position,
    required this.initializationPlanDigest,
    required this.serviceCompositionDigest,
    required this.digest,
  });

  factory ApplicationServiceWiringEntry.create({
    required String initializationEntryId,
    required String serviceId,
    required String runtimeNodeId,
    required String serviceKey,
    required String serviceType,
    required int position,
    required String initializationPlanDigest,
    required String serviceCompositionDigest,
  }) {
    if (initializationEntryId.isEmpty ||
        serviceId.isEmpty ||
        runtimeNodeId.isEmpty ||
        serviceKey.isEmpty ||
        serviceType.isEmpty ||
        position < 0 ||
        initializationPlanDigest.isEmpty ||
        serviceCompositionDigest.isEmpty) {
      throw ArgumentError('Application service wiring entry is incomplete.');
    }
    final wiringEntryId = 'application-service-wiring.$serviceId';
    final payload = {
      'wiringEntryId': wiringEntryId,
      'initializationEntryId': initializationEntryId,
      'serviceId': serviceId,
      'runtimeNodeId': runtimeNodeId,
      'serviceKey': serviceKey,
      'serviceType': serviceType,
      'position': position,
      'initializationPlanDigest': initializationPlanDigest,
      'serviceCompositionDigest': serviceCompositionDigest,
    };
    return ApplicationServiceWiringEntry._(
      wiringEntryId: wiringEntryId,
      initializationEntryId: initializationEntryId,
      serviceId: serviceId,
      runtimeNodeId: runtimeNodeId,
      serviceKey: serviceKey,
      serviceType: serviceType,
      position: position,
      initializationPlanDigest: initializationPlanDigest,
      serviceCompositionDigest: serviceCompositionDigest,
      digest: _digest(payload),
    );
  }

  final String wiringEntryId;
  final String initializationEntryId;
  final String serviceId;
  final String runtimeNodeId;
  final String serviceKey;
  final String serviceType;
  final int position;
  final String initializationPlanDigest;
  final String serviceCompositionDigest;
  final String digest;

  Map<String, dynamic> toJson() => {
        'wiringEntryId': wiringEntryId,
        'initializationEntryId': initializationEntryId,
        'serviceId': serviceId,
        'runtimeNodeId': runtimeNodeId,
        'serviceKey': serviceKey,
        'serviceType': serviceType,
        'position': position,
        'initializationPlanDigest': initializationPlanDigest,
        'serviceCompositionDigest': serviceCompositionDigest,
        'digest': digest,
      };
}

class ApplicationServiceWiringLogEntry {
  const ApplicationServiceWiringLogEntry._({
    required this.phase,
    required this.position,
    required this.initializationPlanDigest,
    required this.serviceCompositionDigest,
    required this.wiringSetDigest,
    required this.eventCode,
    required this.digest,
  });

  factory ApplicationServiceWiringLogEntry.create({
    required ApplicationServiceWiringLogPhase phase,
    required int position,
    required String initializationPlanDigest,
    required String serviceCompositionDigest,
    required String wiringSetDigest,
  }) {
    if (position < 0 ||
        initializationPlanDigest.isEmpty ||
        serviceCompositionDigest.isEmpty ||
        wiringSetDigest.isEmpty) {
      throw ArgumentError('Application service wiring log is incomplete.');
    }
    final eventCode = 'application-service-wiring.${phase.name}';
    final payload = {
      'phase': phase.name,
      'position': position,
      'initializationPlanDigest': initializationPlanDigest,
      'serviceCompositionDigest': serviceCompositionDigest,
      'wiringSetDigest': wiringSetDigest,
      'eventCode': eventCode,
    };
    return ApplicationServiceWiringLogEntry._(
      phase: phase,
      position: position,
      initializationPlanDigest: initializationPlanDigest,
      serviceCompositionDigest: serviceCompositionDigest,
      wiringSetDigest: wiringSetDigest,
      eventCode: eventCode,
      digest: _digest(payload),
    );
  }

  final ApplicationServiceWiringLogPhase phase;
  final int position;
  final String initializationPlanDigest;
  final String serviceCompositionDigest;
  final String wiringSetDigest;
  final String eventCode;
  final String digest;

  Map<String, dynamic> toJson() => {
        'phase': phase.name,
        'position': position,
        'initializationPlanDigest': initializationPlanDigest,
        'serviceCompositionDigest': serviceCompositionDigest,
        'wiringSetDigest': wiringSetDigest,
        'eventCode': eventCode,
        'digest': digest,
      };
}

class ApplicationServiceWiringPlan {
  const ApplicationServiceWiringPlan._({
    required this.id,
    required this.initializationPlanId,
    required this.initializationPlanDigest,
    required this.serviceCompositionId,
    required this.serviceCompositionDigest,
    required this.entries,
    required this.log,
    required this.digest,
  });

  factory ApplicationServiceWiringPlan.create({
    required RuntimeHostInitializationPlan initializationPlan,
    required RuntimeServiceCompositionContract serviceComposition,
    required List<ApplicationServiceWiringEntry> entries,
    required List<ApplicationServiceWiringLogEntry> log,
  }) {
    _validateInputs(
      initializationPlan: initializationPlan,
      serviceComposition: serviceComposition,
    );
    if (entries.length != initializationPlan.entries.length) {
      throw ArgumentError('Application service wiring coverage is incomplete.');
    }
    final initializationByService = {
      for (final entry in initializationPlan.entries) entry.serviceId: entry,
    };
    final serviceById = {
      for (final service in serviceComposition.nodes)
        service.serviceId: service,
    };
    final ordered = [...entries]
      ..sort((left, right) => left.position.compareTo(right.position));
    final wiringIds = <String>{};
    final initializationIds = <String>{};
    final serviceIds = <String>{};
    final runtimeNodeIds = <String>{};
    final positions = <int>{};
    for (var position = 0; position < ordered.length; position++) {
      final entry = ordered[position];
      final initialization = initializationByService[entry.serviceId];
      final service = serviceById[entry.serviceId];
      final expected = ApplicationServiceWiringEntry.create(
        initializationEntryId: entry.initializationEntryId,
        serviceId: entry.serviceId,
        runtimeNodeId: entry.runtimeNodeId,
        serviceKey: entry.serviceKey,
        serviceType: entry.serviceType,
        position: position,
        initializationPlanDigest: initializationPlan.digest,
        serviceCompositionDigest: serviceComposition.digest,
      );
      if (initialization == null ||
          service == null ||
          entry.position != position ||
          initialization.position != position ||
          service.position != position ||
          entry.initializationEntryId != initialization.initializationEntryId ||
          entry.runtimeNodeId != initialization.runtimeNodeId ||
          entry.serviceId != initialization.serviceId ||
          entry.serviceKey != service.serviceKey ||
          entry.serviceType != service.type.name ||
          entry.initializationPlanDigest != initializationPlan.digest ||
          entry.serviceCompositionDigest != serviceComposition.digest ||
          entry.wiringEntryId != expected.wiringEntryId ||
          entry.digest != expected.digest ||
          !wiringIds.add(entry.wiringEntryId) ||
          !initializationIds.add(entry.initializationEntryId) ||
          !serviceIds.add(entry.serviceId) ||
          !runtimeNodeIds.add(entry.runtimeNodeId) ||
          !positions.add(entry.position)) {
        throw ArgumentError(
            'Application service wiring provenance is invalid.');
      }
    }

    final wiringSetDigest =
        _digest(ordered.map((entry) => entry.toJson()).toList());
    final orderedLog = [...log]
      ..sort((left, right) => left.position.compareTo(right.position));
    if (orderedLog.length != ApplicationServiceWiringLogPhase.values.length) {
      throw ArgumentError('Application service wiring log is incomplete.');
    }
    for (var position = 0; position < orderedLog.length; position++) {
      final entry = orderedLog[position];
      final expected = ApplicationServiceWiringLogEntry.create(
        phase: ApplicationServiceWiringLogPhase.values[position],
        position: position,
        initializationPlanDigest: initializationPlan.digest,
        serviceCompositionDigest: serviceComposition.digest,
        wiringSetDigest: wiringSetDigest,
      );
      if (entry.phase != expected.phase ||
          entry.position != expected.position ||
          entry.initializationPlanDigest != expected.initializationPlanDigest ||
          entry.serviceCompositionDigest != expected.serviceCompositionDigest ||
          entry.wiringSetDigest != expected.wiringSetDigest ||
          entry.eventCode != expected.eventCode ||
          entry.digest != expected.digest) {
        throw ArgumentError('Application service wiring log is invalid.');
      }
    }

    final payload = {
      'plannerVersion': applicationServiceWiringPlannerVersion,
      'policyVersion': applicationServiceWiringPlannerPolicyVersion,
      'initializationPlanId': initializationPlan.id,
      'initializationPlanDigest': initializationPlan.digest,
      'serviceCompositionId': serviceComposition.id,
      'serviceCompositionDigest': serviceComposition.digest,
      'entries': ordered.map((entry) => entry.toJson()).toList(),
      'log': orderedLog.map((entry) => entry.toJson()).toList(),
    };
    final digest = _digest(payload);
    return ApplicationServiceWiringPlan._(
      id: 'application-service-wiring-plan.${digest.substring(0, 16)}',
      initializationPlanId: initializationPlan.id,
      initializationPlanDigest: initializationPlan.digest,
      serviceCompositionId: serviceComposition.id,
      serviceCompositionDigest: serviceComposition.digest,
      entries: List.unmodifiable(ordered),
      log: List.unmodifiable(orderedLog),
      digest: digest,
    );
  }

  final String id;
  final String initializationPlanId;
  final String initializationPlanDigest;
  final String serviceCompositionId;
  final String serviceCompositionDigest;
  final List<ApplicationServiceWiringEntry> entries;
  final List<ApplicationServiceWiringLogEntry> log;
  final String digest;

  Map<String, dynamic> toJson() => {
        'plannerVersion': applicationServiceWiringPlannerVersion,
        'policyVersion': applicationServiceWiringPlannerPolicyVersion,
        'id': id,
        'initializationPlanId': initializationPlanId,
        'initializationPlanDigest': initializationPlanDigest,
        'serviceCompositionId': serviceCompositionId,
        'serviceCompositionDigest': serviceCompositionDigest,
        'entries': entries.map((entry) => entry.toJson()).toList(),
        'log': log.map((entry) => entry.toJson()).toList(),
        'digest': digest,
      };
}

class ApplicationServiceWiringPlanner {
  const ApplicationServiceWiringPlanner();

  ApplicationServiceWiringPlan plan({
    required RuntimeHostInitializationPlan initializationPlan,
    required RuntimeServiceCompositionContract serviceComposition,
  }) {
    _validateInputs(
      initializationPlan: initializationPlan,
      serviceComposition: serviceComposition,
    );
    final serviceById = {
      for (final service in serviceComposition.nodes)
        service.serviceId: service,
    };
    final entries = [
      for (final initialization in initializationPlan.entries)
        ApplicationServiceWiringEntry.create(
          initializationEntryId: initialization.initializationEntryId,
          serviceId: initialization.serviceId,
          runtimeNodeId: initialization.runtimeNodeId,
          serviceKey: serviceById[initialization.serviceId]?.serviceKey ??
              (throw ArgumentError(
                'Application service wiring contains an orphan service.',
              )),
          serviceType: serviceById[initialization.serviceId]?.type.name ??
              (throw ArgumentError(
                'Application service wiring contains an orphan service.',
              )),
          position: initialization.position,
          initializationPlanDigest: initializationPlan.digest,
          serviceCompositionDigest: serviceComposition.digest,
        ),
    ]..sort((left, right) => left.position.compareTo(right.position));
    final wiringSetDigest =
        _digest(entries.map((entry) => entry.toJson()).toList());
    return ApplicationServiceWiringPlan.create(
      initializationPlan: initializationPlan,
      serviceComposition: serviceComposition,
      entries: entries,
      log: [
        for (var position = 0;
            position < ApplicationServiceWiringLogPhase.values.length;
            position++)
          ApplicationServiceWiringLogEntry.create(
            phase: ApplicationServiceWiringLogPhase.values[position],
            position: position,
            initializationPlanDigest: initializationPlan.digest,
            serviceCompositionDigest: serviceComposition.digest,
            wiringSetDigest: wiringSetDigest,
          ),
      ],
    );
  }
}

void _validateInputs({
  required RuntimeHostInitializationPlan initializationPlan,
  required RuntimeServiceCompositionContract serviceComposition,
}) {
  if (initializationPlan.entries.isEmpty ||
      serviceComposition.nodes.isEmpty ||
      initializationPlan.entries.length != serviceComposition.nodes.length) {
    throw ArgumentError('Application service wiring inputs are incompatible.');
  }
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
