import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/runtime_execution_graph_contracts.dart';

const runtimeStateProjectionContractVersion = 1;
const runtimeStateProjectionPolicyVersion = 'runtime-state-projection/1.0.0';

enum RuntimeState { notStarted, ready, waiting, blocked, completed }

class RuntimeStateNode {
  const RuntimeStateNode({required this.executionNodeId, required this.state});
  final String executionNodeId;
  final RuntimeState state;
  Map<String, dynamic> toJson() => {'executionNodeId': executionNodeId, 'state': state.name};
}

class RuntimeStateSummary {
  const RuntimeStateSummary({required this.notStarted, required this.ready, required this.waiting, required this.blocked, required this.completed});
  final int notStarted;
  final int ready;
  final int waiting;
  final int blocked;
  final int completed;
  Map<String, dynamic> toJson() => {'notStarted': notStarted, 'ready': ready, 'waiting': waiting, 'blocked': blocked, 'completed': completed};
}

class RuntimeStateProjectionContract {
  const RuntimeStateProjectionContract._({required this.id, required this.graphId, required this.graphDigest, required this.nodes, required this.summary, required this.digest});
  final String id;
  final String graphId;
  final String graphDigest;
  final List<RuntimeStateNode> nodes;
  final RuntimeStateSummary summary;
  final String digest;
  Map<String, dynamic> toJson() => {'schemaVersion': runtimeStateProjectionContractVersion, 'policyVersion': runtimeStateProjectionPolicyVersion, 'id': id, 'graphId': graphId, 'graphDigest': graphDigest, 'nodes': nodes.map((node) => node.toJson()).toList(), 'summary': summary.toJson(), 'digest': digest};
}

class RuntimeStateProjector {
  const RuntimeStateProjector();

  RuntimeStateProjectionContract project(RuntimeExecutionGraphContract graph) {
    final incoming = {for (final node in graph.nodes) node.id: 0};
    for (final dependency in graph.dependencies) {
      if (!incoming.containsKey(dependency.toNodeId)) throw ArgumentError('Runtime state has a stale dependency.');
      incoming[dependency.toNodeId] = incoming[dependency.toNodeId]! + 1;
    }
    final ordered = [...graph.nodes]..sort((a, b) => a.id.compareTo(b.id));
    final projected = ordered.map((node) => RuntimeStateNode(executionNodeId: node.id, state: incoming[node.id] == 0 ? RuntimeState.ready : RuntimeState.waiting)).toList();
    final summary = RuntimeStateSummary(ready: projected.where((node) => node.state == RuntimeState.ready).length, waiting: projected.where((node) => node.state == RuntimeState.waiting).length, notStarted: 0, blocked: 0, completed: 0);
    final payload = {'schemaVersion': runtimeStateProjectionContractVersion, 'policyVersion': runtimeStateProjectionPolicyVersion, 'graphId': graph.id, 'graphDigest': graph.digest, 'nodes': projected.map((node) => node.toJson()).toList(), 'summary': summary.toJson()};
    final digest = _digest(payload);
    return RuntimeStateProjectionContract._(id: 'runtime-state.${digest.substring(0, 16)}', graphId: graph.id, graphDigest: graph.digest, nodes: List.unmodifiable(projected), summary: summary, digest: digest);
  }
}

String _digest(Object value) => sha256.convert(utf8.encode(jsonEncode(value))).toString();
