import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/runtime_dispatch_contracts.dart';

const runtimeActivationProjectionContractVersion = 1;
const runtimeActivationProjectionPolicyVersion = 'runtime-activation-projection/1.0.0';

class RuntimeActivationEntry {
  const RuntimeActivationEntry({required this.dispatchEntryId, required this.runtimeNodeId, required this.activationKey, required this.position, required this.metadata});
  final String dispatchEntryId;
  final String runtimeNodeId;
  final String activationKey;
  final int position;
  final String metadata;
  Map<String, dynamic> toJson() => {'dispatchEntryId': dispatchEntryId, 'runtimeNodeId': runtimeNodeId, 'activationKey': activationKey, 'position': position, 'metadata': metadata};
}

class RuntimeActivationProjectionContract {
  const RuntimeActivationProjectionContract._({required this.id, required this.dispatchId, required this.dispatchDigest, required this.entries, required this.digest});
  factory RuntimeActivationProjectionContract.create({required RuntimeDispatchContract dispatch, required List<RuntimeActivationEntry> entries}) {
    final ordered = [...entries]..sort((a, b) => a.position.compareTo(b.position));
    final dispatchBindings = dispatch.entries.map((entry) => '${entry.mappingId}:${entry.runtimeNodeId}').toSet();
    if (ordered.length != dispatch.entries.length || ordered.map((entry) => entry.activationKey).toSet().length != ordered.length || ordered.map((entry) => entry.position).toSet().length != ordered.length || ordered.any((entry) => entry.position < 0 || entry.activationKey.trim().isEmpty || entry.metadata != runtimeActivationProjectionPolicyVersion || !dispatchBindings.contains('${entry.dispatchEntryId}:${entry.runtimeNodeId}'))) throw ArgumentError('Runtime activation projection contains invalid or orphan entries.');
    final payload = {'schemaVersion': runtimeActivationProjectionContractVersion, 'policyVersion': runtimeActivationProjectionPolicyVersion, 'dispatchId': dispatch.id, 'dispatchDigest': dispatch.digest, 'entries': ordered.map((entry) => entry.toJson()).toList()};
    final digest = _digest(payload);
    return RuntimeActivationProjectionContract._(id: 'runtime-activation.${digest.substring(0, 16)}', dispatchId: dispatch.id, dispatchDigest: dispatch.digest, entries: List.unmodifiable(ordered), digest: digest);
  }
  final String id;
  final String dispatchId;
  final String dispatchDigest;
  final List<RuntimeActivationEntry> entries;
  final String digest;
  Map<String, dynamic> toJson() => {'schemaVersion': runtimeActivationProjectionContractVersion, 'policyVersion': runtimeActivationProjectionPolicyVersion, 'id': id, 'dispatchId': dispatchId, 'dispatchDigest': dispatchDigest, 'entries': entries.map((entry) => entry.toJson()).toList(), 'digest': digest};
}

class RuntimeActivationProjector {
  const RuntimeActivationProjector();
  RuntimeActivationProjectionContract project(RuntimeDispatchContract dispatch) {
    final entries = [for (final entry in dispatch.entries) RuntimeActivationEntry(dispatchEntryId: entry.mappingId, runtimeNodeId: entry.runtimeNodeId, activationKey: '${entry.dispatchKey}:activation', position: entry.position, metadata: runtimeActivationProjectionPolicyVersion)];
    return RuntimeActivationProjectionContract.create(dispatch: dispatch, entries: entries);
  }
}

String _digest(Object value) => sha256.convert(utf8.encode(jsonEncode(value))).toString();
