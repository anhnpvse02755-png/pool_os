import 'dart:convert';

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
