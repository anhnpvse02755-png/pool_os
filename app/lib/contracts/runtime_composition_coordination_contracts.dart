import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/runtime_composition_contracts.dart';
import 'package:pool_os/contracts/runtime_pipeline_contracts.dart';

const runtimeCompositionCoordinationContractVersion = 1;
const runtimeCompositionCoordinationPolicyVersion = 'runtime-composition-coordination/1.0.0';

class RuntimeCoordinationMapping {
  const RuntimeCoordinationMapping({required this.runtimeNodeId, required this.pipelineStageId});
  final String runtimeNodeId;
  final String pipelineStageId;
  Map<String, dynamic> toJson() => {'runtimeNodeId': runtimeNodeId, 'pipelineStageId': pipelineStageId};
}

class RuntimeCompositionCoordinationContract {
  const RuntimeCompositionCoordinationContract._({required this.id, required this.compositionId, required this.compositionDigest, required this.pipelineId, required this.pipelineDigest, required this.mappings, required this.digest});

  factory RuntimeCompositionCoordinationContract.create({required RuntimeCompositionContract composition, required RuntimePipelineContract pipeline, required List<RuntimeCoordinationMapping> mappings}) {
    if (pipeline.compositionId != composition.id || pipeline.compositionDigest != composition.digest) throw ArgumentError('Runtime coordination has a stale or foreign pipeline.');
    final ordered = [...mappings]..sort((a, b) => '${a.runtimeNodeId}:${a.pipelineStageId}'.compareTo('${b.runtimeNodeId}:${b.pipelineStageId}'));
    final nodeIds = composition.nodes.map((node) => node.id).toSet();
    final stageIds = pipeline.stages.map((stage) => stage.id).toSet();
    final keys = ordered.map((mapping) => '${mapping.runtimeNodeId}->${mapping.pipelineStageId}').toList();
    if (keys.toSet().length != keys.length || ordered.any((mapping) => !nodeIds.contains(mapping.runtimeNodeId) || !stageIds.contains(mapping.pipelineStageId)) || ordered.map((mapping) => mapping.runtimeNodeId).toSet().length != nodeIds.length || ordered.map((mapping) => mapping.pipelineStageId).toSet().length != stageIds.length) {
      throw ArgumentError('Runtime coordination contains duplicate, broken, or orphan mappings.');
    }
    final payload = {'schemaVersion': runtimeCompositionCoordinationContractVersion, 'policyVersion': runtimeCompositionCoordinationPolicyVersion, 'compositionId': composition.id, 'compositionDigest': composition.digest, 'pipelineId': pipeline.id, 'pipelineDigest': pipeline.digest, 'mappings': ordered.map((mapping) => mapping.toJson()).toList()};
    final digest = _digest(payload);
    return RuntimeCompositionCoordinationContract._(id: 'runtime-coordination.${digest.substring(0, 16)}', compositionId: composition.id, compositionDigest: composition.digest, pipelineId: pipeline.id, pipelineDigest: pipeline.digest, mappings: List.unmodifiable(ordered), digest: digest);
  }

  final String id;
  final String compositionId;
  final String compositionDigest;
  final String pipelineId;
  final String pipelineDigest;
  final List<RuntimeCoordinationMapping> mappings;
  final String digest;
  Map<String, dynamic> toJson() => {'schemaVersion': runtimeCompositionCoordinationContractVersion, 'policyVersion': runtimeCompositionCoordinationPolicyVersion, 'id': id, 'compositionId': compositionId, 'compositionDigest': compositionDigest, 'pipelineId': pipelineId, 'pipelineDigest': pipelineDigest, 'mappings': mappings.map((mapping) => mapping.toJson()).toList(), 'digest': digest};
}

class RuntimeCompositionCoordinator {
  const RuntimeCompositionCoordinator();
  RuntimeCompositionCoordinationContract coordinate({required RuntimeCompositionContract composition, required RuntimePipelineContract pipeline, required List<RuntimeCoordinationMapping> mappings}) => RuntimeCompositionCoordinationContract.create(composition: composition, pipeline: pipeline, mappings: mappings);
}

String _digest(Object value) => sha256.convert(utf8.encode(jsonEncode(value))).toString();
