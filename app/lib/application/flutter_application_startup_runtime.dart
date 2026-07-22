import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/application/flutter_application_adapter_planner.dart';
import 'package:pool_os/application/runtime_execution_orchestrator.dart';

const flutterApplicationStartupRuntimeVersion = 1;
const flutterApplicationStartupPolicyVersion =
    'flutter-application-startup/1.0.0';

enum FlutterStartupLogPhase {
  validateAuthorization,
  orderStartup,
  bindFlutterCoverage,
  invokeFlutterExecutor,
  completed,
}

class FlutterStartupAuthorization {
  const FlutterStartupAuthorization._({
    required this.runtimeExecutionStateId,
    required this.runtimeExecutionStateDigest,
    required this.flutterApplicationAdapterPlanId,
    required this.flutterApplicationAdapterPlanDigest,
    required this.digest,
  });

  factory FlutterStartupAuthorization.create({
    required RuntimeExecutionState runtimeExecutionState,
    required FlutterApplicationAdapterPlan flutterApplicationAdapterPlan,
  }) {
    if (runtimeExecutionState.id.isEmpty ||
        runtimeExecutionState.digest.isEmpty ||
        runtimeExecutionState.entries.isEmpty ||
        flutterApplicationAdapterPlan.id.isEmpty ||
        flutterApplicationAdapterPlan.digest.isEmpty ||
        flutterApplicationAdapterPlan.entries.isEmpty) {
      throw ArgumentError('Flutter startup authorization is incomplete.');
    }
    final payload = {
      'version': flutterApplicationStartupRuntimeVersion,
      'runtimeExecutionStateId': runtimeExecutionState.id,
      'runtimeExecutionStateDigest': runtimeExecutionState.digest,
      'flutterApplicationAdapterPlanId': flutterApplicationAdapterPlan.id,
      'flutterApplicationAdapterPlanDigest':
          flutterApplicationAdapterPlan.digest,
    };
    return FlutterStartupAuthorization._(
      runtimeExecutionStateId: runtimeExecutionState.id,
      runtimeExecutionStateDigest: runtimeExecutionState.digest,
      flutterApplicationAdapterPlanId: flutterApplicationAdapterPlan.id,
      flutterApplicationAdapterPlanDigest: flutterApplicationAdapterPlan.digest,
      digest: _digest(payload),
    );
  }

  final String runtimeExecutionStateId;
  final String runtimeExecutionStateDigest;
  final String flutterApplicationAdapterPlanId;
  final String flutterApplicationAdapterPlanDigest;
  final String digest;
}

abstract interface class FlutterStartupExecutor {
  Future<List<FlutterStartupResult>> start(FlutterStartupRequest request);
}

class FlutterStartupTarget {
  const FlutterStartupTarget({
    required this.startupTargetId,
    required this.adapterEntryId,
    required this.featureId,
    required this.compositionEntryId,
    required this.position,
    required this.adapterEntryDigest,
    required this.authorizationDigest,
  });

  final String startupTargetId;
  final String adapterEntryId;
  final String featureId;
  final String compositionEntryId;
  final int position;
  final String adapterEntryDigest;
  final String authorizationDigest;

  Map<String, dynamic> toJson() => {
        'startupTargetId': startupTargetId,
        'adapterEntryId': adapterEntryId,
        'featureId': featureId,
        'compositionEntryId': compositionEntryId,
        'position': position,
        'adapterEntryDigest': adapterEntryDigest,
        'authorizationDigest': authorizationDigest,
      };
}

class FlutterStartupRequest {
  FlutterStartupRequest._({
    required this.authorizationDigest,
    required this.runtimeExecutionStateDigest,
    required this.flutterApplicationAdapterPlanDigest,
    required List<FlutterStartupTarget> targets,
    required this.digest,
  }) : targets = List.unmodifiable(targets);

  final String authorizationDigest;
  final String runtimeExecutionStateDigest;
  final String flutterApplicationAdapterPlanDigest;
  final List<FlutterStartupTarget> targets;
  final String digest;
}

class FlutterStartupResult {
  const FlutterStartupResult._({
    required this.startupTargetId,
    required this.startupHandleId,
    required this.requestDigest,
    required this.digest,
  });

  factory FlutterStartupResult.create({
    required String startupTargetId,
    required String startupHandleId,
    required String requestDigest,
  }) {
    if (startupTargetId.isEmpty ||
        startupHandleId.isEmpty ||
        requestDigest.isEmpty) {
      throw ArgumentError('Flutter startup result is incomplete.');
    }
    final payload = {
      'startupTargetId': startupTargetId,
      'startupHandleId': startupHandleId,
      'requestDigest': requestDigest,
    };
    return FlutterStartupResult._(
      startupTargetId: startupTargetId,
      startupHandleId: startupHandleId,
      requestDigest: requestDigest,
      digest: _digest(payload),
    );
  }

  final String startupTargetId;
  final String startupHandleId;
  final String requestDigest;
  final String digest;
}

class RuntimeFlutterStartupEntry {
  const RuntimeFlutterStartupEntry._({
    required this.startupTargetId,
    required this.adapterEntryId,
    required this.featureId,
    required this.compositionEntryId,
    required this.position,
    required this.startupHandleId,
    required this.authorizationDigest,
    required this.resultDigest,
    required this.digest,
  });

  final String startupTargetId;
  final String adapterEntryId;
  final String featureId;
  final String compositionEntryId;
  final int position;
  final String startupHandleId;
  final String authorizationDigest;
  final String resultDigest;
  final String digest;

  Map<String, dynamic> toJson() => {
        'startupTargetId': startupTargetId,
        'adapterEntryId': adapterEntryId,
        'featureId': featureId,
        'compositionEntryId': compositionEntryId,
        'position': position,
        'startupHandleId': startupHandleId,
        'authorizationDigest': authorizationDigest,
        'resultDigest': resultDigest,
        'digest': digest,
      };
}

class FlutterStartupLogEntry {
  const FlutterStartupLogEntry._({
    required this.phase,
    required this.position,
    required this.authorizationDigest,
    required this.startupSetDigest,
    required this.digest,
  });

  factory FlutterStartupLogEntry.create({
    required FlutterStartupLogPhase phase,
    required int position,
    required String authorizationDigest,
    required String startupSetDigest,
  }) {
    if (position < 0 ||
        authorizationDigest.isEmpty ||
        startupSetDigest.isEmpty) {
      throw ArgumentError('Flutter startup log entry is incomplete.');
    }
    final payload = {
      'phase': phase.name,
      'position': position,
      'authorizationDigest': authorizationDigest,
      'startupSetDigest': startupSetDigest,
      'eventCode': 'flutter-startup.${phase.name}',
    };
    return FlutterStartupLogEntry._(
      phase: phase,
      position: position,
      authorizationDigest: authorizationDigest,
      startupSetDigest: startupSetDigest,
      digest: _digest(payload),
    );
  }

  final FlutterStartupLogPhase phase;
  final int position;
  final String authorizationDigest;
  final String startupSetDigest;
  final String digest;

  Map<String, dynamic> toJson() => {
        'phase': phase.name,
        'position': position,
        'authorizationDigest': authorizationDigest,
        'startupSetDigest': startupSetDigest,
        'eventCode': 'flutter-startup.${phase.name}',
        'digest': digest,
      };
}

class RuntimeFlutterStartupState {
  RuntimeFlutterStartupState._({
    required this.id,
    required this.authorizationDigest,
    required this.runtimeExecutionStateId,
    required this.runtimeExecutionStateDigest,
    required this.flutterApplicationAdapterPlanId,
    required this.flutterApplicationAdapterPlanDigest,
    required this.requestDigest,
    required List<RuntimeFlutterStartupEntry> entries,
    required List<FlutterStartupLogEntry> log,
    required this.digest,
  })  : entries = List.unmodifiable(entries),
        log = List.unmodifiable(log);

  final String id;
  final String authorizationDigest;
  final String runtimeExecutionStateId;
  final String runtimeExecutionStateDigest;
  final String flutterApplicationAdapterPlanId;
  final String flutterApplicationAdapterPlanDigest;
  final String requestDigest;
  final List<RuntimeFlutterStartupEntry> entries;
  final List<FlutterStartupLogEntry> log;
  final String digest;

  Map<String, dynamic> toJson() => {
        'version': flutterApplicationStartupRuntimeVersion,
        'policyVersion': flutterApplicationStartupPolicyVersion,
        'id': id,
        'authorizationDigest': authorizationDigest,
        'runtimeExecutionStateId': runtimeExecutionStateId,
        'runtimeExecutionStateDigest': runtimeExecutionStateDigest,
        'flutterApplicationAdapterPlanId': flutterApplicationAdapterPlanId,
        'flutterApplicationAdapterPlanDigest':
            flutterApplicationAdapterPlanDigest,
        'requestDigest': requestDigest,
        'entries': entries.map((entry) => entry.toJson()).toList(),
        'log': log.map((entry) => entry.toJson()).toList(),
        'digest': digest,
      };
}

class FlutterApplicationStartupRuntime {
  const FlutterApplicationStartupRuntime();

  Future<RuntimeFlutterStartupState> start({
    required RuntimeExecutionState runtimeExecutionState,
    required FlutterApplicationAdapterPlan flutterApplicationAdapterPlan,
    required FlutterStartupAuthorization authorization,
    required FlutterStartupExecutor executor,
  }) async {
    final expectedAuthorization = FlutterStartupAuthorization.create(
      runtimeExecutionState: runtimeExecutionState,
      flutterApplicationAdapterPlan: flutterApplicationAdapterPlan,
    );
    if (authorization.runtimeExecutionStateId !=
            expectedAuthorization.runtimeExecutionStateId ||
        authorization.runtimeExecutionStateDigest !=
            expectedAuthorization.runtimeExecutionStateDigest ||
        authorization.flutterApplicationAdapterPlanId !=
            expectedAuthorization.flutterApplicationAdapterPlanId ||
        authorization.flutterApplicationAdapterPlanDigest !=
            expectedAuthorization.flutterApplicationAdapterPlanDigest ||
        authorization.digest != expectedAuthorization.digest) {
      throw ArgumentError('Flutter startup authorization is invalid.');
    }
    final ordered = [...flutterApplicationAdapterPlan.entries]
      ..sort((left, right) => left.position.compareTo(right.position));
    final adapterIds = <String>{};
    final featureIds = <String>{};
    final compositionIds = <String>{};
    final targets = <FlutterStartupTarget>[];
    for (var position = 0; position < ordered.length; position++) {
      final entry = ordered[position];
      final expected = FlutterApplicationAdapterEntry.create(
        featureId: entry.featureId,
        compositionEntryId: entry.compositionEntryId,
        position: position,
        applicationCompositionPlanDigest:
            flutterApplicationAdapterPlan.applicationCompositionPlanDigest,
        bootstrapHostRunDigest:
            flutterApplicationAdapterPlan.bootstrapHostRunDigest,
      );
      if (entry.position != position ||
          entry.adapterEntryId != expected.adapterEntryId ||
          entry.applicationCompositionPlanDigest !=
              expected.applicationCompositionPlanDigest ||
          entry.bootstrapHostRunDigest != expected.bootstrapHostRunDigest ||
          entry.provenanceDigest != expected.provenanceDigest ||
          entry.digest != expected.digest ||
          !adapterIds.add(entry.adapterEntryId) ||
          !featureIds.add(entry.featureId) ||
          !compositionIds.add(entry.compositionEntryId)) {
        throw ArgumentError('Flutter startup coverage is invalid.');
      }
      targets.add(FlutterStartupTarget(
        startupTargetId: 'flutter-startup-target.${entry.adapterEntryId}',
        adapterEntryId: entry.adapterEntryId,
        featureId: entry.featureId,
        compositionEntryId: entry.compositionEntryId,
        position: position,
        adapterEntryDigest: entry.digest,
        authorizationDigest: authorization.digest,
      ));
    }
    final requestPayload = {
      'version': flutterApplicationStartupRuntimeVersion,
      'authorizationDigest': authorization.digest,
      'runtimeExecutionStateDigest': runtimeExecutionState.digest,
      'flutterApplicationAdapterPlanDigest':
          flutterApplicationAdapterPlan.digest,
      'targets': targets.map((target) => target.toJson()).toList(),
    };
    final request = FlutterStartupRequest._(
      authorizationDigest: authorization.digest,
      runtimeExecutionStateDigest: runtimeExecutionState.digest,
      flutterApplicationAdapterPlanDigest: flutterApplicationAdapterPlan.digest,
      targets: targets,
      digest: _digest(requestPayload),
    );
    final results = await executor.start(request);
    final byId = <String, FlutterStartupResult>{};
    final handles = <String>{};
    for (final result in results) {
      final expected = FlutterStartupResult.create(
        startupTargetId: result.startupTargetId,
        startupHandleId: result.startupHandleId,
        requestDigest: request.digest,
      );
      if (result.requestDigest != request.digest ||
          result.digest != expected.digest ||
          byId.containsKey(result.startupTargetId) ||
          !handles.add(result.startupHandleId)) {
        throw StateError('Flutter startup executor result is invalid.');
      }
      byId[result.startupTargetId] = result;
    }
    final targetIds = targets.map((target) => target.startupTargetId).toSet();
    if (byId.length != targets.length ||
        byId.keys.any((id) => !targetIds.contains(id))) {
      throw StateError('Flutter startup executor coverage is invalid.');
    }
    final entries = <RuntimeFlutterStartupEntry>[];
    for (final target in targets) {
      final result = byId[target.startupTargetId]!;
      final payload = {
        ...target.toJson(),
        'startupHandleId': result.startupHandleId,
        'resultDigest': result.digest,
      };
      entries.add(RuntimeFlutterStartupEntry._(
        startupTargetId: target.startupTargetId,
        adapterEntryId: target.adapterEntryId,
        featureId: target.featureId,
        compositionEntryId: target.compositionEntryId,
        position: target.position,
        startupHandleId: result.startupHandleId,
        authorizationDigest: authorization.digest,
        resultDigest: result.digest,
        digest: _digest(payload),
      ));
    }
    final startupSetDigest =
        _digest(entries.map((entry) => entry.toJson()).toList());
    final log = [
      for (var position = 0;
          position < FlutterStartupLogPhase.values.length;
          position++)
        FlutterStartupLogEntry.create(
          phase: FlutterStartupLogPhase.values[position],
          position: position,
          authorizationDigest: authorization.digest,
          startupSetDigest: startupSetDigest,
        ),
    ];
    final payload = {
      ...requestPayload,
      'requestDigest': request.digest,
      'entries': entries.map((entry) => entry.toJson()).toList(),
      'log': log.map((entry) => entry.toJson()).toList(),
    };
    final digest = _digest(payload);
    return RuntimeFlutterStartupState._(
      id: 'runtime-flutter-startup.${digest.substring(0, 16)}',
      authorizationDigest: authorization.digest,
      runtimeExecutionStateId: runtimeExecutionState.id,
      runtimeExecutionStateDigest: runtimeExecutionState.digest,
      flutterApplicationAdapterPlanId: flutterApplicationAdapterPlan.id,
      flutterApplicationAdapterPlanDigest: flutterApplicationAdapterPlan.digest,
      requestDigest: request.digest,
      entries: entries,
      log: log,
      digest: digest,
    );
  }
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
