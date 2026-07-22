import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/application/ai_provider_adapter_planner.dart';
import 'package:pool_os/contracts/runtime_health_diagnostics_projection_contracts.dart';

const observabilityAdapterPlannerVersion = 1;
const observabilityAdapterPlannerPolicyVersion =
    'observability-adapter-planner/1.0.0';

enum ObservabilityAdapterLogPhase {
  validateInputs,
  orderFeatures,
  bindHealthProvenance,
  completed,
}

class ObservabilityAdapterEntry {
  const ObservabilityAdapterEntry._({
    required this.observabilityAdapterEntryId,
    required this.featureId,
    required this.aiProviderAdapterEntryId,
    required this.position,
    required this.aiProviderAdapterPlanDigest,
    required this.runtimeHealthDiagnosticsProjectionDigest,
    required this.provenanceDigest,
    required this.digest,
  });

  factory ObservabilityAdapterEntry.create({
    required String featureId,
    required String aiProviderAdapterEntryId,
    required int position,
    required String aiProviderAdapterPlanDigest,
    required String runtimeHealthDiagnosticsProjectionDigest,
  }) {
    if (featureId.isEmpty ||
        aiProviderAdapterEntryId.isEmpty ||
        position < 0 ||
        aiProviderAdapterPlanDigest.isEmpty ||
        runtimeHealthDiagnosticsProjectionDigest.isEmpty) {
      throw ArgumentError('Observability adapter entry is incomplete.');
    }
    final observabilityAdapterEntryId = 'observability-adapter.$featureId';
    final provenanceDigest = _digest({
      'aiProviderAdapterPlanDigest': aiProviderAdapterPlanDigest,
      'runtimeHealthDiagnosticsProjectionDigest':
          runtimeHealthDiagnosticsProjectionDigest,
    });
    final payload = {
      'observabilityAdapterEntryId': observabilityAdapterEntryId,
      'featureId': featureId,
      'aiProviderAdapterEntryId': aiProviderAdapterEntryId,
      'position': position,
      'aiProviderAdapterPlanDigest': aiProviderAdapterPlanDigest,
      'runtimeHealthDiagnosticsProjectionDigest':
          runtimeHealthDiagnosticsProjectionDigest,
      'provenanceDigest': provenanceDigest,
    };
    return ObservabilityAdapterEntry._(
      observabilityAdapterEntryId: observabilityAdapterEntryId,
      featureId: featureId,
      aiProviderAdapterEntryId: aiProviderAdapterEntryId,
      position: position,
      aiProviderAdapterPlanDigest: aiProviderAdapterPlanDigest,
      runtimeHealthDiagnosticsProjectionDigest:
          runtimeHealthDiagnosticsProjectionDigest,
      provenanceDigest: provenanceDigest,
      digest: _digest(payload),
    );
  }

  final String observabilityAdapterEntryId;
  final String featureId;
  final String aiProviderAdapterEntryId;
  final int position;
  final String aiProviderAdapterPlanDigest;
  final String runtimeHealthDiagnosticsProjectionDigest;
  final String provenanceDigest;
  final String digest;

  Map<String, dynamic> toJson() => {
        'observabilityAdapterEntryId': observabilityAdapterEntryId,
        'featureId': featureId,
        'aiProviderAdapterEntryId': aiProviderAdapterEntryId,
        'position': position,
        'aiProviderAdapterPlanDigest': aiProviderAdapterPlanDigest,
        'runtimeHealthDiagnosticsProjectionDigest':
            runtimeHealthDiagnosticsProjectionDigest,
        'provenanceDigest': provenanceDigest,
        'digest': digest,
      };
}

class ObservabilityAdapterLogEntry {
  const ObservabilityAdapterLogEntry._({
    required this.phase,
    required this.position,
    required this.aiProviderAdapterPlanDigest,
    required this.runtimeHealthDiagnosticsProjectionDigest,
    required this.observabilityAdapterSetDigest,
    required this.eventCode,
    required this.digest,
  });

  factory ObservabilityAdapterLogEntry.create({
    required ObservabilityAdapterLogPhase phase,
    required int position,
    required String aiProviderAdapterPlanDigest,
    required String runtimeHealthDiagnosticsProjectionDigest,
    required String observabilityAdapterSetDigest,
  }) {
    if (position < 0 ||
        aiProviderAdapterPlanDigest.isEmpty ||
        runtimeHealthDiagnosticsProjectionDigest.isEmpty ||
        observabilityAdapterSetDigest.isEmpty) {
      throw ArgumentError('Observability adapter log is incomplete.');
    }
    final eventCode = 'observability-adapter.${phase.name}';
    final payload = {
      'phase': phase.name,
      'position': position,
      'aiProviderAdapterPlanDigest': aiProviderAdapterPlanDigest,
      'runtimeHealthDiagnosticsProjectionDigest':
          runtimeHealthDiagnosticsProjectionDigest,
      'observabilityAdapterSetDigest': observabilityAdapterSetDigest,
      'eventCode': eventCode,
    };
    return ObservabilityAdapterLogEntry._(
      phase: phase,
      position: position,
      aiProviderAdapterPlanDigest: aiProviderAdapterPlanDigest,
      runtimeHealthDiagnosticsProjectionDigest:
          runtimeHealthDiagnosticsProjectionDigest,
      observabilityAdapterSetDigest: observabilityAdapterSetDigest,
      eventCode: eventCode,
      digest: _digest(payload),
    );
  }

  final ObservabilityAdapterLogPhase phase;
  final int position;
  final String aiProviderAdapterPlanDigest;
  final String runtimeHealthDiagnosticsProjectionDigest;
  final String observabilityAdapterSetDigest;
  final String eventCode;
  final String digest;

  Map<String, dynamic> toJson() => {
        'phase': phase.name,
        'position': position,
        'aiProviderAdapterPlanDigest': aiProviderAdapterPlanDigest,
        'runtimeHealthDiagnosticsProjectionDigest':
            runtimeHealthDiagnosticsProjectionDigest,
        'observabilityAdapterSetDigest': observabilityAdapterSetDigest,
        'eventCode': eventCode,
        'digest': digest,
      };
}

class ObservabilityAdapterPlan {
  const ObservabilityAdapterPlan._({
    required this.id,
    required this.aiProviderAdapterPlanId,
    required this.aiProviderAdapterPlanDigest,
    required this.runtimeHealthDiagnosticsProjectionId,
    required this.runtimeHealthDiagnosticsProjectionDigest,
    required this.entries,
    required this.log,
    required this.digest,
  });

  factory ObservabilityAdapterPlan.create({
    required AIProviderAdapterPlan aiProviderAdapterPlan,
    required RuntimeHealthDiagnosticsProjectionContract
        runtimeHealthDiagnosticsProjection,
    required List<ObservabilityAdapterEntry> entries,
    required List<ObservabilityAdapterLogEntry> log,
  }) {
    _validateInputs(
      aiProviderAdapterPlan: aiProviderAdapterPlan,
      runtimeHealthDiagnosticsProjection: runtimeHealthDiagnosticsProjection,
    );
    if (entries.length != aiProviderAdapterPlan.entries.length) {
      throw ArgumentError('Observability adapter coverage is incomplete.');
    }
    final adapterByFeature = {
      for (final entry in aiProviderAdapterPlan.entries) entry.featureId: entry,
    };
    final ordered = [...entries]
      ..sort((left, right) => left.position.compareTo(right.position));
    final observabilityAdapterIds = <String>{};
    final featureIds = <String>{};
    final sourceAdapterIds = <String>{};
    final positions = <int>{};
    for (var position = 0; position < ordered.length; position++) {
      final entry = ordered[position];
      final adapterEntry = adapterByFeature[entry.featureId];
      final expected = ObservabilityAdapterEntry.create(
        featureId: entry.featureId,
        aiProviderAdapterEntryId: entry.aiProviderAdapterEntryId,
        position: position,
        aiProviderAdapterPlanDigest: aiProviderAdapterPlan.digest,
        runtimeHealthDiagnosticsProjectionDigest:
            runtimeHealthDiagnosticsProjection.digest,
      );
      if (adapterEntry == null ||
          adapterEntry.position != position ||
          entry.position != position ||
          entry.aiProviderAdapterEntryId !=
              adapterEntry.aiProviderAdapterEntryId ||
          entry.aiProviderAdapterPlanDigest != aiProviderAdapterPlan.digest ||
          entry.runtimeHealthDiagnosticsProjectionDigest !=
              runtimeHealthDiagnosticsProjection.digest ||
          entry.observabilityAdapterEntryId !=
              expected.observabilityAdapterEntryId ||
          entry.provenanceDigest != expected.provenanceDigest ||
          entry.digest != expected.digest ||
          !observabilityAdapterIds.add(entry.observabilityAdapterEntryId) ||
          !featureIds.add(entry.featureId) ||
          !sourceAdapterIds.add(entry.aiProviderAdapterEntryId) ||
          !positions.add(entry.position)) {
        throw ArgumentError('Observability adapter provenance is invalid.');
      }
    }

    final observabilityAdapterSetDigest =
        _digest(ordered.map((entry) => entry.toJson()).toList());
    final orderedLog = [...log]
      ..sort((left, right) => left.position.compareTo(right.position));
    if (orderedLog.length != ObservabilityAdapterLogPhase.values.length) {
      throw ArgumentError('Observability adapter log is incomplete.');
    }
    for (var position = 0; position < orderedLog.length; position++) {
      final entry = orderedLog[position];
      final expected = ObservabilityAdapterLogEntry.create(
        phase: ObservabilityAdapterLogPhase.values[position],
        position: position,
        aiProviderAdapterPlanDigest: aiProviderAdapterPlan.digest,
        runtimeHealthDiagnosticsProjectionDigest:
            runtimeHealthDiagnosticsProjection.digest,
        observabilityAdapterSetDigest: observabilityAdapterSetDigest,
      );
      if (entry.phase != expected.phase ||
          entry.position != expected.position ||
          entry.aiProviderAdapterPlanDigest !=
              expected.aiProviderAdapterPlanDigest ||
          entry.runtimeHealthDiagnosticsProjectionDigest !=
              expected.runtimeHealthDiagnosticsProjectionDigest ||
          entry.observabilityAdapterSetDigest !=
              expected.observabilityAdapterSetDigest ||
          entry.eventCode != expected.eventCode ||
          entry.digest != expected.digest) {
        throw ArgumentError('Observability adapter log is invalid.');
      }
    }

    final payload = {
      'plannerVersion': observabilityAdapterPlannerVersion,
      'policyVersion': observabilityAdapterPlannerPolicyVersion,
      'aiProviderAdapterPlanId': aiProviderAdapterPlan.id,
      'aiProviderAdapterPlanDigest': aiProviderAdapterPlan.digest,
      'runtimeHealthDiagnosticsProjectionId':
          runtimeHealthDiagnosticsProjection.id,
      'runtimeHealthDiagnosticsProjectionDigest':
          runtimeHealthDiagnosticsProjection.digest,
      'entries': ordered.map((entry) => entry.toJson()).toList(),
      'log': orderedLog.map((entry) => entry.toJson()).toList(),
    };
    final digest = _digest(payload);
    return ObservabilityAdapterPlan._(
      id: 'observability-adapter-plan.${digest.substring(0, 16)}',
      aiProviderAdapterPlanId: aiProviderAdapterPlan.id,
      aiProviderAdapterPlanDigest: aiProviderAdapterPlan.digest,
      runtimeHealthDiagnosticsProjectionId:
          runtimeHealthDiagnosticsProjection.id,
      runtimeHealthDiagnosticsProjectionDigest:
          runtimeHealthDiagnosticsProjection.digest,
      entries: List.unmodifiable(ordered),
      log: List.unmodifiable(orderedLog),
      digest: digest,
    );
  }

  final String id;
  final String aiProviderAdapterPlanId;
  final String aiProviderAdapterPlanDigest;
  final String runtimeHealthDiagnosticsProjectionId;
  final String runtimeHealthDiagnosticsProjectionDigest;
  final List<ObservabilityAdapterEntry> entries;
  final List<ObservabilityAdapterLogEntry> log;
  final String digest;

  Map<String, dynamic> toJson() => {
        'plannerVersion': observabilityAdapterPlannerVersion,
        'policyVersion': observabilityAdapterPlannerPolicyVersion,
        'id': id,
        'aiProviderAdapterPlanId': aiProviderAdapterPlanId,
        'aiProviderAdapterPlanDigest': aiProviderAdapterPlanDigest,
        'runtimeHealthDiagnosticsProjectionId':
            runtimeHealthDiagnosticsProjectionId,
        'runtimeHealthDiagnosticsProjectionDigest':
            runtimeHealthDiagnosticsProjectionDigest,
        'entries': entries.map((entry) => entry.toJson()).toList(),
        'log': log.map((entry) => entry.toJson()).toList(),
        'digest': digest,
      };
}

class ObservabilityAdapterPlanner {
  const ObservabilityAdapterPlanner();

  ObservabilityAdapterPlan plan({
    required AIProviderAdapterPlan aiProviderAdapterPlan,
    required RuntimeHealthDiagnosticsProjectionContract
        runtimeHealthDiagnosticsProjection,
  }) {
    _validateInputs(
      aiProviderAdapterPlan: aiProviderAdapterPlan,
      runtimeHealthDiagnosticsProjection: runtimeHealthDiagnosticsProjection,
    );
    final entries = [
      for (final adapterEntry in aiProviderAdapterPlan.entries)
        ObservabilityAdapterEntry.create(
          featureId: adapterEntry.featureId,
          aiProviderAdapterEntryId: adapterEntry.aiProviderAdapterEntryId,
          position: adapterEntry.position,
          aiProviderAdapterPlanDigest: aiProviderAdapterPlan.digest,
          runtimeHealthDiagnosticsProjectionDigest:
              runtimeHealthDiagnosticsProjection.digest,
        ),
    ]..sort((left, right) => left.position.compareTo(right.position));
    final observabilityAdapterSetDigest =
        _digest(entries.map((entry) => entry.toJson()).toList());
    return ObservabilityAdapterPlan.create(
      aiProviderAdapterPlan: aiProviderAdapterPlan,
      runtimeHealthDiagnosticsProjection: runtimeHealthDiagnosticsProjection,
      entries: entries,
      log: [
        for (var position = 0;
            position < ObservabilityAdapterLogPhase.values.length;
            position++)
          ObservabilityAdapterLogEntry.create(
            phase: ObservabilityAdapterLogPhase.values[position],
            position: position,
            aiProviderAdapterPlanDigest: aiProviderAdapterPlan.digest,
            runtimeHealthDiagnosticsProjectionDigest:
                runtimeHealthDiagnosticsProjection.digest,
            observabilityAdapterSetDigest: observabilityAdapterSetDigest,
          ),
      ],
    );
  }
}

void _validateInputs({
  required AIProviderAdapterPlan aiProviderAdapterPlan,
  required RuntimeHealthDiagnosticsProjectionContract
      runtimeHealthDiagnosticsProjection,
}) {
  if (aiProviderAdapterPlan.id.isEmpty ||
      aiProviderAdapterPlan.digest.isEmpty ||
      aiProviderAdapterPlan.entries.isEmpty ||
      runtimeHealthDiagnosticsProjection.id.isEmpty ||
      runtimeHealthDiagnosticsProjection.digest.isEmpty ||
      runtimeHealthDiagnosticsProjection.entries.isEmpty) {
    throw ArgumentError('Observability adapter inputs are incomplete.');
  }
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
