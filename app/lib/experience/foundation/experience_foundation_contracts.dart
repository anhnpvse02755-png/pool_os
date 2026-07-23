import '../../shared/foundation/identifier.dart';
import '../../shared/foundation/immutable.dart';
import '../../shared/foundation/value_object.dart';

final class ExperienceIdentity extends ValueObject {
  const ExperienceIdentity(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class ExperienceVersion extends ValueObject {
  const ExperienceVersion(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class ExperienceMetadata extends ValueObject {
  ExperienceMetadata({
    required this.identity,
    required this.version,
    Iterable<RuntimeIdentifier> capabilities = const [],
  }) : capabilities = immutableList(capabilities);

  final ExperienceIdentity identity;
  final ExperienceVersion version;
  final List<RuntimeIdentifier> capabilities;

  @override
  List<Object?> get components => [
        identity,
        version,
        capabilities.length,
        ...capabilities,
      ];
}

final class ExperienceCompatibility extends ValueObject {
  ExperienceCompatibility({
    required this.requiredVersion,
    Iterable<ExperienceVersion> supportedVersions = const [],
  }) : supportedVersions = immutableList(supportedVersions);

  final ExperienceVersion requiredVersion;
  final List<ExperienceVersion> supportedVersions;

  @override
  List<Object?> get components => [
        requiredVersion,
        supportedVersions.length,
        ...supportedVersions,
      ];
}

final class ExperienceProvenance extends ValueObject {
  const ExperienceProvenance({
    required this.source,
    required this.digest,
    required this.metadata,
  });

  final RuntimeIdentifier source;
  final String digest;
  final ExperienceMetadata metadata;

  @override
  List<Object?> get components => [source, digest, metadata];
}

final class ExperienceExecutionContext extends ValueObject {
  const ExperienceExecutionContext({
    required this.requestId,
    required this.metadata,
    required this.compatibility,
  });

  final RuntimeIdentifier requestId;
  final ExperienceMetadata metadata;
  final ExperienceCompatibility compatibility;

  @override
  List<Object?> get components => [requestId, metadata, compatibility];
}

final class ExperienceExecutionResult<TValue extends ValueObject>
    extends ValueObject {
  const ExperienceExecutionResult({
    required this.value,
    required this.metadata,
    required this.provenance,
  });

  final TValue value;
  final ExperienceMetadata metadata;
  final ExperienceProvenance provenance;

  @override
  List<Object?> get components => [value, metadata, provenance];
}

abstract interface class ExperienceComponent<TState extends ValueObject> {
  ExperienceMetadata get metadata;
}

abstract interface class ExperienceContext {
  ExperienceExecutionContext get executionContext;
}

abstract interface class ExperienceState<TValue extends ValueObject> {
  TValue get value;
}

abstract interface class ExperienceEvent<TPayload extends ValueObject> {
  TPayload get payload;

  ExperienceMetadata get metadata;
}

abstract interface class ExperienceLifecycle<TState extends ValueObject> {
  ExperienceState<TState> get state;
}

abstract interface class ExperienceCapability {
  ExperienceMetadata get metadata;
}
