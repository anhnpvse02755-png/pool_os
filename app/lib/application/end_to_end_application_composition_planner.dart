import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/application/production_startup_validation_planner.dart';
import 'package:pool_os/application/runtime_observability_integration_planner.dart';

const endToEndApplicationCompositionPlannerVersion = 1;
const endToEndApplicationCompositionPlannerPolicyVersion =
    'end-to-end-application-composition-planner/1.0.0';

enum EndToEndApplicationCompositionLogPhase {
  validateInputs,
  orderFeatures,
  bindStartupValidation,
  completed,
}

class EndToEndApplicationCompositionEntry {
  const EndToEndApplicationCompositionEntry._({
    required this.compositionEntryId,
    required this.observabilityIntegrationEntryId,
    required this.featureId,
    required this.position,
    required this.startupValidationPlanDigest,
    required this.observabilityIntegrationPlanDigest,
    required this.digest,
  });

  factory EndToEndApplicationCompositionEntry.create({
    required String observabilityIntegrationEntryId,
    required String featureId,
    required int position,
    required String startupValidationPlanDigest,
    required String observabilityIntegrationPlanDigest,
  }) {
    if (observabilityIntegrationEntryId.isEmpty ||
        featureId.isEmpty ||
        position < 0 ||
        startupValidationPlanDigest.isEmpty ||
        observabilityIntegrationPlanDigest.isEmpty) {
      throw ArgumentError(
        'End-to-end application composition entry is incomplete.',
      );
    }
    final compositionEntryId = 'end-to-end-composition.$featureId';
    final payload = {
      'compositionEntryId': compositionEntryId,
      'observabilityIntegrationEntryId': observabilityIntegrationEntryId,
      'featureId': featureId,
      'position': position,
      'startupValidationPlanDigest': startupValidationPlanDigest,
      'observabilityIntegrationPlanDigest': observabilityIntegrationPlanDigest,
    };
    return EndToEndApplicationCompositionEntry._(
      compositionEntryId: compositionEntryId,
      observabilityIntegrationEntryId: observabilityIntegrationEntryId,
      featureId: featureId,
      position: position,
      startupValidationPlanDigest: startupValidationPlanDigest,
      observabilityIntegrationPlanDigest: observabilityIntegrationPlanDigest,
      digest: _digest(payload),
    );
  }

  final String compositionEntryId;
  final String observabilityIntegrationEntryId;
  final String featureId;
  final int position;
  final String startupValidationPlanDigest;
  final String observabilityIntegrationPlanDigest;
  final String digest;

  Map<String, dynamic> toJson() => {
        'compositionEntryId': compositionEntryId,
        'observabilityIntegrationEntryId': observabilityIntegrationEntryId,
        'featureId': featureId,
        'position': position,
        'startupValidationPlanDigest': startupValidationPlanDigest,
        'observabilityIntegrationPlanDigest':
            observabilityIntegrationPlanDigest,
        'digest': digest,
      };
}

class EndToEndApplicationCompositionLogEntry {
  const EndToEndApplicationCompositionLogEntry._({
    required this.phase,
    required this.position,
    required this.startupValidationPlanDigest,
    required this.observabilityIntegrationPlanDigest,
    required this.compositionSetDigest,
    required this.eventCode,
    required this.digest,
  });

  factory EndToEndApplicationCompositionLogEntry.create({
    required EndToEndApplicationCompositionLogPhase phase,
    required int position,
    required String startupValidationPlanDigest,
    required String observabilityIntegrationPlanDigest,
    required String compositionSetDigest,
  }) {
    if (position < 0 ||
        startupValidationPlanDigest.isEmpty ||
        observabilityIntegrationPlanDigest.isEmpty ||
        compositionSetDigest.isEmpty) {
      throw ArgumentError(
          'End-to-end application composition log is incomplete.');
    }
    final eventCode = 'end-to-end-application-composition.${phase.name}';
    final payload = {
      'phase': phase.name,
      'position': position,
      'startupValidationPlanDigest': startupValidationPlanDigest,
      'observabilityIntegrationPlanDigest': observabilityIntegrationPlanDigest,
      'compositionSetDigest': compositionSetDigest,
      'eventCode': eventCode,
    };
    return EndToEndApplicationCompositionLogEntry._(
      phase: phase,
      position: position,
      startupValidationPlanDigest: startupValidationPlanDigest,
      observabilityIntegrationPlanDigest: observabilityIntegrationPlanDigest,
      compositionSetDigest: compositionSetDigest,
      eventCode: eventCode,
      digest: _digest(payload),
    );
  }

  final EndToEndApplicationCompositionLogPhase phase;
  final int position;
  final String startupValidationPlanDigest;
  final String observabilityIntegrationPlanDigest;
  final String compositionSetDigest;
  final String eventCode;
  final String digest;

  Map<String, dynamic> toJson() => {
        'phase': phase.name,
        'position': position,
        'startupValidationPlanDigest': startupValidationPlanDigest,
        'observabilityIntegrationPlanDigest':
            observabilityIntegrationPlanDigest,
        'compositionSetDigest': compositionSetDigest,
        'eventCode': eventCode,
        'digest': digest,
      };
}

class EndToEndApplicationCompositionPlan {
  const EndToEndApplicationCompositionPlan._({
    required this.id,
    required this.startupValidationPlanId,
    required this.startupValidationPlanDigest,
    required this.observabilityIntegrationPlanId,
    required this.observabilityIntegrationPlanDigest,
    required this.entries,
    required this.log,
    required this.digest,
  });

  factory EndToEndApplicationCompositionPlan.create({
    required ProductionStartupValidationPlan startupValidationPlan,
    required RuntimeObservabilityIntegrationPlan observabilityIntegrationPlan,
    required List<EndToEndApplicationCompositionEntry> entries,
    required List<EndToEndApplicationCompositionLogEntry> log,
  }) {
    _validateInputs(
      startupValidationPlan: startupValidationPlan,
      observabilityIntegrationPlan: observabilityIntegrationPlan,
    );
    if (entries.length != observabilityIntegrationPlan.entries.length) {
      throw ArgumentError(
        'End-to-end application composition coverage is incomplete.',
      );
    }
    final integrationByFeature = {
      for (final entry in observabilityIntegrationPlan.entries)
        entry.featureId: entry,
    };
    final ordered = [...entries]
      ..sort((left, right) => left.position.compareTo(right.position));
    final compositionIds = <String>{};
    final integrationIds = <String>{};
    final featureIds = <String>{};
    final positions = <int>{};
    for (var position = 0; position < ordered.length; position++) {
      final entry = ordered[position];
      final integration = integrationByFeature[entry.featureId];
      final expected = EndToEndApplicationCompositionEntry.create(
        observabilityIntegrationEntryId: entry.observabilityIntegrationEntryId,
        featureId: entry.featureId,
        position: position,
        startupValidationPlanDigest: startupValidationPlan.digest,
        observabilityIntegrationPlanDigest: observabilityIntegrationPlan.digest,
      );
      if (integration == null ||
          entry.position != position ||
          integration.position != position ||
          entry.observabilityIntegrationEntryId !=
              integration.integrationEntryId ||
          entry.startupValidationPlanDigest != startupValidationPlan.digest ||
          entry.observabilityIntegrationPlanDigest !=
              observabilityIntegrationPlan.digest ||
          entry.compositionEntryId != expected.compositionEntryId ||
          entry.digest != expected.digest ||
          !compositionIds.add(entry.compositionEntryId) ||
          !integrationIds.add(entry.observabilityIntegrationEntryId) ||
          !featureIds.add(entry.featureId) ||
          !positions.add(entry.position)) {
        throw ArgumentError(
          'End-to-end application composition provenance is invalid.',
        );
      }
    }

    final compositionSetDigest =
        _digest(ordered.map((entry) => entry.toJson()).toList());
    final orderedLog = [...log]
      ..sort((left, right) => left.position.compareTo(right.position));
    if (orderedLog.length !=
        EndToEndApplicationCompositionLogPhase.values.length) {
      throw ArgumentError(
          'End-to-end application composition log is incomplete.');
    }
    for (var position = 0; position < orderedLog.length; position++) {
      final entry = orderedLog[position];
      final expected = EndToEndApplicationCompositionLogEntry.create(
        phase: EndToEndApplicationCompositionLogPhase.values[position],
        position: position,
        startupValidationPlanDigest: startupValidationPlan.digest,
        observabilityIntegrationPlanDigest: observabilityIntegrationPlan.digest,
        compositionSetDigest: compositionSetDigest,
      );
      if (entry.phase != expected.phase ||
          entry.position != expected.position ||
          entry.startupValidationPlanDigest !=
              expected.startupValidationPlanDigest ||
          entry.observabilityIntegrationPlanDigest !=
              expected.observabilityIntegrationPlanDigest ||
          entry.compositionSetDigest != expected.compositionSetDigest ||
          entry.eventCode != expected.eventCode ||
          entry.digest != expected.digest) {
        throw ArgumentError(
            'End-to-end application composition log is invalid.');
      }
    }

    final payload = {
      'plannerVersion': endToEndApplicationCompositionPlannerVersion,
      'policyVersion': endToEndApplicationCompositionPlannerPolicyVersion,
      'startupValidationPlanId': startupValidationPlan.id,
      'startupValidationPlanDigest': startupValidationPlan.digest,
      'observabilityIntegrationPlanId': observabilityIntegrationPlan.id,
      'observabilityIntegrationPlanDigest': observabilityIntegrationPlan.digest,
      'entries': ordered.map((entry) => entry.toJson()).toList(),
      'log': orderedLog.map((entry) => entry.toJson()).toList(),
    };
    final digest = _digest(payload);
    return EndToEndApplicationCompositionPlan._(
      id: 'end-to-end-application-composition-plan.${digest.substring(0, 16)}',
      startupValidationPlanId: startupValidationPlan.id,
      startupValidationPlanDigest: startupValidationPlan.digest,
      observabilityIntegrationPlanId: observabilityIntegrationPlan.id,
      observabilityIntegrationPlanDigest: observabilityIntegrationPlan.digest,
      entries: List.unmodifiable(ordered),
      log: List.unmodifiable(orderedLog),
      digest: digest,
    );
  }

  final String id;
  final String startupValidationPlanId;
  final String startupValidationPlanDigest;
  final String observabilityIntegrationPlanId;
  final String observabilityIntegrationPlanDigest;
  final List<EndToEndApplicationCompositionEntry> entries;
  final List<EndToEndApplicationCompositionLogEntry> log;
  final String digest;

  Map<String, dynamic> toJson() => {
        'plannerVersion': endToEndApplicationCompositionPlannerVersion,
        'policyVersion': endToEndApplicationCompositionPlannerPolicyVersion,
        'id': id,
        'startupValidationPlanId': startupValidationPlanId,
        'startupValidationPlanDigest': startupValidationPlanDigest,
        'observabilityIntegrationPlanId': observabilityIntegrationPlanId,
        'observabilityIntegrationPlanDigest':
            observabilityIntegrationPlanDigest,
        'entries': entries.map((entry) => entry.toJson()).toList(),
        'log': log.map((entry) => entry.toJson()).toList(),
        'digest': digest,
      };
}

class EndToEndApplicationCompositionPlanner {
  const EndToEndApplicationCompositionPlanner();

  EndToEndApplicationCompositionPlan plan({
    required ProductionStartupValidationPlan startupValidationPlan,
    required RuntimeObservabilityIntegrationPlan observabilityIntegrationPlan,
  }) {
    _validateInputs(
      startupValidationPlan: startupValidationPlan,
      observabilityIntegrationPlan: observabilityIntegrationPlan,
    );
    final entries = [
      for (final integration in observabilityIntegrationPlan.entries)
        EndToEndApplicationCompositionEntry.create(
          observabilityIntegrationEntryId: integration.integrationEntryId,
          featureId: integration.featureId,
          position: integration.position,
          startupValidationPlanDigest: startupValidationPlan.digest,
          observabilityIntegrationPlanDigest:
              observabilityIntegrationPlan.digest,
        ),
    ]..sort((left, right) => left.position.compareTo(right.position));
    final compositionSetDigest =
        _digest(entries.map((entry) => entry.toJson()).toList());
    return EndToEndApplicationCompositionPlan.create(
      startupValidationPlan: startupValidationPlan,
      observabilityIntegrationPlan: observabilityIntegrationPlan,
      entries: entries,
      log: [
        for (var position = 0;
            position < EndToEndApplicationCompositionLogPhase.values.length;
            position++)
          EndToEndApplicationCompositionLogEntry.create(
            phase: EndToEndApplicationCompositionLogPhase.values[position],
            position: position,
            startupValidationPlanDigest: startupValidationPlan.digest,
            observabilityIntegrationPlanDigest:
                observabilityIntegrationPlan.digest,
            compositionSetDigest: compositionSetDigest,
          ),
      ],
    );
  }
}

void _validateInputs({
  required ProductionStartupValidationPlan startupValidationPlan,
  required RuntimeObservabilityIntegrationPlan observabilityIntegrationPlan,
}) {
  if (startupValidationPlan.entries.isEmpty ||
      observabilityIntegrationPlan.entries.isEmpty) {
    throw ArgumentError(
        'End-to-end application composition inputs are incomplete.');
  }
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
