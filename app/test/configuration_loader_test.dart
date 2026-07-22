import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/application/configuration_adapter_planner.dart';
import 'package:pool_os/application/configuration_loader.dart';
import 'package:pool_os/contracts/runtime_configuration_environment_projection_contracts.dart';
import 'package:pool_os/contracts/runtime_delivery_projection_contracts.dart';

void main() {
  final fixture = _fixture();

  test('loads complete configuration with deterministic ownership bindings',
      () async {
    final provider = _Provider(_loaded(fixture.projection.entries));
    final result = await const ConfigurationLoader().load(
      configurationProjection: fixture.projection,
      configurationAdapterPlan: fixture.plan,
      provider: provider,
    );

    expect(result.entries, hasLength(2));
    expect(result.configurationProjectionId, fixture.projection.id);
    expect(result.configurationProjectionDigest, fixture.projection.digest);
    expect(result.configurationAdapterPlanId, fixture.plan.id);
    expect(result.configurationAdapterPlanDigest, fixture.plan.digest);
    expect(result.loadRequestDigest, provider.request!.digest);
    expect(result.digest, hasLength(64));
    expect(result.entries.first.values, {'endpoint': 'a', 'mode': 'test'});
  });

  test('same provider snapshot replays to identical JSON and digest', () async {
    final first = await const ConfigurationLoader().load(
      configurationProjection: fixture.projection,
      configurationAdapterPlan: fixture.plan,
      provider: _Provider(_loaded(fixture.projection.entries)),
    );
    final reversed = _loaded(fixture.projection.entries.reversed.toList())
        .map(
          (entry) => LoadedConfigurationEntry(
            configurationEntryId: entry.configurationEntryId,
            values: entry.values.reversed.toList(),
          ),
        )
        .toList();
    final replay = await const ConfigurationLoader().load(
      configurationProjection: fixture.projection,
      configurationAdapterPlan: fixture.plan,
      provider: _Provider(reversed),
    );

    expect(replay.toJson(), first.toJson());
    expect(replay.digest, first.digest);
  });

  test('missing required configuration fails closed', () async {
    await expectLater(
      const ConfigurationLoader().load(
        configurationProjection: fixture.projection,
        configurationAdapterPlan: fixture.plan,
        provider: _Provider([
          _loaded(fixture.projection.entries).first,
        ]),
      ),
      throwsStateError,
    );
  });

  test('empty required configuration fails closed', () async {
    final loaded = _loaded(fixture.projection.entries);
    loaded[0] = LoadedConfigurationEntry(
      configurationEntryId: loaded.first.configurationEntryId,
      values: const [],
    );
    await expectLater(
      const ConfigurationLoader().load(
        configurationProjection: fixture.projection,
        configurationAdapterPlan: fixture.plan,
        provider: _Provider(loaded),
      ),
      throwsStateError,
    );
  });

  test('duplicate provider entries and value names fail closed', () async {
    final source = _loaded(fixture.projection.entries);
    await expectLater(
      const ConfigurationLoader().load(
        configurationProjection: fixture.projection,
        configurationAdapterPlan: fixture.plan,
        provider: _Provider([source.first, source.first]),
      ),
      throwsStateError,
    );

    final duplicateValues = [...source];
    duplicateValues[0] = LoadedConfigurationEntry(
      configurationEntryId: source.first.configurationEntryId,
      values: const [
        LoadedConfigurationValue(name: 'mode', value: 'one'),
        LoadedConfigurationValue(name: 'mode', value: 'two'),
      ],
    );
    await expectLater(
      const ConfigurationLoader().load(
        configurationProjection: fixture.projection,
        configurationAdapterPlan: fixture.plan,
        provider: _Provider(duplicateValues),
      ),
      throwsStateError,
    );
  });

  test('foreign and duplicate ownership are rejected before provider access',
      () async {
    final foreignProvider = _Provider(_loaded(fixture.projection.entries));
    await expectLater(
      const ConfigurationLoader().load(
        configurationProjection: fixture.projection,
        configurationAdapterPlan: _Plan(
          configurationProjectionId: 'foreign',
          configurationProjectionDigest: fixture.projection.digest,
          entries: fixture.plan.entries,
        ),
        provider: foreignProvider,
      ),
      throwsArgumentError,
    );
    expect(foreignProvider.calls, 0);

    final duplicateProvider = _Provider(_loaded(fixture.projection.entries));
    final duplicateProjection = _Projection([
      fixture.projection.entries.first,
      fixture.projection.entries.first,
    ]);
    await expectLater(
      const ConfigurationLoader().load(
        configurationProjection: duplicateProjection,
        configurationAdapterPlan: _Plan(
          configurationProjectionId: duplicateProjection.id,
          configurationProjectionDigest: duplicateProjection.digest,
          entries: [
            for (var position = 0; position < 2; position++)
              ConfigurationAdapterEntry.create(
                featureId: 'feature.$position',
                flutterAdapterEntryId: 'flutter.$position',
                position: position,
                configurationProjectionDigest: duplicateProjection.digest,
                flutterApplicationAdapterPlanDigest: _flutterDigest,
              ),
          ],
        ),
        provider: duplicateProvider,
      ),
      throwsArgumentError,
    );
    expect(duplicateProvider.calls, 0);
  });

  test('request and runtime result collections are immutable', () async {
    final source = _loaded(fixture.projection.entries);
    final provider = _Provider(source);
    final result = await const ConfigurationLoader().load(
      configurationProjection: fixture.projection,
      configurationAdapterPlan: fixture.plan,
      provider: provider,
    );

    expect(
      () => provider.request!.ownership.add(provider.request!.ownership.first),
      throwsUnsupportedError,
    );
    expect(
      () => result.entries.add(result.entries.first),
      throwsUnsupportedError,
    );
    expect(
      () => result.entries.first.values['new'] = 'value',
      throwsUnsupportedError,
    );
    source[0] = LoadedConfigurationEntry(
      configurationEntryId: source.first.configurationEntryId,
      values: const [
        LoadedConfigurationValue(name: 'changed', value: 'after-load'),
      ],
    );
    expect(result.entries.first.values, {'endpoint': 'a', 'mode': 'test'});
  });
}

const _configurationDigest =
    'cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc';
const _flutterDigest =
    'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff';

class _Fixture {
  const _Fixture({required this.projection, required this.plan});

  final RuntimeConfigurationEnvironmentProjectionContract projection;
  final ConfigurationAdapterPlan plan;
}

_Fixture _fixture() {
  final projection = _Projection([
    _entry(position: 0, suffix: 'a'),
    _entry(position: 1, suffix: 'b'),
  ]);
  return _Fixture(
    projection: projection,
    plan: _Plan(
      configurationProjectionId: projection.id,
      configurationProjectionDigest: projection.digest,
      entries: [
        for (var position = 0; position < 2; position++)
          ConfigurationAdapterEntry.create(
            featureId: 'feature.$position',
            flutterAdapterEntryId: 'flutter.$position',
            position: position,
            configurationProjectionDigest: projection.digest,
            flutterApplicationAdapterPlanDigest: _flutterDigest,
          ),
      ],
    ),
  );
}

RuntimeConfigurationEnvironmentEntry _entry({
  required int position,
  required String suffix,
}) =>
    RuntimeConfigurationEnvironmentEntry(
      configurationEntryId: 'configuration-entry.$suffix',
      configurationId: 'configuration.$suffix',
      environmentId: 'environment.test',
      runtimeNodeId: 'node.$suffix',
      serviceId: 'service.$suffix',
      deliveryId: 'delivery.$suffix',
      deliveryTarget: RuntimeDeliveryTarget.application,
      runtimeHealthProjectionDigest: 'health',
      runtimeDeliveryProjectionDigest: 'delivery',
      configurationProvenanceDigest: 'provenance.$suffix',
      canonicalPosition: position,
    );

List<LoadedConfigurationEntry> _loaded(
  List<RuntimeConfigurationEnvironmentEntry> entries,
) =>
    [
      for (final entry in entries)
        LoadedConfigurationEntry(
          configurationEntryId: entry.configurationEntryId,
          values: const [
            LoadedConfigurationValue(name: 'mode', value: 'test'),
            LoadedConfigurationValue(name: 'endpoint', value: 'a'),
          ],
        ),
    ];

class _Provider implements ConfigurationValueProvider {
  _Provider(this.entries);

  final List<LoadedConfigurationEntry> entries;
  ConfigurationLoadRequest? request;
  int calls = 0;

  @override
  Future<List<LoadedConfigurationEntry>> load(
    ConfigurationLoadRequest request,
  ) async {
    calls++;
    this.request = request;
    return entries;
  }
}

class _Projection implements RuntimeConfigurationEnvironmentProjectionContract {
  _Projection(this.entries);

  @override
  final List<RuntimeConfigurationEnvironmentEntry> entries;

  @override
  String get id => 'configuration-projection.test';

  @override
  String get digest => _configurationDigest;

  @override
  String get configurationProjectionId => 'configuration.test';

  @override
  String get runtimeDeliveryProjectionDigest => 'delivery';

  @override
  String get runtimeDeliveryProjectionId => 'delivery.test';

  @override
  String get runtimeHealthProjectionDigest => 'health';

  @override
  String get runtimeHealthProjectionId => 'health.test';

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'digest': digest,
        'entries': entries.map((entry) => entry.toJson()).toList(),
      };
}

class _Plan implements ConfigurationAdapterPlan {
  _Plan({
    required this.configurationProjectionId,
    required this.configurationProjectionDigest,
    required this.entries,
  });

  @override
  final String configurationProjectionId;

  @override
  final String configurationProjectionDigest;

  @override
  final List<ConfigurationAdapterEntry> entries;

  @override
  String get id => 'configuration-adapter-plan.test';

  @override
  String get digest =>
      'dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd';

  @override
  String get flutterApplicationAdapterPlanDigest => _flutterDigest;

  @override
  String get flutterApplicationAdapterPlanId => 'flutter-plan.test';

  @override
  List<ConfigurationAdapterLogEntry> get log => const [];

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'digest': digest,
        'configurationProjectionId': configurationProjectionId,
        'configurationProjectionDigest': configurationProjectionDigest,
        'entries': entries.map((entry) => entry.toJson()).toList(),
      };
}
