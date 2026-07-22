import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/application/configuration_loader.dart';
import 'package:pool_os/application/persistence_adapter_planner.dart';

const persistenceRuntimeContractVersion = 1;
const persistenceRuntimePolicyVersion = 'persistence-runtime/1.0.0';

abstract interface class PersistenceBackend {
  Future<List<PersistenceBackendInitialization>> initialize(
    PersistenceInitializationRequest request,
  );
}

class PersistenceInitializationTarget {
  const PersistenceInitializationTarget({
    required this.persistenceAdapterEntryId,
    required this.featureId,
    required this.configurationAdapterEntryId,
    required this.position,
    required this.persistenceAdapterProvenanceDigest,
  });

  final String persistenceAdapterEntryId;
  final String featureId;
  final String configurationAdapterEntryId;
  final int position;
  final String persistenceAdapterProvenanceDigest;

  Map<String, dynamic> toJson() => {
        'persistenceAdapterEntryId': persistenceAdapterEntryId,
        'featureId': featureId,
        'configurationAdapterEntryId': configurationAdapterEntryId,
        'position': position,
        'persistenceAdapterProvenanceDigest':
            persistenceAdapterProvenanceDigest,
      };
}

class PersistenceInitializationRequest {
  PersistenceInitializationRequest._({
    required this.persistenceAdapterPlanId,
    required this.persistenceAdapterPlanDigest,
    required this.runtimeConfigurationId,
    required this.runtimeConfigurationDigest,
    required this.runtimeConfiguration,
    required List<PersistenceInitializationTarget> targets,
    required this.digest,
  }) : targets = List.unmodifiable(targets);

  final String persistenceAdapterPlanId;
  final String persistenceAdapterPlanDigest;
  final String runtimeConfigurationId;
  final String runtimeConfigurationDigest;
  final RuntimeConfiguration runtimeConfiguration;
  final List<PersistenceInitializationTarget> targets;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': persistenceRuntimeContractVersion,
        'policyVersion': persistenceRuntimePolicyVersion,
        'persistenceAdapterPlanId': persistenceAdapterPlanId,
        'persistenceAdapterPlanDigest': persistenceAdapterPlanDigest,
        'runtimeConfigurationId': runtimeConfigurationId,
        'runtimeConfigurationDigest': runtimeConfigurationDigest,
        'targets': targets.map((target) => target.toJson()).toList(),
        'digest': digest,
      };
}

class PersistenceBackendInitialization {
  const PersistenceBackendInitialization._({
    required this.persistenceAdapterEntryId,
    required this.backendId,
    required this.requestDigest,
    required this.digest,
  });

  factory PersistenceBackendInitialization.create({
    required String persistenceAdapterEntryId,
    required String backendId,
    required String requestDigest,
  }) {
    if (persistenceAdapterEntryId.isEmpty ||
        backendId.isEmpty ||
        requestDigest.isEmpty) {
      throw ArgumentError('Persistence backend initialization is incomplete.');
    }
    final payload = {
      'persistenceAdapterEntryId': persistenceAdapterEntryId,
      'backendId': backendId,
      'requestDigest': requestDigest,
    };
    return PersistenceBackendInitialization._(
      persistenceAdapterEntryId: persistenceAdapterEntryId,
      backendId: backendId,
      requestDigest: requestDigest,
      digest: _digest(payload),
    );
  }

  final String persistenceAdapterEntryId;
  final String backendId;
  final String requestDigest;
  final String digest;

  Map<String, dynamic> toJson() => {
        'persistenceAdapterEntryId': persistenceAdapterEntryId,
        'backendId': backendId,
        'requestDigest': requestDigest,
        'digest': digest,
      };
}

class RuntimePersistenceEntry {
  const RuntimePersistenceEntry._({
    required this.id,
    required this.persistenceAdapterEntryId,
    required this.featureId,
    required this.configurationAdapterEntryId,
    required this.backendId,
    required this.position,
    required this.persistenceAdapterProvenanceDigest,
    required this.backendInitializationDigest,
    required this.digest,
  });

  final String id;
  final String persistenceAdapterEntryId;
  final String featureId;
  final String configurationAdapterEntryId;
  final String backendId;
  final int position;
  final String persistenceAdapterProvenanceDigest;
  final String backendInitializationDigest;
  final String digest;

  Map<String, dynamic> toJson() => {
        'id': id,
        'persistenceAdapterEntryId': persistenceAdapterEntryId,
        'featureId': featureId,
        'configurationAdapterEntryId': configurationAdapterEntryId,
        'backendId': backendId,
        'position': position,
        'persistenceAdapterProvenanceDigest':
            persistenceAdapterProvenanceDigest,
        'backendInitializationDigest': backendInitializationDigest,
        'digest': digest,
      };
}

class RuntimePersistenceState {
  RuntimePersistenceState._({
    required this.id,
    required this.persistenceAdapterPlanId,
    required this.persistenceAdapterPlanDigest,
    required this.runtimeConfigurationId,
    required this.runtimeConfigurationDigest,
    required this.initializationRequestDigest,
    required List<RuntimePersistenceEntry> entries,
    required this.digest,
  }) : entries = List.unmodifiable(entries);

  final String id;
  final String persistenceAdapterPlanId;
  final String persistenceAdapterPlanDigest;
  final String runtimeConfigurationId;
  final String runtimeConfigurationDigest;
  final String initializationRequestDigest;
  final List<RuntimePersistenceEntry> entries;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': persistenceRuntimeContractVersion,
        'policyVersion': persistenceRuntimePolicyVersion,
        'id': id,
        'persistenceAdapterPlanId': persistenceAdapterPlanId,
        'persistenceAdapterPlanDigest': persistenceAdapterPlanDigest,
        'runtimeConfigurationId': runtimeConfigurationId,
        'runtimeConfigurationDigest': runtimeConfigurationDigest,
        'initializationRequestDigest': initializationRequestDigest,
        'entries': entries.map((entry) => entry.toJson()).toList(),
        'digest': digest,
      };
}

class PersistenceRuntime {
  const PersistenceRuntime();

  Future<RuntimePersistenceState> initialize({
    required PersistenceAdapterPlan persistenceAdapterPlan,
    required RuntimeConfiguration runtimeConfiguration,
    required PersistenceBackend backend,
  }) async {
    final targets = _validateAndProjectTargets(
      persistenceAdapterPlan: persistenceAdapterPlan,
      runtimeConfiguration: runtimeConfiguration,
    );
    final requestPayload = {
      'schemaVersion': persistenceRuntimeContractVersion,
      'policyVersion': persistenceRuntimePolicyVersion,
      'persistenceAdapterPlanId': persistenceAdapterPlan.id,
      'persistenceAdapterPlanDigest': persistenceAdapterPlan.digest,
      'runtimeConfigurationId': runtimeConfiguration.id,
      'runtimeConfigurationDigest': runtimeConfiguration.digest,
      'targets': targets.map((target) => target.toJson()).toList(),
    };
    final request = PersistenceInitializationRequest._(
      persistenceAdapterPlanId: persistenceAdapterPlan.id,
      persistenceAdapterPlanDigest: persistenceAdapterPlan.digest,
      runtimeConfigurationId: runtimeConfiguration.id,
      runtimeConfigurationDigest: runtimeConfiguration.digest,
      runtimeConfiguration: runtimeConfiguration,
      targets: targets,
      digest: _digest(requestPayload),
    );
    final initialized = await backend.initialize(request);
    final initializedByTarget = <String, PersistenceBackendInitialization>{};
    final backendIds = <String>{};
    for (final entry in initialized) {
      final expected = PersistenceBackendInitialization.create(
        persistenceAdapterEntryId: entry.persistenceAdapterEntryId,
        backendId: entry.backendId,
        requestDigest: request.digest,
      );
      if (entry.requestDigest != request.digest ||
          entry.digest != expected.digest ||
          initializedByTarget.containsKey(entry.persistenceAdapterEntryId) ||
          !backendIds.add(entry.backendId)) {
        throw StateError('Persistence backend initialization is invalid.');
      }
      initializedByTarget[entry.persistenceAdapterEntryId] = entry;
    }
    if (initializedByTarget.length != targets.length ||
        initializedByTarget.keys.any(
          (id) => !targets.any(
            (target) => target.persistenceAdapterEntryId == id,
          ),
        )) {
      throw StateError('Persistence initialization coverage is invalid.');
    }

    final entries = <RuntimePersistenceEntry>[];
    for (final target in targets) {
      final initialization =
          initializedByTarget[target.persistenceAdapterEntryId];
      if (initialization == null) {
        throw StateError('Required persistence initialization is missing.');
      }
      final entryPayload = {
        ...target.toJson(),
        'backendId': initialization.backendId,
        'backendInitializationDigest': initialization.digest,
      };
      final digest = _digest(entryPayload);
      entries.add(RuntimePersistenceEntry._(
        id: 'runtime-persistence-entry.${digest.substring(0, 16)}',
        persistenceAdapterEntryId: target.persistenceAdapterEntryId,
        featureId: target.featureId,
        configurationAdapterEntryId: target.configurationAdapterEntryId,
        backendId: initialization.backendId,
        position: target.position,
        persistenceAdapterProvenanceDigest:
            target.persistenceAdapterProvenanceDigest,
        backendInitializationDigest: initialization.digest,
        digest: digest,
      ));
    }
    final payload = {
      'schemaVersion': persistenceRuntimeContractVersion,
      'policyVersion': persistenceRuntimePolicyVersion,
      'persistenceAdapterPlanId': persistenceAdapterPlan.id,
      'persistenceAdapterPlanDigest': persistenceAdapterPlan.digest,
      'runtimeConfigurationId': runtimeConfiguration.id,
      'runtimeConfigurationDigest': runtimeConfiguration.digest,
      'initializationRequestDigest': request.digest,
      'entries': entries.map((entry) => entry.toJson()).toList(),
    };
    final digest = _digest(payload);
    return RuntimePersistenceState._(
      id: 'runtime-persistence.${digest.substring(0, 16)}',
      persistenceAdapterPlanId: persistenceAdapterPlan.id,
      persistenceAdapterPlanDigest: persistenceAdapterPlan.digest,
      runtimeConfigurationId: runtimeConfiguration.id,
      runtimeConfigurationDigest: runtimeConfiguration.digest,
      initializationRequestDigest: request.digest,
      entries: entries,
      digest: digest,
    );
  }
}

List<PersistenceInitializationTarget> _validateAndProjectTargets({
  required PersistenceAdapterPlan persistenceAdapterPlan,
  required RuntimeConfiguration runtimeConfiguration,
}) {
  if (persistenceAdapterPlan.id.isEmpty ||
      persistenceAdapterPlan.digest.isEmpty ||
      persistenceAdapterPlan.entries.isEmpty ||
      runtimeConfiguration.id.isEmpty ||
      runtimeConfiguration.digest.isEmpty ||
      runtimeConfiguration.entries.isEmpty ||
      persistenceAdapterPlan.configurationAdapterPlanId !=
          runtimeConfiguration.configurationAdapterPlanId ||
      persistenceAdapterPlan.configurationAdapterPlanDigest !=
          runtimeConfiguration.configurationAdapterPlanDigest) {
    throw ArgumentError('Persistence runtime inputs are incompatible.');
  }
  final ordered = [...persistenceAdapterPlan.entries]
    ..sort((left, right) => left.position.compareTo(right.position));
  final persistenceIds = <String>{};
  final featureIds = <String>{};
  final configurationAdapterIds = <String>{};
  final targets = <PersistenceInitializationTarget>[];
  for (var position = 0; position < ordered.length; position++) {
    final entry = ordered[position];
    if (entry.position != position ||
        entry.persistenceAdapterEntryId.isEmpty ||
        entry.featureId.isEmpty ||
        entry.configurationAdapterEntryId.isEmpty ||
        entry.configurationAdapterPlanDigest !=
            runtimeConfiguration.configurationAdapterPlanDigest ||
        entry.provenanceDigest.isEmpty ||
        !persistenceIds.add(entry.persistenceAdapterEntryId) ||
        !featureIds.add(entry.featureId) ||
        !configurationAdapterIds.add(entry.configurationAdapterEntryId)) {
      throw ArgumentError('Persistence adapter ownership is invalid.');
    }
    targets.add(PersistenceInitializationTarget(
      persistenceAdapterEntryId: entry.persistenceAdapterEntryId,
      featureId: entry.featureId,
      configurationAdapterEntryId: entry.configurationAdapterEntryId,
      position: position,
      persistenceAdapterProvenanceDigest: entry.provenanceDigest,
    ));
  }
  return List.unmodifiable(targets);
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
