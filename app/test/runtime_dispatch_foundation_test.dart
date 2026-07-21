import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/runtime_composition_contracts.dart';
import 'package:pool_os/contracts/runtime_composition_coordination_contracts.dart';
import 'package:pool_os/contracts/runtime_dispatch_contracts.dart';
import 'package:pool_os/contracts/runtime_pipeline_contracts.dart';

void main() {
  final composition = const RuntimeCompositionEngine().compose(nodes: const [RuntimeNodeContract(id: 'a', kind: RuntimeNodeKind.session, sourceContractVersion: 1, sourceDigest: 'a'), RuntimeNodeContract(id: 'b', kind: RuntimeNodeKind.activation, sourceContractVersion: 1, sourceDigest: 'b')], edges: const [RuntimeEdgeContract(fromId: 'a', toId: 'b')]);
  final pipeline = const RuntimePipelineEngine().build(composition: composition, stages: const [PipelineStage(id: 'first', runtimeNodeId: 'a'), PipelineStage(id: 'second', runtimeNodeId: 'b')], transitions: const [PipelineTransition(fromStageId: 'first', toStageId: 'second')]);
  final coordination = const RuntimeCompositionCoordinator().coordinate(composition: composition, pipeline: pipeline, mappings: const [RuntimeCoordinationMapping(runtimeNodeId: 'a', pipelineStageId: 'first'), RuntimeCoordinationMapping(runtimeNodeId: 'b', pipelineStageId: 'second')]);
  test('dispatcher projection is deterministic and immutable', () { final first = const RuntimeDispatcher().project(coordination); final second = const RuntimeDispatcher().project(coordination); expect(second.digest, first.digest); expect(first.entries, hasLength(2)); expect(() => first.entries.add(first.entries.first), throwsUnsupportedError); });
  test('dispatch entries have unique canonical keys and positions', () { final result = const RuntimeDispatcher().project(coordination); expect(result.entries.map((entry) => entry.dispatchKey).toSet(), hasLength(2)); expect(result.entries.map((entry) => entry.position), [0, 1]); });
  test('duplicate dispatch key fails closed', () { final result = const RuntimeDispatcher().project(coordination); expect(() => RuntimeDispatchContract.create(coordination: coordination, entries: [result.entries.first, RuntimeDispatchEntry(mappingId: 'x', runtimeNodeId: 'b', pipelineStageId: 'second', dispatchKey: result.entries.first.dispatchKey, position: 1)]), throwsArgumentError); });
  test('orphan mapping fails closed', () { final result = const RuntimeDispatcher().project(coordination); expect(() => RuntimeDispatchContract.create(coordination: coordination, entries: [result.entries.first]), throwsArgumentError); });
  test('foreign binding fails closed', () { final result = const RuntimeDispatcher().project(coordination); expect(() => RuntimeDispatchContract.create(coordination: coordination, entries: [result.entries.first, const RuntimeDispatchEntry(mappingId: 'x', runtimeNodeId: 'foreign', pipelineStageId: 'second', dispatchKey: 'foreign:second', position: 1)]), throwsArgumentError); });
  test('invalid position fails closed', () { final result = const RuntimeDispatcher().project(coordination); expect(() => RuntimeDispatchContract.create(coordination: coordination, entries: [const RuntimeDispatchEntry(mappingId: 'x', runtimeNodeId: 'a', pipelineStageId: 'first', dispatchKey: 'a:first', position: -1), result.entries[1]]), throwsArgumentError); });
  test('dispatcher does not execute or mutate coordination', () { final before = coordination.toJson(); const RuntimeDispatcher().project(coordination); expect(coordination.toJson(), before); });
}
