import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/runtime_activation_coordination_contracts.dart';
import 'package:pool_os/contracts/runtime_composition_contracts.dart';
import 'package:pool_os/contracts/runtime_dependency_resolution_contracts.dart';
import 'package:pool_os/contracts/runtime_service_composition_contracts.dart';
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
        kind: RuntimeNodeKind.promptAssembly,
        sourceContractVersion: 1,
        sourceDigest: 'b',
      ),
      RuntimeNodeContract(
        id: 'c',
        kind: RuntimeNodeKind.activation,
        sourceContractVersion: 1,
        sourceDigest: 'c',
      ),
    ],
    edges: const [
      RuntimeEdgeContract(fromId: 'a', toId: 'c'),
      RuntimeEdgeContract(fromId: 'b', toId: 'c'),
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

  test('activation coordination is immutable and deterministic', () {
    final first = const RuntimeActivationCoordinator().coordinate(dependencies);
    final second =
        const RuntimeActivationCoordinator().coordinate(dependencies);
    expect(second.toJson(), first.toJson());
    expect(first.entries, hasLength(3));
    expect(
        () => first.entries.add(first.entries.first), throwsUnsupportedError);
  });

  test('activation order respects dependencies and canonical ties', () {
    final result =
        const RuntimeActivationCoordinator().coordinate(dependencies);
    expect(
      result.entries.map((entry) => entry.runtimeNodeId),
      ['a', 'b', 'c'],
    );
  });

  test('entries bind dependency identity and provenance', () {
    final result =
        const RuntimeActivationCoordinator().coordinate(dependencies);
    expect(result.dependencyResolutionId, dependencies.id);
    expect(result.dependencyResolutionDigest, dependencies.digest);
    expect(
      result.entries.every(
        (entry) => entry.dependencyResolutionDigest == dependencies.digest,
      ),
      isTrue,
    );
  });

  test('duplicate activation entry or position fails closed', () {
    final result =
        const RuntimeActivationCoordinator().coordinate(dependencies);
    expect(
      () => RuntimeActivationCoordinationContract.create(
        dependencyResolution: dependencies,
        entries: [
          result.entries.first,
          result.entries.first,
          result.entries.last,
        ],
      ),
      throwsArgumentError,
    );
  });

  test('invalid activation topology fails closed', () {
    final result =
        const RuntimeActivationCoordinator().coordinate(dependencies);
    expect(
      () => RuntimeActivationCoordinationContract.create(
        dependencyResolution: dependencies,
        entries: [
          RuntimeActivationCoordinationEntry(
            activationId: result.entries[1].activationId,
            serviceId: result.entries[1].serviceId,
            runtimeNodeId: result.entries[1].runtimeNodeId,
            dependencyResolutionDigest:
                result.entries[1].dependencyResolutionDigest,
            position: 0,
            metadata: result.entries[1].metadata,
          ),
          RuntimeActivationCoordinationEntry(
            activationId: result.entries[0].activationId,
            serviceId: result.entries[0].serviceId,
            runtimeNodeId: result.entries[0].runtimeNodeId,
            dependencyResolutionDigest:
                result.entries[0].dependencyResolutionDigest,
            position: 1,
            metadata: result.entries[0].metadata,
          ),
          result.entries[2],
        ],
      ),
      throwsArgumentError,
    );
  });

  test('stale dependency binding or broken metadata fails closed', () {
    final result =
        const RuntimeActivationCoordinator().coordinate(dependencies);
    expect(
      () => RuntimeActivationCoordinationContract.create(
        dependencyResolution: dependencies,
        entries: [
          RuntimeActivationCoordinationEntry(
            activationId: result.entries.first.activationId,
            serviceId: result.entries.first.serviceId,
            runtimeNodeId: result.entries.first.runtimeNodeId,
            dependencyResolutionDigest: 'stale',
            position: 0,
            metadata: 'broken',
          ),
          result.entries[1],
          result.entries[2],
        ],
      ),
      throwsArgumentError,
    );
  });

  test('coordinator does not mutate dependency projection', () {
    final before = dependencies.toJson();
    const RuntimeActivationCoordinator().coordinate(dependencies);
    expect(dependencies.toJson(), before);
  });
}
