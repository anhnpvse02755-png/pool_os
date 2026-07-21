import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/prompt_assembly_contracts.dart';
import 'package:pool_os/contracts/prompt_rendering_contracts.dart';

void main() {
  test('renderer creates structured provider-neutral sections only', () {
    final assembly = _assembly();
    final rendering = const PromptRenderer().render(assembly);
    expect(rendering.providerTarget, 'provider-neutral');
    expect(rendering.assemblyDigest, assembly.digest);
    expect(rendering.sections.map((section) => section.kind), [
      PromptRenderingSectionKind.variables,
      PromptRenderingSectionKind.orderedReferences,
      PromptRenderingSectionKind.systemBlock,
      PromptRenderingSectionKind.userBlock,
      PromptRenderingSectionKind.assistantContextBlock,
    ]);
    final json = jsonEncode(rendering.toJson());
    expect(json, isNot(contains('promptText')));
    expect(json, isNot(contains('http')));
    expect(json, isNot(contains('providerPayload')));
  });

  test('same Assembly replays to the same Rendering digest', () {
    final assembly = _assembly();
    const renderer = PromptRenderer();
    final first = renderer.render(assembly);
    final replay = renderer.render(assembly);
    expect(replay.digest, first.digest);
    expect(replay.renderedPayloadDigest, first.renderedPayloadDigest);
    expect(replay.toJson(), first.toJson());
  });

  test('invalid strategy, target, ordering, and duplicate sections fail loudly',
      () {
    final sections = _sections();
    expect(
      () => PromptRenderingContract.create(
        capabilityId: 'chat_generation',
        assemblyDigest: 'assembly',
        sessionDigest: 'session',
        registryDigest: 'registry',
        providerTarget: 'openai',
        strategy: PromptRenderingStrategy.structuredReferences,
        sections: sections,
      ),
      throwsArgumentError,
    );
    expect(
      () => PromptRenderingContract.create(
        capabilityId: 'chat_generation',
        assemblyDigest: 'assembly',
        sessionDigest: 'session',
        registryDigest: 'registry',
        providerTarget: 'provider-neutral',
        strategy: PromptRenderingStrategy.structuredReferences,
        sections: [sections[1], ...sections.skip(1)],
      ),
      throwsArgumentError,
    );
  });

  test('Rendering and section collections are immutable', () {
    final rendering = const PromptRenderer().render(_assembly());
    expect(() => rendering.sections.clear(), throwsUnsupportedError);
    expect(() => rendering.sections.first.referenceIds.clear(),
        throwsUnsupportedError);
  });

  test('v2 carries Assembly provenance and v1 artifacts remain readable', () {
    final assembly = _assembly();
    final rendering = const PromptRenderer().render(assembly);
    expect(rendering.schemaVersion, promptRenderingContractVersion);
    expect(rendering.sessionDigest, assembly.sessionDigest);
    expect(rendering.registryDigest, assembly.registryDigest);
    expect(PromptRenderingContract.fromJson(rendering.toJson()).toJson(),
        rendering.toJson());

    final legacy = _legacyRenderingJson();
    final restored = PromptRenderingContract.fromJson(legacy);
    expect(restored.schemaVersion, legacyPromptRenderingContractVersion);
    expect(restored.sessionDigest, isNull);
    expect(restored.registryDigest, isNull);
    expect(restored.toJson(), legacy);
  });
}

PromptAssemblyContract _assembly() => PromptAssemblyContract.create(
      capabilityId: 'chat_generation',
      sessionDigest: 'session-digest',
      registryDigest: 'registry-digest',
      contextDigest: 'context-digest',
      planningDigest: 'planning-digest',
      recommendationDigest: 'recommendation-digest',
      adaptationDigest: 'adaptation-digest',
      contextId: 'context-id',
      planId: 'plan-id',
      recommendationId: 'recommendation-id',
      executionId: 'execution-id',
      planningNodeIds: const ['node-a', 'node-b'],
      recommendationIds: const ['recommendation-id'],
      executionIds: const ['execution-id'],
      adaptationIds: const ['adaptation-id'],
      metadata: const {'locale': 'vi'},
    );

List<PromptRenderingSectionContract> _sections() => [
      for (var index = 0;
          index < PromptRenderingSectionKind.values.length;
          index++)
        PromptRenderingSectionContract(
          position: index + 1,
          kind: PromptRenderingSectionKind.values[index],
          referenceIds: ['reference-$index'],
          metadata: const {},
        ),
    ];

Map<String, dynamic> _legacyRenderingJson() {
  final sections = _sections();
  final payload = {
    'renderingVersion': promptRenderingVersion,
    'strategy': PromptRenderingStrategy.structuredReferences.name,
    'capabilityId': 'chat_generation',
    'assemblyDigest': 'legacy-assembly',
    'providerTarget': 'provider-neutral',
    'sections': sections.map((section) => section.toJson()).toList(),
    'policyVersion': promptRenderingPolicyVersion,
  };
  final payloadDigest =
      sha256.convert(utf8.encode(jsonEncode(payload))).toString();
  final digest = sha256
      .convert(utf8.encode(jsonEncode({
        ...payload,
        'renderedPayloadDigest': payloadDigest,
      })))
      .toString();
  return {
    'schemaVersion': legacyPromptRenderingContractVersion,
    'id': 'prompt-rendering.${digest.substring(0, 16)}',
    ...payload,
    'renderedPayloadDigest': payloadDigest,
    'digest': digest,
  };
}
