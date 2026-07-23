import '../../shared/foundation/identifier.dart';
import '../../shared/foundation/immutable.dart';
import '../../shared/foundation/result.dart';
import '../../shared/foundation/value_object.dart';
import '../contracts/infrastructure_contracts.dart';

enum RepositoryCapability {
  read,
  write,
  aggregate,
  projection,
  local,
  external
}

final class RepositoryIdentity extends ValueObject {
  const RepositoryIdentity(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class RepositoryVersion extends ValueObject {
  const RepositoryVersion(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class RepositoryCapabilityMetadata extends ValueObject {
  RepositoryCapabilityMetadata({
    required this.identity,
    required this.version,
    Iterable<RepositoryCapability> capabilities = const [],
  }) : capabilities = immutableList(capabilities);

  final RepositoryIdentity identity;
  final RepositoryVersion version;
  final List<RepositoryCapability> capabilities;

  @override
  List<Object?> get components => [
        identity,
        version,
        capabilities.length,
        ...capabilities,
      ];
}

final class RepositoryCompatibility extends ValueObject {
  RepositoryCompatibility({
    required this.requiredVersion,
    Iterable<RepositoryVersion> supportedVersions = const [],
  }) : supportedVersions = immutableList(supportedVersions);

  final RepositoryVersion requiredVersion;
  final List<RepositoryVersion> supportedVersions;

  @override
  List<Object?> get components => [
        requiredVersion,
        supportedVersions.length,
        ...supportedVersions,
      ];
}

final class RepositoryProvenance extends ValueObject {
  const RepositoryProvenance({
    required this.repository,
    required this.adapter,
  });

  final RepositoryCapabilityMetadata repository;
  final AdapterProvenance adapter;

  @override
  List<Object?> get components => [repository, adapter];
}

final class RepositoryExecutionContext extends ValueObject {
  const RepositoryExecutionContext({
    required this.requestId,
    required this.adapter,
    required this.compatibility,
  });

  final RuntimeIdentifier requestId;
  final AdapterExecutionContext adapter;
  final RepositoryCompatibility compatibility;

  @override
  List<Object?> get components => [requestId, adapter, compatibility];
}

final class RepositoryExecutionResult<TModel extends ValueObject>
    extends ValueObject {
  const RepositoryExecutionResult({
    required this.value,
    required this.capability,
    required this.provenance,
  });

  final TModel value;
  final RepositoryCapability capability;
  final RepositoryProvenance provenance;

  @override
  List<Object?> get components => [value, capability, provenance];
}

abstract interface class RepositoryAdapter<TModel extends ValueObject> {
  RepositoryCapabilityMetadata get metadata;
}

abstract interface class AggregateRepositoryAdapter<
    TAggregate extends ValueObject> implements RepositoryAdapter<TAggregate> {}

abstract interface class ReadRepositoryAdapter<TId extends ValueObject,
    TModel extends ValueObject> implements RepositoryAdapter<TModel> {
  Future<Result<RepositoryExecutionResult<TModel>>> read(
    TId id,
    RepositoryExecutionContext context,
  );
}

abstract interface class WriteRepositoryAdapter<TId extends ValueObject,
    TModel extends ValueObject> implements RepositoryAdapter<TModel> {
  Future<Result<RepositoryExecutionResult<TModel>>> write(
    TId id,
    TModel model,
    RepositoryExecutionContext context,
  );
}

abstract interface class LocalRepositoryAdapter<TModel extends ValueObject>
    implements RepositoryAdapter<TModel> {}

abstract interface class ExternalRepositoryAdapter<TModel extends ValueObject>
    implements RepositoryAdapter<TModel> {}

abstract interface class ProjectionRepositoryAdapter<
        TProjection extends ValueObject>
    implements RepositoryAdapter<TProjection> {}
