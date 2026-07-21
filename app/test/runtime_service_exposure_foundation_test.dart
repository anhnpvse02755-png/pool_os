import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/runtime_activation_coordination_contracts.dart';
import 'package:pool_os/contracts/runtime_composition_contracts.dart';
import 'package:pool_os/contracts/runtime_dependency_resolution_contracts.dart';
import 'package:pool_os/contracts/runtime_service_composition_contracts.dart';
import 'package:pool_os/contracts/runtime_service_exposure_contracts.dart';
import 'package:pool_os/contracts/runtime_service_registry_contracts.dart';

void main() {
  final runtimeComposition = const RuntimeCompositionEngine().compose(
    nodes: const [
      RuntimeNodeContract(
        id: 'a',
        kind: RuntimeNodeKind.session,
        sourceContractVersion: 1,
        sourceDigest: 'a',
      ),
      RuntimeNodeContract(
        id: 'b',
        kind: RuntimeNodeKind.toolInvocation,
        sourceContractVersion: 1,
        sourceDigest: 'b',
      ),
      RuntimeNodeContract(
        id: 'c',
        kind: RuntimeNodeKind.conversationMemory,
        sourceContractVersion: 1,
        sourceDigest: 'c',
      ),
      RuntimeNodeContract(
        id: 'd',
        kind: RuntimeNodeKind.promptAssembly,
        sourceContractVersion: 1,
        sourceDigest: 'd',
      ),
      RuntimeNodeContract(
        id: 'e',
        kind: RuntimeNodeKind.providerRequest,
        sourceContractVersion: 1,
        sourceDigest: 'e',
      ),
    ],
    edges: const [
      RuntimeEdgeContract(fromId: 'a', toId: 'b'),
      RuntimeEdgeContract(fromId: 'b', toId: 'c'),
      RuntimeEdgeContract(fromId: 'c', toId: 'd'),
      RuntimeEdgeContract(fromId: 'd', toId: 'e'),
    ],
  );
  final serviceComposition = const RuntimeServiceCompositionEngine().compose(
    runtimeComposition,
  );
  final registry =
      const RuntimeServiceRegistryBuilder().build(serviceComposition);
  final dependencies = const RuntimeDependencyResolutionBuilder().build(
    registry: registry,
    runtimeComposition: runtimeComposition,
  );
  final activation =
      const RuntimeActivationCoordinator().coordinate(dependencies);

  test('exposure projection is immutable and deterministic', () {
    final first = const RuntimeServiceExposureProjector().project(
      activationCoordination: activation,
      registry: registry,
    );
    final second = const RuntimeServiceExposureProjector().project(
      activationCoordination: activation,
      registry: registry,
    );
    expect(second.toJson(), first.toJson());
    expect(first.entries, hasLength(5));
    expect(
        () => first.entries.add(first.entries.first), throwsUnsupportedError);
  });

  test('v1 exposure policy maps every service type explicitly', () {
    final result = const RuntimeServiceExposureProjector().project(
      activationCoordination: activation,
      registry: registry,
    );
    expect(result.entries.map((entry) => entry.scope), [
      RuntimeExposureScope.internal,
      RuntimeExposureScope.application,
      RuntimeExposureScope.application,
      RuntimeExposureScope.aiConsumer,
      RuntimeExposureScope.api,
    ]);
  });

  test('entries bind activation and registry provenance', () {
    final result = const RuntimeServiceExposureProjector().project(
      activationCoordination: activation,
      registry: registry,
    );
    expect(result.activationCoordinationDigest, activation.digest);
    expect(result.runtimeServiceRegistryDigest, registry.digest);
    expect(result.entries.first.runtimeNodeId, 'a');
  });

  test('duplicate exposure entry or position fails closed', () {
    final result = const RuntimeServiceExposureProjector().project(
      activationCoordination: activation,
      registry: registry,
    );
    expect(
      () => RuntimeServiceExposureContract.create(
        activationCoordination: activation,
        registry: registry,
        entries: [result.entries.first, ...result.entries.take(4)],
      ),
      throwsArgumentError,
    );
  });

  test('orphan activation or registry mismatch fails closed', () {
    final shortRuntime = const RuntimeCompositionEngine().compose(
      nodes: const [
        RuntimeNodeContract(
          id: 'x',
          kind: RuntimeNodeKind.session,
          sourceContractVersion: 1,
          sourceDigest: 'x',
        ),
      ],
      edges: const [],
    );
    final shortRegistry = const RuntimeServiceRegistryBuilder().build(
      const RuntimeServiceCompositionEngine().compose(shortRuntime),
    );
    expect(
      () => const RuntimeServiceExposureProjector().project(
        activationCoordination: activation,
        registry: shortRegistry,
      ),
      throwsArgumentError,
    );
  });

  test('invalid exposure scope fails closed', () {
    final result = const RuntimeServiceExposureProjector().project(
      activationCoordination: activation,
      registry: registry,
    );
    final first = result.entries.first;
    expect(
      () => RuntimeServiceExposureContract.create(
        activationCoordination: activation,
        registry: registry,
        entries: [
          RuntimeServiceExposureEntry(
            exposureId: first.exposureId,
            activationCoordinationDigest: first.activationCoordinationDigest,
            runtimeServiceRegistryDigest: first.runtimeServiceRegistryDigest,
            serviceId: first.serviceId,
            runtimeNodeId: first.runtimeNodeId,
            serviceType: first.serviceType,
            scope: RuntimeExposureScope.api,
            position: first.position,
          ),
          ...result.entries.skip(1),
        ],
      ),
      throwsArgumentError,
    );
  });

  test('stale binding or broken service type fails closed', () {
    final result = const RuntimeServiceExposureProjector().project(
      activationCoordination: activation,
      registry: registry,
    );
    final first = result.entries.first;
    expect(
      () => RuntimeServiceExposureContract.create(
        activationCoordination: activation,
        registry: registry,
        entries: [
          RuntimeServiceExposureEntry(
            exposureId: first.exposureId,
            activationCoordinationDigest: 'stale',
            runtimeServiceRegistryDigest: 'stale',
            serviceId: first.serviceId,
            runtimeNodeId: first.runtimeNodeId,
            serviceType: RuntimeServiceType.adapter,
            scope: RuntimeExposureScope.api,
            position: first.position,
          ),
          ...result.entries.skip(1),
        ],
      ),
      throwsArgumentError,
    );
  });

  test('projector does not mutate authoritative inputs', () {
    final beforeActivation = activation.toJson();
    final beforeRegistry = registry.toJson();
    const RuntimeServiceExposureProjector().project(
      activationCoordination: activation,
      registry: registry,
    );
    expect(activation.toJson(), beforeActivation);
    expect(registry.toJson(), beforeRegistry);
  });
}
