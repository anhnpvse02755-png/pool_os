import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/runtime_activation_projection_contracts.dart';
import 'package:pool_os/contracts/runtime_composition_contracts.dart';
import 'package:pool_os/contracts/runtime_composition_coordination_contracts.dart';
import 'package:pool_os/contracts/runtime_dispatch_contracts.dart';
import 'package:pool_os/contracts/runtime_integration_projection_contracts.dart';
import 'package:pool_os/contracts/runtime_lifecycle_projection_contracts.dart';
import 'package:pool_os/contracts/runtime_pipeline_contracts.dart';

void main() {
  final composition = const RuntimeCompositionEngine().compose(nodes: const [RuntimeNodeContract(id: 'a', kind: RuntimeNodeKind.session, sourceContractVersion: 1, sourceDigest: 'a'), RuntimeNodeContract(id: 'b', kind: RuntimeNodeKind.activation, sourceContractVersion: 1, sourceDigest: 'b')], edges: const [RuntimeEdgeContract(fromId: 'a', toId: 'b')]);
  final pipeline = const RuntimePipelineEngine().build(composition: composition, stages: const [PipelineStage(id: 'first', runtimeNodeId: 'a'), PipelineStage(id: 'second', runtimeNodeId: 'b')], transitions: const [PipelineTransition(fromStageId: 'first', toStageId: 'second')]);
  final coordination = const RuntimeCompositionCoordinator().coordinate(composition: composition, pipeline: pipeline, mappings: const [RuntimeCoordinationMapping(runtimeNodeId: 'a', pipelineStageId: 'first'), RuntimeCoordinationMapping(runtimeNodeId: 'b', pipelineStageId: 'second')]);
  final dispatch = const RuntimeDispatcher().project(coordination);
  final activation = const RuntimeActivationProjector().project(dispatch);
  final lifecycle = const RuntimeLifecycleProjector().project(activation);
  test('integration projection is deterministic and immutable', () { final first = const RuntimeIntegrationProjector().project(lifecycle); final second = const RuntimeIntegrationProjector().project(lifecycle); expect(second.digest, first.digest); expect(first.entries, hasLength(2)); expect(() => first.entries.add(first.entries.first), throwsUnsupportedError); });
  test('integration types are canonical projection metadata', () { final result = const RuntimeIntegrationProjector().project(lifecycle); expect(result.entries.map((entry) => entry.type), [RuntimeIntegrationType.runtime, RuntimeIntegrationType.application]); });
  test('integration binds lifecycle provenance', () { final result = const RuntimeIntegrationProjector().project(lifecycle); expect(result.lifecycleDigest, lifecycle.digest); expect(result.entries.every((entry) => entry.metadata == runtimeIntegrationProjectionPolicyVersion), isTrue); });
  test('duplicate integration key fails closed', () { final result = const RuntimeIntegrationProjector().project(lifecycle); expect(() => RuntimeIntegrationProjectionContract.create(lifecycle: lifecycle, entries: [result.entries.first, RuntimeIntegrationEntry(lifecycleEntryId: result.entries[1].lifecycleEntryId, runtimeNodeId: result.entries[1].runtimeNodeId, integrationKey: result.entries.first.integrationKey, type: RuntimeIntegrationType.application, position: 1, metadata: runtimeIntegrationProjectionPolicyVersion)]), throwsArgumentError); });
  test('orphan lifecycle entry fails closed', () { final result = const RuntimeIntegrationProjector().project(lifecycle); expect(() => RuntimeIntegrationProjectionContract.create(lifecycle: lifecycle, entries: [result.entries.first]), throwsArgumentError); });
  test('foreign binding or metadata fails closed', () { final result = const RuntimeIntegrationProjector().project(lifecycle); expect(() => RuntimeIntegrationProjectionContract.create(lifecycle: lifecycle, entries: [result.entries.first, const RuntimeIntegrationEntry(lifecycleEntryId: 'foreign', runtimeNodeId: 'foreign', integrationKey: 'foreign', type: RuntimeIntegrationType.adapter, position: 1, metadata: runtimeIntegrationProjectionPolicyVersion)]), throwsArgumentError); });
  test('projector does not integrate or mutate lifecycle', () { final before = lifecycle.toJson(); const RuntimeIntegrationProjector().project(lifecycle); expect(lifecycle.toJson(), before); });
}
