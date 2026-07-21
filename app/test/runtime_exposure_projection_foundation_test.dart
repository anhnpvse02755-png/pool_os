import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/runtime_activation_projection_contracts.dart';
import 'package:pool_os/contracts/runtime_composition_contracts.dart';
import 'package:pool_os/contracts/runtime_composition_coordination_contracts.dart';
import 'package:pool_os/contracts/runtime_dispatch_contracts.dart';
import 'package:pool_os/contracts/runtime_exposure_projection_contracts.dart';
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
  final integration = const RuntimeIntegrationProjector().project(lifecycle);
  test('exposure projection is deterministic and immutable', () { final first = const RuntimeExposureProjector().project(integration); final second = const RuntimeExposureProjector().project(integration); expect(second.digest, first.digest); expect(first.entries, hasLength(2)); expect(() => first.entries.add(first.entries.first), throwsUnsupportedError); });
  test('exposure scopes are canonical metadata', () { final result = const RuntimeExposureProjector().project(integration); expect(result.entries.map((entry) => entry.scope), [RuntimeExposureScope.internal, RuntimeExposureScope.application]); });
  test('exposure binds integration provenance', () { final result = const RuntimeExposureProjector().project(integration); expect(result.integrationDigest, integration.digest); expect(result.entries.every((entry) => entry.metadata == runtimeExposureProjectionPolicyVersion), isTrue); });
  test('duplicate exposure key fails closed', () { final result = const RuntimeExposureProjector().project(integration); expect(() => RuntimeExposureProjectionContract.create(integration: integration, entries: [result.entries.first, RuntimeExposureEntry(integrationEntryId: result.entries[1].integrationEntryId, runtimeNodeId: result.entries[1].runtimeNodeId, exposureKey: result.entries.first.exposureKey, scope: RuntimeExposureScope.application, position: 1, metadata: runtimeExposureProjectionPolicyVersion)]), throwsArgumentError); });
  test('orphan integration entry fails closed', () { final result = const RuntimeExposureProjector().project(integration); expect(() => RuntimeExposureProjectionContract.create(integration: integration, entries: [result.entries.first]), throwsArgumentError); });
  test('foreign binding or metadata fails closed', () { final result = const RuntimeExposureProjector().project(integration); expect(() => RuntimeExposureProjectionContract.create(integration: integration, entries: [result.entries.first, const RuntimeExposureEntry(integrationEntryId: 'foreign', runtimeNodeId: 'foreign', exposureKey: 'foreign', scope: RuntimeExposureScope.api, position: 1, metadata: runtimeExposureProjectionPolicyVersion)]), throwsArgumentError); });
  test('projector does not expose API or mutate integration', () { final before = integration.toJson(); const RuntimeExposureProjector().project(integration); expect(integration.toJson(), before); });
}
