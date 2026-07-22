import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/application/ai_provider_adapter_planner.dart';
import 'package:pool_os/application/ai_provider_runtime.dart';
import 'package:pool_os/application/transport_runtime.dart';

void main() {
  final fixture = _fixture();

  test('initializes exact AI provider targets through abstract port', () async {
    final provider = _Provider();
    final state = await const AIProviderRuntime().initialize(
      aiProviderAdapterPlan: fixture.plan,
      runtimeTransportState: fixture.transport,
      provider: provider,
    );
    expect(state.entries, hasLength(2));
    expect(state.aiProviderAdapterPlanId, fixture.plan.id);
    expect(state.runtimeTransportStateId, fixture.transport.id);
    expect(state.initializationRequestDigest, provider.request!.digest);
    expect(provider.request!.runtimeTransportState, same(fixture.transport));
    expect(state.digest, hasLength(64));
  });

  test('reordered plan and provider results replay identically', () async {
    final first = await const AIProviderRuntime().initialize(
      aiProviderAdapterPlan: fixture.plan,
      runtimeTransportState: fixture.transport,
      provider: _Provider(),
    );
    final replay = await const AIProviderRuntime().initialize(
      aiProviderAdapterPlan: _Plan(fixture.plan.entries.reversed.toList()),
      runtimeTransportState: fixture.transport,
      provider: _Provider(reverse: true),
    );
    expect(replay.toJson(), first.toJson());
  });

  test('stale transport plan identity and digest fail before provider',
      () async {
    for (final transport in [
      _TransportState(fixture.transport.entries, planId: 'foreign'),
      _TransportState(fixture.transport.entries, planDigest: 'stale'),
    ]) {
      final provider = _Provider();
      await expectLater(
        const AIProviderRuntime().initialize(
          aiProviderAdapterPlan: fixture.plan,
          runtimeTransportState: transport,
          provider: provider,
        ),
        throwsArgumentError,
      );
      expect(provider.calls, 0);
    }
  });

  test('orphan and incomplete transport ownership fail closed', () async {
    final orphan = _Plan([
      fixture.plan.entries.first,
      AIProviderAdapterEntry.create(
        featureId: 'orphan',
        transportAdapterEntryId: 'transport.orphan',
        position: 1,
        transportAdapterPlanDigest: _transportPlanDigest,
        aiCoachInteractionSurfaceDigest: 'surface',
      ),
    ]);
    for (final plan in [
      orphan,
      _Plan([fixture.plan.entries.first])
    ]) {
      await expectLater(
        const AIProviderRuntime().initialize(
          aiProviderAdapterPlan: plan,
          runtimeTransportState: fixture.transport,
          provider: _Provider(),
        ),
        throwsArgumentError,
      );
    }
  });

  test('missing and orphan provider coverage fail closed', () async {
    for (final provider in [
      _Provider(omitLast: true),
      _Provider(orphan: true),
    ]) {
      await expectLater(
        const AIProviderRuntime().initialize(
          aiProviderAdapterPlan: fixture.plan,
          runtimeTransportState: fixture.transport,
          provider: provider,
        ),
        throwsStateError,
      );
    }
  });

  test('duplicate target and runtime provider identity are rejected', () async {
    for (final provider in [
      _Provider(duplicateTarget: true),
      _Provider(duplicateProvider: true),
    ]) {
      await expectLater(
        const AIProviderRuntime().initialize(
          aiProviderAdapterPlan: fixture.plan,
          runtimeTransportState: fixture.transport,
          provider: provider,
        ),
        throwsStateError,
      );
    }
  });

  test('stale provider initialization fails closed', () async {
    await expectLater(
      const AIProviderRuntime().initialize(
        aiProviderAdapterPlan: fixture.plan,
        runtimeTransportState: fixture.transport,
        provider: _Provider(staleRequest: true),
      ),
      throwsStateError,
    );
  });

  test('request and state are immutable and contain no inference fields',
      () async {
    final provider = _Provider();
    final state = await const AIProviderRuntime().initialize(
      aiProviderAdapterPlan: fixture.plan,
      runtimeTransportState: fixture.transport,
      provider: provider,
    );
    expect(
      () => provider.request!.targets.add(provider.request!.targets.first),
      throwsUnsupportedError,
    );
    expect(
        () => state.entries.add(state.entries.first), throwsUnsupportedError);
    final json = state.toJson().toString().toLowerCase();
    for (final forbidden in [
      'prompt',
      'model',
      'token',
      'embedding',
      'conversation',
      'memory',
      'completion',
    ]) {
      expect(json, isNot(contains(forbidden)));
    }
  });
}

const _transportPlanId = 'transport-adapter-plan.test';
const _transportPlanDigest =
    'tttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt';
const _aiPlanDigest =
    'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
const _transportStateDigest =
    'ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss';

class _Fixture {
  const _Fixture({required this.plan, required this.transport});

  final AIProviderAdapterPlan plan;
  final RuntimeTransportState transport;
}

_Fixture _fixture() => _Fixture(
      plan: _Plan([
        for (var position = 0; position < 2; position++)
          AIProviderAdapterEntry.create(
            featureId: 'feature.$position',
            transportAdapterEntryId: 'transport-adapter.$position',
            position: position,
            transportAdapterPlanDigest: _transportPlanDigest,
            aiCoachInteractionSurfaceDigest: 'surface',
          ),
      ]),
      transport: _TransportState(const [
        _TransportEntry(position: 0),
        _TransportEntry(position: 1),
      ]),
    );

class _Provider implements AIRuntimeProvider {
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
  AIProviderInitializationRequest? request;
  int calls = 0;

  @override
  Future<List<AIProviderInitialization>> initialize(
    AIProviderInitializationRequest request,
  ) async {
    calls++;
    this.request = request;
    final targets = [...request.targets];
    if (omitLast) targets.removeLast();
    if (orphan) {
      targets.add(const AIProviderInitializationTarget(
        aiProviderAdapterEntryId: 'orphan',
        featureId: 'orphan',
        transportAdapterEntryId: 'orphan',
        position: 99,
        aiProviderAdapterProvenanceDigest: 'orphan',
      ));
    }
    final initialized = [
      for (var position = 0; position < targets.length; position++)
        AIProviderInitialization.create(
          aiProviderAdapterEntryId: targets[position].aiProviderAdapterEntryId,
          runtimeProviderId:
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

class _Plan implements AIProviderAdapterPlan {
  _Plan(this.entries);

  @override
  final List<AIProviderAdapterEntry> entries;
  @override
  String get id => 'ai-provider-adapter-plan.test';
  @override
  String get digest => _aiPlanDigest;
  @override
  String get transportAdapterPlanId => _transportPlanId;
  @override
  String get transportAdapterPlanDigest => _transportPlanDigest;
  @override
  String get aiCoachInteractionSurfaceDigest => 'surface';
  @override
  String get aiCoachInteractionSurfaceId => 'surface.test';
  @override
  List<AIProviderAdapterLogEntry> get log => const [];
  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'digest': digest,
        'entries': entries.map((entry) => entry.toJson()).toList(),
      };
}

class _TransportState implements RuntimeTransportState {
  _TransportState(
    this.entries, {
    this.planId = _transportPlanId,
    this.planDigest = _transportPlanDigest,
  });

  @override
  final List<RuntimeTransportEntry> entries;
  final String planId;
  final String planDigest;
  @override
  String get id => 'runtime-transport.test';
  @override
  String get digest => _transportStateDigest;
  @override
  String get transportAdapterPlanId => planId;
  @override
  String get transportAdapterPlanDigest => planDigest;
  @override
  String get runtimePersistenceStateId => 'persistence.test';
  @override
  String get runtimePersistenceStateDigest => 'persistence-digest';
  @override
  String get initializationRequestDigest => 'request-digest';
  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'digest': digest,
        'entries': entries.map((entry) => entry.toJson()).toList(),
      };
}

class _TransportEntry implements RuntimeTransportEntry {
  const _TransportEntry({required this.position});

  @override
  final int position;
  @override
  String get transportAdapterEntryId => 'transport-adapter.$position';
  @override
  String get featureId => 'feature.$position';
  @override
  String get id => 'runtime-transport-entry.$position';
  @override
  String get persistenceAdapterEntryId => 'persistence.$position';
  @override
  String get providerId => 'transport-provider.$position';
  @override
  String get providerInitializationDigest => 'provider-digest.$position';
  @override
  String get transportAdapterProvenanceDigest => 'provenance.$position';
  @override
  String get digest => 'digest.$position';
  @override
  Map<String, dynamic> toJson() => {
        'transportAdapterEntryId': transportAdapterEntryId,
        'position': position,
      };
}
