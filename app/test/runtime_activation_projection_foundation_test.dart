import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/runtime_activation_projection_contracts.dart';
import 'package:pool_os/contracts/runtime_composition_contracts.dart';
import 'package:pool_os/contracts/runtime_composition_coordination_contracts.dart';
import 'package:pool_os/contracts/runtime_dispatch_contracts.dart';
import 'package:pool_os/contracts/runtime_pipeline_contracts.dart';

void main() {
  final composition = const RuntimeCompositionEngine().compose(nodes: const [RuntimeNodeContract(id: 'a', kind: RuntimeNodeKind.session, sourceContractVersion: 1, sourceDigest: 'a'), RuntimeNodeContract(id: 'b', kind: RuntimeNodeKind.activation, sourceContractVersion: 1, sourceDigest: 'b')], edges: const [RuntimeEdgeContract(fromId: 'a', toId: 'b')]);
  final pipeline = const RuntimePipelineEngine().build(composition: composition, stages: const [PipelineStage(id: 'first', runtimeNodeId: 'a'), PipelineStage(id: 'second', runtimeNodeId: 'b')], transitions: const [PipelineTransition(fromStageId: 'first', toStageId: 'second')]);
  final coordination = const RuntimeCompositionCoordinator().coordinate(composition: composition, pipeline: pipeline, mappings: const [RuntimeCoordinationMapping(runtimeNodeId: 'a', pipelineStageId: 'first'), RuntimeCoordinationMapping(runtimeNodeId: 'b', pipelineStageId: 'second')]);
  final dispatch = const RuntimeDispatcher().project(coordination);
  test('activation projection is deterministic and immutable', () { final first = const RuntimeActivationProjector().project(dispatch); final second = const RuntimeActivationProjector().project(dispatch); expect(second.digest, first.digest); expect(first.entries, hasLength(2)); expect(() => first.entries.add(first.entries.first), throwsUnsupportedError); });
  test('activation entries bind dispatch identity and canonical metadata', () { final result = const RuntimeActivationProjector().project(dispatch); expect(result.dispatchDigest, dispatch.digest); expect(result.entries.every((entry) => entry.metadata == runtimeActivationProjectionPolicyVersion), isTrue); });
  test('duplicate activation key fails closed', () { final result = const RuntimeActivationProjector().project(dispatch); expect(() => RuntimeActivationProjectionContract.create(dispatch: dispatch, entries: [result.entries.first, RuntimeActivationEntry(dispatchEntryId: result.entries[1].dispatchEntryId, runtimeNodeId: result.entries[1].runtimeNodeId, activationKey: result.entries.first.activationKey, position: 1, metadata: runtimeActivationProjectionPolicyVersion)]), throwsArgumentError); });
  test('orphan dispatch entry fails closed', () { final result = const RuntimeActivationProjector().project(dispatch); expect(() => RuntimeActivationProjectionContract.create(dispatch: dispatch, entries: [result.entries.first]), throwsArgumentError); });
  test('foreign runtime binding fails closed', () { final result = const RuntimeActivationProjector().project(dispatch); expect(() => RuntimeActivationProjectionContract.create(dispatch: dispatch, entries: [result.entries.first, const RuntimeActivationEntry(dispatchEntryId: 'foreign', runtimeNodeId: 'foreign', activationKey: 'foreign', position: 1, metadata: runtimeActivationProjectionPolicyVersion)]), throwsArgumentError); });
  test('invalid position or provenance fails closed', () { final result = const RuntimeActivationProjector().project(dispatch); expect(() => RuntimeActivationProjectionContract.create(dispatch: dispatch, entries: [result.entries.first, RuntimeActivationEntry(dispatchEntryId: result.entries[1].dispatchEntryId, runtimeNodeId: result.entries[1].runtimeNodeId, activationKey: 'b', position: -1, metadata: 'foreign')]), throwsArgumentError); });
  test('projector does not activate or mutate dispatch', () { final before = dispatch.toJson(); const RuntimeActivationProjector().project(dispatch); expect(dispatch.toJson(), before); });
}
