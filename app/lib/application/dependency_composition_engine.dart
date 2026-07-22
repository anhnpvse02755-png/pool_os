import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/dependency_composition_root_contracts.dart';
import 'package:pool_os/contracts/runtime_service_activation_projection_contracts.dart';

const dependencyCompositionEngineVersion = 1;
const dependencyCompositionEnginePolicyVersion =
    'dependency-composition-engine/1.0.0';

enum DependencyCompositionLogPhase {
  validateComposition,
  orderRegistrations,
  bindActivationProjection,
  completed,
}

class DependencyRegistrationDescriptor {
  const DependencyRegistrationDescriptor._({
    required this.registrationId,
    required this.compositionEntryId,
    required this.activationId,
    required this.serviceId,
    required this.runtimeNodeId,
    required this.position,
    required this.compositionRootDigest,
    required this.activationProjectionDigest,
    required this.digest,
  });

  factory DependencyRegistrationDescriptor.create({
    required String compositionEntryId,
    required String activationId,
    required String serviceId,
    required String runtimeNodeId,
    required int position,
    required String compositionRootDigest,
    required String activationProjectionDigest,
  }) {
    if (compositionEntryId.isEmpty ||
        activationId.isEmpty ||
        serviceId.isEmpty ||
        runtimeNodeId.isEmpty ||
        position < 0 ||
        compositionRootDigest.isEmpty ||
        activationProjectionDigest.isEmpty) {
      throw ArgumentError('Dependency registration descriptor is incomplete.');
    }
    final registrationId = 'dependency-registration.$activationId';
    final payload = {
      'registrationId': registrationId,
      'compositionEntryId': compositionEntryId,
      'activationId': activationId,
      'serviceId': serviceId,
      'runtimeNodeId': runtimeNodeId,
      'position': position,
      'compositionRootDigest': compositionRootDigest,
      'activationProjectionDigest': activationProjectionDigest,
    };
    return DependencyRegistrationDescriptor._(
      registrationId: registrationId,
      compositionEntryId: compositionEntryId,
      activationId: activationId,
      serviceId: serviceId,
      runtimeNodeId: runtimeNodeId,
      position: position,
      compositionRootDigest: compositionRootDigest,
      activationProjectionDigest: activationProjectionDigest,
      digest: _digest(payload),
    );
  }

  final String registrationId;
  final String compositionEntryId;
  final String activationId;
  final String serviceId;
  final String runtimeNodeId;
  final int position;
  final String compositionRootDigest;
  final String activationProjectionDigest;
  final String digest;

  Map<String, dynamic> toJson() => {
        'registrationId': registrationId,
        'compositionEntryId': compositionEntryId,
        'activationId': activationId,
        'serviceId': serviceId,
        'runtimeNodeId': runtimeNodeId,
        'position': position,
        'compositionRootDigest': compositionRootDigest,
        'activationProjectionDigest': activationProjectionDigest,
        'digest': digest,
      };
}

class DependencyCompositionLogEntry {
  const DependencyCompositionLogEntry._({
    required this.phase,
    required this.position,
    required this.compositionRootDigest,
    required this.activationProjectionDigest,
    required this.registrationSetDigest,
    required this.eventCode,
    required this.digest,
  });

  factory DependencyCompositionLogEntry.create({
    required DependencyCompositionLogPhase phase,
    required int position,
    required String compositionRootDigest,
    required String activationProjectionDigest,
    required String registrationSetDigest,
  }) {
    if (position < 0 ||
        compositionRootDigest.isEmpty ||
        activationProjectionDigest.isEmpty ||
        registrationSetDigest.isEmpty) {
      throw ArgumentError('Dependency composition log entry is incomplete.');
    }
    final eventCode = 'dependency-composition.${phase.name}';
    final payload = {
      'phase': phase.name,
      'position': position,
      'compositionRootDigest': compositionRootDigest,
      'activationProjectionDigest': activationProjectionDigest,
      'registrationSetDigest': registrationSetDigest,
      'eventCode': eventCode,
    };
    return DependencyCompositionLogEntry._(
      phase: phase,
      position: position,
      compositionRootDigest: compositionRootDigest,
      activationProjectionDigest: activationProjectionDigest,
      registrationSetDigest: registrationSetDigest,
      eventCode: eventCode,
      digest: _digest(payload),
    );
  }

  final DependencyCompositionLogPhase phase;
  final int position;
  final String compositionRootDigest;
  final String activationProjectionDigest;
  final String registrationSetDigest;
  final String eventCode;
  final String digest;

  Map<String, dynamic> toJson() => {
        'phase': phase.name,
        'position': position,
        'compositionRootDigest': compositionRootDigest,
        'activationProjectionDigest': activationProjectionDigest,
        'registrationSetDigest': registrationSetDigest,
        'eventCode': eventCode,
        'digest': digest,
      };
}

class DependencyRegistrationPlan {
  const DependencyRegistrationPlan._({
    required this.id,
    required this.compositionRootId,
    required this.compositionRootDigest,
    required this.activationProjectionId,
    required this.activationProjectionDigest,
    required this.registrations,
    required this.log,
    required this.digest,
  });

  factory DependencyRegistrationPlan.create({
    required DependencyCompositionRootContract compositionRoot,
    required RuntimeServiceActivationProjectionContract activationProjection,
    required List<DependencyRegistrationDescriptor> registrations,
    required List<DependencyCompositionLogEntry> log,
  }) {
    _validateInputs(
      compositionRoot: compositionRoot,
      activationProjection: activationProjection,
    );
    if (registrations.length != compositionRoot.entries.length) {
      throw ArgumentError('Dependency registration plan is incomplete.');
    }

    final compositionById = {
      for (final entry in compositionRoot.entries)
        entry.compositionEntryId: entry,
    };
    final activationById = {
      for (final entry in activationProjection.entries)
        entry.activationId: entry,
    };
    final ordered = [...registrations]
      ..sort((left, right) => left.position.compareTo(right.position));
    final registrationIds = <String>{};
    final compositionEntryIds = <String>{};
    final activationIds = <String>{};
    final serviceIds = <String>{};
    for (var position = 0; position < ordered.length; position++) {
      final registration = ordered[position];
      final composition = compositionById[registration.compositionEntryId];
      final activation = activationById[registration.activationId];
      final expected = DependencyRegistrationDescriptor.create(
        compositionEntryId: registration.compositionEntryId,
        activationId: registration.activationId,
        serviceId: registration.serviceId,
        runtimeNodeId: registration.runtimeNodeId,
        position: position,
        compositionRootDigest: compositionRoot.digest,
        activationProjectionDigest: activationProjection.digest,
      );
      if (composition == null ||
          activation == null ||
          registration.position != position ||
          activation.activationPosition != position ||
          activation.compositionEntryId != composition.compositionEntryId ||
          registration.serviceId != composition.serviceId ||
          registration.serviceId != activation.serviceId ||
          registration.runtimeNodeId != composition.runtimeNodeId ||
          registration.runtimeNodeId != activation.runtimeNodeId ||
          registration.compositionRootDigest != compositionRoot.digest ||
          registration.activationProjectionDigest !=
              activationProjection.digest ||
          registration.registrationId != expected.registrationId ||
          registration.digest != expected.digest ||
          !registrationIds.add(registration.registrationId) ||
          !compositionEntryIds.add(registration.compositionEntryId) ||
          !activationIds.add(registration.activationId) ||
          !serviceIds.add(registration.serviceId)) {
        throw ArgumentError('Dependency registration provenance is invalid.');
      }
    }

    final registrationSetDigest = _digest(
      ordered.map((registration) => registration.toJson()).toList(),
    );
    final orderedLog = [...log]
      ..sort((left, right) => left.position.compareTo(right.position));
    if (orderedLog.length != DependencyCompositionLogPhase.values.length) {
      throw ArgumentError('Dependency composition log is incomplete.');
    }
    for (var position = 0; position < orderedLog.length; position++) {
      final entry = orderedLog[position];
      final expected = DependencyCompositionLogEntry.create(
        phase: DependencyCompositionLogPhase.values[position],
        position: position,
        compositionRootDigest: compositionRoot.digest,
        activationProjectionDigest: activationProjection.digest,
        registrationSetDigest: registrationSetDigest,
      );
      if (entry.phase != expected.phase ||
          entry.position != expected.position ||
          entry.compositionRootDigest != expected.compositionRootDigest ||
          entry.activationProjectionDigest !=
              expected.activationProjectionDigest ||
          entry.registrationSetDigest != expected.registrationSetDigest ||
          entry.eventCode != expected.eventCode ||
          entry.digest != expected.digest) {
        throw ArgumentError('Dependency composition log is invalid.');
      }
    }

    final payload = {
      'engineVersion': dependencyCompositionEngineVersion,
      'policyVersion': dependencyCompositionEnginePolicyVersion,
      'compositionRootId': compositionRoot.id,
      'compositionRootDigest': compositionRoot.digest,
      'activationProjectionId': activationProjection.id,
      'activationProjectionDigest': activationProjection.digest,
      'registrations': ordered.map((entry) => entry.toJson()).toList(),
      'log': orderedLog.map((entry) => entry.toJson()).toList(),
    };
    final digest = _digest(payload);
    return DependencyRegistrationPlan._(
      id: 'dependency-registration-plan.${digest.substring(0, 16)}',
      compositionRootId: compositionRoot.id,
      compositionRootDigest: compositionRoot.digest,
      activationProjectionId: activationProjection.id,
      activationProjectionDigest: activationProjection.digest,
      registrations: List.unmodifiable(ordered),
      log: List.unmodifiable(orderedLog),
      digest: digest,
    );
  }

  final String id;
  final String compositionRootId;
  final String compositionRootDigest;
  final String activationProjectionId;
  final String activationProjectionDigest;
  final List<DependencyRegistrationDescriptor> registrations;
  final List<DependencyCompositionLogEntry> log;
  final String digest;

  Map<String, dynamic> toJson() => {
        'engineVersion': dependencyCompositionEngineVersion,
        'policyVersion': dependencyCompositionEnginePolicyVersion,
        'id': id,
        'compositionRootId': compositionRootId,
        'compositionRootDigest': compositionRootDigest,
        'activationProjectionId': activationProjectionId,
        'activationProjectionDigest': activationProjectionDigest,
        'registrations':
            registrations.map((registration) => registration.toJson()).toList(),
        'log': log.map((entry) => entry.toJson()).toList(),
        'digest': digest,
      };
}

class DependencyCompositionEngine {
  const DependencyCompositionEngine();

  DependencyRegistrationPlan plan({
    required DependencyCompositionRootContract compositionRoot,
    required RuntimeServiceActivationProjectionContract activationProjection,
  }) {
    _validateInputs(
      compositionRoot: compositionRoot,
      activationProjection: activationProjection,
    );
    final activationByCompositionEntry = {
      for (final entry in activationProjection.entries)
        entry.compositionEntryId: entry,
    };
    final registrations = [
      for (final composition in compositionRoot.entries)
        DependencyRegistrationDescriptor.create(
          compositionEntryId: composition.compositionEntryId,
          activationId:
              activationByCompositionEntry[composition.compositionEntryId]
                      ?.activationId ??
                  (throw ArgumentError(
                    'Dependency composition contains an orphan entry.',
                  )),
          serviceId: composition.serviceId,
          runtimeNodeId: composition.runtimeNodeId,
          position: activationByCompositionEntry[composition.compositionEntryId]
                  ?.activationPosition ??
              (throw ArgumentError(
                'Dependency composition contains an orphan entry.',
              )),
          compositionRootDigest: compositionRoot.digest,
          activationProjectionDigest: activationProjection.digest,
        ),
    ];
    registrations
        .sort((left, right) => left.position.compareTo(right.position));
    final registrationSetDigest = _digest(
      registrations.map((registration) => registration.toJson()).toList(),
    );
    return DependencyRegistrationPlan.create(
      compositionRoot: compositionRoot,
      activationProjection: activationProjection,
      registrations: registrations,
      log: [
        for (var position = 0;
            position < DependencyCompositionLogPhase.values.length;
            position++)
          DependencyCompositionLogEntry.create(
            phase: DependencyCompositionLogPhase.values[position],
            position: position,
            compositionRootDigest: compositionRoot.digest,
            activationProjectionDigest: activationProjection.digest,
            registrationSetDigest: registrationSetDigest,
          ),
      ],
    );
  }
}

void _validateInputs({
  required DependencyCompositionRootContract compositionRoot,
  required RuntimeServiceActivationProjectionContract activationProjection,
}) {
  if (compositionRoot.entries.isEmpty ||
      activationProjection.entries.isEmpty ||
      activationProjection.dependencyCompositionRootId != compositionRoot.id ||
      activationProjection.dependencyCompositionRootDigest !=
          compositionRoot.digest ||
      activationProjection.entries.length != compositionRoot.entries.length) {
    throw ArgumentError('Dependency composition inputs are incompatible.');
  }
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
