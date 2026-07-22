import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/application/configuration_adapter_planner.dart';
import 'package:pool_os/contracts/runtime_delivery_projection_contracts.dart';

const persistenceAdapterPlannerVersion = 1;
const persistenceAdapterPlannerPolicyVersion =
    'persistence-adapter-planner/1.0.0';

enum PersistenceAdapterLogPhase {
  validateInputs,
  orderFeatures,
  bindPersistenceProvenance,
  completed,
}

class PersistenceAdapterEntry {
  const PersistenceAdapterEntry._({
    required this.persistenceAdapterEntryId,
    required this.featureId,
    required this.configurationAdapterEntryId,
    required this.position,
    required this.configurationAdapterPlanDigest,
    required this.runtimeDeliveryProjectionDigest,
    required this.provenanceDigest,
    required this.digest,
  });

  factory PersistenceAdapterEntry.create({
    required String featureId,
    required String configurationAdapterEntryId,
    required int position,
    required String configurationAdapterPlanDigest,
    required String runtimeDeliveryProjectionDigest,
  }) {
    if (featureId.isEmpty ||
        configurationAdapterEntryId.isEmpty ||
        position < 0 ||
        configurationAdapterPlanDigest.isEmpty ||
        runtimeDeliveryProjectionDigest.isEmpty) {
      throw ArgumentError('Persistence adapter entry is incomplete.');
    }
    final persistenceAdapterEntryId = 'persistence-adapter.$featureId';
    final provenanceDigest = _digest({
      'configurationAdapterPlanDigest': configurationAdapterPlanDigest,
      'runtimeDeliveryProjectionDigest': runtimeDeliveryProjectionDigest,
    });
    final payload = {
      'persistenceAdapterEntryId': persistenceAdapterEntryId,
      'featureId': featureId,
      'configurationAdapterEntryId': configurationAdapterEntryId,
      'position': position,
      'configurationAdapterPlanDigest': configurationAdapterPlanDigest,
      'runtimeDeliveryProjectionDigest': runtimeDeliveryProjectionDigest,
      'provenanceDigest': provenanceDigest,
    };
    return PersistenceAdapterEntry._(
      persistenceAdapterEntryId: persistenceAdapterEntryId,
      featureId: featureId,
      configurationAdapterEntryId: configurationAdapterEntryId,
      position: position,
      configurationAdapterPlanDigest: configurationAdapterPlanDigest,
      runtimeDeliveryProjectionDigest: runtimeDeliveryProjectionDigest,
      provenanceDigest: provenanceDigest,
      digest: _digest(payload),
    );
  }

  final String persistenceAdapterEntryId;
  final String featureId;
  final String configurationAdapterEntryId;
  final int position;
  final String configurationAdapterPlanDigest;
  final String runtimeDeliveryProjectionDigest;
  final String provenanceDigest;
  final String digest;

  Map<String, dynamic> toJson() => {
        'persistenceAdapterEntryId': persistenceAdapterEntryId,
        'featureId': featureId,
        'configurationAdapterEntryId': configurationAdapterEntryId,
        'position': position,
        'configurationAdapterPlanDigest': configurationAdapterPlanDigest,
        'runtimeDeliveryProjectionDigest': runtimeDeliveryProjectionDigest,
        'provenanceDigest': provenanceDigest,
        'digest': digest,
      };
}

class PersistenceAdapterLogEntry {
  const PersistenceAdapterLogEntry._({
    required this.phase,
    required this.position,
    required this.configurationAdapterPlanDigest,
    required this.runtimeDeliveryProjectionDigest,
    required this.persistenceAdapterSetDigest,
    required this.eventCode,
    required this.digest,
  });

  factory PersistenceAdapterLogEntry.create({
    required PersistenceAdapterLogPhase phase,
    required int position,
    required String configurationAdapterPlanDigest,
    required String runtimeDeliveryProjectionDigest,
    required String persistenceAdapterSetDigest,
  }) {
    if (position < 0 ||
        configurationAdapterPlanDigest.isEmpty ||
        runtimeDeliveryProjectionDigest.isEmpty ||
        persistenceAdapterSetDigest.isEmpty) {
      throw ArgumentError('Persistence adapter log is incomplete.');
    }
    final eventCode = 'persistence-adapter.${phase.name}';
    final payload = {
      'phase': phase.name,
      'position': position,
      'configurationAdapterPlanDigest': configurationAdapterPlanDigest,
      'runtimeDeliveryProjectionDigest': runtimeDeliveryProjectionDigest,
      'persistenceAdapterSetDigest': persistenceAdapterSetDigest,
      'eventCode': eventCode,
    };
    return PersistenceAdapterLogEntry._(
      phase: phase,
      position: position,
      configurationAdapterPlanDigest: configurationAdapterPlanDigest,
      runtimeDeliveryProjectionDigest: runtimeDeliveryProjectionDigest,
      persistenceAdapterSetDigest: persistenceAdapterSetDigest,
      eventCode: eventCode,
      digest: _digest(payload),
    );
  }

  final PersistenceAdapterLogPhase phase;
  final int position;
  final String configurationAdapterPlanDigest;
  final String runtimeDeliveryProjectionDigest;
  final String persistenceAdapterSetDigest;
  final String eventCode;
  final String digest;

  Map<String, dynamic> toJson() => {
        'phase': phase.name,
        'position': position,
        'configurationAdapterPlanDigest': configurationAdapterPlanDigest,
        'runtimeDeliveryProjectionDigest': runtimeDeliveryProjectionDigest,
        'persistenceAdapterSetDigest': persistenceAdapterSetDigest,
        'eventCode': eventCode,
        'digest': digest,
      };
}

class PersistenceAdapterPlan {
  const PersistenceAdapterPlan._({
    required this.id,
    required this.configurationAdapterPlanId,
    required this.configurationAdapterPlanDigest,
    required this.runtimeDeliveryProjectionId,
    required this.runtimeDeliveryProjectionDigest,
    required this.entries,
    required this.log,
    required this.digest,
  });

  factory PersistenceAdapterPlan.create({
    required ConfigurationAdapterPlan configurationAdapterPlan,
    required RuntimeDeliveryProjectionContract runtimeDeliveryProjection,
    required List<PersistenceAdapterEntry> entries,
    required List<PersistenceAdapterLogEntry> log,
  }) {
    _validateInputs(
      configurationAdapterPlan: configurationAdapterPlan,
      runtimeDeliveryProjection: runtimeDeliveryProjection,
    );
    if (entries.length != configurationAdapterPlan.entries.length) {
      throw ArgumentError('Persistence adapter coverage is incomplete.');
    }
    final configurationByFeature = {
      for (final entry in configurationAdapterPlan.entries)
        entry.featureId: entry,
    };
    final ordered = [...entries]
      ..sort((left, right) => left.position.compareTo(right.position));
    final persistenceAdapterIds = <String>{};
    final featureIds = <String>{};
    final configurationAdapterIds = <String>{};
    final positions = <int>{};
    for (var position = 0; position < ordered.length; position++) {
      final entry = ordered[position];
      final configurationEntry = configurationByFeature[entry.featureId];
      final expected = PersistenceAdapterEntry.create(
        featureId: entry.featureId,
        configurationAdapterEntryId: entry.configurationAdapterEntryId,
        position: position,
        configurationAdapterPlanDigest: configurationAdapterPlan.digest,
        runtimeDeliveryProjectionDigest: runtimeDeliveryProjection.digest,
      );
      if (configurationEntry == null ||
          configurationEntry.position != position ||
          entry.position != position ||
          entry.configurationAdapterEntryId !=
              configurationEntry.configurationAdapterEntryId ||
          entry.configurationAdapterPlanDigest !=
              configurationAdapterPlan.digest ||
          entry.runtimeDeliveryProjectionDigest !=
              runtimeDeliveryProjection.digest ||
          entry.persistenceAdapterEntryId !=
              expected.persistenceAdapterEntryId ||
          entry.provenanceDigest != expected.provenanceDigest ||
          entry.digest != expected.digest ||
          !persistenceAdapterIds.add(entry.persistenceAdapterEntryId) ||
          !featureIds.add(entry.featureId) ||
          !configurationAdapterIds.add(entry.configurationAdapterEntryId) ||
          !positions.add(entry.position)) {
        throw ArgumentError('Persistence adapter provenance is invalid.');
      }
    }

    final persistenceAdapterSetDigest =
        _digest(ordered.map((entry) => entry.toJson()).toList());
    final orderedLog = [...log]
      ..sort((left, right) => left.position.compareTo(right.position));
    if (orderedLog.length != PersistenceAdapterLogPhase.values.length) {
      throw ArgumentError('Persistence adapter log is incomplete.');
    }
    for (var position = 0; position < orderedLog.length; position++) {
      final entry = orderedLog[position];
      final expected = PersistenceAdapterLogEntry.create(
        phase: PersistenceAdapterLogPhase.values[position],
        position: position,
        configurationAdapterPlanDigest: configurationAdapterPlan.digest,
        runtimeDeliveryProjectionDigest: runtimeDeliveryProjection.digest,
        persistenceAdapterSetDigest: persistenceAdapterSetDigest,
      );
      if (entry.phase != expected.phase ||
          entry.position != expected.position ||
          entry.configurationAdapterPlanDigest !=
              expected.configurationAdapterPlanDigest ||
          entry.runtimeDeliveryProjectionDigest !=
              expected.runtimeDeliveryProjectionDigest ||
          entry.persistenceAdapterSetDigest !=
              expected.persistenceAdapterSetDigest ||
          entry.eventCode != expected.eventCode ||
          entry.digest != expected.digest) {
        throw ArgumentError('Persistence adapter log is invalid.');
      }
    }

    final payload = {
      'plannerVersion': persistenceAdapterPlannerVersion,
      'policyVersion': persistenceAdapterPlannerPolicyVersion,
      'configurationAdapterPlanId': configurationAdapterPlan.id,
      'configurationAdapterPlanDigest': configurationAdapterPlan.digest,
      'runtimeDeliveryProjectionId': runtimeDeliveryProjection.id,
      'runtimeDeliveryProjectionDigest': runtimeDeliveryProjection.digest,
      'entries': ordered.map((entry) => entry.toJson()).toList(),
      'log': orderedLog.map((entry) => entry.toJson()).toList(),
    };
    final digest = _digest(payload);
    return PersistenceAdapterPlan._(
      id: 'persistence-adapter-plan.${digest.substring(0, 16)}',
      configurationAdapterPlanId: configurationAdapterPlan.id,
      configurationAdapterPlanDigest: configurationAdapterPlan.digest,
      runtimeDeliveryProjectionId: runtimeDeliveryProjection.id,
      runtimeDeliveryProjectionDigest: runtimeDeliveryProjection.digest,
      entries: List.unmodifiable(ordered),
      log: List.unmodifiable(orderedLog),
      digest: digest,
    );
  }

  final String id;
  final String configurationAdapterPlanId;
  final String configurationAdapterPlanDigest;
  final String runtimeDeliveryProjectionId;
  final String runtimeDeliveryProjectionDigest;
  final List<PersistenceAdapterEntry> entries;
  final List<PersistenceAdapterLogEntry> log;
  final String digest;

  Map<String, dynamic> toJson() => {
        'plannerVersion': persistenceAdapterPlannerVersion,
        'policyVersion': persistenceAdapterPlannerPolicyVersion,
        'id': id,
        'configurationAdapterPlanId': configurationAdapterPlanId,
        'configurationAdapterPlanDigest': configurationAdapterPlanDigest,
        'runtimeDeliveryProjectionId': runtimeDeliveryProjectionId,
        'runtimeDeliveryProjectionDigest': runtimeDeliveryProjectionDigest,
        'entries': entries.map((entry) => entry.toJson()).toList(),
        'log': log.map((entry) => entry.toJson()).toList(),
        'digest': digest,
      };
}

class PersistenceAdapterPlanner {
  const PersistenceAdapterPlanner();

  PersistenceAdapterPlan plan({
    required ConfigurationAdapterPlan configurationAdapterPlan,
    required RuntimeDeliveryProjectionContract runtimeDeliveryProjection,
  }) {
    _validateInputs(
      configurationAdapterPlan: configurationAdapterPlan,
      runtimeDeliveryProjection: runtimeDeliveryProjection,
    );
    final entries = [
      for (final configurationEntry in configurationAdapterPlan.entries)
        PersistenceAdapterEntry.create(
          featureId: configurationEntry.featureId,
          configurationAdapterEntryId:
              configurationEntry.configurationAdapterEntryId,
          position: configurationEntry.position,
          configurationAdapterPlanDigest: configurationAdapterPlan.digest,
          runtimeDeliveryProjectionDigest: runtimeDeliveryProjection.digest,
        ),
    ]..sort((left, right) => left.position.compareTo(right.position));
    final persistenceAdapterSetDigest =
        _digest(entries.map((entry) => entry.toJson()).toList());
    return PersistenceAdapterPlan.create(
      configurationAdapterPlan: configurationAdapterPlan,
      runtimeDeliveryProjection: runtimeDeliveryProjection,
      entries: entries,
      log: [
        for (var position = 0;
            position < PersistenceAdapterLogPhase.values.length;
            position++)
          PersistenceAdapterLogEntry.create(
            phase: PersistenceAdapterLogPhase.values[position],
            position: position,
            configurationAdapterPlanDigest: configurationAdapterPlan.digest,
            runtimeDeliveryProjectionDigest: runtimeDeliveryProjection.digest,
            persistenceAdapterSetDigest: persistenceAdapterSetDigest,
          ),
      ],
    );
  }
}

void _validateInputs({
  required ConfigurationAdapterPlan configurationAdapterPlan,
  required RuntimeDeliveryProjectionContract runtimeDeliveryProjection,
}) {
  if (configurationAdapterPlan.id.isEmpty ||
      configurationAdapterPlan.digest.isEmpty ||
      configurationAdapterPlan.entries.isEmpty ||
      runtimeDeliveryProjection.id.isEmpty ||
      runtimeDeliveryProjection.digest.isEmpty ||
      runtimeDeliveryProjection.entries.isEmpty) {
    throw ArgumentError('Persistence adapter inputs are incomplete.');
  }
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
