import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/runtime_composition_contracts.dart';
import 'package:pool_os/contracts/runtime_execution_graph_contracts.dart';
import 'package:pool_os/contracts/runtime_pipeline_contracts.dart';
import 'package:pool_os/contracts/runtime_state_projection_contracts.dart';
import 'package:pool_os/contracts/runtime_transition_contracts.dart';

void main() {
  final projection = const RuntimeStateProjector().project(const RuntimeExecutionGraphBuilder().build(pipeline: const RuntimePipelineEngine().build(composition: const RuntimeCompositionEngine().compose(nodes: [const RuntimeNodeContract(id: 'a', kind: RuntimeNodeKind.session, sourceContractVersion: 1, sourceDigest: 'a')], edges: const []), stages: const [PipelineStage(id: 'one', runtimeNodeId: 'a')], transitions: const []), nodes: const [ExecutionNode(id: 'one', stageId: 'one')], dependencies: const []));
  test('allowed transition contract is immutable and deterministic', () { final first = RuntimeTransitionContract.create(projection: projection, transitions: const [RuntimeTransitionNode(executionNodeId: 'one', fromState: RuntimeState.notStarted, toState: RuntimeState.ready)]); final second = RuntimeTransitionContract.create(projection: projection, transitions: const [RuntimeTransitionNode(executionNodeId: 'one', fromState: RuntimeState.notStarted, toState: RuntimeState.ready)]); expect(second.digest, first.digest); expect(() => first.transitions.add(first.transitions.first), throwsUnsupportedError); });
  test('duplicate transitions fail closed', () => expect(() => RuntimeTransitionContract.create(projection: projection, transitions: const [RuntimeTransitionNode(executionNodeId: 'one', fromState: RuntimeState.notStarted, toState: RuntimeState.ready), RuntimeTransitionNode(executionNodeId: 'one', fromState: RuntimeState.notStarted, toState: RuntimeState.ready)]), throwsArgumentError));
  test('impossible transitions fail closed', () => expect(() => RuntimeTransitionContract.create(projection: projection, transitions: const [RuntimeTransitionNode(executionNodeId: 'one', fromState: RuntimeState.completed, toState: RuntimeState.ready)]), throwsArgumentError));
  test('foreign node fails closed', () => expect(() => RuntimeTransitionContract.create(projection: projection, transitions: const [RuntimeTransitionNode(executionNodeId: 'foreign', fromState: RuntimeState.notStarted, toState: RuntimeState.ready)]), throwsArgumentError));
  test('projection binding is preserved', () { final transition = RuntimeTransitionContract.create(projection: projection, transitions: const [RuntimeTransitionNode(executionNodeId: 'one', fromState: RuntimeState.notStarted, toState: RuntimeState.ready)]); expect(transition.projectionDigest, projection.digest); });
  test('empty transition set is valid immutable evidence', () { final transition = RuntimeTransitionContract.create(projection: projection, transitions: const []); expect(transition.summary.total, 0); });
  test('transition validation does not mutate projection', () { final before = projection.toJson(); RuntimeTransitionContract.create(projection: projection, transitions: const []); expect(projection.toJson(), before); });
}
