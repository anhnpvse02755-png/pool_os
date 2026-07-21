import 'package:pool_os/contracts/ai_session_contracts.dart';
import 'package:pool_os/contracts/ai_capability_registry_contracts.dart';
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
    this.providerId = 'stub/deterministic',
    this.providerContractVersion = 'stub-response/1.0.0',
  });

  final String providerId;
  final String providerContractVersion;

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
      providerId: providerId,
      providerContractVersion: providerContractVersion,
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
