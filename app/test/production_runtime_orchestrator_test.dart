import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/application/flutter_application_startup_runtime.dart';
import 'package:pool_os/application/infrastructure_integration_validation_planner.dart';
import 'package:pool_os/application/production_runtime_orchestrator.dart';

void main() {
  final fixture = _fixture();

  test('executes canonical production targets through abstract port', () async {
    final executor = _Executor();
    final state = await _run(fixture, executor);
    expect(state.entries, hasLength(2));
    expect(state.entries.first.featureId, 'feature.0');
    expect(state.requestDigest, executor.request!.digest);
    expect(state.log, ProductionRuntimeLogPhase.values);
  });

  test('reordered input and results replay identically', () async {
    final first = await _run(fixture, _Executor());
    final startup = _Startup(fixture.startup.entries.reversed.toList());
    final plan = _Plan(fixture.plan.entries.reversed.toList());
    final replay = await _run(
      _Fixture(
          startup,
          plan,
          ProductionRuntimeAuthorization.create(
              flutterStartupState: startup, infrastructurePlan: plan)),
      _Executor(reverse: true),
    );
    expect(replay.toJson(), first.toJson());
  });

  test('stale authorization fails before executor', () async {
    final staleStartup = _Startup(fixture.startup.entries, digest: 'stale');
    final stalePlan = _Plan(fixture.plan.entries, digest: 'stale');
    for (final authorization in [
      ProductionRuntimeAuthorization.create(
          flutterStartupState: staleStartup, infrastructurePlan: fixture.plan),
      ProductionRuntimeAuthorization.create(
          flutterStartupState: fixture.startup, infrastructurePlan: stalePlan),
    ]) {
      final executor = _Executor();
      await expectLater(
        const ProductionRuntimeOrchestrator().execute(
          flutterStartupState: fixture.startup,
          infrastructurePlan: fixture.plan,
          authorization: authorization,
          executor: executor,
        ),
        throwsArgumentError,
      );
      expect(executor.calls, 0);
    }
  });

  test('feature mismatch and incomplete coverage fail closed', () async {
    for (final plan in [
      _Plan(const [_InfraEntry(0)]),
      _Plan(const [_InfraEntry(0, feature: 'foreign'), _InfraEntry(1)]),
    ]) {
      await expectLater(
        const ProductionRuntimeOrchestrator().execute(
          flutterStartupState: fixture.startup,
          infrastructurePlan: plan,
          authorization: ProductionRuntimeAuthorization.create(
              flutterStartupState: fixture.startup, infrastructurePlan: plan),
          executor: _Executor(),
        ),
        throwsArgumentError,
      );
    }
  });

  test('duplicate and gapped canonical positions reject', () async {
    for (final plan in [
      _Plan(const [_InfraEntry(0), _InfraEntry(0)]),
      _Plan(const [_InfraEntry(0), _InfraEntry(2)]),
    ]) {
      await expectLater(
        const ProductionRuntimeOrchestrator().execute(
          flutterStartupState: fixture.startup,
          infrastructurePlan: plan,
          authorization: ProductionRuntimeAuthorization.create(
              flutterStartupState: fixture.startup, infrastructurePlan: plan),
          executor: _Executor(),
        ),
        throwsArgumentError,
      );
    }
  });

  test('duplicate target and runtime handle reject', () async {
    for (final executor in [
      _Executor(duplicateTarget: true),
      _Executor(duplicateHandle: true),
    ]) {
      await expectLater(_run(fixture, executor), throwsStateError);
    }
  });

  test('missing orphan and stale results fail closed', () async {
    for (final executor in [
      _Executor(omitLast: true),
      _Executor(orphan: true),
      _Executor(stale: true),
    ]) {
      await expectLater(_run(fixture, executor), throwsStateError);
    }
  });

  test('request and output collections are immutable', () async {
    final executor = _Executor();
    final state = await _run(fixture, executor);
    expect(() => executor.request!.targets.add(executor.request!.targets.first),
        throwsUnsupportedError);
    expect(
        () => state.entries.add(state.entries.first), throwsUnsupportedError);
    expect(() => state.log.add(state.log.first), throwsUnsupportedError);
  });
}

Future<ProductionRuntimeState> _run(_Fixture f, ProductionRuntimeExecutor e) =>
    const ProductionRuntimeOrchestrator().execute(
      flutterStartupState: f.startup,
      infrastructurePlan: f.plan,
      authorization: f.authorization,
      executor: e,
    );

class _Fixture {
  const _Fixture(this.startup, this.plan, this.authorization);
  final RuntimeFlutterStartupState startup;
  final InfrastructureIntegrationValidationPlan plan;
  final ProductionRuntimeAuthorization authorization;
}

_Fixture _fixture() {
  final startup = _Startup(const [_StartupEntry(0), _StartupEntry(1)]);
  final plan = _Plan(const [_InfraEntry(0), _InfraEntry(1)]);
  return _Fixture(
      startup,
      plan,
      ProductionRuntimeAuthorization.create(
          flutterStartupState: startup, infrastructurePlan: plan));
}

class _Executor implements ProductionRuntimeExecutor {
  _Executor(
      {this.reverse = false,
      this.omitLast = false,
      this.orphan = false,
      this.duplicateTarget = false,
      this.duplicateHandle = false,
      this.stale = false});
  final bool reverse, omitLast, orphan, duplicateTarget, duplicateHandle, stale;
  ProductionRuntimeRequest? request;
  int calls = 0;
  @override
  Future<List<ProductionRuntimeResult>> execute(
      ProductionRuntimeRequest r) async {
    calls++;
    request = r;
    final targets = [...r.targets];
    if (omitLast) targets.removeLast();
    final results = [
      for (var i = 0; i < targets.length; i++)
        ProductionRuntimeResult.create(
            runtimeTargetId: targets[i].runtimeTargetId,
            runtimeHandleId: duplicateHandle ? 'shared' : 'handle.$i',
            requestDigest: stale ? 'stale' : r.digest)
    ];
    if (orphan) {
      results.add(ProductionRuntimeResult.create(
          runtimeTargetId: 'orphan',
          runtimeHandleId: 'orphan',
          requestDigest: r.digest));
    }
    if (duplicateTarget && results.isNotEmpty) results.add(results.first);
    return reverse ? results.reversed.toList() : results;
  }
}

class _Startup implements RuntimeFlutterStartupState {
  _Startup(this.entries, {this.digest = 'startup-digest'});
  @override
  final List<RuntimeFlutterStartupEntry> entries;
  @override
  final String digest;
  @override
  String get id => 'startup.test';
  @override
  String get authorizationDigest => 'auth';
  @override
  String get runtimeExecutionStateId => 'execution';
  @override
  String get runtimeExecutionStateDigest => 'execution-digest';
  @override
  String get flutterApplicationAdapterPlanId => 'flutter-plan';
  @override
  String get flutterApplicationAdapterPlanDigest => 'flutter-digest';
  @override
  String get requestDigest => 'request';
  @override
  List<FlutterStartupLogEntry> get log => const [];
  @override
  Map<String, dynamic> toJson() => {'id': id, 'digest': digest};
}

class _StartupEntry implements RuntimeFlutterStartupEntry {
  const _StartupEntry(this.position);
  @override
  final int position;
  @override
  String get featureId => 'feature.$position';
  @override
  String get startupTargetId => 'target.$position';
  @override
  String get adapterEntryId => 'adapter.$position';
  @override
  String get compositionEntryId => 'composition.$position';
  @override
  String get startupHandleId => 'startup-handle.$position';
  @override
  String get authorizationDigest => 'auth';
  @override
  String get resultDigest => 'result.$position';
  @override
  String get digest => 'startup-entry.$position';
  @override
  Map<String, dynamic> toJson() =>
      {'featureId': featureId, 'position': position};
}

class _Plan implements InfrastructureIntegrationValidationPlan {
  _Plan(this.entries, {this.digest = 'infra-plan-digest'});
  @override
  final List<InfrastructureIntegrationValidationEntry> entries;
  @override
  final String digest;
  @override
  String get id => 'infra-plan.test';
  @override
  String get packagingDeploymentAdapterPlanId => 'packaging-plan';
  @override
  String get packagingDeploymentAdapterPlanDigest => 'packaging-digest';
  @override
  String get productionReadinessProjectionId => 'readiness';
  @override
  String get productionReadinessProjectionDigest => 'readiness-digest';
  @override
  List<InfrastructureIntegrationValidationLogEntry> get log => const [];
  @override
  Map<String, dynamic> toJson() => {'id': id, 'digest': digest};
}

class _InfraEntry implements InfrastructureIntegrationValidationEntry {
  const _InfraEntry(this.position, {this.feature});
  @override
  final int position;
  final String? feature;
  @override
  String get featureId => feature ?? 'feature.$position';
  @override
  String get packagingDeploymentAdapterEntryId => 'packaging.$position';
  @override
  String get infrastructureIntegrationValidationEntryId =>
      'infrastructure-integration-validation.$featureId';
  @override
  String get packagingDeploymentAdapterPlanDigest => 'packaging-digest';
  @override
  String get productionReadinessProjectionDigest => 'readiness-digest';
  @override
  String get provenanceDigest =>
      InfrastructureIntegrationValidationEntry.create(
              featureId: featureId,
              packagingDeploymentAdapterEntryId:
                  packagingDeploymentAdapterEntryId,
              position: position,
              packagingDeploymentAdapterPlanDigest:
                  packagingDeploymentAdapterPlanDigest,
              productionReadinessProjectionDigest:
                  productionReadinessProjectionDigest)
          .provenanceDigest;
  @override
  String get digest => InfrastructureIntegrationValidationEntry.create(
          featureId: featureId,
          packagingDeploymentAdapterEntryId: packagingDeploymentAdapterEntryId,
          position: position,
          packagingDeploymentAdapterPlanDigest:
              packagingDeploymentAdapterPlanDigest,
          productionReadinessProjectionDigest:
              productionReadinessProjectionDigest)
      .digest;
  @override
  Map<String, dynamic> toJson() =>
      {'featureId': featureId, 'position': position};
}
