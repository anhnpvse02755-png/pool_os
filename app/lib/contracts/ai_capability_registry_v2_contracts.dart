import 'dart:convert';

import 'package:crypto/crypto.dart';

const aiCapabilityRegistryV2ContractVersion = 2;
const aiCapabilityRegistryV2PolicyVersion = 'ai-capability-registry/2.0.0';

enum AIToolInvocationPolicyV2 {
  none,
  knowledgeLookup,
  visionAnalysis,
  memoryRead,
  memoryWrite,
  externalSearch,
  simulation,
}

class AICapabilityDefinitionV2 {
  const AICapabilityDefinitionV2({
    required this.capabilityId,
    required this.capabilityContractVersion,
    required this.minimumAIContractVersion,
    required this.requiredRuntimeContracts,
    required this.compatibilityRules,
    required this.allowedToolIds,
    required this.defaultToolId,
    required this.toolInvocationPolicy,
  });

  final String capabilityId;
  final int capabilityContractVersion;
  final String minimumAIContractVersion;
  final Map<String, int> requiredRuntimeContracts;
  final Map<String, String> compatibilityRules;
  final List<String> allowedToolIds;
  final String? defaultToolId;
  final AIToolInvocationPolicyV2 toolInvocationPolicy;

  Map<String, dynamic> toJson() => {
        'schemaVersion': aiCapabilityRegistryV2ContractVersion,
        'capabilityId': capabilityId,
        'capabilityContractVersion': capabilityContractVersion,
        'minimumAIContractVersion': minimumAIContractVersion,
        'requiredRuntimeContracts': _orderedInts(requiredRuntimeContracts),
        'compatibilityRules': _orderedStrings(compatibilityRules),
        'allowedToolIds': allowedToolIds,
        'defaultToolId': defaultToolId,
        'toolInvocationPolicy': toolInvocationPolicy.name,
      };
}

class AICapabilityRegistryV2Contract {
  const AICapabilityRegistryV2Contract._({
    required this.schemaVersion,
    required this.id,
    required this.aiContractVersion,
    required this.minimumSupportedAIContractVersion,
    required this.capabilities,
    required this.digest,
  });

  factory AICapabilityRegistryV2Contract.create({
    required int aiContractVersion,
    required String minimumSupportedAIContractVersion,
    required List<AICapabilityDefinitionV2> capabilities,
  }) {
    final ordered = [...capabilities]
      ..sort((a, b) => a.capabilityId.compareTo(b.capabilityId));
    _validate(aiContractVersion, minimumSupportedAIContractVersion, ordered);
    final payload = {
      'schemaVersion': aiCapabilityRegistryV2ContractVersion,
      'aiContractVersion': aiContractVersion,
      'minimumSupportedAIContractVersion': minimumSupportedAIContractVersion,
      'capabilities': ordered.map((item) => item.toJson()).toList(),
      'policyVersion': aiCapabilityRegistryV2PolicyVersion,
    };
    final digest = _digest(payload);
    return AICapabilityRegistryV2Contract._(
      schemaVersion: aiCapabilityRegistryV2ContractVersion,
      id: 'ai-capability-registry.${digest.substring(0, 16)}',
      aiContractVersion: aiContractVersion,
      minimumSupportedAIContractVersion: minimumSupportedAIContractVersion,
      capabilities: List.unmodifiable(ordered),
      digest: digest,
    );
  }

  factory AICapabilityRegistryV2Contract.fromJson(Map<String, dynamic> json) {
    final schemaVersion = json['schemaVersion'] as int?;
    if (schemaVersion != 1 &&
        schemaVersion != aiCapabilityRegistryV2ContractVersion) {
      throw ArgumentError('AI Capability Registry version is unsupported.');
    }
    final capabilities = (json['capabilities'] as List)
        .cast<Map<String, dynamic>>()
        .map((item) => AICapabilityDefinitionV2(
              capabilityId: item['capabilityId'] as String,
              capabilityContractVersion:
                  item['capabilityContractVersion'] as int,
              minimumAIContractVersion:
                  item['minimumAIContractVersion'] as String,
              requiredRuntimeContracts: Map.unmodifiable(_orderedInts(
                  (item['requiredRuntimeContracts'] as Map)
                      .cast<String, int>())),
              compatibilityRules: Map.unmodifiable(_orderedStrings(
                  (item['compatibilityRules'] as Map).cast<String, String>())),
              allowedToolIds: List.unmodifiable(schemaVersion == 1
                  ? const <String>[]
                  : (item['allowedToolIds'] as List).cast<String>()),
              defaultToolId:
                  schemaVersion == 1 ? null : item['defaultToolId'] as String?,
              toolInvocationPolicy: schemaVersion == 1
                  ? AIToolInvocationPolicyV2.none
                  : AIToolInvocationPolicyV2.values.singleWhere(
                      (value) => value.name == item['toolInvocationPolicy'],
                      orElse: () => throw ArgumentError(
                        'AI Capability tool policy is invalid.',
                      ),
                    ),
            ))
        .toList()
      ..sort((a, b) => a.capabilityId.compareTo(b.capabilityId));
    _validate(
      json['aiContractVersion'] as int,
      json['minimumSupportedAIContractVersion'] as String,
      capabilities,
      legacy: schemaVersion == 1,
    );
    final payload = {
      'schemaVersion': schemaVersion,
      'aiContractVersion': json['aiContractVersion'],
      'minimumSupportedAIContractVersion':
          json['minimumSupportedAIContractVersion'],
      'capabilities': capabilities
          .map((item) =>
              schemaVersion == 1 ? _legacyDefinitionJson(item) : item.toJson())
          .toList(),
      'policyVersion': schemaVersion == 1
          ? 'ai-capability-registry/1.0.0'
          : aiCapabilityRegistryV2PolicyVersion,
    };
    final digest = _digest(payload);
    if (json['digest'] != digest ||
        json['id'] != 'ai-capability-registry.${digest.substring(0, 16)}') {
      throw ArgumentError('AI Capability Registry artifact digest is invalid.');
    }
    return AICapabilityRegistryV2Contract._(
      schemaVersion: schemaVersion!,
      id: json['id'] as String,
      aiContractVersion: json['aiContractVersion'] as int,
      minimumSupportedAIContractVersion:
          json['minimumSupportedAIContractVersion'] as String,
      capabilities: List.unmodifiable(capabilities),
      digest: digest,
    );
  }

  final int schemaVersion;
  final String id;
  final int aiContractVersion;
  final String minimumSupportedAIContractVersion;
  final List<AICapabilityDefinitionV2> capabilities;
  final String digest;

  AICapabilityDefinitionV2 definitionFor(String capabilityId) =>
      capabilities.singleWhere(
        (item) => item.capabilityId == capabilityId,
        orElse: () => throw StateError('AI capability is not registered.'),
      );

  Map<String, dynamic> toJson() => {
        'schemaVersion': schemaVersion,
        'id': id,
        'aiContractVersion': aiContractVersion,
        'minimumSupportedAIContractVersion': minimumSupportedAIContractVersion,
        'capabilities': capabilities
            .map((item) => schemaVersion == 1
                ? _legacyDefinitionJson(item)
                : item.toJson())
            .toList(),
        'policyVersion': schemaVersion == 1
            ? 'ai-capability-registry/1.0.0'
            : aiCapabilityRegistryV2PolicyVersion,
        'digest': digest,
      };
}

void _validate(
  int aiContractVersion,
  String minimumVersion,
  List<AICapabilityDefinitionV2> capabilities, {
  bool legacy = false,
}) {
  if (aiContractVersion < 1 ||
      minimumVersion.trim().isEmpty ||
      capabilities.isEmpty ||
      capabilities.map((item) => item.capabilityId).toSet().length !=
          capabilities.length) {
    throw ArgumentError('AI Capability Registry metadata is invalid.');
  }
  for (final item in capabilities) {
    if (item.capabilityId.trim().isEmpty ||
        item.capabilityContractVersion < 1 ||
        item.minimumAIContractVersion.trim().isEmpty ||
        item.requiredRuntimeContracts.values.any((version) => version < 1) ||
        item.allowedToolIds.toSet().length != item.allowedToolIds.length ||
        !_sameList(item.allowedToolIds, [...item.allowedToolIds]..sort()) ||
        item.allowedToolIds.any((id) =>
            id.trim().isEmpty ||
            !RegExp(r'^[a-z0-9]+(?:[._-][a-z0-9]+)*$').hasMatch(id)) ||
        (item.defaultToolId != null &&
            !item.allowedToolIds.contains(item.defaultToolId)) ||
        (item.allowedToolIds.isEmpty) !=
            (item.toolInvocationPolicy == AIToolInvocationPolicyV2.none) ||
        (legacy && item.allowedToolIds.isNotEmpty)) {
      throw ArgumentError('AI Capability definition is invalid.');
    }
  }
}

Map<String, dynamic> _legacyDefinitionJson(AICapabilityDefinitionV2 item) => {
      'schemaVersion': 1,
      'capabilityId': item.capabilityId,
      'capabilityContractVersion': item.capabilityContractVersion,
      'minimumAIContractVersion': item.minimumAIContractVersion,
      'requiredRuntimeContracts': _orderedInts(item.requiredRuntimeContracts),
      'compatibilityRules': _orderedStrings(item.compatibilityRules),
    };

Map<String, int> _orderedInts(Map<String, int> values) => {
      for (final key in values.keys.toList()..sort()) key: values[key]!,
    };

Map<String, String> _orderedStrings(Map<String, String> values) => {
      for (final key in values.keys.toList()..sort()) key: values[key]!,
    };

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();

bool _sameList(List<String> left, List<String> right) {
  if (left.length != right.length) return false;
  for (var index = 0; index < left.length; index++) {
    if (left[index] != right[index]) return false;
  }
  return true;
}
