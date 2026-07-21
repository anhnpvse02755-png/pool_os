import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/runtime_integration_projection_contracts.dart';

const runtimeExposureProjectionContractVersion = 1;
const runtimeExposureProjectionPolicyVersion = 'runtime-exposure-projection/1.0.0';
enum RuntimeExposureScope { internal, application, api, ui, aiConsumer }

class RuntimeExposureEntry {
  const RuntimeExposureEntry({required this.integrationEntryId, required this.runtimeNodeId, required this.exposureKey, required this.scope, required this.position, required this.metadata});
  final String integrationEntryId;
  final String runtimeNodeId;
  final String exposureKey;
  final RuntimeExposureScope scope;
  final int position;
  final String metadata;
  Map<String, dynamic> toJson() => {'integrationEntryId': integrationEntryId, 'runtimeNodeId': runtimeNodeId, 'exposureKey': exposureKey, 'scope': scope.name, 'position': position, 'metadata': metadata};
}

class RuntimeExposureProjectionContract {
  const RuntimeExposureProjectionContract._({required this.id, required this.integrationId, required this.integrationDigest, required this.entries, required this.digest});
  factory RuntimeExposureProjectionContract.create({required RuntimeIntegrationProjectionContract integration, required List<RuntimeExposureEntry> entries}) {
    final ordered = [...entries]..sort((a, b) => a.position.compareTo(b.position));
    final bindings = integration.entries.map((entry) => '${entry.integrationKey}:${entry.runtimeNodeId}').toSet();
    if (ordered.length != integration.entries.length || ordered.map((entry) => entry.exposureKey).toSet().length != ordered.length || ordered.map((entry) => entry.position).toSet().length != ordered.length || ordered.any((entry) => entry.position < 0 || entry.metadata != runtimeExposureProjectionPolicyVersion || !bindings.contains('${entry.integrationEntryId}:${entry.runtimeNodeId}'))) throw ArgumentError('Runtime exposure projection contains invalid or orphan entries.');
    final payload = {'schemaVersion': runtimeExposureProjectionContractVersion, 'policyVersion': runtimeExposureProjectionPolicyVersion, 'integrationId': integration.id, 'integrationDigest': integration.digest, 'entries': ordered.map((entry) => entry.toJson()).toList()};
    final digest = _digest(payload);
    return RuntimeExposureProjectionContract._(id: 'runtime-exposure.${digest.substring(0, 16)}', integrationId: integration.id, integrationDigest: integration.digest, entries: List.unmodifiable(ordered), digest: digest);
  }
  final String id;
  final String integrationId;
  final String integrationDigest;
  final List<RuntimeExposureEntry> entries;
  final String digest;
  Map<String, dynamic> toJson() => {'schemaVersion': runtimeExposureProjectionContractVersion, 'policyVersion': runtimeExposureProjectionPolicyVersion, 'id': id, 'integrationId': integrationId, 'integrationDigest': integrationDigest, 'entries': entries.map((entry) => entry.toJson()).toList(), 'digest': digest};
}

class RuntimeExposureProjector {
  const RuntimeExposureProjector();
  RuntimeExposureProjectionContract project(RuntimeIntegrationProjectionContract integration) {
    final entries = [for (var i = 0; i < integration.entries.length; i++) RuntimeExposureEntry(integrationEntryId: integration.entries[i].integrationKey, runtimeNodeId: integration.entries[i].runtimeNodeId, exposureKey: '${integration.entries[i].integrationKey}:exposure', scope: i == 0 ? RuntimeExposureScope.internal : RuntimeExposureScope.application, position: integration.entries[i].position, metadata: runtimeExposureProjectionPolicyVersion)];
    return RuntimeExposureProjectionContract.create(integration: integration, entries: entries);
  }
}
String _digest(Object value) => sha256.convert(utf8.encode(jsonEncode(value))).toString();
