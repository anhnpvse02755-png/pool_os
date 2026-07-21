import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/ai_capability_registry_v2_contracts.dart';
import 'package:pool_os/contracts/ai_conversation_memory_contracts.dart';
import 'package:pool_os/contracts/ai_observability_projection_contracts.dart';
import 'package:pool_os/contracts/ai_provider_contracts.dart';
import 'package:pool_os/contracts/ai_provider_request_v2_contracts.dart';
import 'package:pool_os/contracts/ai_response_processing_v2_contracts.dart';
import 'package:pool_os/contracts/ai_session_contracts.dart';
import 'package:pool_os/contracts/ai_tool_result_projection_contracts.dart';
import 'package:pool_os/contracts/coach_response_contracts.dart';
import 'package:pool_os/contracts/prompt_assembly_contracts.dart';
import 'package:pool_os/contracts/prompt_rendering_contracts.dart';
import 'package:pool_os/contracts/tool_invocation_contracts.dart';

void main() {
  test('projects the complete deterministic AI stage chain', () {
    final fixture = _fixture();
    final projection = fixture.project();

    expect(projection.stages.map((item) => item.stage), [
      'session',
      'assembly',
      'rendering',
      'invocationPlan',
      'providerRequest',
      'providerResult',
      'responseProcessing',
      'conversationMemory',
      'toolResultProjection',
    ]);
    expect(projection.stages.map((item) => item.position),
        [1, 2, 3, 4, 5, 6, 7, 8, 9]);
  });

  test('same public contracts replay to the same JSON and digest', () {
    final fixture = _fixture();
    final first = fixture.project();
    final second = fixture.project();

    expect(second.digest, first.digest);
    expect(second.toJson(), first.toJson());
  });

  test('foreign session or broken rendering chain fails closed', () {
    final fixture = _fixture();
    final foreign = _fixture('foreign');
    expect(
      () => fixture.project(session: foreign.session),
      throwsArgumentError,
    );
    expect(
      () => fixture.project(rendering: foreign.rendering),
      throwsArgumentError,
    );
  });

  test('foreign memory or tool projection fails closed', () {
    final fixture = _fixture();
    final foreign = _fixture('foreign');
    expect(() => fixture.project(memory: foreign.memory), throwsArgumentError);
    expect(() => fixture.project(toolProjection: foreign.toolProjection),
        throwsArgumentError);
  });

  test('projection is immutable and contains no runtime observability data',
      () {
    final projection = _fixture().project();
    expect(() => projection.stages.add(projection.stages.first),
        throwsUnsupportedError);
    final encoded = jsonEncode(projection.toJson());
    expect(encoded, isNot(contains('promptText')));
    expect(encoded, isNot(contains('latency')));
    expect(encoded, isNot(contains('tokenCount')));
    expect(encoded, isNot(contains('cost')));
    expect(encoded, isNot(contains('providerLog')));
  });
}

_Fixture _fixture([String suffix = 'main']) {
  final session = _session(suffix);
  final registry = AICapabilityRegistryV2Contract.create(
    aiContractVersion: 1,
    minimumSupportedAIContractVersion: minimumAIContractVersion,
    capabilities: const [
      AICapabilityDefinitionV2(
        capabilityId: 'chat_generation',
        capabilityContractVersion: 1,
        minimumAIContractVersion: minimumAIContractVersion,
        requiredRuntimeContracts: requiredAISessionRuntimeContracts,
        compatibilityRules: {'mode': 'structured-only'},
        allowedToolIds: ['tool.knowledge'],
        defaultToolId: 'tool.knowledge',
        toolInvocationPolicy: AIToolInvocationPolicyV2.knowledgeLookup,
      ),
    ],
  );
  final assembly = PromptAssemblyContract.create(
    capabilityId: 'chat_generation',
    sessionDigest: session.digest,
    registryDigest: registry.digest,
    contextDigest: session.contextDigest,
    planningDigest: session.planDigest,
    recommendationDigest: session.recommendationDigest,
    adaptationDigest: 'adaptation.$suffix',
    contextId: session.contextId,
    planId: session.planId,
    recommendationId: session.recommendationId,
    executionId: session.executionId,
    planningNodeIds: const [],
    recommendationIds: const [],
    executionIds: const [],
    adaptationIds: const [],
    metadata: const {'locale': 'en'},
  );
  final rendering = const PromptRenderer().render(assembly);
  final invocationPlan = const ToolInvocationPlanner().plan(
    rendering: rendering,
    registry: registry,
  );
  final envelope = CoachAIRequestEnvelope.create(
    session: session,
    providerId: 'stub/deterministic',
    providerContractVersion: 'stub-provider/1.0.0',
  );
  final providerRequest = AIProviderRequestV2Contract.create(
    invocationPlan: invocationPlan,
    providerPayload: envelope,
  );
  final providerResult = const DeterministicStubAIProvider().invoke(envelope);
  final processing = AIResponseProcessingV2Contract.create(
    request: providerRequest,
    result: providerResult,
  );
  final memory =
      AIConversationMemoryContract.create([processing.baseProcessing]);
  final toolProjection = AIToolResultProjectionContract.create([processing]);
  return _Fixture(
    session,
    assembly,
    rendering,
    invocationPlan,
    providerRequest,
    providerResult,
    processing,
    memory,
    toolProjection,
  );
}

AISessionContract _session(String suffix) => AISessionContract.create(
      contextId: 'context.$suffix',
      planId: 'plan.$suffix',
      recommendationId: 'recommendation.$suffix',
      executionId: 'execution.$suffix',
      knowledgeVersion: 'knowledge.observability/1',
      knowledgeDigest: 'knowledge-observability-digest',
      contextDigest: 'context-observability-digest',
      planDigest: 'plan-observability-digest',
      recommendationDigest: 'recommendation-observability-digest',
      executionDigest: 'execution-observability-digest',
      provenance: const AISessionProvenance(
        knowledgeVersion: 'knowledge.observability/1',
        knowledgeDigest: 'knowledge-observability-digest',
        contextDigest: 'context-observability-digest',
        planDigest: 'plan-observability-digest',
        recommendationDigest: 'recommendation-observability-digest',
        executionDigest: 'execution-observability-digest',
      ),
      requiredRuntimeContracts: requiredAISessionRuntimeContracts,
      minimumAIContractVersion: minimumAIContractVersion,
    );

class _Fixture {
  const _Fixture(
    this.session,
    this.assembly,
    this.rendering,
    this.invocationPlan,
    this.providerRequest,
    this.providerResult,
    this.processing,
    this.memory,
    this.toolProjection,
  );

  final AISessionContract session;
  final PromptAssemblyContract assembly;
  final PromptRenderingContract rendering;
  final ToolInvocationPlanContract invocationPlan;
  final AIProviderRequestV2Contract providerRequest;
  final AIProviderResult providerResult;
  final AIResponseProcessingV2Contract processing;
  final AIConversationMemoryContract memory;
  final AIToolResultProjectionContract toolProjection;

  AIObservabilityProjectionContract project({
    AISessionContract? session,
    PromptRenderingContract? rendering,
    AIConversationMemoryContract? memory,
    AIToolResultProjectionContract? toolProjection,
  }) =>
      const AIObservabilityProjector().project(
        session: session ?? this.session,
        assembly: assembly,
        rendering: rendering ?? this.rendering,
        invocationPlan: invocationPlan,
        providerRequest: providerRequest,
        providerResult: providerResult,
        processing: processing,
        memory: memory ?? this.memory,
        toolProjection: toolProjection ?? this.toolProjection,
      );
}
