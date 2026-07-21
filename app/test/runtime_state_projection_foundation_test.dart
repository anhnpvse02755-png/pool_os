import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/runtime_composition_contracts.dart';
import 'package:pool_os/contracts/runtime_execution_graph_contracts.dart';
import 'package:pool_os/contracts/runtime_pipeline_contracts.dart';
import 'package:pool_os/contracts/runtime_state_projection_contracts.dart';

void main() {
  final graph = const RuntimeExecutionGraphBuilder().build(
    pipeline: const RuntimePipelineEngine().build(composition: const RuntimeCompositionEngine().compose(nodes: [const RuntimeNodeContract(id: 'a', kind: RuntimeNodeKind.session, sourceContractVersion: 1, sourceDigest: 'a'), const RuntimeNodeContract(id: 'b', kind: RuntimeNodeKind.promptAssembly, sourceContractVersion: 1, sourceDigest: 'b'), const RuntimeNodeContract(id: 'c', kind: RuntimeNodeKind.activation, sourceContractVersion: 1, sourceDigest: 'c')], edges: const [RuntimeEdgeContract(fromId: 'a', toId: 'b'), RuntimeEdgeContract(fromId: 'b', toId: 'c')]), stages: const [PipelineStage(id: 'first', runtimeNodeId: 'a'), PipelineStage(id: 'second', runtimeNodeId: 'b'), PipelineStage(id: 'third', runtimeNodeId: 'c')], transitions: const [PipelineTransition(fromStageId: 'first', toStageId: 'second'), PipelineTransition(fromStageId: 'second', toStageId: 'third')]),
    nodes: const [ExecutionNode(id: 'one', stageId: 'first'), ExecutionNode(id: 'two', stageId: 'second'), ExecutionNode(id: 'three', stageId: 'third')],
    dependencies: const [ExecutionDependency(fromNodeId: 'one', toNodeId: 'two'), ExecutionDependency(fromNodeId: 'two', toNodeId: 'three')],
  );
  test('projection is deterministic and graph-bound', () { final first = const RuntimeStateProjector().project(graph); final second = const RuntimeStateProjector().project(graph); expect(second.digest, first.digest); expect(first.graphDigest, graph.digest); expect(first.summary.ready, 1); expect(first.summary.waiting, 2); expect(() => first.nodes.add(first.nodes.first), throwsUnsupportedError); });
  test('projection canonical JSON is replayable', () { const projector = RuntimeStateProjector(); expect(projector.project(graph).toJson(), projector.project(graph).toJson()); });
  test('state policy marks roots ready and dependent nodes waiting', () { final projection = const RuntimeStateProjector().project(graph); expect(projection.nodes.map((node) => node.state), [RuntimeState.ready, RuntimeState.waiting, RuntimeState.waiting]); });
  test('projection does not mutate execution graph', () { final before = graph.toJson(); const RuntimeStateProjector().project(graph); expect(graph.toJson(), before); });
  test('state summary accounts for every execution node', () { final summary = const RuntimeStateProjector().project(graph).summary; expect(summary.ready + summary.waiting + summary.notStarted + summary.blocked + summary.completed, graph.nodes.length); });
  test('projection contains no execution result or mutation fields', () { final json = const RuntimeStateProjector().project(graph).toJson().toString(); expect(json, isNot(contains('result'))); expect(json, isNot(contains('transition'))); });
  test('projector is pure for repeated calls', () { const projector = RuntimeStateProjector(); expect(projector.project(graph).digest, projector.project(graph).digest); });
}
