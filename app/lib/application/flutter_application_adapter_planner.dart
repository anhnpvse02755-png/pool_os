import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/application/application_bootstrap_host.dart';
import 'package:pool_os/application/end_to_end_application_composition_planner.dart';

const flutterApplicationAdapterPlannerVersion = 1;
const flutterApplicationAdapterPlannerPolicyVersion =
    'flutter-application-adapter-planner/1.0.0';

enum FlutterApplicationAdapterLogPhase {
  validateInputs,
  orderFeatures,
  bindBootstrapHost,
  completed,
}

class FlutterApplicationAdapterEntry {
  const FlutterApplicationAdapterEntry._({
    required this.adapterEntryId,
    required this.featureId,
    required this.compositionEntryId,
    required this.position,
    required this.applicationCompositionPlanDigest,
    required this.bootstrapHostRunDigest,
    required this.provenanceDigest,
    required this.digest,
  });

  factory FlutterApplicationAdapterEntry.create({
    required String featureId,
    required String compositionEntryId,
    required int position,
    required String applicationCompositionPlanDigest,
    required String bootstrapHostRunDigest,
  }) {
    if (featureId.isEmpty ||
        compositionEntryId.isEmpty ||
        position < 0 ||
        applicationCompositionPlanDigest.isEmpty ||
        bootstrapHostRunDigest.isEmpty) {
      throw ArgumentError('Flutter application adapter entry is incomplete.');
    }
    final adapterEntryId = 'flutter-application-adapter.$featureId';
    final provenanceDigest = _digest({
      'applicationCompositionPlanDigest': applicationCompositionPlanDigest,
      'bootstrapHostRunDigest': bootstrapHostRunDigest,
    });
    final payload = {
      'adapterEntryId': adapterEntryId,
      'featureId': featureId,
      'compositionEntryId': compositionEntryId,
      'position': position,
      'applicationCompositionPlanDigest': applicationCompositionPlanDigest,
      'bootstrapHostRunDigest': bootstrapHostRunDigest,
      'provenanceDigest': provenanceDigest,
    };
    return FlutterApplicationAdapterEntry._(
      adapterEntryId: adapterEntryId,
      featureId: featureId,
      compositionEntryId: compositionEntryId,
      position: position,
      applicationCompositionPlanDigest: applicationCompositionPlanDigest,
      bootstrapHostRunDigest: bootstrapHostRunDigest,
      provenanceDigest: provenanceDigest,
      digest: _digest(payload),
    );
  }

  final String adapterEntryId;
  final String featureId;
  final String compositionEntryId;
  final int position;
  final String applicationCompositionPlanDigest;
  final String bootstrapHostRunDigest;
  final String provenanceDigest;
  final String digest;

  Map<String, dynamic> toJson() => {
        'adapterEntryId': adapterEntryId,
        'featureId': featureId,
        'compositionEntryId': compositionEntryId,
        'position': position,
        'applicationCompositionPlanDigest': applicationCompositionPlanDigest,
        'bootstrapHostRunDigest': bootstrapHostRunDigest,
        'provenanceDigest': provenanceDigest,
        'digest': digest,
      };
}

class FlutterApplicationAdapterLogEntry {
  const FlutterApplicationAdapterLogEntry._({
    required this.phase,
    required this.position,
    required this.applicationCompositionPlanDigest,
    required this.bootstrapHostRunDigest,
    required this.adapterSetDigest,
    required this.eventCode,
    required this.digest,
  });

  factory FlutterApplicationAdapterLogEntry.create({
    required FlutterApplicationAdapterLogPhase phase,
    required int position,
    required String applicationCompositionPlanDigest,
    required String bootstrapHostRunDigest,
    required String adapterSetDigest,
  }) {
    if (position < 0 ||
        applicationCompositionPlanDigest.isEmpty ||
        bootstrapHostRunDigest.isEmpty ||
        adapterSetDigest.isEmpty) {
      throw ArgumentError('Flutter application adapter log is incomplete.');
    }
    final eventCode = 'flutter-application-adapter.${phase.name}';
    final payload = {
      'phase': phase.name,
      'position': position,
      'applicationCompositionPlanDigest': applicationCompositionPlanDigest,
      'bootstrapHostRunDigest': bootstrapHostRunDigest,
      'adapterSetDigest': adapterSetDigest,
      'eventCode': eventCode,
    };
    return FlutterApplicationAdapterLogEntry._(
      phase: phase,
      position: position,
      applicationCompositionPlanDigest: applicationCompositionPlanDigest,
      bootstrapHostRunDigest: bootstrapHostRunDigest,
      adapterSetDigest: adapterSetDigest,
      eventCode: eventCode,
      digest: _digest(payload),
    );
  }

  final FlutterApplicationAdapterLogPhase phase;
  final int position;
  final String applicationCompositionPlanDigest;
  final String bootstrapHostRunDigest;
  final String adapterSetDigest;
  final String eventCode;
  final String digest;

  Map<String, dynamic> toJson() => {
        'phase': phase.name,
        'position': position,
        'applicationCompositionPlanDigest': applicationCompositionPlanDigest,
        'bootstrapHostRunDigest': bootstrapHostRunDigest,
        'adapterSetDigest': adapterSetDigest,
        'eventCode': eventCode,
        'digest': digest,
      };
}

class FlutterApplicationAdapterPlan {
  const FlutterApplicationAdapterPlan._({
    required this.id,
    required this.applicationCompositionPlanId,
    required this.applicationCompositionPlanDigest,
    required this.bootstrapHostRunId,
    required this.bootstrapHostRunDigest,
    required this.entries,
    required this.log,
    required this.digest,
  });

  factory FlutterApplicationAdapterPlan.create({
    required EndToEndApplicationCompositionPlan applicationCompositionPlan,
    required ApplicationBootstrapHostRun bootstrapHostRun,
    required List<FlutterApplicationAdapterEntry> entries,
    required List<FlutterApplicationAdapterLogEntry> log,
  }) {
    _validateInputs(
      applicationCompositionPlan: applicationCompositionPlan,
      bootstrapHostRun: bootstrapHostRun,
    );
    if (entries.length != applicationCompositionPlan.entries.length) {
      throw ArgumentError(
          'Flutter application adapter coverage is incomplete.');
    }
    final compositionByFeature = {
      for (final entry in applicationCompositionPlan.entries)
        entry.featureId: entry,
    };
    final ordered = [...entries]
      ..sort((left, right) => left.position.compareTo(right.position));
    final adapterIds = <String>{};
    final featureIds = <String>{};
    final compositionIds = <String>{};
    final positions = <int>{};
    for (var position = 0; position < ordered.length; position++) {
      final entry = ordered[position];
      final composition = compositionByFeature[entry.featureId];
      final expected = FlutterApplicationAdapterEntry.create(
        featureId: entry.featureId,
        compositionEntryId: entry.compositionEntryId,
        position: position,
        applicationCompositionPlanDigest: applicationCompositionPlan.digest,
        bootstrapHostRunDigest: bootstrapHostRun.digest,
      );
      if (composition == null ||
          composition.position != position ||
          entry.position != position ||
          entry.compositionEntryId != composition.compositionEntryId ||
          entry.applicationCompositionPlanDigest !=
              applicationCompositionPlan.digest ||
          entry.bootstrapHostRunDigest != bootstrapHostRun.digest ||
          entry.adapterEntryId != expected.adapterEntryId ||
          entry.provenanceDigest != expected.provenanceDigest ||
          entry.digest != expected.digest ||
          !adapterIds.add(entry.adapterEntryId) ||
          !featureIds.add(entry.featureId) ||
          !compositionIds.add(entry.compositionEntryId) ||
          !positions.add(entry.position)) {
        throw ArgumentError(
            'Flutter application adapter provenance is invalid.');
      }
    }

    final adapterSetDigest =
        _digest(ordered.map((entry) => entry.toJson()).toList());
    final orderedLog = [...log]
      ..sort((left, right) => left.position.compareTo(right.position));
    if (orderedLog.length != FlutterApplicationAdapterLogPhase.values.length) {
      throw ArgumentError('Flutter application adapter log is incomplete.');
    }
    for (var position = 0; position < orderedLog.length; position++) {
      final entry = orderedLog[position];
      final expected = FlutterApplicationAdapterLogEntry.create(
        phase: FlutterApplicationAdapterLogPhase.values[position],
        position: position,
        applicationCompositionPlanDigest: applicationCompositionPlan.digest,
        bootstrapHostRunDigest: bootstrapHostRun.digest,
        adapterSetDigest: adapterSetDigest,
      );
      if (entry.phase != expected.phase ||
          entry.position != expected.position ||
          entry.applicationCompositionPlanDigest !=
              expected.applicationCompositionPlanDigest ||
          entry.bootstrapHostRunDigest != expected.bootstrapHostRunDigest ||
          entry.adapterSetDigest != expected.adapterSetDigest ||
          entry.eventCode != expected.eventCode ||
          entry.digest != expected.digest) {
        throw ArgumentError('Flutter application adapter log is invalid.');
      }
    }

    final payload = {
      'plannerVersion': flutterApplicationAdapterPlannerVersion,
      'policyVersion': flutterApplicationAdapterPlannerPolicyVersion,
      'applicationCompositionPlanId': applicationCompositionPlan.id,
      'applicationCompositionPlanDigest': applicationCompositionPlan.digest,
      'bootstrapHostRunId': bootstrapHostRun.id,
      'bootstrapHostRunDigest': bootstrapHostRun.digest,
      'entries': ordered.map((entry) => entry.toJson()).toList(),
      'log': orderedLog.map((entry) => entry.toJson()).toList(),
    };
    final digest = _digest(payload);
    return FlutterApplicationAdapterPlan._(
      id: 'flutter-application-adapter-plan.${digest.substring(0, 16)}',
      applicationCompositionPlanId: applicationCompositionPlan.id,
      applicationCompositionPlanDigest: applicationCompositionPlan.digest,
      bootstrapHostRunId: bootstrapHostRun.id,
      bootstrapHostRunDigest: bootstrapHostRun.digest,
      entries: List.unmodifiable(ordered),
      log: List.unmodifiable(orderedLog),
      digest: digest,
    );
  }

  final String id;
  final String applicationCompositionPlanId;
  final String applicationCompositionPlanDigest;
  final String bootstrapHostRunId;
  final String bootstrapHostRunDigest;
  final List<FlutterApplicationAdapterEntry> entries;
  final List<FlutterApplicationAdapterLogEntry> log;
  final String digest;

  Map<String, dynamic> toJson() => {
        'plannerVersion': flutterApplicationAdapterPlannerVersion,
        'policyVersion': flutterApplicationAdapterPlannerPolicyVersion,
        'id': id,
        'applicationCompositionPlanId': applicationCompositionPlanId,
        'applicationCompositionPlanDigest': applicationCompositionPlanDigest,
        'bootstrapHostRunId': bootstrapHostRunId,
        'bootstrapHostRunDigest': bootstrapHostRunDigest,
        'entries': entries.map((entry) => entry.toJson()).toList(),
        'log': log.map((entry) => entry.toJson()).toList(),
        'digest': digest,
      };
}

class FlutterApplicationAdapterPlanner {
  const FlutterApplicationAdapterPlanner();

  FlutterApplicationAdapterPlan plan({
    required EndToEndApplicationCompositionPlan applicationCompositionPlan,
    required ApplicationBootstrapHostRun bootstrapHostRun,
  }) {
    _validateInputs(
      applicationCompositionPlan: applicationCompositionPlan,
      bootstrapHostRun: bootstrapHostRun,
    );
    final entries = [
      for (final composition in applicationCompositionPlan.entries)
        FlutterApplicationAdapterEntry.create(
          featureId: composition.featureId,
          compositionEntryId: composition.compositionEntryId,
          position: composition.position,
          applicationCompositionPlanDigest: applicationCompositionPlan.digest,
          bootstrapHostRunDigest: bootstrapHostRun.digest,
        ),
    ]..sort((left, right) => left.position.compareTo(right.position));
    final adapterSetDigest =
        _digest(entries.map((entry) => entry.toJson()).toList());
    return FlutterApplicationAdapterPlan.create(
      applicationCompositionPlan: applicationCompositionPlan,
      bootstrapHostRun: bootstrapHostRun,
      entries: entries,
      log: [
        for (var position = 0;
            position < FlutterApplicationAdapterLogPhase.values.length;
            position++)
          FlutterApplicationAdapterLogEntry.create(
            phase: FlutterApplicationAdapterLogPhase.values[position],
            position: position,
            applicationCompositionPlanDigest: applicationCompositionPlan.digest,
            bootstrapHostRunDigest: bootstrapHostRun.digest,
            adapterSetDigest: adapterSetDigest,
          ),
      ],
    );
  }
}

void _validateInputs({
  required EndToEndApplicationCompositionPlan applicationCompositionPlan,
  required ApplicationBootstrapHostRun bootstrapHostRun,
}) {
  if (applicationCompositionPlan.entries.isEmpty ||
      applicationCompositionPlan.id.isEmpty ||
      applicationCompositionPlan.digest.isEmpty ||
      bootstrapHostRun.id.isEmpty ||
      bootstrapHostRun.digest.isEmpty ||
      bootstrapHostRun.lifecycle.length !=
          ApplicationBootstrapPhase.values.length) {
    throw ArgumentError('Flutter application adapter inputs are incomplete.');
  }
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
