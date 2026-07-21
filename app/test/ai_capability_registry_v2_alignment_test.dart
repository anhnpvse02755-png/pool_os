import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/ai_capability_registry_v2_contracts.dart';

void main() {
  test('Registry v2 canonicalizes and binds tool policy metadata', () {
    final first = _registry([
      _definition('chat_generation', const ['tool.search', 'tool.knowledge'],
          defaultTool: 'tool.knowledge'),
    ]);
    final second = _registry([
      _definition('chat_generation', const ['tool.knowledge', 'tool.search'],
          defaultTool: 'tool.knowledge'),
    ]);

    expect(first.digest, second.digest);
    expect(first.definitionFor('chat_generation').allowedToolIds,
        ['tool.knowledge', 'tool.search']);
    expect(
        first.definitionFor('chat_generation').defaultToolId, 'tool.knowledge');
    expect(first.toJson(),
        AICapabilityRegistryV2Contract.fromJson(first.toJson()).toJson());
  });

  test('Registry v2 fails closed for unsupported tool declarations', () {
    expect(
      () => _registry([
        _definition('chat_generation', const ['tool.search'],
            defaultTool: 'tool.other'),
      ]),
      throwsArgumentError,
    );
    expect(
      () => _registry([
        _definition('chat_generation', const ['tool.search', 'tool.search']),
      ]),
      throwsArgumentError,
    );
  });

  test('Registry v1 artifact remains readable without tool policy', () {
    final capability = {
      'schemaVersion': 1,
      'capabilityId': 'chat_generation',
      'capabilityContractVersion': 1,
      'minimumAIContractVersion': 'ai-session/1.0.0',
      'requiredRuntimeContracts': {'coachContext': 1},
      'compatibilityRules': {'mode': 'structured-only'},
    };
    final payload = {
      'schemaVersion': 1,
      'aiContractVersion': 1,
      'minimumSupportedAIContractVersion': 'ai-session/1.0.0',
      'capabilities': [capability],
      'policyVersion': 'ai-capability-registry/1.0.0',
    };
    final digest = sha256.convert(utf8.encode(jsonEncode(payload))).toString();
    final legacy = {
      ...payload,
      'id': 'ai-capability-registry.${digest.substring(0, 16)}',
      'digest': digest,
    };
    final restored = AICapabilityRegistryV2Contract.fromJson(legacy);

    expect(restored.toJson(), legacy);
    expect(restored.definitionFor('chat_generation').allowedToolIds, isEmpty);
  });

  test('Registry v2 rejects re-digested non-canonical tool order', () {
    final json = _registry([
      _definition('chat_generation', const ['tool.search', 'tool.knowledge']),
    ]).toJson();
    final definition = json['capabilities']![0] as Map<String, dynamic>;
    definition['allowedToolIds'] = ['tool.search', 'tool.knowledge'];
    final payload = {
      'schemaVersion': 2,
      'aiContractVersion': json['aiContractVersion'],
      'minimumSupportedAIContractVersion':
          json['minimumSupportedAIContractVersion'],
      'capabilities': json['capabilities'],
      'policyVersion': aiCapabilityRegistryV2PolicyVersion,
    };
    final digest = sha256.convert(utf8.encode(jsonEncode(payload))).toString();
    json['id'] = 'ai-capability-registry.${digest.substring(0, 16)}';
    json['digest'] = digest;
    expect(() => AICapabilityRegistryV2Contract.fromJson(json),
        throwsArgumentError);
  });
}

AICapabilityRegistryV2Contract _registry(
        List<AICapabilityDefinitionV2> capabilities) =>
    AICapabilityRegistryV2Contract.create(
      aiContractVersion: 1,
      minimumSupportedAIContractVersion: 'ai-session/1.0.0',
      capabilities: capabilities,
    );

AICapabilityDefinitionV2 _definition(String id, List<String> tools,
        {String? defaultTool}) =>
    AICapabilityDefinitionV2(
      capabilityId: id,
      capabilityContractVersion: 1,
      minimumAIContractVersion: 'ai-session/1.0.0',
      requiredRuntimeContracts: const {'coachContext': 1},
      compatibilityRules: const {'mode': 'structured-only'},
      allowedToolIds: List.unmodifiable([...tools]..sort()),
      defaultToolId: defaultTool ?? tools.first,
      toolInvocationPolicy: AIToolInvocationPolicyV2.knowledgeLookup,
    );
