import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/ai_capability_registry_v2_contracts.dart';
import 'package:pool_os/contracts/ai_provider_contracts.dart';
import 'package:pool_os/contracts/ai_provider_request_contracts.dart';
import 'package:pool_os/contracts/ai_response_processing_contracts.dart';
import 'package:pool_os/contracts/ai_session_contracts.dart';
import 'package:pool_os/contracts/coach_response_contracts.dart';
import 'package:pool_os/contracts/tool_invocation_contracts.dart';

void main() {
  late AIProviderRequestContract request;
  late AIProviderResult result;

  setUp(() {
    final session = _session();
    final envelope = _envelope(session);
    request = AIProviderRequestContract.create(
      invocationPlan: _plan(session.digest),
      providerPayload: envelope,
    );
    result = const DeterministicStubAIProvider().invoke(envelope);
  });

  test('processor creates a provider-neutral provenance-bound projection', () {
    final processed = const AIResponseProcessor().process(
      request: request,
      result: result,
    );

    expect(processed.providerPayloadDigest, request.providerPayloadDigest);
    expect(processed.providerRequestDigest, request.providerRequestDigest);
    expect(processed.providerResultDigest, result.digest);
    expect(processed.capabilityId, 'chat_generation');
    expect(processed.processingMetadata['status'], 'stubbed');
  });

  test('same inputs replay to the same JSON and processing digest', () {
    const processor = AIResponseProcessor();
    final first = processor.process(request: request, result: result);
    final second = processor.process(request: request, result: result);

    expect(second.processingDigest, first.processingDigest);
    expect(second.toJson(), first.toJson());
  });

  test('stale provider result fails closed', () {
    final staleEnvelope = _envelope(_session(contextId: 'context.stale'));
    final staleResult =
        const DeterministicStubAIProvider().invoke(staleEnvelope);

    expect(
      () => const AIResponseProcessor().process(
        request: request,
        result: staleResult,
      ),
      throwsArgumentError,
    );
  });

  test('provider identity mismatch fails closed', () {
    final foreignEnvelope = CoachAIRequestEnvelope.create(
      session: _session(),
      providerId: 'stub/foreign',
      providerContractVersion: 'stub-provider/2.0.0',
    );
    final foreign = const DeterministicStubAIProvider(
      providerId: 'stub/foreign',
      providerContractVersion: 'stub-provider/2.0.0',
    ).invoke(foreignEnvelope);

    expect(
      () => const AIResponseProcessor().process(
        request: request,
        result: foreign,
      ),
      throwsArgumentError,
    );
  });

  test('processing metadata is immutable and invalid contracts fail closed',
      () {
    final processed = const AIResponseProcessor().process(
      request: request,
      result: result,
    );
    expect(
        () => processed.processingMetadata['x'] = 'y', throwsUnsupportedError);
    expect(
      () => AIResponseProcessingContract.create(
        providerPayloadDigest: '',
        providerRequestDigest: request.providerRequestDigest,
        providerResultDigest: result.digest,
        capabilityId: request.capabilityId,
        processingMetadata: const {'status': 'stubbed'},
      ),
      throwsArgumentError,
    );
  });

  test('processor remains structured and does not mutate inputs', () {
    final beforeRequest = jsonEncode(request.toJson());
    final beforeResult = jsonEncode(result.toJson());
    final processed = const AIResponseProcessor().process(
      request: request,
      result: result,
    );
    final encoded = jsonEncode(processed.toJson());

    expect(jsonEncode(request.toJson()), beforeRequest);
    expect(jsonEncode(result.toJson()), beforeResult);
    expect(encoded, isNot(contains('prose')));
    expect(encoded, isNot(contains('recommendation')));
    expect(encoded, isNot(contains('score')));
  });
}

ToolInvocationPlanContract _plan(String sessionDigest) {
  final invocation = ToolInvocationContract.create(
    capabilityId: 'chat_generation',
    toolId: 'tool.knowledge',
    invocationReason: AIToolInvocationPolicyV2.knowledgeLookup,
    renderingDigest: 'rendering.digest',
    sessionDigest: sessionDigest,
    registryDigest: 'registry.digest',
    metadata: const {'policy': 'knowledgeLookup'},
  );
  return ToolInvocationPlanContract.create(
    renderingDigest: 'rendering.digest',
    registryDigest: 'registry.digest',
    invocations: [invocation],
  );
}

CoachAIRequestEnvelope _envelope(AISessionContract session) =>
    CoachAIRequestEnvelope.create(
      session: session,
      providerId: 'stub/deterministic',
      providerContractVersion: 'stub-provider/1.0.0',
    );

AISessionContract _session({String contextId = 'context.processing'}) =>
    AISessionContract.create(
      contextId: contextId,
      planId: 'plan.processing',
      recommendationId: 'recommendation.processing',
      executionId: 'execution.processing',
      knowledgeVersion: 'knowledge.processing/1',
      knowledgeDigest: 'knowledge-processing-digest',
      contextDigest: 'context-processing-digest',
      planDigest: 'plan-processing-digest',
      recommendationDigest: 'recommendation-processing-digest',
      executionDigest: 'execution-processing-digest',
      provenance: const AISessionProvenance(
        knowledgeVersion: 'knowledge.processing/1',
        knowledgeDigest: 'knowledge-processing-digest',
        contextDigest: 'context-processing-digest',
        planDigest: 'plan-processing-digest',
        recommendationDigest: 'recommendation-processing-digest',
        executionDigest: 'execution-processing-digest',
      ),
      requiredRuntimeContracts: requiredAISessionRuntimeContracts,
      minimumAIContractVersion: minimumAIContractVersion,
    );
