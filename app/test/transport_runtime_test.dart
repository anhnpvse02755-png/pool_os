import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/application/persistence_runtime.dart';
import 'package:pool_os/application/transport_adapter_planner.dart';
import 'package:pool_os/application/transport_runtime.dart';

void main() {
  final fixture = _fixture();

  test('initializes exact transport targets through abstract provider',
      () async {
    final provider = _Provider();
    final state = await const TransportRuntime().initialize(
      transportAdapterPlan: fixture.plan,
      runtimePersistenceState: fixture.persistence,
      provider: provider,
    );

    expect(state.entries, hasLength(2));
    expect(state.transportAdapterPlanId, fixture.plan.id);
    expect(state.runtimePersistenceStateId, fixture.persistence.id);
    expect(state.initializationRequestDigest, provider.request!.digest);
    expect(
        provider.request!.runtimePersistenceState, same(fixture.persistence));
    expect(state.digest, hasLength(64));
  });

  test('reordered plan and provider results replay identically', () async {
    final first = await const TransportRuntime().initialize(
      transportAdapterPlan: fixture.plan,
      runtimePersistenceState: fixture.persistence,
      provider: _Provider(),
    );
    final replay = await const TransportRuntime().initialize(
      transportAdapterPlan: _Plan(fixture.plan.entries.reversed.toList()),
      runtimePersistenceState: fixture.persistence,
      provider: _Provider(reverse: true),
    );

    expect(replay.toJson(), first.toJson());
    expect(replay.digest, first.digest);
  });

  test('mismatched persistence plan ID and digest fail before provider access',
      () async {
    for (final persistence in [
      _PersistenceState(
        fixture.persistence.entries,
        persistenceAdapterPlanId: 'foreign',
      ),
      _PersistenceState(
        fixture.persistence.entries,
        persistenceAdapterPlanDigest: 'stale',
      ),
    ]) {
      final provider = _Provider();
      await expectLater(
        const TransportRuntime().initialize(
          transportAdapterPlan: fixture.plan,
          runtimePersistenceState: persistence,
          provider: provider,
        ),
        throwsArgumentError,
      );
      expect(provider.calls, 0);
    }
  });

  test('orphan and incomplete persistence ownership fail closed', () async {
    final orphanPlan = _Plan([
      fixture.plan.entries.first,
      TransportAdapterEntry.create(
        featureId: 'feature.orphan',
        persistenceAdapterEntryId: 'persistence.orphan',
        position: 1,
        persistenceAdapterPlanDigest: _persistencePlanDigest,
        runtimeServiceExposureDigest: 'exposure-digest',
      ),
    ]);
    await expectLater(
      const TransportRuntime().initialize(
        transportAdapterPlan: orphanPlan,
        runtimePersistenceState: fixture.persistence,
        provider: _Provider(),
      ),
      throwsArgumentError,
    );
    await expectLater(
      const TransportRuntime().initialize(
        transportAdapterPlan: _Plan([fixture.plan.entries.first]),
        runtimePersistenceState: fixture.persistence,
        provider: _Provider(),
      ),
      throwsArgumentError,
    );
  });

  test('missing and orphan provider coverage fail closed', () async {
    await expectLater(
      const TransportRuntime().initialize(
        transportAdapterPlan: fixture.plan,
        runtimePersistenceState: fixture.persistence,
        provider: _Provider(omitLast: true),
      ),
      throwsStateError,
    );
    await expectLater(
      const TransportRuntime().initialize(
        transportAdapterPlan: fixture.plan,
        runtimePersistenceState: fixture.persistence,
        provider: _Provider(orphan: true),
      ),
      throwsStateError,
    );
  });

  test('duplicate target and provider initialization are rejected', () async {
    await expectLater(
      const TransportRuntime().initialize(
        transportAdapterPlan: fixture.plan,
        runtimePersistenceState: fixture.persistence,
        provider: _Provider(duplicateTarget: true),
      ),
      throwsStateError,
    );
    await expectLater(
      const TransportRuntime().initialize(
        transportAdapterPlan: fixture.plan,
        runtimePersistenceState: fixture.persistence,
        provider: _Provider(duplicateProvider: true),
      ),
      throwsStateError,
    );
  });

  test('stale provider result fails closed', () async {
    await expectLater(
      const TransportRuntime().initialize(
        transportAdapterPlan: fixture.plan,
        runtimePersistenceState: fixture.persistence,
        provider: _Provider(staleRequest: true),
      ),
      throwsStateError,
    );
  });

  test('request and runtime state are immutable and framework-neutral',
      () async {
    final provider = _Provider();
    final state = await const TransportRuntime().initialize(
      transportAdapterPlan: fixture.plan,
      runtimePersistenceState: fixture.persistence,
      provider: provider,
    );

    expect(
      () => provider.request!.targets.add(provider.request!.targets.first),
      throwsUnsupportedError,
    );
    expect(
      () => state.entries.add(state.entries.first),
      throwsUnsupportedError,
    );
    final json = state.toJson().toString();
    for (final forbidden in [
      'http',
      'endpoint',
      'socket',
      'authentication',
      'retry',
    ]) {
      expect(json.toLowerCase(), isNot(contains(forbidden)));
    }
  });
}

const _persistencePlanId = 'persistence-adapter-plan.test';
const _persistencePlanDigest =
    'pppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppp';
const _transportPlanDigest =
    'tttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt';
const _persistenceStateDigest =
    'ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss';

class _Fixture {
  const _Fixture({required this.plan, required this.persistence});

  final TransportAdapterPlan plan;
  final RuntimePersistenceState persistence;
}

_Fixture _fixture() => _Fixture(
      plan: _Plan([
        for (var position = 0; position < 2; position++)
          TransportAdapterEntry.create(
            featureId: 'feature.$position',
            persistenceAdapterEntryId: 'persistence-adapter.$position',
            position: position,
            persistenceAdapterPlanDigest: _persistencePlanDigest,
            runtimeServiceExposureDigest: 'exposure-digest',
          ),
      ]),
      persistence: _PersistenceState(const [
        _PersistenceEntry(position: 0),
        _PersistenceEntry(position: 1),
      ]),
    );

class _Provider implements TransportProvider {
  _Provider({
    this.reverse = false,
    this.omitLast = false,
    this.orphan = false,
    this.duplicateTarget = false,
    this.duplicateProvider = false,
    this.staleRequest = false,
  });

  final bool reverse;
  final bool omitLast;
  final bool orphan;
  final bool duplicateTarget;
  final bool duplicateProvider;
  final bool staleRequest;
  TransportInitializationRequest? request;
  int calls = 0;

  @override
  Future<List<TransportProviderInitialization>> initialize(
    TransportInitializationRequest request,
  ) async {
    calls++;
    this.request = request;
    final targets = [...request.targets];
    if (omitLast) targets.removeLast();
    if (orphan) {
      targets.add(const TransportInitializationTarget(
        transportAdapterEntryId: 'orphan',
        featureId: 'orphan',
        persistenceAdapterEntryId: 'orphan',
        position: 99,
        transportAdapterProvenanceDigest: 'orphan',
      ));
    }
    final initialized = [
      for (var position = 0; position < targets.length; position++)
        TransportProviderInitialization.create(
          transportAdapterEntryId: targets[position].transportAdapterEntryId,
          providerId:
              duplicateProvider ? 'provider.shared' : 'provider.$position',
          requestDigest: staleRequest ? 'stale' : request.digest,
        ),
    ];
    if (duplicateTarget && initialized.isNotEmpty) {
      initialized.add(initialized.first);
    }
    return reverse ? initialized.reversed.toList() : initialized;
  }
}

class _Plan implements TransportAdapterPlan {
  _Plan(this.entries);

  @override
  final List<TransportAdapterEntry> entries;

  @override
  String get id => 'transport-adapter-plan.test';

  @override
  String get digest => _transportPlanDigest;

  @override
  String get persistenceAdapterPlanId => _persistencePlanId;

  @override
  String get persistenceAdapterPlanDigest => _persistencePlanDigest;

  @override
  String get runtimeServiceExposureDigest => 'exposure-digest';

  @override
  String get runtimeServiceExposureId => 'exposure.test';

  @override
  List<TransportAdapterLogEntry> get log => const [];

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'digest': digest,
        'persistenceAdapterPlanId': persistenceAdapterPlanId,
        'persistenceAdapterPlanDigest': persistenceAdapterPlanDigest,
        'entries': entries.map((entry) => entry.toJson()).toList(),
      };
}

class _PersistenceState implements RuntimePersistenceState {
  _PersistenceState(
    this.entries, {
    this.persistenceAdapterPlanId = _persistencePlanId,
    this.persistenceAdapterPlanDigest = _persistencePlanDigest,
  });

  @override
  final List<RuntimePersistenceEntry> entries;

  @override
  final String persistenceAdapterPlanId;

  @override
  final String persistenceAdapterPlanDigest;

  @override
  String get id => 'runtime-persistence.test';

  @override
  String get digest => _persistenceStateDigest;

  @override
  String get initializationRequestDigest => 'initialization-request';

  @override
  String get runtimeConfigurationDigest => 'configuration-digest';

  @override
  String get runtimeConfigurationId => 'configuration.test';

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'digest': digest,
        'persistenceAdapterPlanId': persistenceAdapterPlanId,
        'persistenceAdapterPlanDigest': persistenceAdapterPlanDigest,
        'entries': entries.map((entry) => entry.toJson()).toList(),
      };
}

class _PersistenceEntry implements RuntimePersistenceEntry {
  const _PersistenceEntry({required this.position});

  @override
  final int position;

  @override
  String get persistenceAdapterEntryId => 'persistence-adapter.$position';

  @override
  String get backendId => 'backend.$position';

  @override
  String get backendInitializationDigest => 'backend-digest.$position';

  @override
  String get configurationAdapterEntryId => 'configuration-adapter.$position';

  @override
  String get digest => 'digest.$position';

  @override
  String get featureId => 'feature.$position';

  @override
  String get id => 'runtime-persistence-entry.$position';

  @override
  String get persistenceAdapterProvenanceDigest => 'provenance.$position';

  @override
  Map<String, dynamic> toJson() => {
        'persistenceAdapterEntryId': persistenceAdapterEntryId,
        'position': position,
      };
}
