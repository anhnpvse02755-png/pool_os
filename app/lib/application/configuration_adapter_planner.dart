import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/application/flutter_application_adapter_planner.dart';
import 'package:pool_os/contracts/runtime_configuration_environment_projection_contracts.dart';

const configurationAdapterPlannerVersion = 1;
const configurationAdapterPlannerPolicyVersion =
    'configuration-adapter-planner/1.0.0';

enum ConfigurationAdapterLogPhase {
  validateInputs,
  orderFeatures,
  bindConfigurationProvenance,
  completed,
}

class ConfigurationAdapterEntry {
  const ConfigurationAdapterEntry._({
    required this.configurationAdapterEntryId,
    required this.featureId,
    required this.flutterAdapterEntryId,
    required this.position,
    required this.configurationProjectionDigest,
    required this.flutterApplicationAdapterPlanDigest,
    required this.provenanceDigest,
    required this.digest,
  });

  factory ConfigurationAdapterEntry.create({
    required String featureId,
    required String flutterAdapterEntryId,
    required int position,
    required String configurationProjectionDigest,
    required String flutterApplicationAdapterPlanDigest,
  }) {
    if (featureId.isEmpty ||
        flutterAdapterEntryId.isEmpty ||
        position < 0 ||
        configurationProjectionDigest.isEmpty ||
        flutterApplicationAdapterPlanDigest.isEmpty) {
      throw ArgumentError('Configuration adapter entry is incomplete.');
    }
    final configurationAdapterEntryId = 'configuration-adapter.$featureId';
    final provenanceDigest = _digest({
      'configurationProjectionDigest': configurationProjectionDigest,
      'flutterApplicationAdapterPlanDigest':
          flutterApplicationAdapterPlanDigest,
    });
    final payload = {
      'configurationAdapterEntryId': configurationAdapterEntryId,
      'featureId': featureId,
      'flutterAdapterEntryId': flutterAdapterEntryId,
      'position': position,
      'configurationProjectionDigest': configurationProjectionDigest,
      'flutterApplicationAdapterPlanDigest':
          flutterApplicationAdapterPlanDigest,
      'provenanceDigest': provenanceDigest,
    };
    return ConfigurationAdapterEntry._(
      configurationAdapterEntryId: configurationAdapterEntryId,
      featureId: featureId,
      flutterAdapterEntryId: flutterAdapterEntryId,
      position: position,
      configurationProjectionDigest: configurationProjectionDigest,
      flutterApplicationAdapterPlanDigest: flutterApplicationAdapterPlanDigest,
      provenanceDigest: provenanceDigest,
      digest: _digest(payload),
    );
  }

  final String configurationAdapterEntryId;
  final String featureId;
  final String flutterAdapterEntryId;
  final int position;
  final String configurationProjectionDigest;
  final String flutterApplicationAdapterPlanDigest;
  final String provenanceDigest;
  final String digest;

  Map<String, dynamic> toJson() => {
        'configurationAdapterEntryId': configurationAdapterEntryId,
        'featureId': featureId,
        'flutterAdapterEntryId': flutterAdapterEntryId,
        'position': position,
        'configurationProjectionDigest': configurationProjectionDigest,
        'flutterApplicationAdapterPlanDigest':
            flutterApplicationAdapterPlanDigest,
        'provenanceDigest': provenanceDigest,
        'digest': digest,
      };
}

class ConfigurationAdapterLogEntry {
  const ConfigurationAdapterLogEntry._({
    required this.phase,
    required this.position,
    required this.configurationProjectionDigest,
    required this.flutterApplicationAdapterPlanDigest,
    required this.configurationAdapterSetDigest,
    required this.eventCode,
    required this.digest,
  });

  factory ConfigurationAdapterLogEntry.create({
    required ConfigurationAdapterLogPhase phase,
    required int position,
    required String configurationProjectionDigest,
    required String flutterApplicationAdapterPlanDigest,
    required String configurationAdapterSetDigest,
  }) {
    if (position < 0 ||
        configurationProjectionDigest.isEmpty ||
        flutterApplicationAdapterPlanDigest.isEmpty ||
        configurationAdapterSetDigest.isEmpty) {
      throw ArgumentError('Configuration adapter log is incomplete.');
    }
    final eventCode = 'configuration-adapter.${phase.name}';
    final payload = {
      'phase': phase.name,
      'position': position,
      'configurationProjectionDigest': configurationProjectionDigest,
      'flutterApplicationAdapterPlanDigest':
          flutterApplicationAdapterPlanDigest,
      'configurationAdapterSetDigest': configurationAdapterSetDigest,
      'eventCode': eventCode,
    };
    return ConfigurationAdapterLogEntry._(
      phase: phase,
      position: position,
      configurationProjectionDigest: configurationProjectionDigest,
      flutterApplicationAdapterPlanDigest: flutterApplicationAdapterPlanDigest,
      configurationAdapterSetDigest: configurationAdapterSetDigest,
      eventCode: eventCode,
      digest: _digest(payload),
    );
  }

  final ConfigurationAdapterLogPhase phase;
  final int position;
  final String configurationProjectionDigest;
  final String flutterApplicationAdapterPlanDigest;
  final String configurationAdapterSetDigest;
  final String eventCode;
  final String digest;

  Map<String, dynamic> toJson() => {
        'phase': phase.name,
        'position': position,
        'configurationProjectionDigest': configurationProjectionDigest,
        'flutterApplicationAdapterPlanDigest':
            flutterApplicationAdapterPlanDigest,
        'configurationAdapterSetDigest': configurationAdapterSetDigest,
        'eventCode': eventCode,
        'digest': digest,
      };
}

class ConfigurationAdapterPlan {
  const ConfigurationAdapterPlan._({
    required this.id,
    required this.configurationProjectionId,
    required this.configurationProjectionDigest,
    required this.flutterApplicationAdapterPlanId,
    required this.flutterApplicationAdapterPlanDigest,
    required this.entries,
    required this.log,
    required this.digest,
  });

  factory ConfigurationAdapterPlan.create({
    required RuntimeConfigurationEnvironmentProjectionContract
        configurationProjection,
    required FlutterApplicationAdapterPlan flutterApplicationAdapterPlan,
    required List<ConfigurationAdapterEntry> entries,
    required List<ConfigurationAdapterLogEntry> log,
  }) {
    _validateInputs(
      configurationProjection: configurationProjection,
      flutterApplicationAdapterPlan: flutterApplicationAdapterPlan,
    );
    if (entries.length != flutterApplicationAdapterPlan.entries.length) {
      throw ArgumentError('Configuration adapter coverage is incomplete.');
    }
    final flutterByFeature = {
      for (final entry in flutterApplicationAdapterPlan.entries)
        entry.featureId: entry,
    };
    final ordered = [...entries]
      ..sort((left, right) => left.position.compareTo(right.position));
    final configurationAdapterIds = <String>{};
    final featureIds = <String>{};
    final flutterAdapterIds = <String>{};
    final positions = <int>{};
    for (var position = 0; position < ordered.length; position++) {
      final entry = ordered[position];
      final flutterEntry = flutterByFeature[entry.featureId];
      final expected = ConfigurationAdapterEntry.create(
        featureId: entry.featureId,
        flutterAdapterEntryId: entry.flutterAdapterEntryId,
        position: position,
        configurationProjectionDigest: configurationProjection.digest,
        flutterApplicationAdapterPlanDigest:
            flutterApplicationAdapterPlan.digest,
      );
      if (flutterEntry == null ||
          flutterEntry.position != position ||
          entry.position != position ||
          entry.flutterAdapterEntryId != flutterEntry.adapterEntryId ||
          entry.configurationProjectionDigest !=
              configurationProjection.digest ||
          entry.flutterApplicationAdapterPlanDigest !=
              flutterApplicationAdapterPlan.digest ||
          entry.configurationAdapterEntryId !=
              expected.configurationAdapterEntryId ||
          entry.provenanceDigest != expected.provenanceDigest ||
          entry.digest != expected.digest ||
          !configurationAdapterIds.add(entry.configurationAdapterEntryId) ||
          !featureIds.add(entry.featureId) ||
          !flutterAdapterIds.add(entry.flutterAdapterEntryId) ||
          !positions.add(entry.position)) {
        throw ArgumentError('Configuration adapter provenance is invalid.');
      }
    }

    final configurationAdapterSetDigest =
        _digest(ordered.map((entry) => entry.toJson()).toList());
    final orderedLog = [...log]
      ..sort((left, right) => left.position.compareTo(right.position));
    if (orderedLog.length != ConfigurationAdapterLogPhase.values.length) {
      throw ArgumentError('Configuration adapter log is incomplete.');
    }
    for (var position = 0; position < orderedLog.length; position++) {
      final entry = orderedLog[position];
      final expected = ConfigurationAdapterLogEntry.create(
        phase: ConfigurationAdapterLogPhase.values[position],
        position: position,
        configurationProjectionDigest: configurationProjection.digest,
        flutterApplicationAdapterPlanDigest:
            flutterApplicationAdapterPlan.digest,
        configurationAdapterSetDigest: configurationAdapterSetDigest,
      );
      if (entry.phase != expected.phase ||
          entry.position != expected.position ||
          entry.configurationProjectionDigest !=
              expected.configurationProjectionDigest ||
          entry.flutterApplicationAdapterPlanDigest !=
              expected.flutterApplicationAdapterPlanDigest ||
          entry.configurationAdapterSetDigest !=
              expected.configurationAdapterSetDigest ||
          entry.eventCode != expected.eventCode ||
          entry.digest != expected.digest) {
        throw ArgumentError('Configuration adapter log is invalid.');
      }
    }

    final payload = {
      'plannerVersion': configurationAdapterPlannerVersion,
      'policyVersion': configurationAdapterPlannerPolicyVersion,
      'configurationProjectionId': configurationProjection.id,
      'configurationProjectionDigest': configurationProjection.digest,
      'flutterApplicationAdapterPlanId': flutterApplicationAdapterPlan.id,
      'flutterApplicationAdapterPlanDigest':
          flutterApplicationAdapterPlan.digest,
      'entries': ordered.map((entry) => entry.toJson()).toList(),
      'log': orderedLog.map((entry) => entry.toJson()).toList(),
    };
    final digest = _digest(payload);
    return ConfigurationAdapterPlan._(
      id: 'configuration-adapter-plan.${digest.substring(0, 16)}',
      configurationProjectionId: configurationProjection.id,
      configurationProjectionDigest: configurationProjection.digest,
      flutterApplicationAdapterPlanId: flutterApplicationAdapterPlan.id,
      flutterApplicationAdapterPlanDigest: flutterApplicationAdapterPlan.digest,
      entries: List.unmodifiable(ordered),
      log: List.unmodifiable(orderedLog),
      digest: digest,
    );
  }

  final String id;
  final String configurationProjectionId;
  final String configurationProjectionDigest;
  final String flutterApplicationAdapterPlanId;
  final String flutterApplicationAdapterPlanDigest;
  final List<ConfigurationAdapterEntry> entries;
  final List<ConfigurationAdapterLogEntry> log;
  final String digest;

  Map<String, dynamic> toJson() => {
        'plannerVersion': configurationAdapterPlannerVersion,
        'policyVersion': configurationAdapterPlannerPolicyVersion,
        'id': id,
        'configurationProjectionId': configurationProjectionId,
        'configurationProjectionDigest': configurationProjectionDigest,
        'flutterApplicationAdapterPlanId': flutterApplicationAdapterPlanId,
        'flutterApplicationAdapterPlanDigest':
            flutterApplicationAdapterPlanDigest,
        'entries': entries.map((entry) => entry.toJson()).toList(),
        'log': log.map((entry) => entry.toJson()).toList(),
        'digest': digest,
      };
}

class ConfigurationAdapterPlanner {
  const ConfigurationAdapterPlanner();

  ConfigurationAdapterPlan plan({
    required RuntimeConfigurationEnvironmentProjectionContract
        configurationProjection,
    required FlutterApplicationAdapterPlan flutterApplicationAdapterPlan,
  }) {
    _validateInputs(
      configurationProjection: configurationProjection,
      flutterApplicationAdapterPlan: flutterApplicationAdapterPlan,
    );
    final entries = [
      for (final flutterEntry in flutterApplicationAdapterPlan.entries)
        ConfigurationAdapterEntry.create(
          featureId: flutterEntry.featureId,
          flutterAdapterEntryId: flutterEntry.adapterEntryId,
          position: flutterEntry.position,
          configurationProjectionDigest: configurationProjection.digest,
          flutterApplicationAdapterPlanDigest:
              flutterApplicationAdapterPlan.digest,
        ),
    ]..sort((left, right) => left.position.compareTo(right.position));
    final configurationAdapterSetDigest =
        _digest(entries.map((entry) => entry.toJson()).toList());
    return ConfigurationAdapterPlan.create(
      configurationProjection: configurationProjection,
      flutterApplicationAdapterPlan: flutterApplicationAdapterPlan,
      entries: entries,
      log: [
        for (var position = 0;
            position < ConfigurationAdapterLogPhase.values.length;
            position++)
          ConfigurationAdapterLogEntry.create(
            phase: ConfigurationAdapterLogPhase.values[position],
            position: position,
            configurationProjectionDigest: configurationProjection.digest,
            flutterApplicationAdapterPlanDigest:
                flutterApplicationAdapterPlan.digest,
            configurationAdapterSetDigest: configurationAdapterSetDigest,
          ),
      ],
    );
  }
}

void _validateInputs({
  required RuntimeConfigurationEnvironmentProjectionContract
      configurationProjection,
  required FlutterApplicationAdapterPlan flutterApplicationAdapterPlan,
}) {
  if (configurationProjection.id.isEmpty ||
      configurationProjection.digest.isEmpty ||
      configurationProjection.entries.isEmpty ||
      flutterApplicationAdapterPlan.id.isEmpty ||
      flutterApplicationAdapterPlan.digest.isEmpty ||
      flutterApplicationAdapterPlan.entries.isEmpty) {
    throw ArgumentError('Configuration adapter inputs are incomplete.');
  }
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
