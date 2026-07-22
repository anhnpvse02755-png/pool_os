import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/application/persistence_runtime.dart';
import 'package:pool_os/application/transport_adapter_planner.dart';

const transportRuntimeContractVersion = 1;
const transportRuntimePolicyVersion = 'transport-runtime/1.0.0';

abstract interface class TransportProvider {
  Future<List<TransportProviderInitialization>> initialize(
    TransportInitializationRequest request,
  );
}

class TransportInitializationTarget {
  const TransportInitializationTarget({
    required this.transportAdapterEntryId,
    required this.featureId,
    required this.persistenceAdapterEntryId,
    required this.position,
    required this.transportAdapterProvenanceDigest,
  });

  final String transportAdapterEntryId;
  final String featureId;
  final String persistenceAdapterEntryId;
  final int position;
  final String transportAdapterProvenanceDigest;

  Map<String, dynamic> toJson() => {
        'transportAdapterEntryId': transportAdapterEntryId,
        'featureId': featureId,
        'persistenceAdapterEntryId': persistenceAdapterEntryId,
        'position': position,
        'transportAdapterProvenanceDigest': transportAdapterProvenanceDigest,
      };
}

class TransportInitializationRequest {
  TransportInitializationRequest._({
    required this.transportAdapterPlanId,
    required this.transportAdapterPlanDigest,
    required this.runtimePersistenceStateId,
    required this.runtimePersistenceStateDigest,
    required this.runtimePersistenceState,
    required List<TransportInitializationTarget> targets,
    required this.digest,
  }) : targets = List.unmodifiable(targets);

  final String transportAdapterPlanId;
  final String transportAdapterPlanDigest;
  final String runtimePersistenceStateId;
  final String runtimePersistenceStateDigest;
  final RuntimePersistenceState runtimePersistenceState;
  final List<TransportInitializationTarget> targets;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': transportRuntimeContractVersion,
        'policyVersion': transportRuntimePolicyVersion,
        'transportAdapterPlanId': transportAdapterPlanId,
        'transportAdapterPlanDigest': transportAdapterPlanDigest,
        'runtimePersistenceStateId': runtimePersistenceStateId,
        'runtimePersistenceStateDigest': runtimePersistenceStateDigest,
        'targets': targets.map((target) => target.toJson()).toList(),
        'digest': digest,
      };
}

class TransportProviderInitialization {
  const TransportProviderInitialization._({
    required this.transportAdapterEntryId,
    required this.providerId,
    required this.requestDigest,
    required this.digest,
  });

  factory TransportProviderInitialization.create({
    required String transportAdapterEntryId,
    required String providerId,
    required String requestDigest,
  }) {
    if (transportAdapterEntryId.isEmpty ||
        providerId.isEmpty ||
        requestDigest.isEmpty) {
      throw ArgumentError('Transport provider initialization is incomplete.');
    }
    final payload = {
      'transportAdapterEntryId': transportAdapterEntryId,
      'providerId': providerId,
      'requestDigest': requestDigest,
    };
    return TransportProviderInitialization._(
      transportAdapterEntryId: transportAdapterEntryId,
      providerId: providerId,
      requestDigest: requestDigest,
      digest: _digest(payload),
    );
  }

  final String transportAdapterEntryId;
  final String providerId;
  final String requestDigest;
  final String digest;
}

class RuntimeTransportEntry {
  const RuntimeTransportEntry._({
    required this.id,
    required this.transportAdapterEntryId,
    required this.featureId,
    required this.persistenceAdapterEntryId,
    required this.providerId,
    required this.position,
    required this.transportAdapterProvenanceDigest,
    required this.providerInitializationDigest,
    required this.digest,
  });

  final String id;
  final String transportAdapterEntryId;
  final String featureId;
  final String persistenceAdapterEntryId;
  final String providerId;
  final int position;
  final String transportAdapterProvenanceDigest;
  final String providerInitializationDigest;
  final String digest;

  Map<String, dynamic> toJson() => {
        'id': id,
        'transportAdapterEntryId': transportAdapterEntryId,
        'featureId': featureId,
        'persistenceAdapterEntryId': persistenceAdapterEntryId,
        'providerId': providerId,
        'position': position,
        'transportAdapterProvenanceDigest': transportAdapterProvenanceDigest,
        'providerInitializationDigest': providerInitializationDigest,
        'digest': digest,
      };
}

class RuntimeTransportState {
  RuntimeTransportState._({
    required this.id,
    required this.transportAdapterPlanId,
    required this.transportAdapterPlanDigest,
    required this.runtimePersistenceStateId,
    required this.runtimePersistenceStateDigest,
    required this.initializationRequestDigest,
    required List<RuntimeTransportEntry> entries,
    required this.digest,
  }) : entries = List.unmodifiable(entries);

  final String id;
  final String transportAdapterPlanId;
  final String transportAdapterPlanDigest;
  final String runtimePersistenceStateId;
  final String runtimePersistenceStateDigest;
  final String initializationRequestDigest;
  final List<RuntimeTransportEntry> entries;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': transportRuntimeContractVersion,
        'policyVersion': transportRuntimePolicyVersion,
        'id': id,
        'transportAdapterPlanId': transportAdapterPlanId,
        'transportAdapterPlanDigest': transportAdapterPlanDigest,
        'runtimePersistenceStateId': runtimePersistenceStateId,
        'runtimePersistenceStateDigest': runtimePersistenceStateDigest,
        'initializationRequestDigest': initializationRequestDigest,
        'entries': entries.map((entry) => entry.toJson()).toList(),
        'digest': digest,
      };
}

class TransportRuntime {
  const TransportRuntime();

  Future<RuntimeTransportState> initialize({
    required TransportAdapterPlan transportAdapterPlan,
    required RuntimePersistenceState runtimePersistenceState,
    required TransportProvider provider,
  }) async {
    final targets = _validateAndProjectTargets(
      transportAdapterPlan: transportAdapterPlan,
      runtimePersistenceState: runtimePersistenceState,
    );
    final requestPayload = {
      'schemaVersion': transportRuntimeContractVersion,
      'policyVersion': transportRuntimePolicyVersion,
      'transportAdapterPlanId': transportAdapterPlan.id,
      'transportAdapterPlanDigest': transportAdapterPlan.digest,
      'runtimePersistenceStateId': runtimePersistenceState.id,
      'runtimePersistenceStateDigest': runtimePersistenceState.digest,
      'targets': targets.map((target) => target.toJson()).toList(),
    };
    final request = TransportInitializationRequest._(
      transportAdapterPlanId: transportAdapterPlan.id,
      transportAdapterPlanDigest: transportAdapterPlan.digest,
      runtimePersistenceStateId: runtimePersistenceState.id,
      runtimePersistenceStateDigest: runtimePersistenceState.digest,
      runtimePersistenceState: runtimePersistenceState,
      targets: targets,
      digest: _digest(requestPayload),
    );
    final initialized = await provider.initialize(request);
    final initializedByTarget = <String, TransportProviderInitialization>{};
    final providerIds = <String>{};
    for (final entry in initialized) {
      final expected = TransportProviderInitialization.create(
        transportAdapterEntryId: entry.transportAdapterEntryId,
        providerId: entry.providerId,
        requestDigest: request.digest,
      );
      if (entry.requestDigest != request.digest ||
          entry.digest != expected.digest ||
          initializedByTarget.containsKey(entry.transportAdapterEntryId) ||
          !providerIds.add(entry.providerId)) {
        throw StateError('Transport provider initialization is invalid.');
      }
      initializedByTarget[entry.transportAdapterEntryId] = entry;
    }
    if (initializedByTarget.length != targets.length ||
        initializedByTarget.keys.any(
          (id) => !targets.any(
            (target) => target.transportAdapterEntryId == id,
          ),
        )) {
      throw StateError('Transport initialization coverage is invalid.');
    }

    final entries = <RuntimeTransportEntry>[];
    for (final target in targets) {
      final initialization =
          initializedByTarget[target.transportAdapterEntryId];
      if (initialization == null) {
        throw StateError('Required transport initialization is missing.');
      }
      final entryPayload = {
        ...target.toJson(),
        'providerId': initialization.providerId,
        'providerInitializationDigest': initialization.digest,
      };
      final digest = _digest(entryPayload);
      entries.add(RuntimeTransportEntry._(
        id: 'runtime-transport-entry.${digest.substring(0, 16)}',
        transportAdapterEntryId: target.transportAdapterEntryId,
        featureId: target.featureId,
        persistenceAdapterEntryId: target.persistenceAdapterEntryId,
        providerId: initialization.providerId,
        position: target.position,
        transportAdapterProvenanceDigest:
            target.transportAdapterProvenanceDigest,
        providerInitializationDigest: initialization.digest,
        digest: digest,
      ));
    }
    final payload = {
      'schemaVersion': transportRuntimeContractVersion,
      'policyVersion': transportRuntimePolicyVersion,
      'transportAdapterPlanId': transportAdapterPlan.id,
      'transportAdapterPlanDigest': transportAdapterPlan.digest,
      'runtimePersistenceStateId': runtimePersistenceState.id,
      'runtimePersistenceStateDigest': runtimePersistenceState.digest,
      'initializationRequestDigest': request.digest,
      'entries': entries.map((entry) => entry.toJson()).toList(),
    };
    final digest = _digest(payload);
    return RuntimeTransportState._(
      id: 'runtime-transport.${digest.substring(0, 16)}',
      transportAdapterPlanId: transportAdapterPlan.id,
      transportAdapterPlanDigest: transportAdapterPlan.digest,
      runtimePersistenceStateId: runtimePersistenceState.id,
      runtimePersistenceStateDigest: runtimePersistenceState.digest,
      initializationRequestDigest: request.digest,
      entries: entries,
      digest: digest,
    );
  }
}

List<TransportInitializationTarget> _validateAndProjectTargets({
  required TransportAdapterPlan transportAdapterPlan,
  required RuntimePersistenceState runtimePersistenceState,
}) {
  if (transportAdapterPlan.id.isEmpty ||
      transportAdapterPlan.digest.isEmpty ||
      transportAdapterPlan.entries.isEmpty ||
      runtimePersistenceState.id.isEmpty ||
      runtimePersistenceState.digest.isEmpty ||
      runtimePersistenceState.entries.isEmpty ||
      transportAdapterPlan.persistenceAdapterPlanId !=
          runtimePersistenceState.persistenceAdapterPlanId ||
      transportAdapterPlan.persistenceAdapterPlanDigest !=
          runtimePersistenceState.persistenceAdapterPlanDigest) {
    throw ArgumentError('Transport runtime inputs are incompatible.');
  }
  final persistenceIds = {
    for (final entry in runtimePersistenceState.entries)
      entry.persistenceAdapterEntryId,
  };
  if (persistenceIds.length != runtimePersistenceState.entries.length) {
    throw ArgumentError('Runtime persistence ownership is invalid.');
  }
  final ordered = [...transportAdapterPlan.entries]
    ..sort((left, right) => left.position.compareTo(right.position));
  final transportIds = <String>{};
  final featureIds = <String>{};
  final referencedPersistenceIds = <String>{};
  final targets = <TransportInitializationTarget>[];
  for (var position = 0; position < ordered.length; position++) {
    final entry = ordered[position];
    if (entry.position != position ||
        entry.transportAdapterEntryId.isEmpty ||
        entry.featureId.isEmpty ||
        entry.persistenceAdapterEntryId.isEmpty ||
        entry.persistenceAdapterPlanDigest !=
            runtimePersistenceState.persistenceAdapterPlanDigest ||
        entry.provenanceDigest.isEmpty ||
        !persistenceIds.contains(entry.persistenceAdapterEntryId) ||
        !transportIds.add(entry.transportAdapterEntryId) ||
        !featureIds.add(entry.featureId) ||
        !referencedPersistenceIds.add(entry.persistenceAdapterEntryId)) {
      throw ArgumentError('Transport adapter ownership is invalid.');
    }
    targets.add(TransportInitializationTarget(
      transportAdapterEntryId: entry.transportAdapterEntryId,
      featureId: entry.featureId,
      persistenceAdapterEntryId: entry.persistenceAdapterEntryId,
      position: position,
      transportAdapterProvenanceDigest: entry.provenanceDigest,
    ));
  }
  if (referencedPersistenceIds.length != persistenceIds.length) {
    throw ArgumentError('Transport adapter coverage is incomplete.');
  }
  return List.unmodifiable(targets);
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
