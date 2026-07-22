import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/runtime_lifecycle_host_projection_contracts.dart';
import 'package:pool_os/contracts/runtime_service_activation_projection_contracts.dart';

const runtimeHostInitializerVersion = 1;
const runtimeHostInitializerPolicyVersion = 'runtime-host-initializer/1.0.0';

enum RuntimeHostInitializationLogPhase {
  validateProjections,
  orderInitialization,
  bindLifecycleHost,
  completed,
}

class RuntimeHostInitializationEntry {
  const RuntimeHostInitializationEntry._({
    required this.initializationEntryId,
    required this.activationId,
    required this.lifecycleEntryId,
    required this.serviceId,
    required this.runtimeNodeId,
    required this.lifecyclePhase,
    required this.position,
    required this.activationProjectionDigest,
    required this.lifecycleHostProjectionDigest,
    required this.digest,
  });

  factory RuntimeHostInitializationEntry.create({
    required String activationId,
    required String lifecycleEntryId,
    required String serviceId,
    required String runtimeNodeId,
    required String lifecyclePhase,
    required int position,
    required String activationProjectionDigest,
    required String lifecycleHostProjectionDigest,
  }) {
    if (activationId.isEmpty ||
        lifecycleEntryId.isEmpty ||
        serviceId.isEmpty ||
        runtimeNodeId.isEmpty ||
        lifecyclePhase.isEmpty ||
        position < 0 ||
        activationProjectionDigest.isEmpty ||
        lifecycleHostProjectionDigest.isEmpty) {
      throw ArgumentError('Runtime host initialization entry is incomplete.');
    }
    final initializationEntryId = 'runtime-host-initialization.$activationId';
    final payload = {
      'initializationEntryId': initializationEntryId,
      'activationId': activationId,
      'lifecycleEntryId': lifecycleEntryId,
      'serviceId': serviceId,
      'runtimeNodeId': runtimeNodeId,
      'lifecyclePhase': lifecyclePhase,
      'position': position,
      'activationProjectionDigest': activationProjectionDigest,
      'lifecycleHostProjectionDigest': lifecycleHostProjectionDigest,
    };
    return RuntimeHostInitializationEntry._(
      initializationEntryId: initializationEntryId,
      activationId: activationId,
      lifecycleEntryId: lifecycleEntryId,
      serviceId: serviceId,
      runtimeNodeId: runtimeNodeId,
      lifecyclePhase: lifecyclePhase,
      position: position,
      activationProjectionDigest: activationProjectionDigest,
      lifecycleHostProjectionDigest: lifecycleHostProjectionDigest,
      digest: _digest(payload),
    );
  }

  final String initializationEntryId;
  final String activationId;
  final String lifecycleEntryId;
  final String serviceId;
  final String runtimeNodeId;
  final String lifecyclePhase;
  final int position;
  final String activationProjectionDigest;
  final String lifecycleHostProjectionDigest;
  final String digest;

  Map<String, dynamic> toJson() => {
        'initializationEntryId': initializationEntryId,
        'activationId': activationId,
        'lifecycleEntryId': lifecycleEntryId,
        'serviceId': serviceId,
        'runtimeNodeId': runtimeNodeId,
        'lifecyclePhase': lifecyclePhase,
        'position': position,
        'activationProjectionDigest': activationProjectionDigest,
        'lifecycleHostProjectionDigest': lifecycleHostProjectionDigest,
        'digest': digest,
      };
}

class RuntimeHostInitializationLogEntry {
  const RuntimeHostInitializationLogEntry._({
    required this.phase,
    required this.position,
    required this.activationProjectionDigest,
    required this.lifecycleHostProjectionDigest,
    required this.initializationSetDigest,
    required this.eventCode,
    required this.digest,
  });

  factory RuntimeHostInitializationLogEntry.create({
    required RuntimeHostInitializationLogPhase phase,
    required int position,
    required String activationProjectionDigest,
    required String lifecycleHostProjectionDigest,
    required String initializationSetDigest,
  }) {
    if (position < 0 ||
        activationProjectionDigest.isEmpty ||
        lifecycleHostProjectionDigest.isEmpty ||
        initializationSetDigest.isEmpty) {
      throw ArgumentError('Runtime host initialization log is incomplete.');
    }
    final eventCode = 'runtime-host-initialization.${phase.name}';
    final payload = {
      'phase': phase.name,
      'position': position,
      'activationProjectionDigest': activationProjectionDigest,
      'lifecycleHostProjectionDigest': lifecycleHostProjectionDigest,
      'initializationSetDigest': initializationSetDigest,
      'eventCode': eventCode,
    };
    return RuntimeHostInitializationLogEntry._(
      phase: phase,
      position: position,
      activationProjectionDigest: activationProjectionDigest,
      lifecycleHostProjectionDigest: lifecycleHostProjectionDigest,
      initializationSetDigest: initializationSetDigest,
      eventCode: eventCode,
      digest: _digest(payload),
    );
  }

  final RuntimeHostInitializationLogPhase phase;
  final int position;
  final String activationProjectionDigest;
  final String lifecycleHostProjectionDigest;
  final String initializationSetDigest;
  final String eventCode;
  final String digest;

  Map<String, dynamic> toJson() => {
        'phase': phase.name,
        'position': position,
        'activationProjectionDigest': activationProjectionDigest,
        'lifecycleHostProjectionDigest': lifecycleHostProjectionDigest,
        'initializationSetDigest': initializationSetDigest,
        'eventCode': eventCode,
        'digest': digest,
      };
}

class RuntimeHostInitializationPlan {
  const RuntimeHostInitializationPlan._({
    required this.id,
    required this.activationProjectionId,
    required this.activationProjectionDigest,
    required this.lifecycleHostProjectionId,
    required this.lifecycleHostProjectionDigest,
    required this.entries,
    required this.log,
    required this.digest,
  });

  factory RuntimeHostInitializationPlan.create({
    required RuntimeServiceActivationProjectionContract activationProjection,
    required RuntimeLifecycleHostProjectionContract lifecycleHostProjection,
    required List<RuntimeHostInitializationEntry> entries,
    required List<RuntimeHostInitializationLogEntry> log,
  }) {
    _validateInputs(
      activationProjection: activationProjection,
      lifecycleHostProjection: lifecycleHostProjection,
    );
    if (entries.length != activationProjection.entries.length) {
      throw ArgumentError(
          'Runtime host initialization coverage is incomplete.');
    }

    final activationById = {
      for (final entry in activationProjection.entries)
        entry.activationId: entry,
    };
    final lifecycleByActivationId = {
      for (final entry in lifecycleHostProjection.entries)
        entry.activationId: entry,
    };
    final ordered = [...entries]
      ..sort((left, right) => left.position.compareTo(right.position));
    final initializationIds = <String>{};
    final activationIds = <String>{};
    final lifecycleIds = <String>{};
    final serviceIds = <String>{};
    final positions = <int>{};
    for (var position = 0; position < ordered.length; position++) {
      final entry = ordered[position];
      final activation = activationById[entry.activationId];
      final lifecycle = lifecycleByActivationId[entry.activationId];
      final expected = RuntimeHostInitializationEntry.create(
        activationId: entry.activationId,
        lifecycleEntryId: entry.lifecycleEntryId,
        serviceId: entry.serviceId,
        runtimeNodeId: entry.runtimeNodeId,
        lifecyclePhase: entry.lifecyclePhase,
        position: position,
        activationProjectionDigest: activationProjection.digest,
        lifecycleHostProjectionDigest: lifecycleHostProjection.digest,
      );
      if (activation == null ||
          lifecycle == null ||
          entry.position != position ||
          activation.activationPosition != position ||
          lifecycle.canonicalPosition != position ||
          entry.lifecycleEntryId != lifecycle.lifecycleEntryId ||
          entry.serviceId != activation.serviceId ||
          entry.serviceId != lifecycle.serviceId ||
          entry.runtimeNodeId != activation.runtimeNodeId ||
          entry.runtimeNodeId != lifecycle.runtimeNodeId ||
          entry.lifecyclePhase != lifecycle.lifecyclePhase.name ||
          entry.activationProjectionDigest != activationProjection.digest ||
          entry.lifecycleHostProjectionDigest !=
              lifecycleHostProjection.digest ||
          entry.initializationEntryId != expected.initializationEntryId ||
          entry.digest != expected.digest ||
          !initializationIds.add(entry.initializationEntryId) ||
          !activationIds.add(entry.activationId) ||
          !lifecycleIds.add(entry.lifecycleEntryId) ||
          !serviceIds.add(entry.serviceId) ||
          !positions.add(entry.position)) {
        throw ArgumentError(
            'Runtime host initialization provenance is invalid.');
      }
    }

    final initializationSetDigest =
        _digest(ordered.map((entry) => entry.toJson()).toList());
    final orderedLog = [...log]
      ..sort((left, right) => left.position.compareTo(right.position));
    if (orderedLog.length != RuntimeHostInitializationLogPhase.values.length) {
      throw ArgumentError('Runtime host initialization log is incomplete.');
    }
    for (var position = 0; position < orderedLog.length; position++) {
      final entry = orderedLog[position];
      final expected = RuntimeHostInitializationLogEntry.create(
        phase: RuntimeHostInitializationLogPhase.values[position],
        position: position,
        activationProjectionDigest: activationProjection.digest,
        lifecycleHostProjectionDigest: lifecycleHostProjection.digest,
        initializationSetDigest: initializationSetDigest,
      );
      if (entry.phase != expected.phase ||
          entry.position != expected.position ||
          entry.activationProjectionDigest !=
              expected.activationProjectionDigest ||
          entry.lifecycleHostProjectionDigest !=
              expected.lifecycleHostProjectionDigest ||
          entry.initializationSetDigest != expected.initializationSetDigest ||
          entry.eventCode != expected.eventCode ||
          entry.digest != expected.digest) {
        throw ArgumentError('Runtime host initialization log is invalid.');
      }
    }

    final payload = {
      'initializerVersion': runtimeHostInitializerVersion,
      'policyVersion': runtimeHostInitializerPolicyVersion,
      'activationProjectionId': activationProjection.id,
      'activationProjectionDigest': activationProjection.digest,
      'lifecycleHostProjectionId': lifecycleHostProjection.id,
      'lifecycleHostProjectionDigest': lifecycleHostProjection.digest,
      'entries': ordered.map((entry) => entry.toJson()).toList(),
      'log': orderedLog.map((entry) => entry.toJson()).toList(),
    };
    final digest = _digest(payload);
    return RuntimeHostInitializationPlan._(
      id: 'runtime-host-initialization-plan.${digest.substring(0, 16)}',
      activationProjectionId: activationProjection.id,
      activationProjectionDigest: activationProjection.digest,
      lifecycleHostProjectionId: lifecycleHostProjection.id,
      lifecycleHostProjectionDigest: lifecycleHostProjection.digest,
      entries: List.unmodifiable(ordered),
      log: List.unmodifiable(orderedLog),
      digest: digest,
    );
  }

  final String id;
  final String activationProjectionId;
  final String activationProjectionDigest;
  final String lifecycleHostProjectionId;
  final String lifecycleHostProjectionDigest;
  final List<RuntimeHostInitializationEntry> entries;
  final List<RuntimeHostInitializationLogEntry> log;
  final String digest;

  Map<String, dynamic> toJson() => {
        'initializerVersion': runtimeHostInitializerVersion,
        'policyVersion': runtimeHostInitializerPolicyVersion,
        'id': id,
        'activationProjectionId': activationProjectionId,
        'activationProjectionDigest': activationProjectionDigest,
        'lifecycleHostProjectionId': lifecycleHostProjectionId,
        'lifecycleHostProjectionDigest': lifecycleHostProjectionDigest,
        'entries': entries.map((entry) => entry.toJson()).toList(),
        'log': log.map((entry) => entry.toJson()).toList(),
        'digest': digest,
      };
}

class RuntimeHostInitializer {
  const RuntimeHostInitializer();

  RuntimeHostInitializationPlan plan({
    required RuntimeServiceActivationProjectionContract activationProjection,
    required RuntimeLifecycleHostProjectionContract lifecycleHostProjection,
  }) {
    _validateInputs(
      activationProjection: activationProjection,
      lifecycleHostProjection: lifecycleHostProjection,
    );
    final activationById = {
      for (final entry in activationProjection.entries)
        entry.activationId: entry,
    };
    final entries = [
      for (final lifecycle in lifecycleHostProjection.entries)
        RuntimeHostInitializationEntry.create(
          activationId: lifecycle.activationId,
          lifecycleEntryId: lifecycle.lifecycleEntryId,
          serviceId: lifecycle.serviceId,
          runtimeNodeId: lifecycle.runtimeNodeId,
          lifecyclePhase: lifecycle.lifecyclePhase.name,
          position:
              activationById[lifecycle.activationId]?.activationPosition ??
                  (throw ArgumentError(
                    'Runtime lifecycle host contains an orphan activation.',
                  )),
          activationProjectionDigest: activationProjection.digest,
          lifecycleHostProjectionDigest: lifecycleHostProjection.digest,
        ),
    ]..sort((left, right) => left.position.compareTo(right.position));
    final initializationSetDigest =
        _digest(entries.map((entry) => entry.toJson()).toList());
    return RuntimeHostInitializationPlan.create(
      activationProjection: activationProjection,
      lifecycleHostProjection: lifecycleHostProjection,
      entries: entries,
      log: [
        for (var position = 0;
            position < RuntimeHostInitializationLogPhase.values.length;
            position++)
          RuntimeHostInitializationLogEntry.create(
            phase: RuntimeHostInitializationLogPhase.values[position],
            position: position,
            activationProjectionDigest: activationProjection.digest,
            lifecycleHostProjectionDigest: lifecycleHostProjection.digest,
            initializationSetDigest: initializationSetDigest,
          ),
      ],
    );
  }
}

void _validateInputs({
  required RuntimeServiceActivationProjectionContract activationProjection,
  required RuntimeLifecycleHostProjectionContract lifecycleHostProjection,
}) {
  if (activationProjection.entries.isEmpty ||
      lifecycleHostProjection.entries.isEmpty ||
      lifecycleHostProjection.runtimeServiceActivationProjectionId !=
          activationProjection.id ||
      lifecycleHostProjection.runtimeServiceActivationProjectionDigest !=
          activationProjection.digest ||
      lifecycleHostProjection.entries.length !=
          activationProjection.entries.length) {
    throw ArgumentError('Runtime host initialization inputs are incompatible.');
  }
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
