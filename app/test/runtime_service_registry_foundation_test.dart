import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/runtime_composition_contracts.dart';
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

  test('registry is immutable, canonical, and deterministic', () {
    final first =
        const RuntimeServiceRegistryBuilder().build(serviceComposition);
    final second =
        const RuntimeServiceRegistryBuilder().build(serviceComposition);
    expect(second.toJson(), first.toJson());
    expect(first.entries, hasLength(2));
    expect(
        () => first.entries.add(first.entries.first), throwsUnsupportedError);
  });

  test('registry entries bind service composition provenance', () {
    final registry =
        const RuntimeServiceRegistryBuilder().build(serviceComposition);
    expect(registry.compositionId, serviceComposition.runtimeCompositionId);
    expect(registry.compositionDigest, serviceComposition.digest);
    expect(
      registry.entries.every(
        (entry) =>
            entry.compositionDigest == serviceComposition.digest &&
            entry.metadata == serviceComposition.runtimeCompositionId,
      ),
      isTrue,
    );
  });

  test('registry identity and positions are canonical', () {
    final registry =
        const RuntimeServiceRegistryBuilder().build(serviceComposition);
    expect(registry.entries.map((entry) => entry.position), [0, 1]);
    expect(registry.entries.map((entry) => entry.serviceKey).toSet(),
        hasLength(2));
    expect(registry.entries.map((entry) => entry.type), [
      RuntimeServiceType.core,
      RuntimeServiceType.projection,
    ]);
  });

  test('duplicate service ID or registry key fails closed', () {
    final registry =
        const RuntimeServiceRegistryBuilder().build(serviceComposition);
    expect(
      () => RuntimeServiceRegistryContract.create(
        composition: serviceComposition,
        entries: [registry.entries.first, registry.entries.first],
      ),
      throwsArgumentError,
    );
  });

  test('orphan composition entry fails closed', () {
    final registry =
        const RuntimeServiceRegistryBuilder().build(serviceComposition);
    expect(
      () => RuntimeServiceRegistryContract.create(
        composition: serviceComposition,
        entries: [registry.entries.first],
      ),
      throwsArgumentError,
    );
  });

  test('stale composition binding or invalid type fails closed', () {
    final registry =
        const RuntimeServiceRegistryBuilder().build(serviceComposition);
    expect(
      () => RuntimeServiceRegistryContract.create(
        composition: serviceComposition,
        entries: [
          registry.entries.first,
          RuntimeServiceRegistryEntry(
            serviceId: registry.entries.last.serviceId,
            serviceKey: registry.entries.last.serviceKey,
            type: RuntimeServiceType.adapter,
            compositionDigest: 'stale',
            position: 1,
            metadata: 'foreign',
          ),
        ],
      ),
      throwsArgumentError,
    );
  });

  test('builder does not mutate the service composition', () {
    final before = serviceComposition.toJson();
    const RuntimeServiceRegistryBuilder().build(serviceComposition);
    expect(serviceComposition.toJson(), before);
  });
}
