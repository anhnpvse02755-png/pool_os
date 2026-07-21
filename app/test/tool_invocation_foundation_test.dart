import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/ai_capability_registry_v2_contracts.dart';
import 'package:pool_os/contracts/prompt_rendering_contracts.dart';
import 'package:pool_os/contracts/tool_invocation_contracts.dart';

void main() {
  late PromptRenderingContract rendering;
  late AICapabilityRegistryV2Contract registry;

  setUp(() {
    registry = _registry();
    rendering = _rendering(registry.digest);
  });

  test('planner creates a deterministic registry-bound invocation plan', () {
    const planner = ToolInvocationPlanner();
    final plan = planner.plan(rendering: rendering, registry: registry);

    expect(plan.invocations, hasLength(1));
    expect(plan.invocations.single.toolId, 'tool.knowledge');
    expect(plan.invocations.single.invocationReason,
        AIToolInvocationPolicyV2.knowledgeLookup);
    expect(plan.renderingDigest, rendering.digest);
    expect(plan.registryDigest, registry.digest);
  });

  test('replay and input ordering produce the same plan digest', () {
    const planner = ToolInvocationPlanner();
    final first = planner.plan(rendering: rendering, registry: registry);
    final second = planner.plan(
      rendering: _rendering(registry.digest),
      registry: _registry(reverse: true),
    );

    expect(second.digest, first.digest);
    expect(second.toJson(), first.toJson());
  });

  test('planner rejects stale rendering or registry provenance', () {
    const planner = ToolInvocationPlanner();
    expect(
      () => planner.plan(
        rendering: _rendering('stale-registry'),
        registry: registry,
      ),
      throwsArgumentError,
    );
    expect(
      () => planner.plan(
        rendering: rendering,
        registry: _registry(registryIdSalt: 'other'),
      ),
      throwsArgumentError,
    );
  });

  test('planner rejects unregistered capability and missing default tool', () {
    const planner = ToolInvocationPlanner();
    expect(
      () => planner.plan(
        rendering: _rendering(registry.digest, capabilityId: 'unknown'),
        registry: registry,
      ),
      throwsStateError,
    );
    final noDefault = _registry(noDefault: true);
    expect(
      () => planner.plan(
        rendering: _rendering(noDefault.digest),
        registry: noDefault,
      ),
      throwsStateError,
    );
  });

  test('legacy rendering cannot cross the v2 planner boundary', () {
    const planner = ToolInvocationPlanner();
    final legacy = PromptRenderingContract.fromJson(
      _legacyRenderingJson(),
    );
    expect(
      () => planner.plan(rendering: legacy, registry: registry),
      throwsArgumentError,
    );
  });

  test('invocation and plan collections are immutable', () {
    const planner = ToolInvocationPlanner();
    final plan = planner.plan(rendering: rendering, registry: registry);
    expect(() => plan.invocations.add(plan.invocations.single),
        throwsUnsupportedError);
    expect(() => plan.invocations.single.metadata['x'] = 'y',
        throwsUnsupportedError);
  });

  test('plan rejects duplicate or mismatched invocation bindings', () {
    final item = ToolInvocationContract.create(
      capabilityId: 'chat_generation',
      toolId: 'tool.knowledge',
      invocationReason: AIToolInvocationPolicyV2.knowledgeLookup,
      renderingDigest: rendering.digest,
      sessionDigest: rendering.sessionDigest!,
      registryDigest: registry.digest,
      metadata: const {'policy': 'knowledgeLookup'},
    );
    expect(
      () => ToolInvocationPlanContract.create(
        renderingDigest: rendering.digest,
        registryDigest: registry.digest,
        invocations: [item, item],
      ),
      throwsArgumentError,
    );
    expect(
      () => ToolInvocationPlanContract.create(
        renderingDigest: 'other',
        registryDigest: registry.digest,
        invocations: [item],
      ),
      throwsArgumentError,
    );
  });
}

AICapabilityRegistryV2Contract _registry({
  bool reverse = false,
  bool noDefault = false,
  String registryIdSalt = '',
}) {
  final tools = reverse
      ? const ['tool.search', 'tool.knowledge']
      : const ['tool.knowledge', 'tool.search'];
  return AICapabilityRegistryV2Contract.create(
    aiContractVersion: 1,
    minimumSupportedAIContractVersion: 'ai-session/1.0.0',
    capabilities: [
      AICapabilityDefinitionV2(
        capabilityId: 'chat_generation',
        capabilityContractVersion: 1,
        minimumAIContractVersion: 'ai-session/1.0.0',
        requiredRuntimeContracts: const {'coachContext': 1},
        compatibilityRules: const {'mode': 'structured-only'},
        allowedToolIds: List.unmodifiable([...tools]..sort()),
        defaultToolId: noDefault ? null : 'tool.knowledge',
        toolInvocationPolicy: AIToolInvocationPolicyV2.knowledgeLookup,
      ),
      if (registryIdSalt.isNotEmpty)
        const AICapabilityDefinitionV2(
          capabilityId: 'other',
          capabilityContractVersion: 1,
          minimumAIContractVersion: 'ai-session/1.0.0',
          requiredRuntimeContracts: {'coachContext': 1},
          compatibilityRules: {'salt': 'other'},
          allowedToolIds: ['tool.other'],
          defaultToolId: 'tool.other',
          toolInvocationPolicy: AIToolInvocationPolicyV2.externalSearch,
        ),
    ],
  );
}

PromptRenderingContract _rendering(String registryDigest,
        {String capabilityId = 'chat_generation'}) =>
    PromptRenderingContract.create(
      capabilityId: capabilityId,
      assemblyDigest: 'assembly.digest',
      sessionDigest: 'session.digest',
      registryDigest: registryDigest,
      providerTarget: 'provider-neutral',
      strategy: PromptRenderingStrategy.structuredReferences,
      sections: [
        for (var index = 0;
            index < PromptRenderingSectionKind.values.length;
            index++)
          PromptRenderingSectionContract(
            position: index + 1,
            kind: PromptRenderingSectionKind.values[index],
            referenceIds: const [],
            metadata: const {},
          ),
      ],
    );

Map<String, dynamic> _legacyRenderingJson() {
  final sections = [
    for (var index = 0;
        index < PromptRenderingSectionKind.values.length;
        index++)
      PromptRenderingSectionContract(
        position: index + 1,
        kind: PromptRenderingSectionKind.values[index],
        referenceIds: const [],
        metadata: const {},
      ).toJson(),
  ];
  final payload = {
    'renderingVersion': promptRenderingVersion,
    'strategy': PromptRenderingStrategy.structuredReferences.name,
    'capabilityId': 'chat_generation',
    'assemblyDigest': 'assembly.digest',
    'providerTarget': 'provider-neutral',
    'sections': sections,
    'policyVersion': promptRenderingPolicyVersion,
  };
  final payloadDigest =
      sha256.convert(utf8.encode(jsonEncode(payload))).toString();
  final digest = sha256
      .convert(utf8.encode(
          jsonEncode({...payload, 'renderedPayloadDigest': payloadDigest})))
      .toString();
  return {
    ...payload,
    'schemaVersion': legacyPromptRenderingContractVersion,
    'id': 'prompt-rendering.${digest.substring(0, 16)}',
    'renderedPayloadDigest': payloadDigest,
    'digest': digest,
  };
}
