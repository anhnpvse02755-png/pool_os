import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/runtime_lifecycle_projection_contracts.dart';

const runtimeIntegrationProjectionContractVersion = 1;
const runtimeIntegrationProjectionPolicyVersion = 'runtime-integration-projection/1.0.0';
enum RuntimeIntegrationType { runtime, application, adapter, externalBoundary }

class RuntimeIntegrationEntry {
  const RuntimeIntegrationEntry({required this.lifecycleEntryId, required this.runtimeNodeId, required this.integrationKey, required this.type, required this.position, required this.metadata});
  final String lifecycleEntryId;
  final String runtimeNodeId;
  final String integrationKey;
  final RuntimeIntegrationType type;
  final int position;
  final String metadata;
  Map<String, dynamic> toJson() => {'lifecycleEntryId': lifecycleEntryId, 'runtimeNodeId': runtimeNodeId, 'integrationKey': integrationKey, 'type': type.name, 'position': position, 'metadata': metadata};
}

class RuntimeIntegrationProjectionContract {
  const RuntimeIntegrationProjectionContract._({required this.id, required this.lifecycleId, required this.lifecycleDigest, required this.entries, required this.digest});
  factory RuntimeIntegrationProjectionContract.create({required RuntimeLifecycleProjectionContract lifecycle, required List<RuntimeIntegrationEntry> entries}) {
    final ordered = [...entries]..sort((a, b) => a.position.compareTo(b.position));
    final bindings = lifecycle.entries.map((entry) => '${entry.activationEntryId}:${entry.runtimeNodeId}').toSet();
    if (ordered.length != lifecycle.entries.length || ordered.map((entry) => entry.integrationKey).toSet().length != ordered.length || ordered.map((entry) => entry.position).toSet().length != ordered.length || ordered.any((entry) => entry.position < 0 || entry.metadata != runtimeIntegrationProjectionPolicyVersion || !bindings.contains('${entry.lifecycleEntryId}:${entry.runtimeNodeId}'))) throw ArgumentError('Runtime integration projection contains invalid or orphan entries.');
    final payload = {'schemaVersion': runtimeIntegrationProjectionContractVersion, 'policyVersion': runtimeIntegrationProjectionPolicyVersion, 'lifecycleId': lifecycle.id, 'lifecycleDigest': lifecycle.digest, 'entries': ordered.map((entry) => entry.toJson()).toList()};
    final digest = _digest(payload);
    return RuntimeIntegrationProjectionContract._(id: 'runtime-integration.${digest.substring(0, 16)}', lifecycleId: lifecycle.id, lifecycleDigest: lifecycle.digest, entries: List.unmodifiable(ordered), digest: digest);
  }
  final String id;
  final String lifecycleId;
  final String lifecycleDigest;
  final List<RuntimeIntegrationEntry> entries;
  final String digest;
  Map<String, dynamic> toJson() => {'schemaVersion': runtimeIntegrationProjectionContractVersion, 'policyVersion': runtimeIntegrationProjectionPolicyVersion, 'id': id, 'lifecycleId': lifecycleId, 'lifecycleDigest': lifecycleDigest, 'entries': entries.map((entry) => entry.toJson()).toList(), 'digest': digest};
}

class RuntimeIntegrationProjector {
  const RuntimeIntegrationProjector();
  RuntimeIntegrationProjectionContract project(RuntimeLifecycleProjectionContract lifecycle) {
    final entries = [for (var i = 0; i < lifecycle.entries.length; i++) RuntimeIntegrationEntry(lifecycleEntryId: lifecycle.entries[i].activationEntryId, runtimeNodeId: lifecycle.entries[i].runtimeNodeId, integrationKey: '${lifecycle.entries[i].runtimeNodeId}:integration', type: i == 0 ? RuntimeIntegrationType.runtime : RuntimeIntegrationType.application, position: lifecycle.entries[i].position, metadata: runtimeIntegrationProjectionPolicyVersion)];
    return RuntimeIntegrationProjectionContract.create(lifecycle: lifecycle, entries: entries);
  }
}
String _digest(Object value) => sha256.convert(utf8.encode(jsonEncode(value))).toString();
