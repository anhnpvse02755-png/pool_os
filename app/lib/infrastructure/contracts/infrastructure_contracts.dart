import '../../shared/foundation/failure.dart';
import '../../shared/foundation/identifier.dart';
import '../../shared/foundation/immutable.dart';
import '../../shared/foundation/result.dart';
import '../../shared/foundation/value_object.dart';

enum InfrastructureCapability { read, write, external, local }

final class AdapterIdentity extends ValueObject {
  const AdapterIdentity({
    required this.id,
    required this.version,
  });

  final RuntimeIdentifier id;
  final RuntimeIdentifier version;

  @override
  List<Object?> get components => [id, version];
}

final class AdapterCapabilityMetadata extends ValueObject {
  AdapterCapabilityMetadata({
    required this.identity,
    Iterable<InfrastructureCapability> capabilities = const [],
  }) : capabilities = immutableList(capabilities);

  final AdapterIdentity identity;
  final List<InfrastructureCapability> capabilities;

  @override
  List<Object?> get components => [
        identity,
        capabilities.length,
        ...capabilities,
      ];
}

final class AdapterProvenance extends ValueObject {
  const AdapterProvenance({
    required this.source,
    required this.digest,
  });

  final RuntimeIdentifier source;
  final String digest;

  @override
  List<Object?> get components => [source, digest];
}

final class AdapterExecutionContext extends ValueObject {
  const AdapterExecutionContext({
    required this.correlationId,
    required this.capability,
    required this.provenance,
  });

  final RuntimeIdentifier correlationId;
  final AdapterCapabilityMetadata capability;
  final AdapterProvenance provenance;

  @override
  List<Object?> get components => [correlationId, capability, provenance];
}

final class AdapterExecutionResult<T extends ValueObject> extends ValueObject {
  const AdapterExecutionResult({
    this.value,
    this.failure,
  });

  final T? value;
  final Failure? failure;

  @override
  List<Object?> get components => [value, failure];
}

abstract interface class InfrastructurePort<TRequest,
    TResult extends ValueObject> {
  Future<Result<AdapterExecutionResult<TResult>>> execute(
    TRequest request,
    AdapterExecutionContext context,
  );
}

abstract interface class InfrastructureAdapter<TRequest,
        TResult extends ValueObject>
    implements InfrastructurePort<TRequest, TResult> {}

abstract interface class ReadAdapter<TRequest, TResult extends ValueObject>
    implements InfrastructureAdapter<TRequest, TResult> {}

abstract interface class WriteAdapter<TRequest, TResult extends ValueObject>
    implements InfrastructureAdapter<TRequest, TResult> {}

abstract interface class ExternalAdapter<TRequest, TResult extends ValueObject>
    implements InfrastructureAdapter<TRequest, TResult> {}

abstract interface class LocalAdapter<TRequest, TResult extends ValueObject>
    implements InfrastructureAdapter<TRequest, TResult> {}
