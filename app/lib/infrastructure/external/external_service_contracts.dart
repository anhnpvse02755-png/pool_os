import '../../shared/foundation/identifier.dart';
import '../../shared/foundation/immutable.dart';
import '../../shared/foundation/result.dart';
import '../../shared/foundation/value_object.dart';
import '../contracts/infrastructure_contracts.dart';

enum ExternalCapability { execute, health, availability }

enum ExternalCircuitState { unspecified, closed, open, halfOpen }

enum ExternalAvailability { unknown, available, unavailable, degraded }

final class ExternalOperationIdentity extends ValueObject {
  const ExternalOperationIdentity({
    required this.service,
    required this.operation,
    required this.version,
  });

  final RuntimeIdentifier service;
  final RuntimeIdentifier operation;
  final RuntimeIdentifier version;

  @override
  List<Object?> get components => [service, operation, version];
}

final class ExternalCapabilityMetadata extends ValueObject {
  ExternalCapabilityMetadata({
    required this.adapter,
    Iterable<ExternalCapability> capabilities = const [],
  }) : capabilities = immutableList(capabilities);

  final AdapterIdentity adapter;
  final List<ExternalCapability> capabilities;

  @override
  List<Object?> get components => [
        adapter,
        capabilities.length,
        ...capabilities,
      ];
}

final class ExternalTimeoutPolicy extends ValueObject {
  const ExternalTimeoutPolicy({required this.identity, required this.version});

  final RuntimeIdentifier identity;
  final RuntimeIdentifier version;

  @override
  List<Object?> get components => [identity, version];
}

final class ExternalRetryPolicy extends ValueObject {
  const ExternalRetryPolicy({required this.identity, required this.version});

  final RuntimeIdentifier identity;
  final RuntimeIdentifier version;

  @override
  List<Object?> get components => [identity, version];
}

final class ExternalCircuitMetadata extends ValueObject {
  const ExternalCircuitMetadata({
    required this.identity,
    required this.state,
  });

  final RuntimeIdentifier identity;
  final ExternalCircuitState state;

  @override
  List<Object?> get components => [identity, state];
}

final class ExternalAvailabilityContract extends ValueObject {
  const ExternalAvailabilityContract({
    required this.identity,
    required this.availability,
  });

  final RuntimeIdentifier identity;
  final ExternalAvailability availability;

  @override
  List<Object?> get components => [identity, availability];
}

final class ExternalRateLimitContract extends ValueObject {
  const ExternalRateLimitContract({
    required this.identity,
    required this.version,
  });

  final RuntimeIdentifier identity;
  final RuntimeIdentifier version;

  @override
  List<Object?> get components => [identity, version];
}

final class ExternalVersionCompatibility extends ValueObject {
  ExternalVersionCompatibility({
    required this.requiredVersion,
    Iterable<RuntimeIdentifier> supportedVersions = const [],
  }) : supportedVersions = immutableList(supportedVersions);

  final RuntimeIdentifier requiredVersion;
  final List<RuntimeIdentifier> supportedVersions;

  @override
  List<Object?> get components => [
        requiredVersion,
        supportedVersions.length,
        ...supportedVersions,
      ];
}

final class ExternalExecutionMetadata extends ValueObject {
  const ExternalExecutionMetadata({
    required this.requestId,
    required this.operation,
    required this.capability,
  });

  final RuntimeIdentifier requestId;
  final ExternalOperationIdentity operation;
  final ExternalCapabilityMetadata capability;

  @override
  List<Object?> get components => [requestId, operation, capability];
}

final class ExternalRequestContext extends ValueObject {
  const ExternalRequestContext({
    required this.execution,
    required this.compatibility,
    required this.timeoutPolicy,
    required this.retryPolicy,
    required this.circuit,
    required this.rateLimit,
  });

  final ExternalExecutionMetadata execution;
  final ExternalVersionCompatibility compatibility;
  final ExternalTimeoutPolicy timeoutPolicy;
  final ExternalRetryPolicy retryPolicy;
  final ExternalCircuitMetadata circuit;
  final ExternalRateLimitContract rateLimit;

  @override
  List<Object?> get components => [
        execution,
        compatibility,
        timeoutPolicy,
        retryPolicy,
        circuit,
        rateLimit,
      ];
}

final class ExternalOperationProvenance extends ValueObject {
  const ExternalOperationProvenance({
    required this.operation,
    required this.adapter,
  });

  final ExternalOperationIdentity operation;
  final AdapterProvenance adapter;

  @override
  List<Object?> get components => [operation, adapter];
}

final class ExternalResponseEnvelope<TPayload extends ValueObject>
    extends ValueObject {
  const ExternalResponseEnvelope({
    required this.payload,
    required this.provenance,
    required this.availability,
  });

  final TPayload payload;
  final ExternalOperationProvenance provenance;
  final ExternalAvailabilityContract availability;

  @override
  List<Object?> get components => [payload, provenance, availability];
}

final class ExternalOperationResult<TPayload extends ValueObject>
    extends ValueObject {
  const ExternalOperationResult({
    required this.execution,
    required this.response,
  });

  final ExternalExecutionMetadata execution;
  final ExternalResponseEnvelope<TPayload> response;

  @override
  List<Object?> get components => [execution, response];
}

abstract interface class ExternalServiceAdapter<TRequest,
    TResponse extends ValueObject> {
  ExternalCapabilityMetadata get metadata;

  Future<Result<ExternalOperationResult<TResponse>>> execute(
    TRequest request,
    ExternalRequestContext context,
  );
}

abstract interface class OutboundServiceContract<TRequest,
        TResponse extends ValueObject>
    implements ExternalServiceAdapter<TRequest, TResponse> {}

abstract interface class ExternalHealthCapability {
  ExternalCapabilityMetadata get healthCapability;
}
