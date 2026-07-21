import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/ai_capability_registry_contracts.dart';
import 'package:pool_os/contracts/ai_provider_contracts.dart';
import 'package:pool_os/contracts/ai_session_contracts.dart';
import 'package:pool_os/contracts/coach_response_contracts.dart';
import 'package:pool_os/features/coach/application/coach_ai_adapter.dart';

void main() {
  late AISessionContract session;
  late AICapabilityRegistryContract registry;

  setUp(() {
    session = _session();
    registry = _registry();
  });

  test('provider accepts only request envelope and returns provenance', () {
    final request = const DeterministicStubAIAdapter().createRequest(
      session: session,
      registry: registry,
      capabilityId: 'chat_generation',
    );
    final result = const DeterministicStubAIProvider().invoke(request);

    expect(result.providerId, 'stub/deterministic');
    expect(result.requestDigest, request.digest);
    expect(result.status, AIProviderInvocationStatus.stubbed);
    expect(jsonEncode(result.toJson()), isNot(contains('sessionContext')));
  });

  test('same request produces deterministic provider result', () {
    final request = const DeterministicStubAIAdapter().createRequest(
      session: session,
      registry: registry,
      capabilityId: 'chat_generation',
    );
    const provider = DeterministicStubAIProvider();
    final first = provider.invoke(request);
    final second = provider.invoke(request);

    expect(second.digest, first.digest);
    expect(second.toJson(), first.toJson());
  });

  test('adapter delegates to an injected provider without exposing internals',
      () {
    final provider = _RecordingProvider();
    final adapter = DeterministicStubAIAdapter(provider: provider);
    final response = adapter.respond(
      session: session,
      registry: registry,
      capabilityId: 'chat_generation',
    );

    expect(provider.invocations, 1);
    expect(provider.lastRequestDigest, response.request.digest);
  });

  test('provider replacement changes only provider request identity', () {
    final first = const DeterministicStubAIAdapter(
      provider: DeterministicStubAIProvider(),
    ).createRequest(
      session: session,
      registry: registry,
      capabilityId: 'chat_generation',
    );
    final second = const DeterministicStubAIAdapter(
      provider: DeterministicStubAIProvider(
        providerId: 'stub/alternate',
        providerContractVersion: 'stub-provider/2.0.0',
      ),
    ).createRequest(
      session: session,
      registry: registry,
      capabilityId: 'chat_generation',
    );

    expect(second.providerId, 'stub/alternate');
    expect(second.sessionDigest, first.sessionDigest);
    expect(second.digest, isNot(first.digest));
  });

  test('provider rejects invalid identity and foreign request binding', () {
    expect(
      () => AIProviderResult.create(
        providerId: '',
        providerContractVersion: 'stub/1',
        request: _request(),
        status: AIProviderInvocationStatus.stubbed,
      ),
      throwsArgumentError,
    );
    expect(
      () => const DeterministicStubAIProvider().invoke(_request()),
      throwsArgumentError,
    );
  });

  test('adapter rejects a provider result bound to another request', () {
    final adapter = DeterministicStubAIAdapter(
      provider: _StaleResultProvider(),
    );

    expect(
      () => adapter.respond(
        session: session,
        registry: registry,
        capabilityId: 'chat_generation',
      ),
      throwsStateError,
    );
  });

  test('adapter/provider path remains structured and has no AI implementation',
      () {
    final response = const DeterministicStubAIAdapter().respond(
      session: session,
      registry: registry,
      capabilityId: 'chat_generation',
    );
    final encoded = jsonEncode(response.toJson());
    expect(encoded, isNot(contains('prompt')));
    expect(encoded, isNot(contains('prose')));
    expect(encoded, isNot(contains('embedding')));
    expect(encoded, isNot(contains('toolCall')));
  });
}

class _RecordingProvider implements AIProvider {
  int invocations = 0;
  String? lastRequestDigest;

  @override
  String get providerId => 'stub/recording';

  @override
  String get providerContractVersion => 'stub-provider/1.0.0';

  @override
  AIProviderResult invoke(CoachAIRequestEnvelope request) {
    invocations++;
    lastRequestDigest = request.digest;
    return AIProviderResult.create(
      providerId: providerId,
      providerContractVersion: providerContractVersion,
      request: request,
      status: AIProviderInvocationStatus.stubbed,
    );
  }
}

class _StaleResultProvider implements AIProvider {
  @override
  String get providerId => 'stub/stale';

  @override
  String get providerContractVersion => 'stub-provider/1.0.0';

  @override
  AIProviderResult invoke(CoachAIRequestEnvelope request) {
    final staleRequest = CoachAIRequestEnvelope.create(
      session: _session(contextId: 'context.stale'),
      providerId: providerId,
      providerContractVersion: providerContractVersion,
    );
    return AIProviderResult.create(
      providerId: providerId,
      providerContractVersion: providerContractVersion,
      request: staleRequest,
      status: AIProviderInvocationStatus.stubbed,
    );
  }
}

CoachAIRequestEnvelope _request() => CoachAIRequestEnvelope.create(
      session: _session(),
      providerId: 'stub/test',
      providerContractVersion: 'stub-provider/1.0.0',
    );

AICapabilityRegistryContract _registry() => AICapabilityRegistryContract.create(
      aiContractVersion: aiSessionContractVersion,
      minimumSupportedAIContractVersion: minimumAIContractVersion,
      capabilities: [
        const AICapabilityDefinition(
          capabilityId: 'chat_generation',
          capabilityContractVersion: 1,
          minimumAIContractVersion: minimumAIContractVersion,
          requiredRuntimeContracts: requiredAISessionRuntimeContracts,
          compatibilityRules: {'mode': 'structured-only'},
        ),
      ],
    );

AISessionContract _session({String contextId = 'context.provider'}) =>
    AISessionContract.create(
      contextId: contextId,
      planId: 'plan.provider',
      recommendationId: 'recommendation.provider',
      executionId: 'execution.provider',
      knowledgeVersion: 'knowledge.provider/1',
      knowledgeDigest: 'knowledge-provider-digest',
      contextDigest: 'context-provider-digest',
      planDigest: 'plan-provider-digest',
      recommendationDigest: 'recommendation-provider-digest',
      executionDigest: 'execution-provider-digest',
      provenance: const AISessionProvenance(
        knowledgeVersion: 'knowledge.provider/1',
        knowledgeDigest: 'knowledge-provider-digest',
        contextDigest: 'context-provider-digest',
        planDigest: 'plan-provider-digest',
        recommendationDigest: 'recommendation-provider-digest',
        executionDigest: 'execution-provider-digest',
      ),
      requiredRuntimeContracts: requiredAISessionRuntimeContracts,
      minimumAIContractVersion: minimumAIContractVersion,
    );
