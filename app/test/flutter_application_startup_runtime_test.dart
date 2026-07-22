import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/application/flutter_application_adapter_planner.dart';
import 'package:pool_os/application/flutter_application_startup_runtime.dart';
import 'package:pool_os/application/runtime_execution_orchestrator.dart';

void main() {
  final fixture = _fixture();

  test('starts canonical Flutter targets through abstract port', () async {
    final executor = _Executor();
    final state = await _start(fixture, executor);
    expect(state.entries, hasLength(2));
    expect(state.entries.first.featureId, 'feature.0');
    expect(state.requestDigest, executor.request!.digest);
    expect(
        state.log.map((entry) => entry.phase), FlutterStartupLogPhase.values);
    expect(state.digest, hasLength(64));
  });

  test('reordered plan and executor results replay identically', () async {
    final first = await _start(fixture, _Executor());
    final reorderedPlan = _Plan(fixture.plan.entries.reversed.toList());
    final replayFixture = _Fixture(
      execution: fixture.execution,
      plan: reorderedPlan,
      authorization: FlutterStartupAuthorization.create(
        runtimeExecutionState: fixture.execution,
        flutterApplicationAdapterPlan: reorderedPlan,
      ),
    );
    final replay = await _start(replayFixture, _Executor(reverse: true));
    expect(replay.toJson(), first.toJson());
  });

  test('stale execution and plan authorization fail before executor', () async {
    final staleExecution = _ExecutionState(digest: 'stale-execution');
    final stalePlan = _Plan(fixture.plan.entries, digest: 'stale-plan');
    for (final authorization in [
      FlutterStartupAuthorization.create(
        runtimeExecutionState: staleExecution,
        flutterApplicationAdapterPlan: fixture.plan,
      ),
      FlutterStartupAuthorization.create(
        runtimeExecutionState: fixture.execution,
        flutterApplicationAdapterPlan: stalePlan,
      ),
    ]) {
      final executor = _Executor();
      await expectLater(
        const FlutterApplicationStartupRuntime().start(
          runtimeExecutionState: fixture.execution,
          flutterApplicationAdapterPlan: fixture.plan,
          authorization: authorization,
          executor: executor,
        ),
        throwsArgumentError,
      );
      expect(executor.calls, 0);
    }
  });

  test('duplicate, gapped, and malformed features fail closed', () async {
    final first = fixture.plan.entries.first;
    for (final entries in [
      [first, first],
      [first, _entry(2)],
      [first, const _MalformedEntry(position: 1)],
    ]) {
      final plan = _Plan(entries);
      final executor = _Executor();
      await expectLater(
        const FlutterApplicationStartupRuntime().start(
          runtimeExecutionState: fixture.execution,
          flutterApplicationAdapterPlan: plan,
          authorization: FlutterStartupAuthorization.create(
            runtimeExecutionState: fixture.execution,
            flutterApplicationAdapterPlan: plan,
          ),
          executor: executor,
        ),
        throwsArgumentError,
      );
      expect(executor.calls, 0);
    }
  });

  test('missing and orphan startup coverage fail closed', () async {
    for (final executor in [
      _Executor(omitLast: true),
      _Executor(orphan: true),
    ]) {
      await expectLater(_start(fixture, executor), throwsStateError);
    }
  });

  test('duplicate startup target and handle reject', () async {
    for (final executor in [
      _Executor(duplicateTarget: true),
      _Executor(duplicateHandle: true),
    ]) {
      await expectLater(_start(fixture, executor), throwsStateError);
    }
  });

  test('stale executor result fails closed', () async {
    await expectLater(
      _start(fixture, _Executor(staleRequest: true)),
      throwsStateError,
    );
  });

  test('request, output, and log are immutable and contain no Flutter runtime',
      () async {
    final executor = _Executor();
    final state = await _start(fixture, executor);
    expect(
      () => executor.request!.targets.add(executor.request!.targets.first),
      throwsUnsupportedError,
    );
    expect(
        () => state.entries.add(state.entries.first), throwsUnsupportedError);
    expect(() => state.log.add(state.log.first), throwsUnsupportedError);
    final json = state.toJson().toString().toLowerCase();
    for (final forbidden in [
      'runapp',
      'widget',
      'buildcontext',
      'navigator',
      'provider',
      'getit',
      'scheduler',
      'http',
    ]) {
      expect(json, isNot(contains(forbidden)));
    }
  });
}

Future<RuntimeFlutterStartupState> _start(
  _Fixture fixture,
  FlutterStartupExecutor executor,
) =>
    const FlutterApplicationStartupRuntime().start(
      runtimeExecutionState: fixture.execution,
      flutterApplicationAdapterPlan: fixture.plan,
      authorization: fixture.authorization,
      executor: executor,
    );

class _Fixture {
  const _Fixture({
    required this.execution,
    required this.plan,
    required this.authorization,
  });
  final RuntimeExecutionState execution;
  final FlutterApplicationAdapterPlan plan;
  final FlutterStartupAuthorization authorization;
}

_Fixture _fixture() {
  final execution = _ExecutionState();
  final plan = _Plan([_entry(0), _entry(1)]);
  return _Fixture(
    execution: execution,
    plan: plan,
    authorization: FlutterStartupAuthorization.create(
      runtimeExecutionState: execution,
      flutterApplicationAdapterPlan: plan,
    ),
  );
}

FlutterApplicationAdapterEntry _entry(int position) =>
    FlutterApplicationAdapterEntry.create(
      featureId: 'feature.$position',
      compositionEntryId: 'composition.$position',
      position: position,
      applicationCompositionPlanDigest: 'composition-plan-digest',
      bootstrapHostRunDigest: 'bootstrap-host-digest',
    );

class _Executor implements FlutterStartupExecutor {
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
  FlutterStartupRequest? request;
  int calls = 0;

  @override
  Future<List<FlutterStartupResult>> start(
      FlutterStartupRequest request) async {
    calls++;
    this.request = request;
    final targets = [...request.targets];
    if (omitLast) targets.removeLast();
    final results = [
      for (var position = 0; position < targets.length; position++)
        FlutterStartupResult.create(
          startupTargetId: targets[position].startupTargetId,
          startupHandleId:
              duplicateHandle ? 'handle.shared' : 'handle.$position',
          requestDigest: staleRequest ? 'stale' : request.digest,
        ),
    ];
    if (orphan) {
      results.add(FlutterStartupResult.create(
        startupTargetId: 'flutter-startup-target.orphan',
        startupHandleId: 'handle.orphan',
        requestDigest: request.digest,
      ));
    }
    if (duplicateTarget && results.isNotEmpty) results.add(results.first);
    return reverse ? results.reversed.toList() : results;
  }
}

class _Plan implements FlutterApplicationAdapterPlan {
  _Plan(this.entries, {this.digest = 'flutter-adapter-plan-digest'});
  @override
  final List<FlutterApplicationAdapterEntry> entries;
  @override
  final String digest;
  @override
  String get id => 'flutter-application-adapter-plan.test';
  @override
  String get applicationCompositionPlanId => 'composition-plan.test';
  @override
  String get applicationCompositionPlanDigest => 'composition-plan-digest';
  @override
  String get bootstrapHostRunId => 'bootstrap-host.test';
  @override
  String get bootstrapHostRunDigest => 'bootstrap-host-digest';
  @override
  List<FlutterApplicationAdapterLogEntry> get log => const [];
  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'digest': digest,
        'entries': entries.map((entry) => entry.toJson()).toList(),
      };
}

class _ExecutionState implements RuntimeExecutionState {
  _ExecutionState({this.digest = 'runtime-execution-digest'});
  @override
  final String digest;
  @override
  String get id => 'runtime-execution.test';
  @override
  List<RuntimeExecutionEntry> get entries => const [_ExecutionEntry()];
  @override
  List<RuntimeExecutionLogEntry> get log => const [];
  @override
  String get authorizationDigest => 'execution-authorization';
  @override
  String get activationStateId => 'activation-state.test';
  @override
  String get activationStateDigest => 'activation-state-digest';
  @override
  String get lifecycleHostProjectionId => 'lifecycle-host.test';
  @override
  String get lifecycleHostProjectionDigest => 'lifecycle-host-digest';
  @override
  String get requestDigest => 'execution-request-digest';
  @override
  Map<String, dynamic> toJson() => {'id': id, 'digest': digest};
}

class _ExecutionEntry implements RuntimeExecutionEntry {
  const _ExecutionEntry();
  @override
  String get executionEntryId => 'execution-entry.test';
  @override
  String get activationId => 'activation.test';
  @override
  String get serviceId => 'service.test';
  @override
  String get runtimeNodeId => 'runtime-node.test';
  @override
  String get lifecyclePhase => 'initialized';
  @override
  int get canonicalPosition => 0;
  @override
  String get executionHandleId => 'execution-handle.test';
  @override
  String get authorizationDigest => 'execution-authorization';
  @override
  String get lifecycleDigest => 'lifecycle-digest';
  @override
  String get resultDigest => 'result-digest';
  @override
  String get digest => 'execution-entry-digest';
  @override
  Map<String, dynamic> toJson() => {'executionEntryId': executionEntryId};
}

class _MalformedEntry implements FlutterApplicationAdapterEntry {
  const _MalformedEntry({required this.position});
  @override
  final int position;
  @override
  String get adapterEntryId => 'flutter-application-adapter.malformed';
  @override
  String get featureId => 'feature.malformed';
  @override
  String get compositionEntryId => 'composition.malformed';
  @override
  String get applicationCompositionPlanDigest => 'composition-plan-digest';
  @override
  String get bootstrapHostRunDigest => 'bootstrap-host-digest';
  @override
  String get provenanceDigest => 'invalid';
  @override
  String get digest => 'invalid';
  @override
  Map<String, dynamic> toJson() => {'featureId': featureId};
}
