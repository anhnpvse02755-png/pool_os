import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/application/ai_provider_adapter_planner.dart';
import 'package:pool_os/application/transport_runtime.dart';

const aiProviderRuntimeContractVersion = 1;
const aiProviderRuntimePolicyVersion = 'ai-provider-runtime/1.0.0';

abstract interface class AIRuntimeProvider {
  Future<List<AIProviderInitialization>> initialize(
    AIProviderInitializationRequest request,
  );
}

class AIProviderInitializationTarget {
  const AIProviderInitializationTarget({
    required this.aiProviderAdapterEntryId,
    required this.featureId,
    required this.transportAdapterEntryId,
    required this.position,
    required this.aiProviderAdapterProvenanceDigest,
  });

  final String aiProviderAdapterEntryId;
  final String featureId;
  final String transportAdapterEntryId;
  final int position;
  final String aiProviderAdapterProvenanceDigest;

  Map<String, dynamic> toJson() => {
        'aiProviderAdapterEntryId': aiProviderAdapterEntryId,
        'featureId': featureId,
        'transportAdapterEntryId': transportAdapterEntryId,
        'position': position,
        'aiProviderAdapterProvenanceDigest': aiProviderAdapterProvenanceDigest,
      };
}

class AIProviderInitializationRequest {
  AIProviderInitializationRequest._({
    required this.aiProviderAdapterPlanId,
    required this.aiProviderAdapterPlanDigest,
    required this.runtimeTransportStateId,
    required this.runtimeTransportStateDigest,
    required this.runtimeTransportState,
    required List<AIProviderInitializationTarget> targets,
    required this.digest,
  }) : targets = List.unmodifiable(targets);

  final String aiProviderAdapterPlanId;
  final String aiProviderAdapterPlanDigest;
  final String runtimeTransportStateId;
  final String runtimeTransportStateDigest;
  final RuntimeTransportState runtimeTransportState;
  final List<AIProviderInitializationTarget> targets;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': aiProviderRuntimeContractVersion,
        'policyVersion': aiProviderRuntimePolicyVersion,
        'aiProviderAdapterPlanId': aiProviderAdapterPlanId,
        'aiProviderAdapterPlanDigest': aiProviderAdapterPlanDigest,
        'runtimeTransportStateId': runtimeTransportStateId,
        'runtimeTransportStateDigest': runtimeTransportStateDigest,
        'targets': targets.map((target) => target.toJson()).toList(),
        'digest': digest,
      };
}

class AIProviderInitialization {
  const AIProviderInitialization._({
    required this.aiProviderAdapterEntryId,
    required this.runtimeProviderId,
    required this.requestDigest,
    required this.digest,
  });

  factory AIProviderInitialization.create({
    required String aiProviderAdapterEntryId,
    required String runtimeProviderId,
    required String requestDigest,
  }) {
    if (aiProviderAdapterEntryId.isEmpty ||
        runtimeProviderId.isEmpty ||
        requestDigest.isEmpty) {
      throw ArgumentError('AI provider initialization is incomplete.');
    }
    final payload = {
      'aiProviderAdapterEntryId': aiProviderAdapterEntryId,
      'runtimeProviderId': runtimeProviderId,
      'requestDigest': requestDigest,
    };
    return AIProviderInitialization._(
      aiProviderAdapterEntryId: aiProviderAdapterEntryId,
      runtimeProviderId: runtimeProviderId,
      requestDigest: requestDigest,
      digest: _digest(payload),
    );
  }

  final String aiProviderAdapterEntryId;
  final String runtimeProviderId;
  final String requestDigest;
  final String digest;
}

class RuntimeAIProviderEntry {
  const RuntimeAIProviderEntry._({
    required this.id,
    required this.aiProviderAdapterEntryId,
    required this.featureId,
    required this.transportAdapterEntryId,
    required this.runtimeProviderId,
    required this.position,
    required this.aiProviderAdapterProvenanceDigest,
    required this.providerInitializationDigest,
    required this.digest,
  });

  final String id;
  final String aiProviderAdapterEntryId;
  final String featureId;
  final String transportAdapterEntryId;
  final String runtimeProviderId;
  final int position;
  final String aiProviderAdapterProvenanceDigest;
  final String providerInitializationDigest;
  final String digest;

  Map<String, dynamic> toJson() => {
        'id': id,
        'aiProviderAdapterEntryId': aiProviderAdapterEntryId,
        'featureId': featureId,
        'transportAdapterEntryId': transportAdapterEntryId,
        'runtimeProviderId': runtimeProviderId,
        'position': position,
        'aiProviderAdapterProvenanceDigest': aiProviderAdapterProvenanceDigest,
        'providerInitializationDigest': providerInitializationDigest,
        'digest': digest,
      };
}

class RuntimeAIProviderState {
  RuntimeAIProviderState._({
    required this.id,
    required this.aiProviderAdapterPlanId,
    required this.aiProviderAdapterPlanDigest,
    required this.runtimeTransportStateId,
    required this.runtimeTransportStateDigest,
    required this.initializationRequestDigest,
    required List<RuntimeAIProviderEntry> entries,
    required this.digest,
  }) : entries = List.unmodifiable(entries);

  final String id;
  final String aiProviderAdapterPlanId;
  final String aiProviderAdapterPlanDigest;
  final String runtimeTransportStateId;
  final String runtimeTransportStateDigest;
  final String initializationRequestDigest;
  final List<RuntimeAIProviderEntry> entries;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': aiProviderRuntimeContractVersion,
        'policyVersion': aiProviderRuntimePolicyVersion,
        'id': id,
        'aiProviderAdapterPlanId': aiProviderAdapterPlanId,
        'aiProviderAdapterPlanDigest': aiProviderAdapterPlanDigest,
        'runtimeTransportStateId': runtimeTransportStateId,
        'runtimeTransportStateDigest': runtimeTransportStateDigest,
        'initializationRequestDigest': initializationRequestDigest,
        'entries': entries.map((entry) => entry.toJson()).toList(),
        'digest': digest,
      };
}

class AIProviderRuntime {
  const AIProviderRuntime();

  Future<RuntimeAIProviderState> initialize({
    required AIProviderAdapterPlan aiProviderAdapterPlan,
    required RuntimeTransportState runtimeTransportState,
    required AIRuntimeProvider provider,
  }) async {
    final targets = _validateAndProjectTargets(
      aiProviderAdapterPlan: aiProviderAdapterPlan,
      runtimeTransportState: runtimeTransportState,
    );
    final requestPayload = {
      'schemaVersion': aiProviderRuntimeContractVersion,
      'policyVersion': aiProviderRuntimePolicyVersion,
      'aiProviderAdapterPlanId': aiProviderAdapterPlan.id,
      'aiProviderAdapterPlanDigest': aiProviderAdapterPlan.digest,
      'runtimeTransportStateId': runtimeTransportState.id,
      'runtimeTransportStateDigest': runtimeTransportState.digest,
      'targets': targets.map((target) => target.toJson()).toList(),
    };
    final request = AIProviderInitializationRequest._(
      aiProviderAdapterPlanId: aiProviderAdapterPlan.id,
      aiProviderAdapterPlanDigest: aiProviderAdapterPlan.digest,
      runtimeTransportStateId: runtimeTransportState.id,
      runtimeTransportStateDigest: runtimeTransportState.digest,
      runtimeTransportState: runtimeTransportState,
      targets: targets,
      digest: _digest(requestPayload),
    );
    final initialized = await provider.initialize(request);
    final initializedByTarget = <String, AIProviderInitialization>{};
    final runtimeProviderIds = <String>{};
    for (final entry in initialized) {
      final expected = AIProviderInitialization.create(
        aiProviderAdapterEntryId: entry.aiProviderAdapterEntryId,
        runtimeProviderId: entry.runtimeProviderId,
        requestDigest: request.digest,
      );
      if (entry.requestDigest != request.digest ||
          entry.digest != expected.digest ||
          initializedByTarget.containsKey(entry.aiProviderAdapterEntryId) ||
          !runtimeProviderIds.add(entry.runtimeProviderId)) {
        throw StateError('AI provider initialization is invalid.');
      }
      initializedByTarget[entry.aiProviderAdapterEntryId] = entry;
    }
    if (initializedByTarget.length != targets.length ||
        initializedByTarget.keys.any(
          (id) => !targets.any(
            (target) => target.aiProviderAdapterEntryId == id,
          ),
        )) {
      throw StateError('AI provider initialization coverage is invalid.');
    }

    final entries = <RuntimeAIProviderEntry>[];
    for (final target in targets) {
      final initialization =
          initializedByTarget[target.aiProviderAdapterEntryId];
      if (initialization == null) {
        throw StateError('Required AI provider initialization is missing.');
      }
      final entryPayload = {
        ...target.toJson(),
        'runtimeProviderId': initialization.runtimeProviderId,
        'providerInitializationDigest': initialization.digest,
      };
      final digest = _digest(entryPayload);
      entries.add(RuntimeAIProviderEntry._(
        id: 'runtime-ai-provider-entry.${digest.substring(0, 16)}',
        aiProviderAdapterEntryId: target.aiProviderAdapterEntryId,
        featureId: target.featureId,
        transportAdapterEntryId: target.transportAdapterEntryId,
        runtimeProviderId: initialization.runtimeProviderId,
        position: target.position,
        aiProviderAdapterProvenanceDigest:
            target.aiProviderAdapterProvenanceDigest,
        providerInitializationDigest: initialization.digest,
        digest: digest,
      ));
    }
    final payload = {
      'schemaVersion': aiProviderRuntimeContractVersion,
      'policyVersion': aiProviderRuntimePolicyVersion,
      'aiProviderAdapterPlanId': aiProviderAdapterPlan.id,
      'aiProviderAdapterPlanDigest': aiProviderAdapterPlan.digest,
      'runtimeTransportStateId': runtimeTransportState.id,
      'runtimeTransportStateDigest': runtimeTransportState.digest,
      'initializationRequestDigest': request.digest,
      'entries': entries.map((entry) => entry.toJson()).toList(),
    };
    final digest = _digest(payload);
    return RuntimeAIProviderState._(
      id: 'runtime-ai-provider.${digest.substring(0, 16)}',
      aiProviderAdapterPlanId: aiProviderAdapterPlan.id,
      aiProviderAdapterPlanDigest: aiProviderAdapterPlan.digest,
      runtimeTransportStateId: runtimeTransportState.id,
      runtimeTransportStateDigest: runtimeTransportState.digest,
      initializationRequestDigest: request.digest,
      entries: entries,
      digest: digest,
    );
  }
}

List<AIProviderInitializationTarget> _validateAndProjectTargets({
  required AIProviderAdapterPlan aiProviderAdapterPlan,
  required RuntimeTransportState runtimeTransportState,
}) {
  if (aiProviderAdapterPlan.id.isEmpty ||
      aiProviderAdapterPlan.digest.isEmpty ||
      aiProviderAdapterPlan.entries.isEmpty ||
      runtimeTransportState.id.isEmpty ||
      runtimeTransportState.digest.isEmpty ||
      runtimeTransportState.entries.isEmpty ||
      aiProviderAdapterPlan.transportAdapterPlanId !=
          runtimeTransportState.transportAdapterPlanId ||
      aiProviderAdapterPlan.transportAdapterPlanDigest !=
          runtimeTransportState.transportAdapterPlanDigest) {
    throw ArgumentError('AI provider runtime inputs are incompatible.');
  }
  final transportIds = {
    for (final entry in runtimeTransportState.entries)
      entry.transportAdapterEntryId,
  };
  if (transportIds.length != runtimeTransportState.entries.length) {
    throw ArgumentError('Runtime transport ownership is invalid.');
  }
  final ordered = [...aiProviderAdapterPlan.entries]
    ..sort((left, right) => left.position.compareTo(right.position));
  final adapterIds = <String>{};
  final featureIds = <String>{};
  final referencedTransportIds = <String>{};
  final targets = <AIProviderInitializationTarget>[];
  for (var position = 0; position < ordered.length; position++) {
    final entry = ordered[position];
    if (entry.position != position ||
        entry.aiProviderAdapterEntryId.isEmpty ||
        entry.featureId.isEmpty ||
        entry.transportAdapterEntryId.isEmpty ||
        entry.transportAdapterPlanDigest !=
            runtimeTransportState.transportAdapterPlanDigest ||
        entry.provenanceDigest.isEmpty ||
        !transportIds.contains(entry.transportAdapterEntryId) ||
        !adapterIds.add(entry.aiProviderAdapterEntryId) ||
        !featureIds.add(entry.featureId) ||
        !referencedTransportIds.add(entry.transportAdapterEntryId)) {
      throw ArgumentError('AI provider adapter ownership is invalid.');
    }
    targets.add(AIProviderInitializationTarget(
      aiProviderAdapterEntryId: entry.aiProviderAdapterEntryId,
      featureId: entry.featureId,
      transportAdapterEntryId: entry.transportAdapterEntryId,
      position: position,
      aiProviderAdapterProvenanceDigest: entry.provenanceDigest,
    ));
  }
  if (referencedTransportIds.length != transportIds.length) {
    throw ArgumentError('AI provider adapter coverage is incomplete.');
  }
  return List.unmodifiable(targets);
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
