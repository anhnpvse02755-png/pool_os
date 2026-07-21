import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/ai_capability_registry_v2_contracts.dart';
import 'package:pool_os/contracts/ai_provider_contracts.dart';
import 'package:pool_os/contracts/ai_provider_request_v2_contracts.dart';
import 'package:pool_os/contracts/ai_response_processing_v2_contracts.dart';
import 'package:pool_os/contracts/ai_session_contracts.dart';
import 'package:pool_os/contracts/coach_response_contracts.dart';
import 'package:pool_os/contracts/tool_invocation_contracts.dart';

void main() {
  test('Provider Request v2 copies tool identity from invocation only', () {
    final fixture = _fixture();
    final request = const AIProviderRequestV2Builder().build(
      invocationPlan: fixture.plan,
      providerPayload: fixture.envelope,
    );

    expect(request.toolId, 'tool.knowledge');
    expect(request.baseRequest.providerPayloadDigest, fixture.envelope.digest);
  });

  test('Response Processing v2 copies tool identity unchanged', () {
    final fixture = _fixture();
    final request = AIProviderRequestV2Contract.create(
      invocationPlan: fixture.plan,
      providerPayload: fixture.envelope,
    );
    final result = const DeterministicStubAIProvider().invoke(fixture.envelope);
    final processing = const AIResponseProcessorV2().process(
      request: request,
      result: result,
    );

    expect(processing.toolId, request.toolId);
    expect(processing.providerResultDigest, result.digest);
  });

  test('v2 replay is deterministic and v1 base identities remain unchanged',
      () {
    final fixture = _fixture();
    final first = AIProviderRequestV2Contract.create(
      invocationPlan: fixture.plan,
      providerPayload: fixture.envelope,
    );
    final second = AIProviderRequestV2Contract.create(
      invocationPlan: fixture.plan,
      providerPayload: fixture.envelope,
    );

    expect(second.toJson(), first.toJson());
    expect(second.baseRequest.providerRequestDigest,
        first.baseRequest.providerRequestDigest);
  });

  test('ambiguous tool provenance fails closed', () {
    final fixture = _fixture(mixedTools: true);
    expect(
      () => AIProviderRequestV2Contract.create(
        invocationPlan: fixture.plan,
        providerPayload: fixture.envelope,
      ),
      throwsArgumentError,
    );
  });

  test('stale Provider Result still fails at v2 processing boundary', () {
    final fixture = _fixture();
    final request = AIProviderRequestV2Contract.create(
      invocationPlan: fixture.plan,
      providerPayload: fixture.envelope,
    );
    final stale = _fixture(contextId: 'context.stale');
    final result = const DeterministicStubAIProvider().invoke(stale.envelope);

    expect(
      () => const AIResponseProcessorV2().process(
        request: request,
        result: result,
      ),
      throwsArgumentError,
    );
  });
}

_Fixture _fixture({
  bool mixedTools = false,
  String contextId = 'context.tool-v2',
}) {
  final session = _session(contextId);
  final envelope = CoachAIRequestEnvelope.create(
    session: session,
    providerId: 'stub/deterministic',
    providerContractVersion: 'stub-provider/1.0.0',
  );
  final invocations = [
    _invocation(session.digest, 'tool.knowledge'),
    if (mixedTools) _invocation(session.digest, 'tool.search'),
  ];
  return _Fixture(
    envelope,
    ToolInvocationPlanContract.create(
      renderingDigest: 'rendering.digest',
      registryDigest: 'registry.digest',
      invocations: invocations,
    ),
  );
}

ToolInvocationContract _invocation(String sessionDigest, String toolId) =>
    ToolInvocationContract.create(
      capabilityId: 'chat_generation',
      toolId: toolId,
      invocationReason: AIToolInvocationPolicyV2.knowledgeLookup,
      renderingDigest: 'rendering.digest',
      sessionDigest: sessionDigest,
      registryDigest: 'registry.digest',
      metadata: const {'policy': 'knowledgeLookup'},
    );

AISessionContract _session(String contextId) => AISessionContract.create(
      contextId: contextId,
      planId: 'plan.tool-v2',
      recommendationId: 'recommendation.tool-v2',
      executionId: 'execution.tool-v2',
      knowledgeVersion: 'knowledge.tool-v2/1',
      knowledgeDigest: 'knowledge-tool-v2-digest',
      contextDigest: 'context-tool-v2-digest',
      planDigest: 'plan-tool-v2-digest',
      recommendationDigest: 'recommendation-tool-v2-digest',
      executionDigest: 'execution-tool-v2-digest',
      provenance: const AISessionProvenance(
        knowledgeVersion: 'knowledge.tool-v2/1',
        knowledgeDigest: 'knowledge-tool-v2-digest',
        contextDigest: 'context-tool-v2-digest',
        planDigest: 'plan-tool-v2-digest',
        recommendationDigest: 'recommendation-tool-v2-digest',
        executionDigest: 'execution-tool-v2-digest',
      ),
      requiredRuntimeContracts: requiredAISessionRuntimeContracts,
      minimumAIContractVersion: minimumAIContractVersion,
    );

class _Fixture {
  const _Fixture(this.envelope, this.plan);

  final CoachAIRequestEnvelope envelope;
  final ToolInvocationPlanContract plan;
}
