import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/runtime_activation_projection_contracts.dart';

const runtimeLifecycleProjectionContractVersion = 1;
const runtimeLifecycleProjectionPolicyVersion = 'runtime-lifecycle-projection/1.0.0';
enum RuntimeLifecyclePhase { initialized, ready, active, completed }

class RuntimeLifecycleEntry {
  const RuntimeLifecycleEntry({required this.activationEntryId, required this.runtimeNodeId, required this.phase, required this.position, required this.metadata});
  final String activationEntryId;
  final String runtimeNodeId;
  final RuntimeLifecyclePhase phase;
  final int position;
  final String metadata;
  Map<String, dynamic> toJson() => {'activationEntryId': activationEntryId, 'runtimeNodeId': runtimeNodeId, 'phase': phase.name, 'position': position, 'metadata': metadata};
}

class RuntimeLifecycleProjectionContract {
  const RuntimeLifecycleProjectionContract._({required this.id, required this.activationId, required this.activationDigest, required this.entries, required this.digest});
  factory RuntimeLifecycleProjectionContract.create({required RuntimeActivationProjectionContract activation, required List<RuntimeLifecycleEntry> entries}) {
    final ordered = [...entries]..sort((a, b) => a.position.compareTo(b.position));
    final bindings = activation.entries.map((entry) => '${entry.dispatchEntryId}:${entry.runtimeNodeId}').toSet();
    if (ordered.length != activation.entries.length || ordered.map((entry) => entry.activationEntryId).toSet().length != ordered.length || ordered.map((entry) => entry.position).toSet().length != ordered.length || ordered.any((entry) => entry.position < 0 || entry.metadata != runtimeLifecycleProjectionPolicyVersion || !bindings.contains('${entry.activationEntryId}:${entry.runtimeNodeId}'))) throw ArgumentError('Runtime lifecycle projection contains invalid or orphan entries.');
    final payload = {'schemaVersion': runtimeLifecycleProjectionContractVersion, 'policyVersion': runtimeLifecycleProjectionPolicyVersion, 'activationId': activation.id, 'activationDigest': activation.digest, 'entries': ordered.map((entry) => entry.toJson()).toList()};
    final digest = _digest(payload);
    return RuntimeLifecycleProjectionContract._(id: 'runtime-lifecycle.${digest.substring(0, 16)}', activationId: activation.id, activationDigest: activation.digest, entries: List.unmodifiable(ordered), digest: digest);
  }
  final String id;
  final String activationId;
  final String activationDigest;
  final List<RuntimeLifecycleEntry> entries;
  final String digest;
  Map<String, dynamic> toJson() => {'schemaVersion': runtimeLifecycleProjectionContractVersion, 'policyVersion': runtimeLifecycleProjectionPolicyVersion, 'id': id, 'activationId': activationId, 'activationDigest': activationDigest, 'entries': entries.map((entry) => entry.toJson()).toList(), 'digest': digest};
}

class RuntimeLifecycleProjector {
  const RuntimeLifecycleProjector();
  RuntimeLifecycleProjectionContract project(RuntimeActivationProjectionContract activation) {
    final entries = [for (var i = 0; i < activation.entries.length; i++) RuntimeLifecycleEntry(activationEntryId: activation.entries[i].dispatchEntryId, runtimeNodeId: activation.entries[i].runtimeNodeId, phase: i == 0 ? RuntimeLifecyclePhase.initialized : RuntimeLifecyclePhase.ready, position: activation.entries[i].position, metadata: runtimeLifecycleProjectionPolicyVersion)];
    return RuntimeLifecycleProjectionContract.create(activation: activation, entries: entries);
  }
}
String _digest(Object value) => sha256.convert(utf8.encode(jsonEncode(value))).toString();
