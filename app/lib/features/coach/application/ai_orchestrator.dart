import 'package:pool_os/contracts/ai_capability_registry_contracts.dart';
import 'package:pool_os/contracts/ai_orchestration_contracts.dart';
import 'package:pool_os/contracts/ai_provider_contracts.dart';
import 'package:pool_os/contracts/ai_session_contracts.dart';
import 'package:pool_os/features/coach/application/coach_ai_adapter.dart';

class DeterministicAIOrchestrator {
  DeterministicAIOrchestrator({
    required List<AIProvider> providers,
    required List<AIOrchestrationRoute> routes,
  })  : providers = List.unmodifiable(providers),
        routes = List.unmodifiable(routes);

  final List<AIProvider> providers;
  final List<AIOrchestrationRoute> routes;

  AIOrchestrationResult orchestrate({
    required AIOrchestrationRequest request,
    required AISessionContract session,
    required AICapabilityRegistryContract capabilityRegistry,
  }) {
    if (request.sessionId != session.id ||
        request.sessionDigest != session.digest ||
        request.capabilityRegistryId != capabilityRegistry.id ||
        request.capabilityRegistryDigest != capabilityRegistry.digest) {
      throw ArgumentError('AI orchestration request is stale or incompatible.');
    }
    final providersByIdentity = <String, AIProvider>{};
    for (final provider in providers) {
      final key = _providerKey(
        provider.providerId,
        provider.providerContractVersion,
      );
      if (providersByIdentity.containsKey(key)) {
        throw StateError('AI orchestration providers contain duplicates.');
      }
      providersByIdentity[key] = provider;
    }

    final routesByCapability = <String, AIOrchestrationRoute>{};
    for (final route in routes) {
      if (route.capabilityId.trim().isEmpty ||
          route.providerId.trim().isEmpty ||
          route.providerContractVersion.trim().isEmpty) {
        throw ArgumentError('AI orchestration route is invalid.');
      }
      if (routesByCapability.containsKey(route.capabilityId)) {
        throw StateError('AI orchestration capability route is ambiguous.');
      }
      routesByCapability[route.capabilityId] = route;
    }

    final steps = <AIOrchestrationStepResult>[];
    for (final capabilityId in request.capabilityIds) {
      final capabilityBinding = capabilityRegistry.resolveForSession(
        session: session,
        capabilityId: capabilityId,
      );
      final route = routesByCapability[capabilityId];
      if (route == null) {
        throw StateError(
            'AI orchestration capability route is not registered.');
      }
      final provider = providersByIdentity[
          _providerKey(route.providerId, route.providerContractVersion)];
      if (provider == null) {
        throw StateError('AI orchestration provider is not registered.');
      }
      final response = DeterministicStubAIAdapter(provider: provider).respond(
        session: session,
        registry: capabilityRegistry,
        capabilityId: route.capabilityId,
      );
      steps.add(
        AIOrchestrationStepResult.create(
          route: route,
          capabilityBinding: capabilityBinding,
          response: response,
        ),
      );
    }
    return AIOrchestrationResult.create(request: request, steps: steps);
  }
}

String _providerKey(String providerId, String providerContractVersion) =>
    '$providerId\u0000$providerContractVersion';
