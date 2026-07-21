import 'package:pool_os/contracts/ai_session_contracts.dart';
import 'package:pool_os/contracts/coach_response_contracts.dart';

abstract class CoachAIAdapter {
  CoachAIRequestEnvelope createRequest(AISessionContract session);

  CoachResponseContract respond(AISessionContract session);
}

class DeterministicStubAIAdapter implements CoachAIAdapter {
  const DeterministicStubAIAdapter({
    this.providerId = 'stub/deterministic',
    this.providerContractVersion = 'stub-response/1.0.0',
  });

  final String providerId;
  final String providerContractVersion;

  @override
  CoachAIRequestEnvelope createRequest(AISessionContract session) =>
      CoachAIRequestEnvelope.create(
        session: session,
        providerId: providerId,
        providerContractVersion: providerContractVersion,
      );

  @override
  CoachResponseContract respond(AISessionContract session) {
    final request = createRequest(session);
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
