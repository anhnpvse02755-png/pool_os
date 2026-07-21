import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/runtime_composition_coordination_contracts.dart';

const runtimeDispatchContractVersion = 1;
const runtimeDispatchPolicyVersion = 'runtime-dispatch/1.0.0';

class RuntimeDispatchEntry {
  const RuntimeDispatchEntry({required this.mappingId, required this.runtimeNodeId, required this.pipelineStageId, required this.dispatchKey, required this.position});
  final String mappingId;
  final String runtimeNodeId;
  final String pipelineStageId;
  final String dispatchKey;
  final int position;
  Map<String, dynamic> toJson() => {'mappingId': mappingId, 'runtimeNodeId': runtimeNodeId, 'pipelineStageId': pipelineStageId, 'dispatchKey': dispatchKey, 'position': position};
}

class RuntimeDispatchContract {
  const RuntimeDispatchContract._({required this.id, required this.coordinationId, required this.coordinationDigest, required this.entries, required this.digest});
  factory RuntimeDispatchContract.create({required RuntimeCompositionCoordinationContract coordination, required List<RuntimeDispatchEntry> entries}) {
    final ordered = [...entries]..sort((a, b) => a.position.compareTo(b.position));
    final keys = ordered.map((entry) => entry.dispatchKey).toSet();
    final mappingIds = coordination.mappings.map((mapping) => '${mapping.runtimeNodeId}:${mapping.pipelineStageId}').toSet();
    if (ordered.length != coordination.mappings.length || ordered.map((entry) => entry.position).toSet().length != ordered.length || keys.length != ordered.length || ordered.any((entry) => entry.position < 0 || entry.dispatchKey.trim().isEmpty || !mappingIds.contains('${entry.runtimeNodeId}:${entry.pipelineStageId}'))) throw ArgumentError('Runtime dispatch contains duplicate, orphan, or invalid entries.');
    final payload = {'schemaVersion': runtimeDispatchContractVersion, 'policyVersion': runtimeDispatchPolicyVersion, 'coordinationId': coordination.id, 'coordinationDigest': coordination.digest, 'entries': ordered.map((entry) => entry.toJson()).toList()};
    final digest = _digest(payload);
    return RuntimeDispatchContract._(id: 'runtime-dispatch.${digest.substring(0, 16)}', coordinationId: coordination.id, coordinationDigest: coordination.digest, entries: List.unmodifiable(ordered), digest: digest);
  }
  final String id;
  final String coordinationId;
  final String coordinationDigest;
  final List<RuntimeDispatchEntry> entries;
  final String digest;
  Map<String, dynamic> toJson() => {'schemaVersion': runtimeDispatchContractVersion, 'policyVersion': runtimeDispatchPolicyVersion, 'id': id, 'coordinationId': coordinationId, 'coordinationDigest': coordinationDigest, 'entries': entries.map((entry) => entry.toJson()).toList(), 'digest': digest};
}

class RuntimeDispatcher {
  const RuntimeDispatcher();
  RuntimeDispatchContract project(RuntimeCompositionCoordinationContract coordination) {
    final mappings = [...coordination.mappings]..sort((a, b) => '${a.runtimeNodeId}:${a.pipelineStageId}'.compareTo('${b.runtimeNodeId}:${b.pipelineStageId}'));
    final entries = [for (var i = 0; i < mappings.length; i++) RuntimeDispatchEntry(mappingId: '${coordination.id}:$i', runtimeNodeId: mappings[i].runtimeNodeId, pipelineStageId: mappings[i].pipelineStageId, dispatchKey: '${mappings[i].runtimeNodeId}:${mappings[i].pipelineStageId}', position: i)];
    return RuntimeDispatchContract.create(coordination: coordination, entries: entries);
  }
}

String _digest(Object value) => sha256.convert(utf8.encode(jsonEncode(value))).toString();
