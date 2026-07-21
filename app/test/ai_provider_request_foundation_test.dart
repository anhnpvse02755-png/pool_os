import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/ai_provider_contracts.dart';
import 'package:pool_os/contracts/ai_provider_request_contracts.dart';
import 'package:pool_os/contracts/ai_session_contracts.dart';
import 'package:pool_os/contracts/coach_response_contracts.dart';
import 'package:pool_os/contracts/tool_invocation_contracts.dart';
import 'package:pool_os/contracts/ai_capability_registry_v2_contracts.dart';

void main() {
  late AISessionContract session;
  late CoachAIRequestEnvelope envelope;
  late ToolInvocationPlanContract plan;

  setUp(() {
    session = _session();
    envelope = _envelope(session);
    plan = _plan(session.digest);
  });

  test('builder creates the authoritative provider request binding', () {
    final request = const AIProviderRequestBuilder().build(
      invocationPlan: plan,
      providerPayload: envelope,
    );

    expect(request.providerPayloadDigest, envelope.digest);
    expect(request.providerRequestDigest, isNot(envelope.digest));
    expect(request.invocationPlanDigest, plan.digest);
    expect(request.sessionDigest, session.digest);
    expect(request.capabilityId, 'chat_generation');
  });

  test('same inputs replay to the same JSON and both digests', () {
    const builder = AIProviderRequestBuilder();
    final first =
        builder.build(invocationPlan: plan, providerPayload: envelope);
    final second =
        builder.build(invocationPlan: plan, providerPayload: envelope);

    expect(second.providerPayloadDigest, first.providerPayloadDigest);
    expect(second.providerRequestDigest, first.providerRequestDigest);
    expect(second.toJson(), first.toJson());
  });

  test('provider result binds only the nested provider payload digest', () {
    final request = const AIProviderRequestBuilder().build(
      invocationPlan: plan,
      providerPayload: envelope,
    );
    final result = const DeterministicStubAIProvider().invoke(envelope);

    expect(result.requestDigest, request.providerPayloadDigest);
    expect(result.requestDigest, isNot(request.providerRequestDigest));
  });

  test('stale session and mixed invocation provenance fail closed', () {
    final staleEnvelope = _envelope(_session(contextId: 'context.stale'));
    expect(
      () => const AIProviderRequestBuilder().build(
        invocationPlan: plan,
        providerPayload: staleEnvelope,
      ),
      throwsArgumentError,
    );
    expect(
      () => AIProviderRequestContract.create(
        invocationPlan: _mixedPlan(session.digest),
        providerPayload: envelope,
      ),
      throwsArgumentError,
    );
  });

  test('builder does not mutate plan or provider payload', () {
    final beforePlan = jsonEncode(plan.toJson());
    final beforeEnvelope = jsonEncode(envelope.toJson());
    const AIProviderRequestBuilder().build(
      invocationPlan: plan,
      providerPayload: envelope,
    );

    expect(jsonEncode(plan.toJson()), beforePlan);
    expect(jsonEncode(envelope.toJson()), beforeEnvelope);
  });

  test('request remains provider-neutral outside nested payload identity', () {
    final request = const AIProviderRequestBuilder().build(
      invocationPlan: plan,
      providerPayload: envelope,
    );
    final encoded = jsonEncode(request.toJson());

    expect(encoded, isNot(contains('prompt')));
    expect(encoded, isNot(contains('response')));
    expect(encoded, isNot(contains('toolResult')));
  });
}

ToolInvocationPlanContract _plan(String sessionDigest) {
  final item = _invocation(sessionDigest, 'chat_generation', 'tool.knowledge');
  return ToolInvocationPlanContract.create(
    renderingDigest: 'rendering.digest',
    registryDigest: 'registry.digest',
    invocations: [item],
  );
}

ToolInvocationPlanContract _mixedPlan(String sessionDigest) {
  return ToolInvocationPlanContract.create(
    renderingDigest: 'rendering.digest',
    registryDigest: 'registry.digest',
    invocations: [
      _invocation(sessionDigest, 'chat_generation', 'tool.knowledge'),
      _invocation(sessionDigest, 'shot_analysis', 'tool.vision'),
    ],
  );
}

ToolInvocationContract _invocation(
  String sessionDigest,
  String capabilityId,
  String toolId,
) =>
    ToolInvocationContract.create(
      capabilityId: capabilityId,
      toolId: toolId,
      invocationReason: AIToolInvocationPolicyV2.knowledgeLookup,
      renderingDigest: 'rendering.digest',
      sessionDigest: sessionDigest,
      registryDigest: 'registry.digest',
      metadata: const {'policy': 'knowledgeLookup'},
    );

CoachAIRequestEnvelope _envelope(AISessionContract session) =>
    CoachAIRequestEnvelope.create(
      session: session,
      providerId: 'stub/deterministic',
      providerContractVersion: 'stub-provider/1.0.0',
    );

AISessionContract _session({String contextId = 'context.provider-request'}) =>
    AISessionContract.create(
      contextId: contextId,
      planId: 'plan.provider-request',
      recommendationId: 'recommendation.provider-request',
      executionId: 'execution.provider-request',
      knowledgeVersion: 'knowledge.provider-request/1',
      knowledgeDigest: 'knowledge-provider-request-digest',
      contextDigest: 'context-provider-request-digest',
      planDigest: 'plan-provider-request-digest',
      recommendationDigest: 'recommendation-provider-request-digest',
      executionDigest: 'execution-provider-request-digest',
      provenance: const AISessionProvenance(
        knowledgeVersion: 'knowledge.provider-request/1',
        knowledgeDigest: 'knowledge-provider-request-digest',
        contextDigest: 'context-provider-request-digest',
        planDigest: 'plan-provider-request-digest',
        recommendationDigest: 'recommendation-provider-request-digest',
        executionDigest: 'execution-provider-request-digest',
      ),
      requiredRuntimeContracts: requiredAISessionRuntimeContracts,
      minimumAIContractVersion: minimumAIContractVersion,
    );
