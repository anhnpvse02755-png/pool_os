import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/application/ai_provider_runtime.dart';
import 'package:pool_os/application/dependency_composition_engine.dart';

const dependencyActivationRuntimeVersion = 1;
const dependencyActivationPolicyVersion = 'dependency-activation/1.0.0';

class DependencyActivationAuthorization {
  const DependencyActivationAuthorization._({
    required this.registrationPlanId,
    required this.registrationPlanDigest,
    required this.aiProviderStateId,
    required this.aiProviderStateDigest,
    required this.digest,
  });

  factory DependencyActivationAuthorization.create({
    required DependencyRegistrationPlan registrationPlan,
    required RuntimeAIProviderState aiProviderState,
  }) {
    if (registrationPlan.id.isEmpty ||
        registrationPlan.digest.isEmpty ||
        registrationPlan.registrations.isEmpty ||
        aiProviderState.id.isEmpty ||
        aiProviderState.digest.isEmpty ||
        aiProviderState.entries.isEmpty) {
      throw ArgumentError('Dependency activation authorization is incomplete.');
    }
    final payload = {
      'version': dependencyActivationRuntimeVersion,
      'registrationPlanId': registrationPlan.id,
      'registrationPlanDigest': registrationPlan.digest,
      'aiProviderStateId': aiProviderState.id,
      'aiProviderStateDigest': aiProviderState.digest,
    };
    return DependencyActivationAuthorization._(
      registrationPlanId: registrationPlan.id,
      registrationPlanDigest: registrationPlan.digest,
      aiProviderStateId: aiProviderState.id,
      aiProviderStateDigest: aiProviderState.digest,
      digest: _digest(payload),
    );
  }

  final String registrationPlanId;
  final String registrationPlanDigest;
  final String aiProviderStateId;
  final String aiProviderStateDigest;
  final String digest;

  Map<String, dynamic> toJson() => {
        'version': dependencyActivationRuntimeVersion,
        'registrationPlanId': registrationPlanId,
        'registrationPlanDigest': registrationPlanDigest,
        'aiProviderStateId': aiProviderStateId,
        'aiProviderStateDigest': aiProviderStateDigest,
        'digest': digest,
      };
}

abstract interface class DependencyActivator {
  Future<List<DependencyActivationResult>> activate(
    DependencyActivationRequest request,
  );
}

class DependencyActivationTarget {
  const DependencyActivationTarget({
    required this.registrationId,
    required this.compositionEntryId,
    required this.activationId,
    required this.serviceId,
    required this.runtimeNodeId,
    required this.position,
    required this.registrationDigest,
  });

  final String registrationId;
  final String compositionEntryId;
  final String activationId;
  final String serviceId;
  final String runtimeNodeId;
  final int position;
  final String registrationDigest;

  Map<String, dynamic> toJson() => {
        'registrationId': registrationId,
        'compositionEntryId': compositionEntryId,
        'activationId': activationId,
        'serviceId': serviceId,
        'runtimeNodeId': runtimeNodeId,
        'position': position,
        'registrationDigest': registrationDigest,
      };
}

class DependencyActivationRequest {
  DependencyActivationRequest._({
    required this.authorizationDigest,
    required this.registrationPlanDigest,
    required this.aiProviderStateDigest,
    required List<DependencyActivationTarget> targets,
    required this.digest,
  }) : targets = List.unmodifiable(targets);

  final String authorizationDigest;
  final String registrationPlanDigest;
  final String aiProviderStateDigest;
  final List<DependencyActivationTarget> targets;
  final String digest;
}

class DependencyActivationResult {
  const DependencyActivationResult._({
    required this.registrationId,
    required this.activationHandleId,
    required this.requestDigest,
    required this.digest,
  });

  factory DependencyActivationResult.create({
    required String registrationId,
    required String activationHandleId,
    required String requestDigest,
  }) {
    if (registrationId.isEmpty ||
        activationHandleId.isEmpty ||
        requestDigest.isEmpty) {
      throw ArgumentError('Dependency activation result is incomplete.');
    }
    final payload = {
      'registrationId': registrationId,
      'activationHandleId': activationHandleId,
      'requestDigest': requestDigest,
    };
    return DependencyActivationResult._(
      registrationId: registrationId,
      activationHandleId: activationHandleId,
      requestDigest: requestDigest,
      digest: _digest(payload),
    );
  }

  final String registrationId;
  final String activationHandleId;
  final String requestDigest;
  final String digest;
}

class RuntimeDependencyActivationEntry {
  const RuntimeDependencyActivationEntry._({
    required this.registrationId,
    required this.activationId,
    required this.serviceId,
    required this.runtimeNodeId,
    required this.activationHandleId,
    required this.position,
    required this.registrationDigest,
    required this.resultDigest,
    required this.digest,
  });

  final String registrationId;
  final String activationId;
  final String serviceId;
  final String runtimeNodeId;
  final String activationHandleId;
  final int position;
  final String registrationDigest;
  final String resultDigest;
  final String digest;

  Map<String, dynamic> toJson() => {
        'registrationId': registrationId,
        'activationId': activationId,
        'serviceId': serviceId,
        'runtimeNodeId': runtimeNodeId,
        'activationHandleId': activationHandleId,
        'position': position,
        'registrationDigest': registrationDigest,
        'resultDigest': resultDigest,
        'digest': digest,
      };
}

class RuntimeDependencyActivationState {
  RuntimeDependencyActivationState._({
    required this.id,
    required this.authorizationDigest,
    required this.registrationPlanId,
    required this.registrationPlanDigest,
    required this.aiProviderStateId,
    required this.aiProviderStateDigest,
    required this.requestDigest,
    required List<RuntimeDependencyActivationEntry> entries,
    required this.digest,
  }) : entries = List.unmodifiable(entries);

  final String id;
  final String authorizationDigest;
  final String registrationPlanId;
  final String registrationPlanDigest;
  final String aiProviderStateId;
  final String aiProviderStateDigest;
  final String requestDigest;
  final List<RuntimeDependencyActivationEntry> entries;
  final String digest;

  Map<String, dynamic> toJson() => {
        'version': dependencyActivationRuntimeVersion,
        'policyVersion': dependencyActivationPolicyVersion,
        'id': id,
        'authorizationDigest': authorizationDigest,
        'registrationPlanId': registrationPlanId,
        'registrationPlanDigest': registrationPlanDigest,
        'aiProviderStateId': aiProviderStateId,
        'aiProviderStateDigest': aiProviderStateDigest,
        'requestDigest': requestDigest,
        'entries': entries.map((entry) => entry.toJson()).toList(),
        'digest': digest,
      };
}

class DependencyActivationRuntime {
  const DependencyActivationRuntime();

  Future<RuntimeDependencyActivationState> activate({
    required DependencyRegistrationPlan registrationPlan,
    required RuntimeAIProviderState aiProviderState,
    required DependencyActivationAuthorization authorization,
    required DependencyActivator activator,
  }) async {
    final expectedAuthorization = DependencyActivationAuthorization.create(
      registrationPlan: registrationPlan,
      aiProviderState: aiProviderState,
    );
    if (authorization.registrationPlanId !=
            expectedAuthorization.registrationPlanId ||
        authorization.registrationPlanDigest !=
            expectedAuthorization.registrationPlanDigest ||
        authorization.aiProviderStateId !=
            expectedAuthorization.aiProviderStateId ||
        authorization.aiProviderStateDigest !=
            expectedAuthorization.aiProviderStateDigest ||
        authorization.digest != expectedAuthorization.digest) {
      throw ArgumentError('Dependency activation authorization is invalid.');
    }
    final ordered = [...registrationPlan.registrations]
      ..sort((left, right) => left.position.compareTo(right.position));
    final ids = <String>{};
    final targets = <DependencyActivationTarget>[];
    for (var position = 0; position < ordered.length; position++) {
      final entry = ordered[position];
      if (entry.position != position ||
          entry.registrationId.isEmpty ||
          entry.digest.isEmpty ||
          !ids.add(entry.registrationId)) {
        throw ArgumentError('Dependency registration ownership is invalid.');
      }
      targets.add(DependencyActivationTarget(
        registrationId: entry.registrationId,
        compositionEntryId: entry.compositionEntryId,
        activationId: entry.activationId,
        serviceId: entry.serviceId,
        runtimeNodeId: entry.runtimeNodeId,
        position: position,
        registrationDigest: entry.digest,
      ));
    }
    final requestPayload = {
      'version': dependencyActivationRuntimeVersion,
      'authorizationDigest': authorization.digest,
      'registrationPlanDigest': registrationPlan.digest,
      'aiProviderStateDigest': aiProviderState.digest,
      'targets': targets.map((entry) => entry.toJson()).toList(),
    };
    final request = DependencyActivationRequest._(
      authorizationDigest: authorization.digest,
      registrationPlanDigest: registrationPlan.digest,
      aiProviderStateDigest: aiProviderState.digest,
      targets: targets,
      digest: _digest(requestPayload),
    );
    final results = await activator.activate(request);
    final byId = <String, DependencyActivationResult>{};
    final handles = <String>{};
    for (final result in results) {
      final expected = DependencyActivationResult.create(
        registrationId: result.registrationId,
        activationHandleId: result.activationHandleId,
        requestDigest: request.digest,
      );
      if (result.requestDigest != request.digest ||
          result.digest != expected.digest ||
          byId.containsKey(result.registrationId) ||
          !handles.add(result.activationHandleId)) {
        throw StateError('Dependency activation result is invalid.');
      }
      byId[result.registrationId] = result;
    }
    if (byId.length != targets.length ||
        byId.keys.any((id) => !ids.contains(id))) {
      throw StateError('Dependency activation coverage is invalid.');
    }
    final entries = <RuntimeDependencyActivationEntry>[];
    for (final target in targets) {
      final result = byId[target.registrationId]!;
      final payload = {
        ...target.toJson(),
        'activationHandleId': result.activationHandleId,
        'resultDigest': result.digest,
      };
      entries.add(RuntimeDependencyActivationEntry._(
        registrationId: target.registrationId,
        activationId: target.activationId,
        serviceId: target.serviceId,
        runtimeNodeId: target.runtimeNodeId,
        activationHandleId: result.activationHandleId,
        position: target.position,
        registrationDigest: target.registrationDigest,
        resultDigest: result.digest,
        digest: _digest(payload),
      ));
    }
    final payload = {
      ...requestPayload,
      'requestDigest': request.digest,
      'entries': entries.map((entry) => entry.toJson()).toList(),
    };
    final digest = _digest(payload);
    return RuntimeDependencyActivationState._(
      id: 'runtime-dependency-activation.${digest.substring(0, 16)}',
      authorizationDigest: authorization.digest,
      registrationPlanId: registrationPlan.id,
      registrationPlanDigest: registrationPlan.digest,
      aiProviderStateId: aiProviderState.id,
      aiProviderStateDigest: aiProviderState.digest,
      requestDigest: request.digest,
      entries: entries,
      digest: digest,
    );
  }
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
