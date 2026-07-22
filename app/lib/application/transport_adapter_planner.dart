import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/application/persistence_adapter_planner.dart';
import 'package:pool_os/contracts/runtime_service_exposure_contracts.dart';

const transportAdapterPlannerVersion = 1;
const transportAdapterPlannerPolicyVersion = 'transport-adapter-planner/1.0.0';

enum TransportAdapterLogPhase {
  validateInputs,
  orderFeatures,
  bindTransportProvenance,
  completed,
}

class TransportAdapterEntry {
  const TransportAdapterEntry._({
    required this.transportAdapterEntryId,
    required this.featureId,
    required this.persistenceAdapterEntryId,
    required this.position,
    required this.persistenceAdapterPlanDigest,
    required this.runtimeServiceExposureDigest,
    required this.provenanceDigest,
    required this.digest,
  });

  factory TransportAdapterEntry.create({
    required String featureId,
    required String persistenceAdapterEntryId,
    required int position,
    required String persistenceAdapterPlanDigest,
    required String runtimeServiceExposureDigest,
  }) {
    if (featureId.isEmpty ||
        persistenceAdapterEntryId.isEmpty ||
        position < 0 ||
        persistenceAdapterPlanDigest.isEmpty ||
        runtimeServiceExposureDigest.isEmpty) {
      throw ArgumentError('Transport adapter entry is incomplete.');
    }
    final transportAdapterEntryId = 'transport-adapter.$featureId';
    final provenanceDigest = _digest({
      'persistenceAdapterPlanDigest': persistenceAdapterPlanDigest,
      'runtimeServiceExposureDigest': runtimeServiceExposureDigest,
    });
    final payload = {
      'transportAdapterEntryId': transportAdapterEntryId,
      'featureId': featureId,
      'persistenceAdapterEntryId': persistenceAdapterEntryId,
      'position': position,
      'persistenceAdapterPlanDigest': persistenceAdapterPlanDigest,
      'runtimeServiceExposureDigest': runtimeServiceExposureDigest,
      'provenanceDigest': provenanceDigest,
    };
    return TransportAdapterEntry._(
      transportAdapterEntryId: transportAdapterEntryId,
      featureId: featureId,
      persistenceAdapterEntryId: persistenceAdapterEntryId,
      position: position,
      persistenceAdapterPlanDigest: persistenceAdapterPlanDigest,
      runtimeServiceExposureDigest: runtimeServiceExposureDigest,
      provenanceDigest: provenanceDigest,
      digest: _digest(payload),
    );
  }

  final String transportAdapterEntryId;
  final String featureId;
  final String persistenceAdapterEntryId;
  final int position;
  final String persistenceAdapterPlanDigest;
  final String runtimeServiceExposureDigest;
  final String provenanceDigest;
  final String digest;

  Map<String, dynamic> toJson() => {
        'transportAdapterEntryId': transportAdapterEntryId,
        'featureId': featureId,
        'persistenceAdapterEntryId': persistenceAdapterEntryId,
        'position': position,
        'persistenceAdapterPlanDigest': persistenceAdapterPlanDigest,
        'runtimeServiceExposureDigest': runtimeServiceExposureDigest,
        'provenanceDigest': provenanceDigest,
        'digest': digest,
      };
}

class TransportAdapterLogEntry {
  const TransportAdapterLogEntry._({
    required this.phase,
    required this.position,
    required this.persistenceAdapterPlanDigest,
    required this.runtimeServiceExposureDigest,
    required this.transportAdapterSetDigest,
    required this.eventCode,
    required this.digest,
  });

  factory TransportAdapterLogEntry.create({
    required TransportAdapterLogPhase phase,
    required int position,
    required String persistenceAdapterPlanDigest,
    required String runtimeServiceExposureDigest,
    required String transportAdapterSetDigest,
  }) {
    if (position < 0 ||
        persistenceAdapterPlanDigest.isEmpty ||
        runtimeServiceExposureDigest.isEmpty ||
        transportAdapterSetDigest.isEmpty) {
      throw ArgumentError('Transport adapter log is incomplete.');
    }
    final eventCode = 'transport-adapter.${phase.name}';
    final payload = {
      'phase': phase.name,
      'position': position,
      'persistenceAdapterPlanDigest': persistenceAdapterPlanDigest,
      'runtimeServiceExposureDigest': runtimeServiceExposureDigest,
      'transportAdapterSetDigest': transportAdapterSetDigest,
      'eventCode': eventCode,
    };
    return TransportAdapterLogEntry._(
      phase: phase,
      position: position,
      persistenceAdapterPlanDigest: persistenceAdapterPlanDigest,
      runtimeServiceExposureDigest: runtimeServiceExposureDigest,
      transportAdapterSetDigest: transportAdapterSetDigest,
      eventCode: eventCode,
      digest: _digest(payload),
    );
  }

  final TransportAdapterLogPhase phase;
  final int position;
  final String persistenceAdapterPlanDigest;
  final String runtimeServiceExposureDigest;
  final String transportAdapterSetDigest;
  final String eventCode;
  final String digest;

  Map<String, dynamic> toJson() => {
        'phase': phase.name,
        'position': position,
        'persistenceAdapterPlanDigest': persistenceAdapterPlanDigest,
        'runtimeServiceExposureDigest': runtimeServiceExposureDigest,
        'transportAdapterSetDigest': transportAdapterSetDigest,
        'eventCode': eventCode,
        'digest': digest,
      };
}

class TransportAdapterPlan {
  const TransportAdapterPlan._({
    required this.id,
    required this.persistenceAdapterPlanId,
    required this.persistenceAdapterPlanDigest,
    required this.runtimeServiceExposureId,
    required this.runtimeServiceExposureDigest,
    required this.entries,
    required this.log,
    required this.digest,
  });

  factory TransportAdapterPlan.create({
    required PersistenceAdapterPlan persistenceAdapterPlan,
    required RuntimeServiceExposureContract runtimeServiceExposure,
    required List<TransportAdapterEntry> entries,
    required List<TransportAdapterLogEntry> log,
  }) {
    _validateInputs(
      persistenceAdapterPlan: persistenceAdapterPlan,
      runtimeServiceExposure: runtimeServiceExposure,
    );
    if (entries.length != persistenceAdapterPlan.entries.length) {
      throw ArgumentError('Transport adapter coverage is incomplete.');
    }
    final configurationByFeature = {
      for (final entry in persistenceAdapterPlan.entries)
        entry.featureId: entry,
    };
    final ordered = [...entries]
      ..sort((left, right) => left.position.compareTo(right.position));
    final transportAdapterIds = <String>{};
    final featureIds = <String>{};
    final configurationAdapterIds = <String>{};
    final positions = <int>{};
    for (var position = 0; position < ordered.length; position++) {
      final entry = ordered[position];
      final configurationEntry = configurationByFeature[entry.featureId];
      final expected = TransportAdapterEntry.create(
        featureId: entry.featureId,
        persistenceAdapterEntryId: entry.persistenceAdapterEntryId,
        position: position,
        persistenceAdapterPlanDigest: persistenceAdapterPlan.digest,
        runtimeServiceExposureDigest: runtimeServiceExposure.digest,
      );
      if (configurationEntry == null ||
          configurationEntry.position != position ||
          entry.position != position ||
          entry.persistenceAdapterEntryId !=
              configurationEntry.persistenceAdapterEntryId ||
          entry.persistenceAdapterPlanDigest != persistenceAdapterPlan.digest ||
          entry.runtimeServiceExposureDigest != runtimeServiceExposure.digest ||
          entry.transportAdapterEntryId != expected.transportAdapterEntryId ||
          entry.provenanceDigest != expected.provenanceDigest ||
          entry.digest != expected.digest ||
          !transportAdapterIds.add(entry.transportAdapterEntryId) ||
          !featureIds.add(entry.featureId) ||
          !configurationAdapterIds.add(entry.persistenceAdapterEntryId) ||
          !positions.add(entry.position)) {
        throw ArgumentError('Transport adapter provenance is invalid.');
      }
    }

    final transportAdapterSetDigest =
        _digest(ordered.map((entry) => entry.toJson()).toList());
    final orderedLog = [...log]
      ..sort((left, right) => left.position.compareTo(right.position));
    if (orderedLog.length != TransportAdapterLogPhase.values.length) {
      throw ArgumentError('Transport adapter log is incomplete.');
    }
    for (var position = 0; position < orderedLog.length; position++) {
      final entry = orderedLog[position];
      final expected = TransportAdapterLogEntry.create(
        phase: TransportAdapterLogPhase.values[position],
        position: position,
        persistenceAdapterPlanDigest: persistenceAdapterPlan.digest,
        runtimeServiceExposureDigest: runtimeServiceExposure.digest,
        transportAdapterSetDigest: transportAdapterSetDigest,
      );
      if (entry.phase != expected.phase ||
          entry.position != expected.position ||
          entry.persistenceAdapterPlanDigest !=
              expected.persistenceAdapterPlanDigest ||
          entry.runtimeServiceExposureDigest !=
              expected.runtimeServiceExposureDigest ||
          entry.transportAdapterSetDigest !=
              expected.transportAdapterSetDigest ||
          entry.eventCode != expected.eventCode ||
          entry.digest != expected.digest) {
        throw ArgumentError('Transport adapter log is invalid.');
      }
    }

    final payload = {
      'plannerVersion': transportAdapterPlannerVersion,
      'policyVersion': transportAdapterPlannerPolicyVersion,
      'persistenceAdapterPlanId': persistenceAdapterPlan.id,
      'persistenceAdapterPlanDigest': persistenceAdapterPlan.digest,
      'runtimeServiceExposureId': runtimeServiceExposure.id,
      'runtimeServiceExposureDigest': runtimeServiceExposure.digest,
      'entries': ordered.map((entry) => entry.toJson()).toList(),
      'log': orderedLog.map((entry) => entry.toJson()).toList(),
    };
    final digest = _digest(payload);
    return TransportAdapterPlan._(
      id: 'transport-adapter-plan.${digest.substring(0, 16)}',
      persistenceAdapterPlanId: persistenceAdapterPlan.id,
      persistenceAdapterPlanDigest: persistenceAdapterPlan.digest,
      runtimeServiceExposureId: runtimeServiceExposure.id,
      runtimeServiceExposureDigest: runtimeServiceExposure.digest,
      entries: List.unmodifiable(ordered),
      log: List.unmodifiable(orderedLog),
      digest: digest,
    );
  }

  final String id;
  final String persistenceAdapterPlanId;
  final String persistenceAdapterPlanDigest;
  final String runtimeServiceExposureId;
  final String runtimeServiceExposureDigest;
  final List<TransportAdapterEntry> entries;
  final List<TransportAdapterLogEntry> log;
  final String digest;

  Map<String, dynamic> toJson() => {
        'plannerVersion': transportAdapterPlannerVersion,
        'policyVersion': transportAdapterPlannerPolicyVersion,
        'id': id,
        'persistenceAdapterPlanId': persistenceAdapterPlanId,
        'persistenceAdapterPlanDigest': persistenceAdapterPlanDigest,
        'runtimeServiceExposureId': runtimeServiceExposureId,
        'runtimeServiceExposureDigest': runtimeServiceExposureDigest,
        'entries': entries.map((entry) => entry.toJson()).toList(),
        'log': log.map((entry) => entry.toJson()).toList(),
        'digest': digest,
      };
}

class TransportAdapterPlanner {
  const TransportAdapterPlanner();

  TransportAdapterPlan plan({
    required PersistenceAdapterPlan persistenceAdapterPlan,
    required RuntimeServiceExposureContract runtimeServiceExposure,
  }) {
    _validateInputs(
      persistenceAdapterPlan: persistenceAdapterPlan,
      runtimeServiceExposure: runtimeServiceExposure,
    );
    final entries = [
      for (final configurationEntry in persistenceAdapterPlan.entries)
        TransportAdapterEntry.create(
          featureId: configurationEntry.featureId,
          persistenceAdapterEntryId:
              configurationEntry.persistenceAdapterEntryId,
          position: configurationEntry.position,
          persistenceAdapterPlanDigest: persistenceAdapterPlan.digest,
          runtimeServiceExposureDigest: runtimeServiceExposure.digest,
        ),
    ]..sort((left, right) => left.position.compareTo(right.position));
    final transportAdapterSetDigest =
        _digest(entries.map((entry) => entry.toJson()).toList());
    return TransportAdapterPlan.create(
      persistenceAdapterPlan: persistenceAdapterPlan,
      runtimeServiceExposure: runtimeServiceExposure,
      entries: entries,
      log: [
        for (var position = 0;
            position < TransportAdapterLogPhase.values.length;
            position++)
          TransportAdapterLogEntry.create(
            phase: TransportAdapterLogPhase.values[position],
            position: position,
            persistenceAdapterPlanDigest: persistenceAdapterPlan.digest,
            runtimeServiceExposureDigest: runtimeServiceExposure.digest,
            transportAdapterSetDigest: transportAdapterSetDigest,
          ),
      ],
    );
  }
}

void _validateInputs({
  required PersistenceAdapterPlan persistenceAdapterPlan,
  required RuntimeServiceExposureContract runtimeServiceExposure,
}) {
  if (persistenceAdapterPlan.id.isEmpty ||
      persistenceAdapterPlan.digest.isEmpty ||
      persistenceAdapterPlan.entries.isEmpty ||
      runtimeServiceExposure.id.isEmpty ||
      runtimeServiceExposure.digest.isEmpty ||
      runtimeServiceExposure.entries.isEmpty) {
    throw ArgumentError('Transport adapter inputs are incomplete.');
  }
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
