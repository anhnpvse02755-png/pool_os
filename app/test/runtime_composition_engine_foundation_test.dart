import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/runtime_composition_contracts.dart';

void main() {
  final nodes = [
    for (final kind in RuntimeNodeKind.values)
      RuntimeNodeContract(id: kind.name, kind: kind, sourceContractVersion: 1, sourceDigest: 'digest-${kind.name}'),
  ];
  final edges = [
    for (var i = 0; i < nodes.length - 1; i++) RuntimeEdgeContract(fromId: nodes[i].id, toId: nodes[i + 1].id),
  ];

  test('complete composition is immutable and deterministic', () {
    final first = const RuntimeCompositionEngine().compose(nodes: nodes, edges: edges);
    final second = const RuntimeCompositionEngine().compose(nodes: nodes.reversed.toList(), edges: edges.reversed.toList());
    expect(second.digest, first.digest);
    expect(first.nodes, hasLength(RuntimeNodeKind.values.length));
    expect(() => first.nodes.add(nodes.first), throwsUnsupportedError);
  });

  test('missing dependency fails closed', () => expect(() => const RuntimeCompositionEngine().compose(nodes: nodes.sublist(1), edges: edges), throwsArgumentError));
  test('duplicate node or edge fails closed', () {
    expect(() => const RuntimeCompositionEngine().compose(nodes: [...nodes, nodes.first], edges: edges), throwsArgumentError);
    expect(() => const RuntimeCompositionEngine().compose(nodes: nodes, edges: [...edges, edges.first]), throwsArgumentError);
  });
  test('cycle fails closed', () => expect(() => const RuntimeCompositionEngine().compose(nodes: nodes, edges: [...edges, RuntimeEdgeContract(fromId: nodes.last.id, toId: nodes.first.id)]), throwsArgumentError));
  test('orphan fails closed', () => expect(() => const RuntimeCompositionEngine().compose(nodes: [...nodes, const RuntimeNodeContract(id: 'orphan', kind: RuntimeNodeKind.activation, sourceContractVersion: 1, sourceDigest: 'orphan')], edges: edges), throwsArgumentError));
  test('stale references fail closed', () => expect(() => const RuntimeCompositionEngine().compose(nodes: nodes, edges: [...edges, const RuntimeEdgeContract(fromId: 'missing', toId: 'session')]), throwsArgumentError));
  test('incompatible node version fails closed', () => expect(() => const RuntimeCompositionEngine().compose(nodes: [...nodes.sublist(0, 1), const RuntimeNodeContract(id: 'bad', kind: RuntimeNodeKind.activation, sourceContractVersion: 2, sourceDigest: 'bad')], edges: const []), throwsArgumentError));
}
