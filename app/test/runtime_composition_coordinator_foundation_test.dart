import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/runtime_composition_contracts.dart';
import 'package:pool_os/contracts/runtime_composition_coordination_contracts.dart';
import 'package:pool_os/contracts/runtime_pipeline_contracts.dart';

void main() {
  final composition = const RuntimeCompositionEngine().compose(nodes: [const RuntimeNodeContract(id: 'a', kind: RuntimeNodeKind.session, sourceContractVersion: 1, sourceDigest: 'a'), const RuntimeNodeContract(id: 'b', kind: RuntimeNodeKind.activation, sourceContractVersion: 1, sourceDigest: 'b')], edges: const [RuntimeEdgeContract(fromId: 'a', toId: 'b')]);
  final pipeline = const RuntimePipelineEngine().build(composition: composition, stages: const [PipelineStage(id: 'first', runtimeNodeId: 'a'), PipelineStage(id: 'second', runtimeNodeId: 'b')], transitions: const [PipelineTransition(fromStageId: 'first', toStageId: 'second')]);
  const mappings = [RuntimeCoordinationMapping(runtimeNodeId: 'a', pipelineStageId: 'first'), RuntimeCoordinationMapping(runtimeNodeId: 'b', pipelineStageId: 'second')];
  test('coordination is immutable canonical and deterministic', () { final first = const RuntimeCompositionCoordinator().coordinate(composition: composition, pipeline: pipeline, mappings: mappings); final second = const RuntimeCompositionCoordinator().coordinate(composition: composition, pipeline: pipeline, mappings: mappings.reversed.toList()); expect(second.digest, first.digest); expect(() => first.mappings.add(mappings.first), throwsUnsupportedError); });
  test('coordination binds composition and pipeline identities', () { final result = const RuntimeCompositionCoordinator().coordinate(composition: composition, pipeline: pipeline, mappings: mappings); expect(result.compositionDigest, composition.digest); expect(result.pipelineDigest, pipeline.digest); });
  test('duplicate mapping fails closed', () => expect(() => const RuntimeCompositionCoordinator().coordinate(composition: composition, pipeline: pipeline, mappings: [...mappings, mappings.first]), throwsArgumentError));
  test('orphan composition or pipeline stage fails closed', () { expect(() => const RuntimeCompositionCoordinator().coordinate(composition: composition, pipeline: pipeline, mappings: mappings.sublist(0, 1)), throwsArgumentError); });
  test('foreign runtime node fails closed', () => expect(() => const RuntimeCompositionCoordinator().coordinate(composition: composition, pipeline: pipeline, mappings: const [RuntimeCoordinationMapping(runtimeNodeId: 'foreign', pipelineStageId: 'first'), RuntimeCoordinationMapping(runtimeNodeId: 'b', pipelineStageId: 'second')]), throwsArgumentError));
  test('broken stage binding fails closed', () => expect(() => const RuntimeCompositionCoordinator().coordinate(composition: composition, pipeline: pipeline, mappings: const [RuntimeCoordinationMapping(runtimeNodeId: 'a', pipelineStageId: 'foreign'), RuntimeCoordinationMapping(runtimeNodeId: 'b', pipelineStageId: 'second')]), throwsArgumentError));
  test('coordinator does not mutate inputs or execute runtime', () { final compositionBefore = composition.toJson(); final pipelineBefore = pipeline.toJson(); const RuntimeCompositionCoordinator().coordinate(composition: composition, pipeline: pipeline, mappings: mappings); expect(composition.toJson(), compositionBefore); expect(pipeline.toJson(), pipelineBefore); });
}
