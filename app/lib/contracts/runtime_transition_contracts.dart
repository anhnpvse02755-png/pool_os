import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/runtime_state_projection_contracts.dart';

const runtimeTransitionContractVersion = 1;
const runtimeTransitionPolicyVersion = 'runtime-transition/1.0.0';

class RuntimeTransitionNode {
  const RuntimeTransitionNode({required this.executionNodeId, required this.fromState, required this.toState});
  final String executionNodeId;
  final RuntimeState fromState;
  final RuntimeState toState;
  Map<String, dynamic> toJson() => {'executionNodeId': executionNodeId, 'fromState': fromState.name, 'toState': toState.name};
}

class RuntimeTransitionSummary {
  const RuntimeTransitionSummary({required this.total, required this.allowed});
  final int total;
  final int allowed;
  Map<String, dynamic> toJson() => {'total': total, 'allowed': allowed};
}

class RuntimeTransitionContract {
  const RuntimeTransitionContract._({required this.id, required this.projectionId, required this.projectionDigest, required this.transitions, required this.summary, required this.digest});
  factory RuntimeTransitionContract.create({required RuntimeStateProjectionContract projection, required List<RuntimeTransitionNode> transitions}) {
    final ordered = [...transitions]..sort((a, b) => a.executionNodeId.compareTo(b.executionNodeId));
    final ids = projection.nodes.map((node) => node.executionNodeId).toSet();
    final keys = ordered.map((node) => '${node.executionNodeId}:${node.fromState.name}->${node.toState.name}').toList();
    if (keys.toSet().length != keys.length || ordered.any((node) => !ids.contains(node.executionNodeId) || !_allowed(node.fromState, node.toState))) throw ArgumentError('Runtime transition is invalid or stale.');
    final summary = RuntimeTransitionSummary(total: ordered.length, allowed: ordered.length);
    final payload = {'schemaVersion': runtimeTransitionContractVersion, 'policyVersion': runtimeTransitionPolicyVersion, 'projectionId': projection.id, 'projectionDigest': projection.digest, 'transitions': ordered.map((node) => node.toJson()).toList(), 'summary': summary.toJson()};
    final digest = _digest(payload);
    return RuntimeTransitionContract._(id: 'runtime-transition.${digest.substring(0, 16)}', projectionId: projection.id, projectionDigest: projection.digest, transitions: List.unmodifiable(ordered), summary: summary, digest: digest);
  }
  final String id;
  final String projectionId;
  final String projectionDigest;
  final List<RuntimeTransitionNode> transitions;
  final RuntimeTransitionSummary summary;
  final String digest;
  Map<String, dynamic> toJson() => {'schemaVersion': runtimeTransitionContractVersion, 'policyVersion': runtimeTransitionPolicyVersion, 'id': id, 'projectionId': projectionId, 'projectionDigest': projectionDigest, 'transitions': transitions.map((node) => node.toJson()).toList(), 'summary': summary.toJson(), 'digest': digest};
}

bool _allowed(RuntimeState from, RuntimeState to) => (from == RuntimeState.notStarted && to == RuntimeState.ready) || (from == RuntimeState.ready && to == RuntimeState.waiting) || (from == RuntimeState.waiting && (to == RuntimeState.completed || to == RuntimeState.blocked));
String _digest(Object value) => sha256.convert(utf8.encode(jsonEncode(value))).toString();
