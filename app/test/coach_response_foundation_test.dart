import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/ai_session_contracts.dart';
import 'package:pool_os/contracts/coach_response_contracts.dart';
import 'package:pool_os/features/coach/application/coach_ai_adapter.dart';

void main() {
  late AISessionContract session;
  const adapter = DeterministicStubAIAdapter();

  setUp(() {
    session = _session();
  });

  test('stub adapter accepts only AISession and emits structured response', () {
    final response = adapter.respond(session);
    final json = jsonEncode(response.toJson());

    expect(response.kind, CoachResponseKind.structuredSessionAcknowledged);
    expect(response.sessionDigest, session.digest);
    expect(response.contextDigest, session.contextDigest);
    expect(response.recommendationId, 'recommendation.ai');
    expect(
        response.generation.status, CoachResponseGenerationStatus.notGenerated);
    expect(json, isNot(contains('prompt')));
    expect(json, isNot(contains('prose')));
    expect(json, isNot(contains('message')));
  });

  test('request envelope is deterministic and bound to AISession', () {
    final first = adapter.createRequest(session);
    final second = adapter.createRequest(session);

    expect(second.digest, first.digest);
    expect(second.toJson(), first.toJson());
    expect(first.sessionId, session.id);
    expect(first.sessionDigest, session.digest);
  });

  test('same AISession produces the same response envelope and digest', () {
    final first = adapter.respond(session);
    final second = adapter.respond(session);

    expect(second.digest, first.digest);
    expect(second.toJson(), first.toJson());
    expect(second.request.digest, first.request.digest);
  });

  test('response binds Knowledge, Context, Recommendation, and Execution', () {
    final response = adapter.respond(session);

    expect(response.knowledgeVersion, session.knowledgeVersion);
    expect(response.knowledgeDigest, session.knowledgeDigest);
    expect(response.contextDigest, session.contextDigest);
    expect(response.executionDigest, session.executionDigest);
    expect(response.recommendationId, session.recommendationId);
  });

  test('generated content remains explicitly separated and absent in stub', () {
    final response = adapter.respond(session);
    final generation = response.toJson()['generation'] as Map<String, dynamic>;

    expect(generation, {'status': 'notGenerated'});
    expect(generation, isNot(contains('content')));
    expect(generation, isNot(contains('text')));
  });

  test('response rejects a request envelope from another AISession', () {
    final request = adapter.createRequest(_session(suffix: '.other'));

    expect(
      () => CoachResponseContract.create(
        session: session,
        request: request,
        kind: CoachResponseKind.structuredSessionAcknowledged,
        generation: const CoachResponseGeneration(
          status: CoachResponseGenerationStatus.notGenerated,
        ),
      ),
      throwsArgumentError,
    );
  });

  test('adapter and response leave AISession unchanged and expose no internals',
      () {
    final before = jsonEncode(session.toJson());
    final response = adapter.respond(session);
    final encoded = jsonEncode(response.toJson());

    expect(jsonEncode(session.toJson()), before);
    expect(encoded, isNot(contains('evidence')));
    expect(encoded, isNot(contains('eventLog')));
    expect(encoded, isNot(contains('learningRuntime')));
    expect(encoded, isNot(contains('playerModel')));
  });
}

AISessionContract _session({String suffix = ''}) {
  final contextDigest = 'context.ai$suffix';
  final planDigest = 'plan.ai$suffix';
  final recommendationDigest = 'recommendation-digest.ai$suffix';
  final executionDigest = 'execution-digest.ai$suffix';
  return AISessionContract.create(
    contextId: contextDigest,
    planId: 'plan.ai$suffix',
    recommendationId: 'recommendation.ai$suffix',
    executionId: 'execution.ai$suffix',
    knowledgeVersion: 'knowledge.ai/1',
    knowledgeDigest: 'knowledge-ai-digest$suffix',
    contextDigest: contextDigest,
    planDigest: planDigest,
    recommendationDigest: recommendationDigest,
    executionDigest: executionDigest,
    provenance: AISessionProvenance(
      knowledgeVersion: 'knowledge.ai/1',
      knowledgeDigest: 'knowledge-ai-digest$suffix',
      contextDigest: contextDigest,
      planDigest: planDigest,
      recommendationDigest: recommendationDigest,
      executionDigest: executionDigest,
    ),
    requiredRuntimeContracts: requiredAISessionRuntimeContracts,
    minimumAIContractVersion: minimumAIContractVersion,
  );
}
