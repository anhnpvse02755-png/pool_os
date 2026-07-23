import '../../shared/foundation/identifier.dart';
import '../../shared/foundation/immutable.dart';
import '../../shared/foundation/value_object.dart';

enum KnowledgeCapabilityKind {
  lifecycle,
  search,
  retrieval,
  classification,
  validation,
  statistics,
}

final class KnowledgeCapabilityIdentity extends ValueObject {
  const KnowledgeCapabilityIdentity(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class KnowledgeCapabilityVersion extends ValueObject {
  const KnowledgeCapabilityVersion(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class KnowledgeCapabilityCompatibility extends ValueObject {
  KnowledgeCapabilityCompatibility({
    required this.requiredVersion,
    Iterable<KnowledgeCapabilityVersion> supportedVersions = const [],
  }) : supportedVersions = immutableList(supportedVersions);

  final KnowledgeCapabilityVersion requiredVersion;
  final List<KnowledgeCapabilityVersion> supportedVersions;

  @override
  List<Object?> get components => [
        requiredVersion,
        supportedVersions.length,
        ...supportedVersions,
      ];
}

final class KnowledgeCapabilityMetadata extends ValueObject {
  KnowledgeCapabilityMetadata({
    required this.identity,
    required this.version,
    Iterable<KnowledgeCapabilityKind> kinds = const [],
  }) : kinds = immutableList(kinds);

  final KnowledgeCapabilityIdentity identity;
  final KnowledgeCapabilityVersion version;
  final List<KnowledgeCapabilityKind> kinds;

  @override
  List<Object?> get components => [
        identity,
        version,
        kinds.length,
        ...kinds,
      ];
}

final class KnowledgeCapabilityProvenance extends ValueObject {
  const KnowledgeCapabilityProvenance({
    required this.source,
    required this.digest,
    required this.metadata,
  });

  final RuntimeIdentifier source;
  final String digest;
  final KnowledgeCapabilityMetadata metadata;

  @override
  List<Object?> get components => [source, digest, metadata];
}

final class KnowledgeCapabilityContext extends ValueObject {
  const KnowledgeCapabilityContext({
    required this.requestId,
    required this.metadata,
    required this.compatibility,
  });

  final RuntimeIdentifier requestId;
  final KnowledgeCapabilityMetadata metadata;
  final KnowledgeCapabilityCompatibility compatibility;

  @override
  List<Object?> get components => [requestId, metadata, compatibility];
}

final class KnowledgeCapabilityResult<TValue extends ValueObject>
    extends ValueObject {
  const KnowledgeCapabilityResult({
    required this.value,
    required this.metadata,
    required this.provenance,
  });

  final TValue value;
  final KnowledgeCapabilityMetadata metadata;
  final KnowledgeCapabilityProvenance provenance;

  @override
  List<Object?> get components => [value, metadata, provenance];
}

abstract interface class KnowledgeCapabilityContract {
  KnowledgeCapabilityMetadata get metadata;
}

abstract interface class KnowledgeLifecycleCapability
    implements KnowledgeCapabilityContract {}

abstract interface class KnowledgeSearchCapability
    implements KnowledgeCapabilityContract {}

abstract interface class KnowledgeRetrievalCapability
    implements KnowledgeCapabilityContract {}

abstract interface class KnowledgeClassificationCapability
    implements KnowledgeCapabilityContract {}

abstract interface class KnowledgeValidationCapability
    implements KnowledgeCapabilityContract {}

abstract interface class KnowledgeStatisticsCapability
    implements KnowledgeCapabilityContract {}
