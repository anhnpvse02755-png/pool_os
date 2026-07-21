import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/ai_session_contracts.dart';

const aiCapabilityRegistryContractVersion = 1;
const aiCapabilityDefinitionContractVersion = 1;
const aiCapabilityRegistryPolicyVersion = 'ai-capability-registry/1.0.0';

class AICapabilityDefinition {
  const AICapabilityDefinition({
    required this.capabilityId,
    required this.capabilityContractVersion,
    required this.minimumAIContractVersion,
    required this.requiredRuntimeContracts,
    required this.compatibilityRules,
  });

  final String capabilityId;
  final int capabilityContractVersion;
  final String minimumAIContractVersion;
  final Map<String, int> requiredRuntimeContracts;
  final Map<String, String> compatibilityRules;

  Map<String, dynamic> toJson() => {
        'schemaVersion': aiCapabilityDefinitionContractVersion,
        'capabilityId': capabilityId,
        'capabilityContractVersion': capabilityContractVersion,
        'minimumAIContractVersion': minimumAIContractVersion,
        'requiredRuntimeContracts': _orderedInts(requiredRuntimeContracts),
        'compatibilityRules': _orderedStrings(compatibilityRules),
      };
}

class AICapabilityBinding {
  const AICapabilityBinding({
    required this.registryDigest,
    required this.capabilityId,
    required this.capabilityContractVersion,
    required this.minimumAIContractVersion,
    required this.compatibilityRules,
    required this.digest,
  });

  final String registryDigest;
  final String capabilityId;
  final int capabilityContractVersion;
  final String minimumAIContractVersion;
  final Map<String, String> compatibilityRules;
  final String digest;

  Map<String, dynamic> toJson() => {
        'registryDigest': registryDigest,
        'capabilityId': capabilityId,
        'capabilityContractVersion': capabilityContractVersion,
        'minimumAIContractVersion': minimumAIContractVersion,
        'compatibilityRules': _orderedStrings(compatibilityRules),
        'digest': digest,
      };
}

class AICapabilityRegistryContract {
  const AICapabilityRegistryContract._({
    required this.id,
    required this.aiContractVersion,
    required this.minimumSupportedAIContractVersion,
    required this.capabilities,
    required this.digest,
  });

  factory AICapabilityRegistryContract.create({
    required int aiContractVersion,
    required String minimumSupportedAIContractVersion,
    required List<AICapabilityDefinition> capabilities,
  }) {
    if (aiContractVersion < 1 ||
        minimumSupportedAIContractVersion.trim().isEmpty ||
        capabilities.isEmpty) {
      throw ArgumentError('AI Capability Registry metadata is invalid.');
    }
    final ordered = [...capabilities]
      ..sort((a, b) => a.capabilityId.compareTo(b.capabilityId));
    if (ordered.any(
      (item) =>
          item.capabilityId.trim().isEmpty ||
          item.capabilityContractVersion < 1 ||
          item.minimumAIContractVersion.trim().isEmpty ||
          item.requiredRuntimeContracts.values.any((version) => version < 1) ||
          item.compatibilityRules.keys.any((key) => key.trim().isEmpty),
    )) {
      throw ArgumentError('AI Capability definition is invalid.');
    }
    if (ordered.map((item) => item.capabilityId).toSet().length !=
        ordered.length) {
      throw ArgumentError('AI Capability Registry contains duplicate IDs.');
    }
    final payload = {
      'schemaVersion': aiCapabilityRegistryContractVersion,
      'aiContractVersion': aiContractVersion,
      'minimumSupportedAIContractVersion': minimumSupportedAIContractVersion,
      'capabilities': ordered.map((item) => item.toJson()).toList(),
      'policyVersion': aiCapabilityRegistryPolicyVersion,
    };
    final digest = _digest(payload);
    return AICapabilityRegistryContract._(
      id: 'ai-capability-registry.${digest.substring(0, 16)}',
      aiContractVersion: aiContractVersion,
      minimumSupportedAIContractVersion: minimumSupportedAIContractVersion,
      capabilities: List.unmodifiable(ordered),
      digest: digest,
    );
  }

  final String id;
  final int aiContractVersion;
  final String minimumSupportedAIContractVersion;
  final List<AICapabilityDefinition> capabilities;
  final String digest;

  AICapabilityBinding resolveForSession({
    required AISessionContract session,
    required String capabilityId,
  }) {
    if (aiContractVersion != aiSessionContractVersion ||
        session.minimumAIContractVersion != minimumSupportedAIContractVersion) {
      throw ArgumentError(
          'AI Capability Registry is incompatible with AISession.');
    }
    final definition = capabilities.singleWhere(
      (item) => item.capabilityId == capabilityId,
      orElse: () => throw StateError('AI capability is not registered.'),
    );
    if (definition.minimumAIContractVersion !=
            session.minimumAIContractVersion ||
        definition.requiredRuntimeContracts.entries.any(
          (entry) => session.requiredRuntimeContracts[entry.key] != entry.value,
        )) {
      throw ArgumentError('AI capability is incompatible with AISession.');
    }
    final payload = {
      'registryDigest': digest,
      'capability': definition.toJson(),
    };
    final bindingDigest = _digest(payload);
    return AICapabilityBinding(
      registryDigest: digest,
      capabilityId: definition.capabilityId,
      capabilityContractVersion: definition.capabilityContractVersion,
      minimumAIContractVersion: definition.minimumAIContractVersion,
      compatibilityRules: Map.unmodifiable(
        _orderedStrings(definition.compatibilityRules),
      ),
      digest: bindingDigest,
    );
  }

  Map<String, dynamic> toJson() => {
        'schemaVersion': aiCapabilityRegistryContractVersion,
        'id': id,
        'aiContractVersion': aiContractVersion,
        'minimumSupportedAIContractVersion': minimumSupportedAIContractVersion,
        'capabilities': capabilities.map((item) => item.toJson()).toList(),
        'policyVersion': aiCapabilityRegistryPolicyVersion,
        'digest': digest,
      };
}

Map<String, int> _orderedInts(Map<String, int> values) => {
      for (final key in values.keys.toList()..sort()) key: values[key]!,
    };

Map<String, String> _orderedStrings(Map<String, String> values) => {
      for (final key in values.keys.toList()..sort()) key: values[key]!,
    };

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
