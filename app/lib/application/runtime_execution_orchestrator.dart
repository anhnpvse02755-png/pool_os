import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/application/dependency_activation_runtime.dart';
import 'package:pool_os/contracts/runtime_lifecycle_host_projection_contracts.dart';

const runtimeExecutionOrchestrationVersion = 1;
const runtimeExecutionOrchestrationPolicyVersion =
    'runtime-execution-orchestration/1.0.0';

enum RuntimeExecutionLogPhase {
  validateAuthorization,
  orderExecution,
  bindLifecycleCoverage,
  invokeRuntimeExecutor,
  completed,
}

class RuntimeExecutionAuthorization {
  const RuntimeExecutionAuthorization._({
    required this.activationStateId,
    required this.activationStateDigest,
    required this.lifecycleHostProjectionId,
    required this.lifecycleHostProjectionDigest,
    required this.digest,
  });

  factory RuntimeExecutionAuthorization.create({
    required RuntimeDependencyActivationState activationState,
    required RuntimeLifecycleHostProjectionContract lifecycleHostProjection,
  }) {
    if (activationState.id.isEmpty ||
        activationState.digest.isEmpty ||
        activationState.entries.isEmpty ||
        lifecycleHostProjection.id.isEmpty ||
        lifecycleHostProjection.digest.isEmpty ||
        lifecycleHostProjection.entries.isEmpty) {
      throw ArgumentError('Runtime execution authorization is incomplete.');
    }
    final payload = {
      'version': runtimeExecutionOrchestrationVersion,
      'activationStateId': activationState.id,
      'activationStateDigest': activationState.digest,
      'lifecycleHostProjectionId': lifecycleHostProjection.id,
      'lifecycleHostProjectionDigest': lifecycleHostProjection.digest,
    };
    return RuntimeExecutionAuthorization._(
      activationStateId: activationState.id,
      activationStateDigest: activationState.digest,
      lifecycleHostProjectionId: lifecycleHostProjection.id,
      lifecycleHostProjectionDigest: lifecycleHostProjection.digest,
      digest: _digest(payload),
    );
  }

  final String activationStateId;
  final String activationStateDigest;
  final String lifecycleHostProjectionId;
  final String lifecycleHostProjectionDigest;
  final String digest;

  Map<String, dynamic> toJson() => {
        'version': runtimeExecutionOrchestrationVersion,
        'activationStateId': activationStateId,
        'activationStateDigest': activationStateDigest,
        'lifecycleHostProjectionId': lifecycleHostProjectionId,
        'lifecycleHostProjectionDigest': lifecycleHostProjectionDigest,
        'digest': digest,
      };
}

abstract interface class RuntimeExecutor {
  Future<List<RuntimeExecutionResult>> execute(RuntimeExecutionRequest request);
}

class RuntimeExecutionTarget {
  const RuntimeExecutionTarget({
    required this.executionEntryId,
    required this.activationId,
    required this.serviceId,
    required this.runtimeNodeId,
    required this.lifecyclePhase,
    required this.canonicalPosition,
    required this.authorizationDigest,
    required this.lifecycleDigest,
  });

  final String executionEntryId;
  final String activationId;
  final String serviceId;
  final String runtimeNodeId;
  final String lifecyclePhase;
  final int canonicalPosition;
  final String authorizationDigest;
  final String lifecycleDigest;

  Map<String, dynamic> toJson() => {
        'executionEntryId': executionEntryId,
        'activationId': activationId,
        'serviceId': serviceId,
        'runtimeNodeId': runtimeNodeId,
        'lifecyclePhase': lifecyclePhase,
        'canonicalPosition': canonicalPosition,
        'authorizationDigest': authorizationDigest,
        'lifecycleDigest': lifecycleDigest,
      };
}

class RuntimeExecutionRequest {
  RuntimeExecutionRequest._({
    required this.authorizationDigest,
    required this.activationStateDigest,
    required this.lifecycleHostProjectionDigest,
    required List<RuntimeExecutionTarget> targets,
    required this.digest,
  }) : targets = List.unmodifiable(targets);

  final String authorizationDigest;
  final String activationStateDigest;
  final String lifecycleHostProjectionDigest;
  final List<RuntimeExecutionTarget> targets;
  final String digest;
}

class RuntimeExecutionResult {
  const RuntimeExecutionResult._({
    required this.executionEntryId,
    required this.executionHandleId,
    required this.requestDigest,
    required this.digest,
  });

  factory RuntimeExecutionResult.create({
    required String executionEntryId,
    required String executionHandleId,
    required String requestDigest,
  }) {
    if (executionEntryId.isEmpty ||
        executionHandleId.isEmpty ||
        requestDigest.isEmpty) {
      throw ArgumentError('Runtime execution result is incomplete.');
    }
    final payload = {
      'executionEntryId': executionEntryId,
      'executionHandleId': executionHandleId,
      'requestDigest': requestDigest,
    };
    return RuntimeExecutionResult._(
      executionEntryId: executionEntryId,
      executionHandleId: executionHandleId,
      requestDigest: requestDigest,
      digest: _digest(payload),
    );
  }

  final String executionEntryId;
  final String executionHandleId;
  final String requestDigest;
  final String digest;
}

class RuntimeExecutionEntry {
  const RuntimeExecutionEntry._({
    required this.executionEntryId,
    required this.activationId,
    required this.serviceId,
    required this.runtimeNodeId,
    required this.lifecyclePhase,
    required this.canonicalPosition,
    required this.executionHandleId,
    required this.authorizationDigest,
    required this.lifecycleDigest,
    required this.resultDigest,
    required this.digest,
  });

  final String executionEntryId;
  final String activationId;
  final String serviceId;
  final String runtimeNodeId;
  final String lifecyclePhase;
  final int canonicalPosition;
  final String executionHandleId;
  final String authorizationDigest;
  final String lifecycleDigest;
  final String resultDigest;
  final String digest;

  Map<String, dynamic> toJson() => {
        'executionEntryId': executionEntryId,
        'activationId': activationId,
        'serviceId': serviceId,
        'runtimeNodeId': runtimeNodeId,
        'lifecyclePhase': lifecyclePhase,
        'canonicalPosition': canonicalPosition,
        'executionHandleId': executionHandleId,
        'authorizationDigest': authorizationDigest,
        'lifecycleDigest': lifecycleDigest,
        'resultDigest': resultDigest,
        'digest': digest,
      };
}

class RuntimeExecutionLogEntry {
  const RuntimeExecutionLogEntry._({
    required this.phase,
    required this.position,
    required this.authorizationDigest,
    required this.executionSetDigest,
    required this.eventCode,
    required this.digest,
  });

  factory RuntimeExecutionLogEntry.create({
    required RuntimeExecutionLogPhase phase,
    required int position,
    required String authorizationDigest,
    required String executionSetDigest,
  }) {
    if (position < 0 ||
        authorizationDigest.isEmpty ||
        executionSetDigest.isEmpty) {
      throw ArgumentError('Runtime execution log entry is incomplete.');
    }
    final eventCode = 'runtime-execution.${phase.name}';
    final payload = {
      'phase': phase.name,
      'position': position,
      'authorizationDigest': authorizationDigest,
      'executionSetDigest': executionSetDigest,
      'eventCode': eventCode,
    };
    return RuntimeExecutionLogEntry._(
      phase: phase,
      position: position,
      authorizationDigest: authorizationDigest,
      executionSetDigest: executionSetDigest,
      eventCode: eventCode,
      digest: _digest(payload),
    );
  }

  final RuntimeExecutionLogPhase phase;
  final int position;
  final String authorizationDigest;
  final String executionSetDigest;
  final String eventCode;
  final String digest;

  Map<String, dynamic> toJson() => {
        'phase': phase.name,
        'position': position,
        'authorizationDigest': authorizationDigest,
        'executionSetDigest': executionSetDigest,
        'eventCode': eventCode,
        'digest': digest,
      };
}

class RuntimeExecutionState {
  RuntimeExecutionState._({
    required this.id,
    required this.authorizationDigest,
    required this.activationStateId,
    required this.activationStateDigest,
    required this.lifecycleHostProjectionId,
    required this.lifecycleHostProjectionDigest,
    required this.requestDigest,
    required List<RuntimeExecutionEntry> entries,
    required List<RuntimeExecutionLogEntry> log,
    required this.digest,
  })  : entries = List.unmodifiable(entries),
        log = List.unmodifiable(log);

  final String id;
  final String authorizationDigest;
  final String activationStateId;
  final String activationStateDigest;
  final String lifecycleHostProjectionId;
  final String lifecycleHostProjectionDigest;
  final String requestDigest;
  final List<RuntimeExecutionEntry> entries;
  final List<RuntimeExecutionLogEntry> log;
  final String digest;

  Map<String, dynamic> toJson() => {
        'version': runtimeExecutionOrchestrationVersion,
        'policyVersion': runtimeExecutionOrchestrationPolicyVersion,
        'id': id,
        'authorizationDigest': authorizationDigest,
        'activationStateId': activationStateId,
        'activationStateDigest': activationStateDigest,
        'lifecycleHostProjectionId': lifecycleHostProjectionId,
        'lifecycleHostProjectionDigest': lifecycleHostProjectionDigest,
        'requestDigest': requestDigest,
        'entries': entries.map((entry) => entry.toJson()).toList(),
        'log': log.map((entry) => entry.toJson()).toList(),
        'digest': digest,
      };
}

class RuntimeExecutionOrchestrator {
  const RuntimeExecutionOrchestrator();

  Future<RuntimeExecutionState> execute({
    required RuntimeDependencyActivationState activationState,
    required RuntimeLifecycleHostProjectionContract lifecycleHostProjection,
    required RuntimeExecutionAuthorization authorization,
    required RuntimeExecutor executor,
  }) async {
    final expectedAuthorization = RuntimeExecutionAuthorization.create(
      activationState: activationState,
      lifecycleHostProjection: lifecycleHostProjection,
    );
    if (authorization.activationStateId !=
            expectedAuthorization.activationStateId ||
        authorization.activationStateDigest !=
            expectedAuthorization.activationStateDigest ||
        authorization.lifecycleHostProjectionId !=
            expectedAuthorization.lifecycleHostProjectionId ||
        authorization.lifecycleHostProjectionDigest !=
            expectedAuthorization.lifecycleHostProjectionDigest ||
        authorization.digest != expectedAuthorization.digest) {
      throw ArgumentError('Runtime execution authorization is invalid.');
    }

    final activated = [...activationState.entries]
      ..sort((left, right) => left.position.compareTo(right.position));
    final lifecycle = [...lifecycleHostProjection.entries]..sort(
        (left, right) =>
            left.canonicalPosition.compareTo(right.canonicalPosition));
    if (activated.length != lifecycle.length) {
      throw ArgumentError('Runtime execution coverage is incomplete.');
    }
    final activationIds = <String>{};
    final serviceIds = <String>{};
    final runtimeNodeIds = <String>{};
    final targets = <RuntimeExecutionTarget>[];
    for (var position = 0; position < activated.length; position++) {
      final activation = activated[position];
      final host = lifecycle[position];
      if (activation.position != position ||
          host.canonicalPosition != position ||
          activation.activationId.isEmpty ||
          activation.serviceId.isEmpty ||
          activation.runtimeNodeId.isEmpty ||
          activation.activationId != host.activationId ||
          activation.serviceId != host.serviceId ||
          activation.runtimeNodeId != host.runtimeNodeId ||
          !activationIds.add(activation.activationId) ||
          !serviceIds.add(activation.serviceId) ||
          !runtimeNodeIds.add(activation.runtimeNodeId)) {
        throw ArgumentError('Runtime lifecycle coverage is invalid.');
      }
      final identityPayload = {
        'activationId': activation.activationId,
        'serviceId': activation.serviceId,
        'runtimeNodeId': activation.runtimeNodeId,
        'canonicalPosition': position,
      };
      targets.add(RuntimeExecutionTarget(
        executionEntryId:
            'runtime-execution-entry.${_digest(identityPayload).substring(0, 16)}',
        activationId: activation.activationId,
        serviceId: activation.serviceId,
        runtimeNodeId: activation.runtimeNodeId,
        lifecyclePhase: host.lifecyclePhase.name,
        canonicalPosition: position,
        authorizationDigest: authorization.digest,
        lifecycleDigest: lifecycleHostProjection.digest,
      ));
    }

    final requestPayload = {
      'version': runtimeExecutionOrchestrationVersion,
      'authorizationDigest': authorization.digest,
      'activationStateDigest': activationState.digest,
      'lifecycleHostProjectionDigest': lifecycleHostProjection.digest,
      'targets': targets.map((target) => target.toJson()).toList(),
    };
    final request = RuntimeExecutionRequest._(
      authorizationDigest: authorization.digest,
      activationStateDigest: activationState.digest,
      lifecycleHostProjectionDigest: lifecycleHostProjection.digest,
      targets: targets,
      digest: _digest(requestPayload),
    );
    final results = await executor.execute(request);
    final resultsById = <String, RuntimeExecutionResult>{};
    final handles = <String>{};
    for (final result in results) {
      final expected = RuntimeExecutionResult.create(
        executionEntryId: result.executionEntryId,
        executionHandleId: result.executionHandleId,
        requestDigest: request.digest,
      );
      if (result.requestDigest != request.digest ||
          result.digest != expected.digest ||
          resultsById.containsKey(result.executionEntryId) ||
          !handles.add(result.executionHandleId)) {
        throw StateError('Runtime executor result is invalid.');
      }
      resultsById[result.executionEntryId] = result;
    }
    final targetIds = targets.map((target) => target.executionEntryId).toSet();
    if (resultsById.length != targets.length ||
        resultsById.keys.any((id) => !targetIds.contains(id))) {
      throw StateError('Runtime executor coverage is invalid.');
    }

    final entries = <RuntimeExecutionEntry>[];
    for (final target in targets) {
      final result = resultsById[target.executionEntryId]!;
      final payload = {
        ...target.toJson(),
        'executionHandleId': result.executionHandleId,
        'resultDigest': result.digest,
      };
      entries.add(RuntimeExecutionEntry._(
        executionEntryId: target.executionEntryId,
        activationId: target.activationId,
        serviceId: target.serviceId,
        runtimeNodeId: target.runtimeNodeId,
        lifecyclePhase: target.lifecyclePhase,
        canonicalPosition: target.canonicalPosition,
        executionHandleId: result.executionHandleId,
        authorizationDigest: authorization.digest,
        lifecycleDigest: lifecycleHostProjection.digest,
        resultDigest: result.digest,
        digest: _digest(payload),
      ));
    }
    final executionSetDigest =
        _digest(entries.map((entry) => entry.toJson()).toList());
    final log = [
      for (var position = 0;
          position < RuntimeExecutionLogPhase.values.length;
          position++)
        RuntimeExecutionLogEntry.create(
          phase: RuntimeExecutionLogPhase.values[position],
          position: position,
          authorizationDigest: authorization.digest,
          executionSetDigest: executionSetDigest,
        ),
    ];
    final payload = {
      ...requestPayload,
      'requestDigest': request.digest,
      'entries': entries.map((entry) => entry.toJson()).toList(),
      'log': log.map((entry) => entry.toJson()).toList(),
    };
    final digest = _digest(payload);
    return RuntimeExecutionState._(
      id: 'runtime-execution.${digest.substring(0, 16)}',
      authorizationDigest: authorization.digest,
      activationStateId: activationState.id,
      activationStateDigest: activationState.digest,
      lifecycleHostProjectionId: lifecycleHostProjection.id,
      lifecycleHostProjectionDigest: lifecycleHostProjection.digest,
      requestDigest: request.digest,
      entries: entries,
      log: log,
      digest: digest,
    );
  }
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
