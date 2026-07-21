import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/ai_capability_registry_v2_contracts.dart';
import 'package:pool_os/contracts/ai_provider_contracts.dart';
import 'package:pool_os/contracts/ai_provider_request_v2_contracts.dart';
import 'package:pool_os/contracts/ai_response_processing_v2_contracts.dart';
import 'package:pool_os/contracts/ai_session_contracts.dart';
import 'package:pool_os/contracts/ai_tool_result_projection_contracts.dart';
import 'package:pool_os/contracts/coach_response_contracts.dart';
import 'package:pool_os/contracts/tool_invocation_contracts.dart';

void main() {
  test('projects canonical tool result references from processing v2 only', () {
    final projection = const AIToolResultProjector().project([
      _processing('b'),
      _processing('a'),
    ]);

    expect(projection.results, hasLength(2));
    expect(projection.results.first.position, 1);
    expect(projection.results.first.toolId, 'tool.knowledge');
    expect(projection.results.first.executionStatus, 'stubbed');
  });

  test('reordered inputs replay to the same JSON and digest', () {
    const projector = AIToolResultProjector();
    final first = projector.project([_processing('a'), _processing('b')]);
    final second = projector.project([_processing('b'), _processing('a')]);

    expect(second.digest, first.digest);
    expect(second.toJson(), first.toJson());
  });

  test('duplicate tool result fails closed', () {
    final item = _processing('same');
    expect(() => const AIToolResultProjector().project([item, item]),
        throwsArgumentError);
  });

  test('foreign capability fails closed', () {
    expect(
      () => const AIToolResultProjector().project([
        _processing('chat'),
        _processing('vision', capability: 'shot_analysis', tool: 'tool.vision'),
      ]),
      throwsArgumentError,
    );
  });

  test('projection is immutable and leaves processing unchanged', () {
    final processing = _processing('a');
    final before = jsonEncode(processing.toJson());
    final projection = const AIToolResultProjector().project([processing]);

    expect(() => projection.results.add(projection.results.single),
        throwsUnsupportedError);
    expect(jsonEncode(processing.toJson()), before);
  });

  test('projection contains no raw tool or runtime payload', () {
    final encoded = jsonEncode(
      const AIToolResultProjector().project([_processing('a')]).toJson(),
    );
    expect(encoded, isNot(contains('rawOutput')));
    expect(encoded, isNot(contains('filesystem')));
    expect(encoded, isNot(contains('shell')));
    expect(encoded, isNot(contains('database')));
    expect(encoded, isNot(contains('mcpPayload')));
  });
}

AIResponseProcessingV2Contract _processing(
  String suffix, {
  String capability = 'chat_generation',
  String tool = 'tool.knowledge',
}) {
  final session = _session(suffix);
  final envelope = CoachAIRequestEnvelope.create(
    session: session,
    providerId: 'stub/deterministic',
    providerContractVersion: 'stub-provider/1.0.0',
  );
  final invocation = ToolInvocationContract.create(
    capabilityId: capability,
    toolId: tool,
    invocationReason: AIToolInvocationPolicyV2.knowledgeLookup,
    renderingDigest: 'rendering.$suffix',
    sessionDigest: session.digest,
    registryDigest: 'registry.digest',
    metadata: const {'policy': 'knowledgeLookup'},
  );
  final plan = ToolInvocationPlanContract.create(
    renderingDigest: 'rendering.$suffix',
    registryDigest: 'registry.digest',
    invocations: [invocation],
  );
  final request = AIProviderRequestV2Contract.create(
    invocationPlan: plan,
    providerPayload: envelope,
  );
  final result = const DeterministicStubAIProvider().invoke(envelope);
  return AIResponseProcessingV2Contract.create(
    request: request,
    result: result,
  );
}

AISessionContract _session(String suffix) => AISessionContract.create(
      contextId: 'context.$suffix',
      planId: 'plan.$suffix',
      recommendationId: 'recommendation.$suffix',
      executionId: 'execution.$suffix',
      knowledgeVersion: 'knowledge.tool-result/1',
      knowledgeDigest: 'knowledge-tool-result-digest',
      contextDigest: 'context-tool-result-digest',
      planDigest: 'plan-tool-result-digest',
      recommendationDigest: 'recommendation-tool-result-digest',
      executionDigest: 'execution-tool-result-digest',
      provenance: const AISessionProvenance(
        knowledgeVersion: 'knowledge.tool-result/1',
        knowledgeDigest: 'knowledge-tool-result-digest',
        contextDigest: 'context-tool-result-digest',
        planDigest: 'plan-tool-result-digest',
        recommendationDigest: 'recommendation-tool-result-digest',
        executionDigest: 'execution-tool-result-digest',
      ),
      requiredRuntimeContracts: requiredAISessionRuntimeContracts,
      minimumAIContractVersion: minimumAIContractVersion,
    );
