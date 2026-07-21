import 'package:pool_os/contracts/ai_session_contracts.dart';
import 'package:pool_os/contracts/ai_capability_registry_contracts.dart';
import 'package:pool_os/contracts/ai_provider_contracts.dart';
import 'package:pool_os/contracts/coach_response_contracts.dart';

abstract class CoachAIAdapter {
  CoachAIRequestEnvelope createRequest({
    required AISessionContract session,
    required AICapabilityRegistryContract registry,
    required String capabilityId,
  });

  CoachResponseContract respond({
    required AISessionContract session,
    required AICapabilityRegistryContract registry,
    required String capabilityId,
  });
}

class DeterministicStubAIAdapter implements CoachAIAdapter {
  const DeterministicStubAIAdapter({
    this.provider = const DeterministicStubAIProvider(),
  });

  final AIProvider provider;

  @override
  CoachAIRequestEnvelope createRequest({
    required AISessionContract session,
    required AICapabilityRegistryContract registry,
    required String capabilityId,
  }) {
    registry.resolveForSession(
      session: session,
      capabilityId: capabilityId,
    );
    return CoachAIRequestEnvelope.create(
      session: session,
      providerId: provider.providerId,
      providerContractVersion: provider.providerContractVersion,
    );
  }

  @override
  CoachResponseContract respond({
    required AISessionContract session,
    required AICapabilityRegistryContract registry,
    required String capabilityId,
  }) {
    final request = createRequest(
      session: session,
      registry: registry,
      capabilityId: capabilityId,
    );
    final providerResult = provider.invoke(request);
    if (providerResult.providerId != provider.providerId ||
        providerResult.providerContractVersion !=
            provider.providerContractVersion ||
        providerResult.requestDigest != request.digest) {
      throw StateError('AI provider returned an incompatible result.');
    }
    return CoachResponseContract.create(
      session: session,
      request: request,
      kind: CoachResponseKind.structuredSessionAcknowledged,
      generation: const CoachResponseGeneration(
        status: CoachResponseGenerationStatus.notGenerated,
      ),
    );
  }
}
