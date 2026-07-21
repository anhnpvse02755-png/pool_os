import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/runtime_pipeline_contracts.dart';

const runtimeExecutionGraphContractVersion = 1;
const runtimeExecutionGraphPolicyVersion = 'runtime-execution-graph/1.0.0';

class ExecutionNode {
  const ExecutionNode({required this.id, required this.stageId});
  final String id;
  final String stageId;
  Map<String, dynamic> toJson() => {'id': id, 'stageId': stageId};
}

class ExecutionDependency {
  const ExecutionDependency({required this.fromNodeId, required this.toNodeId});
  final String fromNodeId;
  final String toNodeId;
  Map<String, dynamic> toJson() => {'fromNodeId': fromNodeId, 'toNodeId': toNodeId};
}

class RuntimeExecutionGraphContract {
  const RuntimeExecutionGraphContract._({required this.id, required this.pipelineId, required this.pipelineDigest, required this.nodes, required this.dependencies, required this.digest});

  factory RuntimeExecutionGraphContract.create({required RuntimePipelineContract pipeline, required List<ExecutionNode> nodes, required List<ExecutionDependency> dependencies}) {
    if (nodes.isEmpty) throw ArgumentError('Execution graph is empty.');
    final orderedNodes = [...nodes]..sort((a, b) => a.id.compareTo(b.id));
    final nodeIds = orderedNodes.map((node) => node.id).toList();
    final stageIds = pipeline.stages.map((stage) => stage.id).toSet();
    if (nodeIds.any((id) => id.trim().isEmpty) || nodeIds.toSet().length != nodeIds.length || orderedNodes.any((node) => !stageIds.contains(node.stageId)) || orderedNodes.length != pipeline.stages.length) {
      throw ArgumentError('Execution graph contains duplicate, stale, or missing nodes.');
    }
    final orderedDeps = [...dependencies]..sort((a, b) => '${a.fromNodeId}:${a.toNodeId}'.compareTo('${b.fromNodeId}:${b.toNodeId}'));
    final keys = orderedDeps.map((d) => '${d.fromNodeId}->${d.toNodeId}').toList();
    if (keys.toSet().length != keys.length || orderedDeps.any((d) => d.fromNodeId == d.toNodeId || !nodeIds.contains(d.fromNodeId) || !nodeIds.contains(d.toNodeId))) {
      throw ArgumentError('Execution graph contains invalid or duplicate dependencies.');
    }
    final outgoing = {for (final id in nodeIds) id: <String>[]};
    final incoming = {for (final id in nodeIds) id: <String>[]};
    for (final dep in orderedDeps) { outgoing[dep.fromNodeId]!.add(dep.toNodeId); incoming[dep.toNodeId]!.add(dep.fromNodeId); }
    if (nodeIds.length > 1 && nodeIds.any((id) => outgoing[id]!.isEmpty && incoming[id]!.isEmpty)) throw ArgumentError('Execution graph contains an orphan node.');
    final indegree = {for (final id in nodeIds) id: incoming[id]!.length};
    final queue = nodeIds.where((id) => indegree[id] == 0).toList();
    var visited = 0;
    while (queue.isNotEmpty) { final id = queue.removeAt(0); visited++; for (final next in outgoing[id]!) { indegree[next] = indegree[next]! - 1; if (indegree[next] == 0) queue.add(next); } }
    if (visited != nodeIds.length) throw ArgumentError('Execution graph contains a cycle or unreachable node.');
    final payload = {'schemaVersion': runtimeExecutionGraphContractVersion, 'policyVersion': runtimeExecutionGraphPolicyVersion, 'pipelineId': pipeline.id, 'pipelineDigest': pipeline.digest, 'nodes': orderedNodes.map((node) => node.toJson()).toList(), 'dependencies': orderedDeps.map((dependency) => dependency.toJson()).toList()};
    final digest = _digest(payload);
    return RuntimeExecutionGraphContract._(id: 'runtime-execution-graph.${digest.substring(0, 16)}', pipelineId: pipeline.id, pipelineDigest: pipeline.digest, nodes: List.unmodifiable(orderedNodes), dependencies: List.unmodifiable(orderedDeps), digest: digest);
  }

  final String id;
  final String pipelineId;
  final String pipelineDigest;
  final List<ExecutionNode> nodes;
  final List<ExecutionDependency> dependencies;
  final String digest;
  Map<String, dynamic> toJson() => {'schemaVersion': runtimeExecutionGraphContractVersion, 'policyVersion': runtimeExecutionGraphPolicyVersion, 'id': id, 'pipelineId': pipelineId, 'pipelineDigest': pipelineDigest, 'nodes': nodes.map((node) => node.toJson()).toList(), 'dependencies': dependencies.map((dependency) => dependency.toJson()).toList(), 'digest': digest};
}

class RuntimeExecutionGraphBuilder {
  const RuntimeExecutionGraphBuilder();
  RuntimeExecutionGraphContract build({required RuntimePipelineContract pipeline, required List<ExecutionNode> nodes, required List<ExecutionDependency> dependencies}) => RuntimeExecutionGraphContract.create(pipeline: pipeline, nodes: nodes, dependencies: dependencies);
}

String _digest(Object value) => sha256.convert(utf8.encode(jsonEncode(value))).toString();
