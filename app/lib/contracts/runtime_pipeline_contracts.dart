import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/runtime_composition_contracts.dart';

const runtimePipelineContractVersion = 1;
const runtimePipelinePolicyVersion = 'runtime-pipeline/1.0.0';

class PipelineStage {
  const PipelineStage({required this.id, required this.runtimeNodeId});

  final String id;
  final String runtimeNodeId;

  Map<String, dynamic> toJson() => {'id': id, 'runtimeNodeId': runtimeNodeId};
}

class PipelineTransition {
  const PipelineTransition({required this.fromStageId, required this.toStageId});

  final String fromStageId;
  final String toStageId;

  Map<String, dynamic> toJson() => {
        'fromStageId': fromStageId,
        'toStageId': toStageId,
      };
}

class RuntimePipelineContract {
  const RuntimePipelineContract._({
    required this.id,
    required this.compositionId,
    required this.compositionDigest,
    required this.stages,
    required this.transitions,
    required this.digest,
  });

  factory RuntimePipelineContract.create({
    required RuntimeCompositionContract composition,
    required List<PipelineStage> stages,
    required List<PipelineTransition> transitions,
  }) {
    if (stages.isEmpty) throw ArgumentError('Runtime pipeline is empty.');
    final orderedStages = [...stages]..sort((a, b) => a.id.compareTo(b.id));
    final stageIds = orderedStages.map((stage) => stage.id).toList();
    final nodeIds = composition.nodes.map((node) => node.id).toSet();
    if (stageIds.any((id) => id.trim().isEmpty) ||
        stageIds.toSet().length != stageIds.length ||
        orderedStages.any((stage) => !nodeIds.contains(stage.runtimeNodeId))) {
      throw ArgumentError('Pipeline contains duplicate or stale stages.');
    }
    final orderedTransitions = [...transitions]
      ..sort((a, b) => '${a.fromStageId}:${a.toStageId}'.compareTo('${b.fromStageId}:${b.toStageId}'));
    final keys = orderedTransitions.map((t) => '${t.fromStageId}->${t.toStageId}').toList();
    if (keys.toSet().length != keys.length ||
        orderedTransitions.any((t) => t.fromStageId == t.toStageId || !stageIds.contains(t.fromStageId) || !stageIds.contains(t.toStageId))) {
      throw ArgumentError('Pipeline contains invalid or duplicate transitions.');
    }
    final outgoing = {for (final id in stageIds) id: <String>[]};
    final incoming = {for (final id in stageIds) id: <String>[]};
    for (final transition in orderedTransitions) {
      outgoing[transition.fromStageId]!.add(transition.toStageId);
      incoming[transition.toStageId]!.add(transition.fromStageId);
    }
    if (stageIds.length > 1 && stageIds.any((id) => outgoing[id]!.isEmpty && incoming[id]!.isEmpty)) {
      throw ArgumentError('Pipeline contains an orphan stage.');
    }
    final indegree = {for (final id in stageIds) id: incoming[id]!.length};
    final queue = stageIds.where((id) => indegree[id] == 0).toList();
    var visited = 0;
    while (queue.isNotEmpty) {
      final id = queue.removeAt(0);
      visited++;
      for (final next in outgoing[id]!) {
        indegree[next] = indegree[next]! - 1;
        if (indegree[next] == 0) queue.add(next);
      }
    }
    if (visited != stageIds.length) throw ArgumentError('Pipeline contains a cycle.');
    final payload = {
      'schemaVersion': runtimePipelineContractVersion,
      'policyVersion': runtimePipelinePolicyVersion,
      'compositionId': composition.id,
      'compositionDigest': composition.digest,
      'stages': orderedStages.map((stage) => stage.toJson()).toList(),
      'transitions': orderedTransitions.map((transition) => transition.toJson()).toList(),
    };
    final digest = _digest(payload);
    return RuntimePipelineContract._(
      id: 'runtime-pipeline.${digest.substring(0, 16)}',
      compositionId: composition.id,
      compositionDigest: composition.digest,
      stages: List.unmodifiable(orderedStages),
      transitions: List.unmodifiable(orderedTransitions),
      digest: digest,
    );
  }

  final String id;
  final String compositionId;
  final String compositionDigest;
  final List<PipelineStage> stages;
  final List<PipelineTransition> transitions;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': runtimePipelineContractVersion,
        'policyVersion': runtimePipelinePolicyVersion,
        'id': id,
        'compositionId': compositionId,
        'compositionDigest': compositionDigest,
        'stages': stages.map((stage) => stage.toJson()).toList(),
        'transitions': transitions.map((transition) => transition.toJson()).toList(),
        'digest': digest,
      };
}

class RuntimePipelineEngine {
  const RuntimePipelineEngine();

  RuntimePipelineContract build({
    required RuntimeCompositionContract composition,
    required List<PipelineStage> stages,
    required List<PipelineTransition> transitions,
  }) => RuntimePipelineContract.create(
        composition: composition,
        stages: stages,
        transitions: transitions,
      );
}

String _digest(Object value) => sha256.convert(utf8.encode(jsonEncode(value))).toString();
