import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/application/ai_provider_runtime.dart';
import 'package:pool_os/application/dependency_activation_runtime.dart';
import 'package:pool_os/application/dependency_composition_engine.dart';

void main() {
  final fixture = _fixture();

  test('activates exact registrations through abstract port', () async {
    final activator = _Activator();
    final state = await const DependencyActivationRuntime().activate(
      registrationPlan: fixture.plan,
      aiProviderState: fixture.aiState,
      authorization: fixture.authorization,
      activator: activator,
    );

    expect(state.entries, hasLength(2));
    expect(state.entries.first.activationId, 'activation.0');
    expect(state.entries.first.serviceId, 'service.0');
    expect(state.entries.first.runtimeNodeId, 'runtime-node.0');
    expect(state.registrationPlanId, fixture.plan.id);
    expect(state.aiProviderStateId, fixture.aiState.id);
    expect(state.authorizationDigest, fixture.authorization.digest);
    expect(state.requestDigest, activator.request!.digest);
    expect(state.digest, hasLength(64));
  });

  test('reordered plan and results replay identically', () async {
    final first = await const DependencyActivationRuntime().activate(
      registrationPlan: fixture.plan,
      aiProviderState: fixture.aiState,
      authorization: fixture.authorization,
      activator: _Activator(),
    );
    final reorderedPlan = _Plan(fixture.plan.registrations.reversed.toList());
    final replay = await const DependencyActivationRuntime().activate(
      registrationPlan: reorderedPlan,
      aiProviderState: fixture.aiState,
      authorization: DependencyActivationAuthorization.create(
        registrationPlan: reorderedPlan,
        aiProviderState: fixture.aiState,
      ),
      activator: _Activator(reverse: true),
    );

    expect(replay.toJson(), first.toJson());
  });

  test('stale authorization fails before activation', () async {
    final stalePlan = _Plan(fixture.plan.registrations, digest: 'stale-plan');
    final staleState = _AIState(fixture.aiState.entries, digest: 'stale-ai');
    for (final authorization in [
      DependencyActivationAuthorization.create(
        registrationPlan: stalePlan,
        aiProviderState: fixture.aiState,
      ),
      DependencyActivationAuthorization.create(
        registrationPlan: fixture.plan,
        aiProviderState: staleState,
      ),
    ]) {
      final activator = _Activator();
      await expectLater(
        const DependencyActivationRuntime().activate(
          registrationPlan: fixture.plan,
          aiProviderState: fixture.aiState,
          authorization: authorization,
          activator: activator,
        ),
        throwsArgumentError,
      );
      expect(activator.calls, 0);
    }
  });

  test('duplicate, gapped, and malformed registrations fail closed', () async {
    final first = fixture.plan.registrations.first;
    for (final registrations in [
      [first, first],
      [first, _registration(2)],
      [first, const _MalformedRegistration(position: 1)],
    ]) {
      final plan = _Plan(registrations);
      final activator = _Activator();
      await expectLater(
        const DependencyActivationRuntime().activate(
          registrationPlan: plan,
          aiProviderState: fixture.aiState,
          authorization: DependencyActivationAuthorization.create(
            registrationPlan: plan,
            aiProviderState: fixture.aiState,
          ),
          activator: activator,
        ),
        throwsArgumentError,
      );
      expect(activator.calls, 0);
    }
  });

  test('missing and orphan activation coverage fail closed', () async {
    for (final activator in [
      _Activator(omitLast: true),
      _Activator(orphan: true),
    ]) {
      await expectLater(
        const DependencyActivationRuntime().activate(
          registrationPlan: fixture.plan,
          aiProviderState: fixture.aiState,
          authorization: fixture.authorization,
          activator: activator,
        ),
        throwsStateError,
      );
    }
  });

  test('duplicate result target and handle are rejected', () async {
    for (final activator in [
      _Activator(duplicateTarget: true),
      _Activator(duplicateHandle: true),
    ]) {
      await expectLater(
        const DependencyActivationRuntime().activate(
          registrationPlan: fixture.plan,
          aiProviderState: fixture.aiState,
          authorization: fixture.authorization,
          activator: activator,
        ),
        throwsStateError,
      );
    }
  });

  test('stale activation result fails closed', () async {
    await expectLater(
      const DependencyActivationRuntime().activate(
        registrationPlan: fixture.plan,
        aiProviderState: fixture.aiState,
        authorization: fixture.authorization,
        activator: _Activator(staleRequest: true),
      ),
      throwsStateError,
    );
  });

  test('authorization, request, and state expose immutable boundaries',
      () async {
    final activator = _Activator();
    final state = await const DependencyActivationRuntime().activate(
      registrationPlan: fixture.plan,
      aiProviderState: fixture.aiState,
      authorization: fixture.authorization,
      activator: activator,
    );

    expect(
      () => activator.request!.targets.add(activator.request!.targets.first),
      throwsUnsupportedError,
    );
    expect(
        () => state.entries.add(state.entries.first), throwsUnsupportedError);
    final json = state.toJson().toString().toLowerCase();
    for (final forbidden in [
      'getit',
      'singleton',
      'factoryinstance',
      'prompt',
      'modelselection',
    ]) {
      expect(json, isNot(contains(forbidden)));
    }
  });
}

const _planDigest =
    'pppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppp';
const _aiStateDigest =
    'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';

class _Fixture {
  const _Fixture({
    required this.plan,
    required this.aiState,
    required this.authorization,
  });

  final DependencyRegistrationPlan plan;
  final RuntimeAIProviderState aiState;
  final DependencyActivationAuthorization authorization;
}

_Fixture _fixture() {
  final plan = _Plan([_registration(0), _registration(1)]);
  final aiState = _AIState(const [_AIEntry(0), _AIEntry(1)]);
  return _Fixture(
    plan: plan,
    aiState: aiState,
    authorization: DependencyActivationAuthorization.create(
      registrationPlan: plan,
      aiProviderState: aiState,
    ),
  );
}

DependencyRegistrationDescriptor _registration(int position) =>
    DependencyRegistrationDescriptor.create(
      compositionEntryId: 'composition.$position',
      activationId: 'activation.$position',
      serviceId: 'service.$position',
      runtimeNodeId: 'runtime-node.$position',
      position: position,
      compositionRootDigest: 'composition-root',
      activationProjectionDigest: 'activation-projection',
    );

class _Activator implements DependencyActivator {
  _Activator({
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
  DependencyActivationRequest? request;
  int calls = 0;

  @override
  Future<List<DependencyActivationResult>> activate(
    DependencyActivationRequest request,
  ) async {
    calls++;
    this.request = request;
    final targets = [...request.targets];
    if (omitLast) targets.removeLast();
    final results = [
      for (var position = 0; position < targets.length; position++)
        DependencyActivationResult.create(
          registrationId: targets[position].registrationId,
          activationHandleId:
              duplicateHandle ? 'handle.shared' : 'handle.$position',
          requestDigest: staleRequest ? 'stale' : request.digest,
        ),
    ];
    if (orphan) {
      results.add(DependencyActivationResult.create(
        registrationId: 'dependency-registration.orphan',
        activationHandleId: 'handle.orphan',
        requestDigest: request.digest,
      ));
    }
    if (duplicateTarget && results.isNotEmpty) results.add(results.first);
    return reverse ? results.reversed.toList() : results;
  }
}

class _Plan implements DependencyRegistrationPlan {
  _Plan(this.registrations, {this.digest = _planDigest});

  @override
  final List<DependencyRegistrationDescriptor> registrations;
  @override
  final String digest;
  @override
  String get id => 'dependency-registration-plan.test';
  @override
  String get compositionRootId => 'composition-root.test';
  @override
  String get compositionRootDigest => 'composition-root';
  @override
  String get activationProjectionId => 'activation-projection.test';
  @override
  String get activationProjectionDigest => 'activation-projection';
  @override
  List<DependencyCompositionLogEntry> get log => const [];
  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'digest': digest,
        'registrations': registrations.map((entry) => entry.toJson()).toList(),
      };
}

class _AIState implements RuntimeAIProviderState {
  _AIState(this.entries, {this.digest = _aiStateDigest});

  @override
  final List<RuntimeAIProviderEntry> entries;
  @override
  final String digest;
  @override
  String get id => 'runtime-ai-provider.test';
  @override
  String get aiProviderAdapterPlanId => 'ai-provider-plan.test';
  @override
  String get aiProviderAdapterPlanDigest => 'ai-provider-plan-digest';
  @override
  String get runtimeTransportStateId => 'transport-state.test';
  @override
  String get runtimeTransportStateDigest => 'transport-state-digest';
  @override
  String get initializationRequestDigest => 'initialization-request-digest';
  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'digest': digest,
        'entries': entries.map((entry) => entry.toJson()).toList(),
      };
}

class _AIEntry implements RuntimeAIProviderEntry {
  const _AIEntry(this.position);

  @override
  final int position;
  @override
  String get id => 'runtime-ai-provider-entry.$position';
  @override
  String get aiProviderAdapterEntryId => 'ai-provider-adapter.$position';
  @override
  String get featureId => 'feature.$position';
  @override
  String get transportAdapterEntryId => 'transport-adapter.$position';
  @override
  String get runtimeProviderId => 'runtime-provider.$position';
  @override
  String get aiProviderAdapterProvenanceDigest => 'provenance.$position';
  @override
  String get providerInitializationDigest => 'provider-result.$position';
  @override
  String get digest => 'entry-digest.$position';
  @override
  Map<String, dynamic> toJson() => {'id': id, 'position': position};
}

class _MalformedRegistration implements DependencyRegistrationDescriptor {
  const _MalformedRegistration({required this.position});

  @override
  final int position;
  @override
  String get registrationId => 'dependency-registration.malformed';
  @override
  String get compositionEntryId => 'composition.malformed';
  @override
  String get activationId => 'activation.malformed';
  @override
  String get serviceId => 'service.malformed';
  @override
  String get runtimeNodeId => 'runtime-node.malformed';
  @override
  String get compositionRootDigest => 'composition-root';
  @override
  String get activationProjectionDigest => 'activation-projection';
  @override
  String get digest => '';
  @override
  Map<String, dynamic> toJson() => {'registrationId': registrationId};
}
