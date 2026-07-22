import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/application/configuration_loader.dart';
import 'package:pool_os/application/persistence_adapter_planner.dart';
import 'package:pool_os/application/persistence_runtime.dart';

void main() {
  final fixture = _fixture();

  test('initializes exact persistence targets through abstract backend',
      () async {
    final backend = _Backend();
    final state = await const PersistenceRuntime().initialize(
      persistenceAdapterPlan: fixture.plan,
      runtimeConfiguration: fixture.configuration,
      backend: backend,
    );

    expect(state.entries, hasLength(2));
    expect(state.persistenceAdapterPlanId, fixture.plan.id);
    expect(state.persistenceAdapterPlanDigest, fixture.plan.digest);
    expect(state.runtimeConfigurationId, fixture.configuration.id);
    expect(state.runtimeConfigurationDigest, fixture.configuration.digest);
    expect(state.initializationRequestDigest, backend.request!.digest);
    expect(backend.request!.runtimeConfiguration, same(fixture.configuration));
    expect(state.digest, hasLength(64));
  });

  test('same inputs and reversed backend results replay identically', () async {
    final first = await const PersistenceRuntime().initialize(
      persistenceAdapterPlan: fixture.plan,
      runtimeConfiguration: fixture.configuration,
      backend: _Backend(),
    );
    final replay = await const PersistenceRuntime().initialize(
      persistenceAdapterPlan: _Plan(fixture.plan.entries.reversed.toList()),
      runtimeConfiguration: fixture.configuration,
      backend: _Backend(reverse: true),
    );

    expect(replay.toJson(), first.toJson());
    expect(replay.digest, first.digest);
  });

  test('stale adapter plan binding is rejected before backend access',
      () async {
    final backend = _Backend();
    await expectLater(
      const PersistenceRuntime().initialize(
        persistenceAdapterPlan: _Plan(
          fixture.plan.entries,
          configurationAdapterPlanDigest: 'stale',
        ),
        runtimeConfiguration: fixture.configuration,
        backend: backend,
      ),
      throwsArgumentError,
    );
    expect(backend.calls, 0);
  });

  test('invalid or empty runtime configuration fails closed', () async {
    final backend = _Backend();
    await expectLater(
      const PersistenceRuntime().initialize(
        persistenceAdapterPlan: fixture.plan,
        runtimeConfiguration: _Configuration(const []),
        backend: backend,
      ),
      throwsArgumentError,
    );
    expect(backend.calls, 0);
  });

  test('missing or orphan initialization coverage fails closed', () async {
    await expectLater(
      const PersistenceRuntime().initialize(
        persistenceAdapterPlan: fixture.plan,
        runtimeConfiguration: fixture.configuration,
        backend: _Backend(omitLast: true),
      ),
      throwsStateError,
    );
    await expectLater(
      const PersistenceRuntime().initialize(
        persistenceAdapterPlan: fixture.plan,
        runtimeConfiguration: fixture.configuration,
        backend: _Backend(orphan: true),
      ),
      throwsStateError,
    );
  });

  test('duplicate target and backend initialization are rejected', () async {
    await expectLater(
      const PersistenceRuntime().initialize(
        persistenceAdapterPlan: fixture.plan,
        runtimeConfiguration: fixture.configuration,
        backend: _Backend(duplicateTarget: true),
      ),
      throwsStateError,
    );
    await expectLater(
      const PersistenceRuntime().initialize(
        persistenceAdapterPlan: fixture.plan,
        runtimeConfiguration: fixture.configuration,
        backend: _Backend(duplicateBackend: true),
      ),
      throwsStateError,
    );
  });

  test('stale backend result fails closed', () async {
    await expectLater(
      const PersistenceRuntime().initialize(
        persistenceAdapterPlan: fixture.plan,
        runtimeConfiguration: fixture.configuration,
        backend: _Backend(staleRequest: true),
      ),
      throwsStateError,
    );
  });

  test('request and runtime state are immutable and output excludes values',
      () async {
    final backend = _Backend();
    final state = await const PersistenceRuntime().initialize(
      persistenceAdapterPlan: fixture.plan,
      runtimeConfiguration: fixture.configuration,
      backend: backend,
    );

    expect(
      () => backend.request!.targets.add(backend.request!.targets.first),
      throwsUnsupportedError,
    );
    expect(
      () => state.entries.add(state.entries.first),
      throwsUnsupportedError,
    );
    final json = state.toJson().toString();
    expect(json, isNot(contains('secret-value')));
    expect(json, isNot(contains('values:')));
  });
}

const _configurationAdapterPlanId = 'configuration-adapter-plan.test';
const _configurationAdapterPlanDigest =
    'cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc';
const _persistenceAdapterPlanDigest =
    'pppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppp';
const _runtimeConfigurationDigest =
    'rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr';

class _Fixture {
  const _Fixture({required this.plan, required this.configuration});

  final PersistenceAdapterPlan plan;
  final RuntimeConfiguration configuration;
}

_Fixture _fixture() => _Fixture(
      plan: _Plan([
        for (var position = 0; position < 2; position++)
          PersistenceAdapterEntry.create(
            featureId: 'feature.$position',
            configurationAdapterEntryId: 'configuration-adapter.$position',
            position: position,
            configurationAdapterPlanDigest: _configurationAdapterPlanDigest,
            runtimeDeliveryProjectionDigest: 'delivery-digest',
          ),
      ]),
      configuration: _Configuration([
        const _RuntimeEntry(position: 0, suffix: 'a'),
        const _RuntimeEntry(position: 1, suffix: 'b'),
      ]),
    );

class _Backend implements PersistenceBackend {
  _Backend({
    this.reverse = false,
    this.omitLast = false,
    this.orphan = false,
    this.duplicateTarget = false,
    this.duplicateBackend = false,
    this.staleRequest = false,
  });

  final bool reverse;
  final bool omitLast;
  final bool orphan;
  final bool duplicateTarget;
  final bool duplicateBackend;
  final bool staleRequest;
  PersistenceInitializationRequest? request;
  int calls = 0;

  @override
  Future<List<PersistenceBackendInitialization>> initialize(
    PersistenceInitializationRequest request,
  ) async {
    calls++;
    this.request = request;
    final targets = [...request.targets];
    if (omitLast) targets.removeLast();
    if (orphan) {
      targets.add(const PersistenceInitializationTarget(
        persistenceAdapterEntryId: 'orphan',
        featureId: 'orphan',
        configurationAdapterEntryId: 'orphan',
        position: 99,
        persistenceAdapterProvenanceDigest: 'orphan',
      ));
    }
    final initialized = [
      for (var position = 0; position < targets.length; position++)
        PersistenceBackendInitialization.create(
          persistenceAdapterEntryId:
              targets[position].persistenceAdapterEntryId,
          backendId: duplicateBackend ? 'backend.shared' : 'backend.$position',
          requestDigest: staleRequest ? 'stale' : request.digest,
        ),
    ];
    if (duplicateTarget && initialized.isNotEmpty) {
      initialized.add(initialized.first);
    }
    return reverse ? initialized.reversed.toList() : initialized;
  }
}

class _Plan implements PersistenceAdapterPlan {
  _Plan(
    this.entries, {
    this.configurationAdapterPlanDigest = _configurationAdapterPlanDigest,
  });

  @override
  final List<PersistenceAdapterEntry> entries;

  @override
  final String configurationAdapterPlanDigest;

  @override
  String get id => 'persistence-adapter-plan.test';

  @override
  String get digest => _persistenceAdapterPlanDigest;

  @override
  String get configurationAdapterPlanId => _configurationAdapterPlanId;

  @override
  String get runtimeDeliveryProjectionDigest => 'delivery-digest';

  @override
  String get runtimeDeliveryProjectionId => 'delivery.test';

  @override
  List<PersistenceAdapterLogEntry> get log => const [];

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'digest': digest,
        'configurationAdapterPlanId': configurationAdapterPlanId,
        'configurationAdapterPlanDigest': configurationAdapterPlanDigest,
        'entries': entries.map((entry) => entry.toJson()).toList(),
      };
}

class _Configuration implements RuntimeConfiguration {
  _Configuration(this.entries);

  @override
  final List<RuntimeConfigurationEntry> entries;

  @override
  String get id => 'runtime-configuration.test';

  @override
  String get digest => _runtimeConfigurationDigest;

  @override
  String get configurationAdapterPlanId => _configurationAdapterPlanId;

  @override
  String get configurationAdapterPlanDigest => _configurationAdapterPlanDigest;

  @override
  String get configurationProjectionDigest => 'projection-digest';

  @override
  String get configurationProjectionId => 'projection.test';

  @override
  String get loadRequestDigest => 'load-request-digest';

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'digest': digest,
        'configurationAdapterPlanId': configurationAdapterPlanId,
        'configurationAdapterPlanDigest': configurationAdapterPlanDigest,
        'entries': entries.map((entry) => entry.toJson()).toList(),
      };
}

class _RuntimeEntry implements RuntimeConfigurationEntry {
  const _RuntimeEntry({required this.position, required this.suffix});

  @override
  final int position;
  final String suffix;

  @override
  String get configurationEntryId => 'configuration-entry.$suffix';

  @override
  String get configurationId => 'configuration.$suffix';

  @override
  String get configurationProvenanceDigest => 'provenance.$suffix';

  @override
  String get deliveryId => 'delivery.$suffix';

  @override
  String get deliveryTarget => 'application';

  @override
  String get digest => 'digest.$suffix';

  @override
  String get environmentId => 'environment.test';

  @override
  String get runtimeNodeId => 'node.$suffix';

  @override
  String get serviceId => 'service.$suffix';

  @override
  Map<String, String> get values => const {'secret': 'secret-value'};

  @override
  Map<String, dynamic> toJson() => {
        'configurationEntryId': configurationEntryId,
        'position': position,
        'values': values,
      };
}
