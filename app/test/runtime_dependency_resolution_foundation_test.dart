import 'package:flutter_test/flutter_test.dart';
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
        kind: RuntimeNodeKind.activation,
        sourceContractVersion: 1,
        sourceDigest: 'b',
      ),
    ],
    edges: const [RuntimeEdgeContract(fromId: 'a', toId: 'b')],
  );
  final serviceComposition = const RuntimeServiceCompositionEngine().compose(
    runtimeComposition,
  );
  final registry =
      const RuntimeServiceRegistryBuilder().build(serviceComposition);

  test('dependency projection is immutable, canonical, and deterministic', () {
    final first = const RuntimeDependencyResolutionBuilder().build(
      registry: registry,
      runtimeComposition: runtimeComposition,
    );
    final second = const RuntimeDependencyResolutionBuilder().build(
      registry: registry,
      runtimeComposition: runtimeComposition,
    );
    expect(second.toJson(), first.toJson());
    expect(first.nodes, hasLength(2));
    expect(first.edges, hasLength(1));
    expect(() => first.edges.add(first.edges.first), throwsUnsupportedError);
  });

  test('nodes bind registry and runtime provenance', () {
    final result = const RuntimeDependencyResolutionBuilder().build(
      registry: registry,
      runtimeComposition: runtimeComposition,
    );
    expect(result.registryDigest, registry.digest);
    expect(result.runtimeCompositionDigest, runtimeComposition.digest);
    expect(result.nodes.first.runtimeNodeId, 'a');
    expect(result.edges.first.runtimeEdgeId, 'runtime-edge.a->b');
  });

  test('dependency edges project authoritative runtime topology', () {
    final result = const RuntimeDependencyResolutionBuilder().build(
      registry: registry,
      runtimeComposition: runtimeComposition,
    );
    expect(result.edges.single.fromServiceId, registry.entries.first.serviceId);
    expect(result.edges.single.toServiceId, registry.entries.last.serviceId);
  });

  test('registry and runtime composition mismatch fails closed', () {
    final other = const RuntimeCompositionEngine().compose(
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
    expect(
      () => const RuntimeDependencyResolutionBuilder().build(
        registry: registry,
        runtimeComposition: other,
      ),
      throwsArgumentError,
    );
  });

  test('orphan or foreign dependency node fails closed', () {
    final result = const RuntimeDependencyResolutionBuilder().build(
      registry: registry,
      runtimeComposition: runtimeComposition,
    );
    expect(
      () => RuntimeDependencyResolutionContract.create(
        registry: registry,
        runtimeComposition: runtimeComposition,
        nodes: [result.nodes.first],
        edges: result.edges,
      ),
      throwsArgumentError,
    );
  });

  test('duplicate dependency edge fails closed', () {
    final result = const RuntimeDependencyResolutionBuilder().build(
      registry: registry,
      runtimeComposition: runtimeComposition,
    );
    expect(
      () => RuntimeDependencyResolutionContract.create(
        registry: registry,
        runtimeComposition: runtimeComposition,
        nodes: result.nodes,
        edges: [result.edges.single, result.edges.single],
      ),
      throwsArgumentError,
    );
  });

  test('cycle detection remains fail closed', () {
    expect(
      () => const RuntimeCompositionEngine().compose(
        nodes: const [
          RuntimeNodeContract(
            id: 'a',
            kind: RuntimeNodeKind.session,
            sourceContractVersion: 1,
            sourceDigest: 'a',
          ),
          RuntimeNodeContract(
            id: 'b',
            kind: RuntimeNodeKind.activation,
            sourceContractVersion: 1,
            sourceDigest: 'b',
          ),
        ],
        edges: const [
          RuntimeEdgeContract(fromId: 'a', toId: 'b'),
          RuntimeEdgeContract(fromId: 'b', toId: 'a'),
        ],
      ),
      throwsArgumentError,
    );
  });

  test('builder does not mutate authoritative inputs', () {
    final beforeRegistry = registry.toJson();
    final beforeRuntime = runtimeComposition.toJson();
    const RuntimeDependencyResolutionBuilder().build(
      registry: registry,
      runtimeComposition: runtimeComposition,
    );
    expect(registry.toJson(), beforeRegistry);
    expect(runtimeComposition.toJson(), beforeRuntime);
  });
}
