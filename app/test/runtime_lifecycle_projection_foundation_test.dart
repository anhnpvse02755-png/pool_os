import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/runtime_activation_projection_contracts.dart';
import 'package:pool_os/contracts/runtime_composition_contracts.dart';
import 'package:pool_os/contracts/runtime_composition_coordination_contracts.dart';
import 'package:pool_os/contracts/runtime_dispatch_contracts.dart';
import 'package:pool_os/contracts/runtime_lifecycle_projection_contracts.dart';
import 'package:pool_os/contracts/runtime_pipeline_contracts.dart';

void main() {
  final composition = const RuntimeCompositionEngine().compose(nodes: const [RuntimeNodeContract(id: 'a', kind: RuntimeNodeKind.session, sourceContractVersion: 1, sourceDigest: 'a'), RuntimeNodeContract(id: 'b', kind: RuntimeNodeKind.activation, sourceContractVersion: 1, sourceDigest: 'b')], edges: const [RuntimeEdgeContract(fromId: 'a', toId: 'b')]);
  final pipeline = const RuntimePipelineEngine().build(composition: composition, stages: const [PipelineStage(id: 'first', runtimeNodeId: 'a'), PipelineStage(id: 'second', runtimeNodeId: 'b')], transitions: const [PipelineTransition(fromStageId: 'first', toStageId: 'second')]);
  final coordination = const RuntimeCompositionCoordinator().coordinate(composition: composition, pipeline: pipeline, mappings: const [RuntimeCoordinationMapping(runtimeNodeId: 'a', pipelineStageId: 'first'), RuntimeCoordinationMapping(runtimeNodeId: 'b', pipelineStageId: 'second')]);
  final dispatch = const RuntimeDispatcher().project(coordination);
  final activation = const RuntimeActivationProjector().project(dispatch);
  test('lifecycle projection is deterministic and immutable', () { final first = const RuntimeLifecycleProjector().project(activation); final second = const RuntimeLifecycleProjector().project(activation); expect(second.digest, first.digest); expect(first.entries, hasLength(2)); expect(() => first.entries.add(first.entries.first), throwsUnsupportedError); });
  test('lifecycle phases are canonical projection values', () { final result = const RuntimeLifecycleProjector().project(activation); expect(result.entries.map((entry) => entry.phase), [RuntimeLifecyclePhase.initialized, RuntimeLifecyclePhase.ready]); });
  test('lifecycle binds activation provenance and metadata', () { final result = const RuntimeLifecycleProjector().project(activation); expect(result.activationDigest, activation.digest); expect(result.entries.every((entry) => entry.metadata == runtimeLifecycleProjectionPolicyVersion), isTrue); });
  test('duplicate lifecycle entry fails closed', () { final result = const RuntimeLifecycleProjector().project(activation); expect(() => RuntimeLifecycleProjectionContract.create(activation: activation, entries: [result.entries.first, result.entries.first]), throwsArgumentError); });
  test('orphan activation fails closed', () { final result = const RuntimeLifecycleProjector().project(activation); expect(() => RuntimeLifecycleProjectionContract.create(activation: activation, entries: [result.entries.first]), throwsArgumentError); });
  test('foreign runtime or provenance fails closed', () { final result = const RuntimeLifecycleProjector().project(activation); expect(() => RuntimeLifecycleProjectionContract.create(activation: activation, entries: [result.entries.first, const RuntimeLifecycleEntry(activationEntryId: 'foreign', runtimeNodeId: 'foreign', phase: RuntimeLifecyclePhase.ready, position: 1, metadata: runtimeLifecycleProjectionPolicyVersion)]), throwsArgumentError); });
  test('projector does not control lifecycle or mutate activation', () { final before = activation.toJson(); const RuntimeLifecycleProjector().project(activation); expect(activation.toJson(), before); });
}
