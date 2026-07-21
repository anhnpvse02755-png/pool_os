import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/runtime_composition_contracts.dart';
import 'package:pool_os/contracts/runtime_service_composition_contracts.dart';

void main() {
  final composition = const RuntimeCompositionEngine().compose(
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

  test('service composition is deterministic and immutable', () {
    final first = const RuntimeServiceCompositionEngine().compose(composition);
    final second = const RuntimeServiceCompositionEngine().compose(composition);
    expect(second.toJson(), first.toJson());
    expect(first.nodes, hasLength(2));
    expect(() => first.nodes.add(first.nodes.first), throwsUnsupportedError);
  });

  test('service nodes bind runtime composition provenance', () {
    final result = const RuntimeServiceCompositionEngine().compose(composition);
    expect(result.runtimeCompositionDigest, composition.digest);
    expect(
      result.nodes.every(
        (node) =>
            node.runtimeCompositionId == composition.id &&
            node.metadata == composition.digest,
      ),
      isTrue,
    );
  });

  test('service identities, positions, and types are canonical', () {
    final result = const RuntimeServiceCompositionEngine().compose(composition);
    expect(result.nodes.first.type, RuntimeServiceType.core);
    expect(result.nodes.last.type, RuntimeServiceType.projection);
    expect(result.nodes.map((node) => node.position), [0, 1]);
    expect(result.nodes.map((node) => node.serviceKey).toSet(), hasLength(2));
  });

  test('duplicate service key or position fails closed', () {
    final result = const RuntimeServiceCompositionEngine().compose(composition);
    expect(
      () => RuntimeServiceCompositionContract.create(
        composition: composition,
        nodes: [result.nodes.first, result.nodes.first],
      ),
      throwsArgumentError,
    );
  });

  test('orphan or foreign runtime binding fails closed', () {
    final result = const RuntimeServiceCompositionEngine().compose(composition);
    expect(
      () => RuntimeServiceCompositionContract.create(
        composition: composition,
        nodes: [result.nodes.first],
      ),
      throwsArgumentError,
    );
    expect(
      () => RuntimeServiceCompositionContract.create(
        composition: composition,
        nodes: [
          result.nodes.first,
          RuntimeServiceNode(
            serviceId: result.nodes.last.serviceId,
            runtimeCompositionId: 'foreign',
            serviceKey: result.nodes.last.serviceKey,
            type: result.nodes.last.type,
            position: 1,
            metadata: result.nodes.last.metadata,
          ),
        ],
      ),
      throwsArgumentError,
    );
  });

  test('stale provenance or invalid service type fails closed', () {
    final result = const RuntimeServiceCompositionEngine().compose(composition);
    expect(
      () => RuntimeServiceCompositionContract.create(
        composition: composition,
        nodes: [
          result.nodes.first,
          RuntimeServiceNode(
            serviceId: result.nodes.last.serviceId,
            runtimeCompositionId: result.nodes.last.runtimeCompositionId,
            serviceKey: result.nodes.last.serviceKey,
            type: RuntimeServiceType.adapter,
            position: 1,
            metadata: 'stale',
          ),
        ],
      ),
      throwsArgumentError,
    );
  });

  test('engine does not instantiate services or mutate composition', () {
    final before = composition.toJson();
    const RuntimeServiceCompositionEngine().compose(composition);
    expect(composition.toJson(), before);
  });
}
