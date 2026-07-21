import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/ai_capability_registry_v2_contracts.dart';
import 'package:pool_os/contracts/ai_conversation_memory_contracts.dart';
import 'package:pool_os/contracts/ai_observability_projection_contracts.dart';
import 'package:pool_os/contracts/ai_production_activation_contracts.dart';
import 'package:pool_os/contracts/ai_provider_contracts.dart';
import 'package:pool_os/contracts/ai_provider_request_v2_contracts.dart';
import 'package:pool_os/contracts/ai_response_processing_v2_contracts.dart';
import 'package:pool_os/contracts/ai_runtime_activation_gate_contracts.dart';
import 'package:pool_os/contracts/ai_session_contracts.dart';
import 'package:pool_os/contracts/ai_tool_result_projection_contracts.dart';
import 'package:pool_os/contracts/coach_response_contracts.dart';
import 'package:pool_os/contracts/prompt_assembly_contracts.dart';
import 'package:pool_os/contracts/prompt_rendering_contracts.dart';
import 'package:pool_os/contracts/tool_invocation_contracts.dart';

void main() {
  test('activated gate and complete observability create activation proof', () {
    final observability = _observability();
    final activation = const AIProductionActivationProjector().project(
      gate: _gate(observability),
      observability: observability,
    );

    expect(activation.activationState, AIProductionActivationState.activated);
    expect(activation.sessionDigest, observability.sessionDigest);
    expect(activation.observabilityDigest, observability.digest);
  });

  test('same inputs replay to identical JSON and digest', () {
    final observability = _observability();
    final gate = _gate(observability);
    const projector = AIProductionActivationProjector();
    final first = projector.project(gate: gate, observability: observability);
    final second = projector.project(gate: gate, observability: observability);
    expect(second.digest, first.digest);
    expect(second.toJson(), first.toJson());
  });

  test('inactive or duplicate gate fails closed', () {
    final observability = _observability();
    for (final reason in [
      AIRuntimeActivationReason.contractMismatch,
      AIRuntimeActivationReason.duplicateActivation,
    ]) {
      final gate = AIRuntimeActivationGateContract.create(
        decision: AIRuntimeActivationDecision.notActivated,
        reason: reason,
        sessionDigest: observability.sessionDigest,
        adaptationDigest: 'adaptation.digest',
        registryDigest: 'registry.digest',
        capabilityId: observability.capabilityId,
        activationKey: 'activation.key',
      );
      expect(
        () => const AIProductionActivationProjector().project(
          gate: gate,
          observability: observability,
        ),
        throwsArgumentError,
      );
    }
  });

  test('foreign session or capability fails closed', () {
    final observability = _observability();
    expect(
      () => const AIProductionActivationProjector().project(
        gate: _gate(observability, sessionDigest: 'foreign'),
        observability: observability,
      ),
      throwsArgumentError,
    );
    expect(
      () => const AIProductionActivationProjector().project(
        gate: _gate(observability, capabilityId: 'foreign'),
        observability: observability,
      ),
      throwsArgumentError,
    );
  });

  test('activation proof contains no runtime integration data', () {
    final observability = _observability();
    final encoded = jsonEncode(
      AIProductionActivationContract.create(
        gate: _gate(observability),
        observability: observability,
      ).toJson(),
    );
    expect(encoded, isNot(contains('credential')));
    expect(encoded, isNot(contains('apiKey')));
    expect(encoded, isNot(contains('providerCall')));
    expect(encoded, isNot(contains('http')));
    expect(encoded, isNot(contains('stream')));
  });
}

AIRuntimeActivationGateContract _gate(
  AIObservabilityProjectionContract observability, {
  String? sessionDigest,
  String? capabilityId,
}) =>
    AIRuntimeActivationGateContract.create(
      decision: AIRuntimeActivationDecision.activated,
      reason: AIRuntimeActivationReason.activated,
      sessionDigest: sessionDigest ?? observability.sessionDigest,
      adaptationDigest: 'adaptation.digest',
      registryDigest: 'registry.digest',
      capabilityId: capabilityId ?? observability.capabilityId,
      activationKey: 'activation.key',
    );

AIObservabilityProjectionContract _observability() {
  final session = _session();
  final registry = AICapabilityRegistryV2Contract.create(
    aiContractVersion: 1,
    minimumSupportedAIContractVersion: minimumAIContractVersion,
    capabilities: const [
      AICapabilityDefinitionV2(
        capabilityId: 'chat_generation',
        capabilityContractVersion: 1,
        minimumAIContractVersion: minimumAIContractVersion,
        requiredRuntimeContracts: requiredAISessionRuntimeContracts,
        compatibilityRules: {},
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
    adaptationDigest: 'adaptation.digest',
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
  final plan = const ToolInvocationPlanner().plan(
    rendering: rendering,
    registry: registry,
  );
  final envelope = CoachAIRequestEnvelope.create(
    session: session,
    providerId: 'stub/deterministic',
    providerContractVersion: 'stub-provider/1.0.0',
  );
  final request = AIProviderRequestV2Contract.create(
    invocationPlan: plan,
    providerPayload: envelope,
  );
  final result = const DeterministicStubAIProvider().invoke(envelope);
  final processing = AIResponseProcessingV2Contract.create(
    request: request,
    result: result,
  );
  final memory =
      AIConversationMemoryContract.create([processing.baseProcessing]);
  final tools = AIToolResultProjectionContract.create([processing]);
  return AIObservabilityProjectionContract.create(
    session: session,
    assembly: assembly,
    rendering: rendering,
    invocationPlan: plan,
    providerRequest: request,
    providerResult: result,
    processing: processing,
    memory: memory,
    toolProjection: tools,
  );
}

AISessionContract _session() => AISessionContract.create(
      contextId: 'context.activation',
      planId: 'plan.activation',
      recommendationId: 'recommendation.activation',
      executionId: 'execution.activation',
      knowledgeVersion: 'knowledge.activation/1',
      knowledgeDigest: 'knowledge-activation-digest',
      contextDigest: 'context-activation-digest',
      planDigest: 'plan-activation-digest',
      recommendationDigest: 'recommendation-activation-digest',
      executionDigest: 'execution-activation-digest',
      provenance: const AISessionProvenance(
        knowledgeVersion: 'knowledge.activation/1',
        knowledgeDigest: 'knowledge-activation-digest',
        contextDigest: 'context-activation-digest',
        planDigest: 'plan-activation-digest',
        recommendationDigest: 'recommendation-activation-digest',
        executionDigest: 'execution-activation-digest',
      ),
      requiredRuntimeContracts: requiredAISessionRuntimeContracts,
      minimumAIContractVersion: minimumAIContractVersion,
    );
