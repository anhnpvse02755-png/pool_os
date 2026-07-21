import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/ai_capability_registry_contracts.dart';
import 'package:pool_os/contracts/ai_orchestration_contracts.dart';
import 'package:pool_os/contracts/ai_provider_contracts.dart';
import 'package:pool_os/contracts/ai_session_contracts.dart';
import 'package:pool_os/features/coach/application/ai_orchestrator.dart';
import 'package:pool_os/features/coach/application/coach_ai_adapter.dart';

void main() {
  late AISessionContract session;
  late AICapabilityRegistryContract registry;
  late List<AIProvider> providers;

  setUp(() {
    session = _session();
    registry = _registry();
    providers = const [
      DeterministicStubAIProvider(),
      DeterministicStubAIProvider(
        providerId: 'stub/vision',
        providerContractVersion: 'stub-provider/vision-1.0.0',
      ),
    ];
  });

  test(
      'request is immutable canonical and deterministic across capability order',
      () {
    final first = _request(
      session,
      registry,
      capabilityIds: _capabilityIds,
    );
    final second = _request(
      session,
      registry,
      capabilityIds: _capabilityIds.reversed.toList(),
    );

    expect(second.digest, first.digest);
    expect(second.toJson(), first.toJson());
    expect(
      () => first.capabilityIds.add(_capabilityIds.first),
      throwsUnsupportedError,
    );
  });

  test('single capability and provider produce a bound completed result', () {
    final request = _request(
      session,
      registry,
      capabilityIds: [_capabilityIds.first],
    );
    final result = _orchestrator(providers).orchestrate(
      request: request,
      session: session,
      capabilityRegistry: registry,
    );

    expect(result.requestDigest, request.digest);
    expect(result.status, AIOrchestrationStatus.completed);
    expect(result.steps, hasLength(1));
    expect(result.steps.single.route.capabilityId, 'chat_generation');
  });

  test('multiple capability/provider routes are deterministic', () {
    final request = _request(session, registry);
    final orchestrator = _orchestrator(providers);
    final first = orchestrator.orchestrate(
      request: request,
      session: session,
      capabilityRegistry: registry,
    );
    final second = orchestrator.orchestrate(
      request: request,
      session: session,
      capabilityRegistry: registry,
    );

    expect(first.steps, hasLength(2));
    expect(second.digest, first.digest);
    expect(second.toJson(), first.toJson());
  });

  test('unknown capability and missing provider fail closed', () {
    final unknownCapability = _request(
      session,
      registry,
      capabilityIds: const ['unknown'],
    );
    final missingProvider = _request(
      session,
      registry,
      capabilityIds: const ['chat_generation'],
    );
    final orchestrator = _orchestrator(providers);

    expect(
      () => orchestrator.orchestrate(
        request: unknownCapability,
        session: session,
        capabilityRegistry: registry,
      ),
      throwsStateError,
    );
    expect(
      () => DeterministicAIOrchestrator(
        providers: providers,
        routes: const [
          AIOrchestrationRoute(
            capabilityId: 'chat_generation',
            providerId: 'stub/missing',
            providerContractVersion: 'stub-provider/1.0.0',
          ),
        ],
      ).orchestrate(
        request: missingProvider,
        session: session,
        capabilityRegistry: registry,
      ),
      throwsStateError,
    );
  });

  test('duplicate capabilities routes and provider identities fail closed', () {
    expect(
      () => _request(
        session,
        registry,
        capabilityIds: [_capabilityIds.first, _capabilityIds.first],
      ),
      throwsArgumentError,
    );
    final request = _request(
      session,
      registry,
      capabilityIds: [_capabilityIds.first],
    );
    expect(
      () => DeterministicAIOrchestrator(
        providers: const [
          DeterministicStubAIProvider(),
          DeterministicStubAIProvider(),
        ],
        routes: _routes,
      ).orchestrate(
        request: request,
        session: session,
        capabilityRegistry: registry,
      ),
      throwsStateError,
    );
    expect(
      () => DeterministicAIOrchestrator(
        providers: providers,
        routes: [_routes.first, _routes.first],
      ).orchestrate(
        request: request,
        session: session,
        capabilityRegistry: registry,
      ),
      throwsStateError,
    );
  });

  test('stale session and registry bindings fail closed', () {
    final request = _request(_session(contextId: 'context.stale'), registry);
    final orchestrator = _orchestrator(providers);

    expect(
      () => orchestrator.orchestrate(
        request: request,
        session: session,
        capabilityRegistry: registry,
      ),
      throwsArgumentError,
    );
  });

  test('result factory rejects a step from another session', () {
    final request = _request(
      session,
      registry,
      capabilityIds: [_capabilityIds.first],
    );
    final staleSession = _session(contextId: 'context.stale');
    final binding = registry.resolveForSession(
      session: staleSession,
      capabilityId: _capabilityIds.first,
    );
    final response = const DeterministicStubAIAdapter().respond(
      session: staleSession,
      registry: registry,
      capabilityId: _capabilityIds.first,
    );
    final staleStep = AIOrchestrationStepResult.create(
      route: _routes.first,
      capabilityBinding: binding,
      response: response,
    );

    expect(
      () => AIOrchestrationResult.create(
        request: request,
        steps: [staleStep],
      ),
      throwsArgumentError,
    );
  });

  test('orchestration stays structured and does not mutate inputs', () {
    final request = _request(session, registry);
    final sessionBefore = jsonEncode(session.toJson());
    final registryBefore = jsonEncode(registry.toJson());
    final result = _orchestrator(providers).orchestrate(
      request: request,
      session: session,
      capabilityRegistry: registry,
    );
    final encoded = jsonEncode(result.toJson());

    expect(jsonEncode(session.toJson()), sessionBefore);
    expect(jsonEncode(registry.toJson()), registryBefore);
    expect(encoded, isNot(contains('prompt')));
    expect(encoded, isNot(contains('retry')));
    expect(encoded, isNot(contains('fallback')));
    expect(encoded, isNot(contains('timeout')));
  });
}

const _routes = [
  AIOrchestrationRoute(
    capabilityId: 'chat_generation',
    providerId: 'stub/deterministic',
    providerContractVersion: 'stub-provider/1.0.0',
  ),
  AIOrchestrationRoute(
    capabilityId: 'shot_analysis',
    providerId: 'stub/vision',
    providerContractVersion: 'stub-provider/vision-1.0.0',
  ),
];

const _capabilityIds = ['chat_generation', 'shot_analysis'];

DeterministicAIOrchestrator _orchestrator(List<AIProvider> providers) =>
    DeterministicAIOrchestrator(providers: providers, routes: _routes);

AIOrchestrationRequest _request(
  AISessionContract session,
  AICapabilityRegistryContract registry, {
  List<String> capabilityIds = _capabilityIds,
}) =>
    AIOrchestrationRequest.create(
      session: session,
      capabilityRegistry: registry,
      capabilityIds: capabilityIds,
    );

AICapabilityRegistryContract _registry() => AICapabilityRegistryContract.create(
      aiContractVersion: aiSessionContractVersion,
      minimumSupportedAIContractVersion: minimumAIContractVersion,
      capabilities: const [
        AICapabilityDefinition(
          capabilityId: 'chat_generation',
          capabilityContractVersion: 1,
          minimumAIContractVersion: minimumAIContractVersion,
          requiredRuntimeContracts: requiredAISessionRuntimeContracts,
          compatibilityRules: {'mode': 'structured-only'},
        ),
        AICapabilityDefinition(
          capabilityId: 'shot_analysis',
          capabilityContractVersion: 1,
          minimumAIContractVersion: minimumAIContractVersion,
          requiredRuntimeContracts: requiredAISessionRuntimeContracts,
          compatibilityRules: {'mode': 'structured-only'},
        ),
      ],
    );

AISessionContract _session({String contextId = 'context.orchestration'}) =>
    AISessionContract.create(
      contextId: contextId,
      planId: 'plan.orchestration',
      recommendationId: 'recommendation.orchestration',
      executionId: 'execution.orchestration',
      knowledgeVersion: 'knowledge.orchestration/1',
      knowledgeDigest: 'knowledge-orchestration-digest',
      contextDigest: 'context-orchestration-digest',
      planDigest: 'plan-orchestration-digest',
      recommendationDigest: 'recommendation-orchestration-digest',
      executionDigest: 'execution-orchestration-digest',
      provenance: const AISessionProvenance(
        knowledgeVersion: 'knowledge.orchestration/1',
        knowledgeDigest: 'knowledge-orchestration-digest',
        contextDigest: 'context-orchestration-digest',
        planDigest: 'plan-orchestration-digest',
        recommendationDigest: 'recommendation-orchestration-digest',
        executionDigest: 'execution-orchestration-digest',
      ),
      requiredRuntimeContracts: requiredAISessionRuntimeContracts,
      minimumAIContractVersion: minimumAIContractVersion,
    );
