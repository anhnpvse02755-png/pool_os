import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/application/dependency_activation_runtime.dart';
import 'package:pool_os/application/runtime_execution_orchestrator.dart';
import 'package:pool_os/contracts/runtime_lifecycle_host_projection_contracts.dart';
import 'package:pool_os/contracts/runtime_lifecycle_projection_contracts.dart';

void main() {
  final fixture = _fixture();

  test('orchestrates deterministic execution through abstract port', () async {
    final executor = _Executor();
    final state = await const RuntimeExecutionOrchestrator().execute(
      activationState: fixture.activation,
      lifecycleHostProjection: fixture.lifecycle,
      authorization: fixture.authorization,
      executor: executor,
    );

    expect(state.entries, hasLength(2));
    expect(state.entries.first.activationId, 'activation.0');
    expect(state.entries.first.lifecyclePhase, 'initialized');
    expect(state.requestDigest, executor.request!.digest);
    expect(
      state.log.map((entry) => entry.phase),
      RuntimeExecutionLogPhase.values,
    );
    expect(state.digest, hasLength(64));
  });

  test('reordered executor results replay identically', () async {
    final first = await _execute(fixture, _Executor());
    final replay = await _execute(fixture, _Executor(reverse: true));
    expect(replay.toJson(), first.toJson());
  });

  test('stale activation and lifecycle authorization fail before executor',
      () async {
    final staleActivation = _ActivationState(
      fixture.activation.entries,
      digest: 'stale-activation',
    );
    final staleLifecycle = _LifecycleProjection(
      fixture.lifecycle.entries,
      digest: 'stale-lifecycle',
    );
    for (final authorization in [
      RuntimeExecutionAuthorization.create(
        activationState: staleActivation,
        lifecycleHostProjection: fixture.lifecycle,
      ),
      RuntimeExecutionAuthorization.create(
        activationState: fixture.activation,
        lifecycleHostProjection: staleLifecycle,
      ),
    ]) {
      final executor = _Executor();
      await expectLater(
        const RuntimeExecutionOrchestrator().execute(
          activationState: fixture.activation,
          lifecycleHostProjection: fixture.lifecycle,
          authorization: authorization,
          executor: executor,
        ),
        throwsArgumentError,
      );
      expect(executor.calls, 0);
    }
  });

  test('structural identity mismatch fails closed before executor', () async {
    for (final lifecycle in [
      _LifecycleProjection([
        const _LifecycleEntry(0, activationId: 'foreign'),
        const _LifecycleEntry(1),
      ]),
      _LifecycleProjection([
        const _LifecycleEntry(0, serviceId: 'foreign'),
        const _LifecycleEntry(1),
      ]),
      _LifecycleProjection([
        const _LifecycleEntry(0, runtimeNodeId: 'foreign'),
        const _LifecycleEntry(1),
      ]),
    ]) {
      final executor = _Executor();
      await expectLater(
        const RuntimeExecutionOrchestrator().execute(
          activationState: fixture.activation,
          lifecycleHostProjection: lifecycle,
          authorization: RuntimeExecutionAuthorization.create(
            activationState: fixture.activation,
            lifecycleHostProjection: lifecycle,
          ),
          executor: executor,
        ),
        throwsArgumentError,
      );
      expect(executor.calls, 0);
    }
  });

  test('duplicate, gapped, and incomplete lifecycle coverage reject', () async {
    for (final lifecycle in [
      _LifecycleProjection(const [_LifecycleEntry(0)]),
      _LifecycleProjection(const [_LifecycleEntry(0), _LifecycleEntry(0)]),
      _LifecycleProjection(const [_LifecycleEntry(0), _LifecycleEntry(2)]),
    ]) {
      await expectLater(
        const RuntimeExecutionOrchestrator().execute(
          activationState: fixture.activation,
          lifecycleHostProjection: lifecycle,
          authorization: RuntimeExecutionAuthorization.create(
            activationState: fixture.activation,
            lifecycleHostProjection: lifecycle,
          ),
          executor: _Executor(),
        ),
        throwsArgumentError,
      );
    }
  });

  test('duplicate execution target and handle reject', () async {
    for (final executor in [
      _Executor(duplicateTarget: true),
      _Executor(duplicateHandle: true),
    ]) {
      await expectLater(_execute(fixture, executor), throwsStateError);
    }
  });

  test('missing, orphan, and stale executor results fail closed', () async {
    for (final executor in [
      _Executor(omitLast: true),
      _Executor(orphan: true),
      _Executor(staleRequest: true),
    ]) {
      await expectLater(_execute(fixture, executor), throwsStateError);
    }
  });

  test('request, output, and log are immutable and framework-neutral',
      () async {
    final executor = _Executor();
    final state = await _execute(fixture, executor);
    expect(
      () => executor.request!.targets.add(executor.request!.targets.first),
      throwsUnsupportedError,
    );
    expect(
        () => state.entries.add(state.entries.first), throwsUnsupportedError);
    expect(() => state.log.add(state.log.first), throwsUnsupportedError);
    final json = state.toJson().toString().toLowerCase();
    for (final forbidden in [
      'flutter',
      'buildcontext',
      'provider',
      'getit',
      'scheduler',
      'timer',
      'http',
      'prompt',
    ]) {
      expect(json, isNot(contains(forbidden)));
    }
  });
}

Future<RuntimeExecutionState> _execute(
  _Fixture fixture,
  RuntimeExecutor executor,
) =>
    const RuntimeExecutionOrchestrator().execute(
      activationState: fixture.activation,
      lifecycleHostProjection: fixture.lifecycle,
      authorization: fixture.authorization,
      executor: executor,
    );

class _Fixture {
  const _Fixture({
    required this.activation,
    required this.lifecycle,
    required this.authorization,
  });

  final RuntimeDependencyActivationState activation;
  final RuntimeLifecycleHostProjectionContract lifecycle;
  final RuntimeExecutionAuthorization authorization;
}

_Fixture _fixture() {
  final activation = _ActivationState(
    const [_ActivationEntry(0), _ActivationEntry(1)],
  );
  final lifecycle = _LifecycleProjection(
    const [_LifecycleEntry(0), _LifecycleEntry(1)],
  );
  return _Fixture(
    activation: activation,
    lifecycle: lifecycle,
    authorization: RuntimeExecutionAuthorization.create(
      activationState: activation,
      lifecycleHostProjection: lifecycle,
    ),
  );
}

class _Executor implements RuntimeExecutor {
  _Executor({
    this.reverse = false,
    this.omitLast = false,
    this.orphan = false,
    this.duplicateTarget = false,
    this.duplicateHandle = false,
    this.staleRequest = false,
  });

  final bool reverse;
  final bool omitLast;
  final bool orphan;
  final bool duplicateTarget;
  final bool duplicateHandle;
  final bool staleRequest;
  RuntimeExecutionRequest? request;
  int calls = 0;

  @override
  Future<List<RuntimeExecutionResult>> execute(
    RuntimeExecutionRequest request,
  ) async {
    calls++;
    this.request = request;
    final targets = [...request.targets];
    if (omitLast) targets.removeLast();
    final results = [
      for (var position = 0; position < targets.length; position++)
        RuntimeExecutionResult.create(
          executionEntryId: targets[position].executionEntryId,
          executionHandleId:
              duplicateHandle ? 'handle.shared' : 'handle.$position',
          requestDigest: staleRequest ? 'stale' : request.digest,
        ),
    ];
    if (orphan) {
      results.add(RuntimeExecutionResult.create(
        executionEntryId: 'runtime-execution-entry.orphan',
        executionHandleId: 'handle.orphan',
        requestDigest: request.digest,
      ));
    }
    if (duplicateTarget && results.isNotEmpty) results.add(results.first);
    return reverse ? results.reversed.toList() : results;
  }
}

class _ActivationState implements RuntimeDependencyActivationState {
  _ActivationState(
    this.entries, {
    this.digest = 'activation-state-digest',
  });

  @override
  final List<RuntimeDependencyActivationEntry> entries;
  @override
  final String digest;
  @override
  String get id => 'runtime-dependency-activation.test';
  @override
  String get authorizationDigest => 'activation-authorization';
  @override
  String get registrationPlanId => 'registration-plan.test';
  @override
  String get registrationPlanDigest => 'registration-plan-digest';
  @override
  String get aiProviderStateId => 'ai-state.test';
  @override
  String get aiProviderStateDigest => 'ai-state-digest';
  @override
  String get requestDigest => 'activation-request-digest';
  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'digest': digest,
        'entries': entries.map((entry) => entry.toJson()).toList(),
      };
}

class _ActivationEntry implements RuntimeDependencyActivationEntry {
  const _ActivationEntry(this.position);

  @override
  final int position;
  @override
  String get registrationId => 'registration.$position';
  @override
  String get activationId => 'activation.$position';
  @override
  String get serviceId => 'service.$position';
  @override
  String get runtimeNodeId => 'runtime-node.$position';
  @override
  String get activationHandleId => 'activation-handle.$position';
  @override
  String get registrationDigest => 'registration-digest.$position';
  @override
  String get resultDigest => 'activation-result.$position';
  @override
  String get digest => 'activation-entry.$position';
  @override
  Map<String, dynamic> toJson() => {
        'activationId': activationId,
        'position': position,
      };
}

class _LifecycleProjection implements RuntimeLifecycleHostProjectionContract {
  _LifecycleProjection(
    this.entries, {
    this.digest = 'lifecycle-host-digest',
  });

  @override
  final List<RuntimeLifecycleHostEntry> entries;
  @override
  final String digest;
  @override
  String get id => 'runtime-lifecycle-host-projection.test';
  @override
  String get lifecycleHostProjectionId => 'lifecycle-host.test';
  @override
  String get runtimeServiceActivationProjectionId => 'activation-projection';
  @override
  String get runtimeServiceActivationProjectionDigest => 'activation-digest';
  @override
  String get runtimeLifecycleProjectionId => 'lifecycle-projection';
  @override
  String get runtimeLifecycleProjectionDigest => 'lifecycle-digest';
  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'digest': digest,
        'entries': entries.map((entry) => entry.toJson()).toList(),
      };
}

class _LifecycleEntry implements RuntimeLifecycleHostEntry {
  const _LifecycleEntry(
    this.canonicalPosition, {
    String? activationId,
    String? serviceId,
    String? runtimeNodeId,
  })  : activationIdOverride = activationId,
        serviceIdOverride = serviceId,
        runtimeNodeIdOverride = runtimeNodeId;

  final String? activationIdOverride;
  final String? serviceIdOverride;
  final String? runtimeNodeIdOverride;
  @override
  final int canonicalPosition;
  @override
  String get activationId =>
      activationIdOverride ?? 'activation.$canonicalPosition';
  @override
  String get serviceId => serviceIdOverride ?? 'service.$canonicalPosition';
  @override
  String get runtimeNodeId =>
      runtimeNodeIdOverride ?? 'runtime-node.$canonicalPosition';
  @override
  String get lifecycleHostProjectionId => 'lifecycle-host.test';
  @override
  String get runtimeServiceActivationProjectionDigest => 'activation-digest';
  @override
  String get runtimeLifecycleProjectionDigest => 'lifecycle-digest';
  @override
  String get lifecycleEntryId => 'lifecycle-entry.$canonicalPosition';
  @override
  RuntimeLifecyclePhase get lifecyclePhase => RuntimeLifecyclePhase.initialized;
  @override
  Map<String, dynamic> toJson() => {
        'activationId': activationId,
        'serviceId': serviceId,
        'runtimeNodeId': runtimeNodeId,
        'canonicalPosition': canonicalPosition,
      };
}
