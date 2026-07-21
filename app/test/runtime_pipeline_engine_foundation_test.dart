import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/runtime_composition_contracts.dart';
import 'package:pool_os/contracts/runtime_pipeline_contracts.dart';

void main() {
  final composition = const RuntimeCompositionEngine().compose(
    nodes: [
      const RuntimeNodeContract(id: 'a', kind: RuntimeNodeKind.session, sourceContractVersion: 1, sourceDigest: 'a'),
      const RuntimeNodeContract(id: 'b', kind: RuntimeNodeKind.promptAssembly, sourceContractVersion: 1, sourceDigest: 'b'),
      const RuntimeNodeContract(id: 'c', kind: RuntimeNodeKind.activation, sourceContractVersion: 1, sourceDigest: 'c'),
    ],
    edges: const [RuntimeEdgeContract(fromId: 'a', toId: 'b'), RuntimeEdgeContract(fromId: 'b', toId: 'c')],
  );
  const stages = [PipelineStage(id: 'first', runtimeNodeId: 'a'), PipelineStage(id: 'second', runtimeNodeId: 'b'), PipelineStage(id: 'third', runtimeNodeId: 'c')];
  const transitions = [PipelineTransition(fromStageId: 'first', toStageId: 'second'), PipelineTransition(fromStageId: 'second', toStageId: 'third')];

  test('pipeline is deterministic, immutable, and bound to composition', () {
    final first = const RuntimePipelineEngine().build(composition: composition, stages: stages, transitions: transitions);
    final second = const RuntimePipelineEngine().build(composition: composition, stages: stages.reversed.toList(), transitions: transitions.reversed.toList());
    expect(second.digest, first.digest);
    expect(first.compositionDigest, composition.digest);
    expect(() => first.stages.add(stages.first), throwsUnsupportedError);
  });
  test('duplicate stage or transition fails closed', () {
    expect(() => const RuntimePipelineEngine().build(composition: composition, stages: [...stages, stages.first], transitions: transitions), throwsArgumentError);
    expect(() => const RuntimePipelineEngine().build(composition: composition, stages: stages, transitions: [...transitions, transitions.first]), throwsArgumentError);
  });
  test('orphan stage fails closed', () => expect(() => const RuntimePipelineEngine().build(composition: composition, stages: [...stages, const PipelineStage(id: 'orphan', runtimeNodeId: 'a')], transitions: transitions), throwsArgumentError));
  test('cyclic pipeline fails closed', () => expect(() => const RuntimePipelineEngine().build(composition: composition, stages: stages, transitions: [...transitions, const PipelineTransition(fromStageId: 'third', toStageId: 'first')]), throwsArgumentError));
  test('invalid transition and stale composition reference fail closed', () {
    expect(() => const RuntimePipelineEngine().build(composition: composition, stages: stages, transitions: [...transitions, const PipelineTransition(fromStageId: 'missing', toStageId: 'first')]), throwsArgumentError);
    expect(() => const RuntimePipelineEngine().build(composition: composition, stages: const [PipelineStage(id: 'bad', runtimeNodeId: 'missing')], transitions: const []), throwsArgumentError);
  });
  test('single stage topology is valid without transitions', () {
    final single = const RuntimePipelineEngine().build(composition: composition, stages: const [PipelineStage(id: 'only', runtimeNodeId: 'a')], transitions: const []);
    expect(single.transitions, isEmpty);
  });
  test('pipeline does not execute or mutate composition', () {
    final before = composition.toJson();
    const RuntimePipelineEngine().build(composition: composition, stages: stages, transitions: transitions);
    expect(composition.toJson(), before);
  });
}
