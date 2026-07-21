import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/ai_capability_registry_contracts.dart';
import 'package:pool_os/contracts/ai_session_contracts.dart';
import 'package:pool_os/features/coach/application/coach_ai_adapter.dart';

void main() {
  late AISessionContract session;
  late AICapabilityRegistryContract registry;

  setUp(() {
    session = _session();
    registry = _registry();
  });

  test('registry is immutable, canonical, and deterministic', () {
    final reversed = AICapabilityRegistryContract.create(
      aiContractVersion: aiSessionContractVersion,
      minimumSupportedAIContractVersion: minimumAIContractVersion,
      capabilities: [
        _capability('shot_analysis'),
        _capability('chat_generation'),
      ],
    );

    expect(reversed.digest, registry.digest);
    expect(reversed.toJson(), registry.toJson());
    expect(registry.capabilities.map((item) => item.capabilityId), [
      'chat_generation',
      'shot_analysis',
    ]);
  });

  test('duplicate capability IDs fail loudly', () {
    expect(
      () => AICapabilityRegistryContract.create(
        aiContractVersion: aiSessionContractVersion,
        minimumSupportedAIContractVersion: minimumAIContractVersion,
        capabilities: [
          _capability('chat_generation'),
          _capability('chat_generation'),
        ],
      ),
      throwsArgumentError,
    );
  });

  test('registered capability resolves with deterministic binding', () {
    final first = registry.resolveForSession(
      session: session,
      capabilityId: 'chat_generation',
    );
    final second = registry.resolveForSession(
      session: session,
      capabilityId: 'chat_generation',
    );

    expect(first.capabilityId, 'chat_generation');
    expect(first.registryDigest, registry.digest);
    expect(second.digest, first.digest);
    expect(second.toJson(), first.toJson());
  });

  test('unknown capability is rejected', () {
    expect(
      () => registry.resolveForSession(
        session: session,
        capabilityId: 'training_plan',
      ),
      throwsStateError,
    );
  });

  test('registry rejects AI version and runtime compatibility mismatch', () {
    final wrongAI = _session(minimumVersion: 'ai-session/9.0.0');
    expect(
      () => registry.resolveForSession(
        session: wrongAI,
        capabilityId: 'chat_generation',
      ),
      throwsArgumentError,
    );
    final wrongRuntime = _session(runtime: {'coachContext': 99});
    expect(
      () => registry.resolveForSession(
        session: wrongRuntime,
        capabilityId: 'chat_generation',
      ),
      throwsArgumentError,
    );
  });

  test('adapter can only create a request for registered compatible capability',
      () {
    const adapter = DeterministicStubAIAdapter();
    expect(
      () => adapter.createRequest(
        session: session,
        registry: registry,
        capabilityId: 'training_plan',
      ),
      throwsStateError,
    );
    final request = adapter.createRequest(
      session: session,
      registry: registry,
      capabilityId: 'chat_generation',
    );
    expect(request.sessionDigest, session.digest);
  });

  test('adapter response remains deterministic after registry resolution', () {
    const adapter = DeterministicStubAIAdapter();
    final first = adapter.respond(
      session: session,
      registry: registry,
      capabilityId: 'chat_generation',
    );
    final second = adapter.respond(
      session: session,
      registry: registry,
      capabilityId: 'chat_generation',
    );

    expect(second.digest, first.digest);
    expect(second.toJson(), first.toJson());
  });

  test('registry and session inputs remain unchanged', () {
    const adapter = DeterministicStubAIAdapter();
    final beforeRegistry = jsonEncode(registry.toJson());
    final beforeSession = jsonEncode(session.toJson());
    adapter.respond(
      session: session,
      registry: registry,
      capabilityId: 'chat_generation',
    );
    expect(jsonEncode(registry.toJson()), beforeRegistry);
    expect(jsonEncode(session.toJson()), beforeSession);
  });
}

AICapabilityDefinition _capability(String id) => AICapabilityDefinition(
      capabilityId: id,
      capabilityContractVersion: 1,
      minimumAIContractVersion: minimumAIContractVersion,
      requiredRuntimeContracts: requiredAISessionRuntimeContracts,
      compatibilityRules: const {'mode': 'structured-only'},
    );

AICapabilityRegistryContract _registry() => AICapabilityRegistryContract.create(
      aiContractVersion: aiSessionContractVersion,
      minimumSupportedAIContractVersion: minimumAIContractVersion,
      capabilities: [
        _capability('chat_generation'),
        _capability('shot_analysis'),
      ],
    );

AISessionContract _session({
  String minimumVersion = minimumAIContractVersion,
  Map<String, int> runtime = requiredAISessionRuntimeContracts,
}) {
  const knowledgeVersion = 'knowledge.ai/1';
  const knowledgeDigest = 'knowledge-ai-digest';
  const contextDigest = 'context.ai';
  const planDigest = 'plan.ai';
  const recommendationDigest = 'recommendation-digest.ai';
  const executionDigest = 'execution-digest.ai';
  return AISessionContract.create(
    contextId: contextDigest,
    planId: 'plan.ai',
    recommendationId: 'recommendation.ai',
    executionId: 'execution.ai',
    knowledgeVersion: knowledgeVersion,
    knowledgeDigest: knowledgeDigest,
    contextDigest: contextDigest,
    planDigest: planDigest,
    recommendationDigest: recommendationDigest,
    executionDigest: executionDigest,
    provenance: const AISessionProvenance(
      knowledgeVersion: knowledgeVersion,
      knowledgeDigest: knowledgeDigest,
      contextDigest: contextDigest,
      planDigest: planDigest,
      recommendationDigest: recommendationDigest,
      executionDigest: executionDigest,
    ),
    requiredRuntimeContracts: runtime,
    minimumAIContractVersion: minimumVersion,
  );
}
