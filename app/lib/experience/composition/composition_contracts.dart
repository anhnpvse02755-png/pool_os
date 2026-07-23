import '../../shared/foundation/identifier.dart';
import '../../shared/foundation/immutable.dart';
import '../../shared/foundation/value_object.dart';

enum CompositionCapability { atomic, aggregate, nested }

final class CompositionIdentity extends ValueObject {
  const CompositionIdentity(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class CompositionVersion extends ValueObject {
  const CompositionVersion(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class CompositionCompatibility extends ValueObject {
  CompositionCompatibility({
    required this.requiredVersion,
    Iterable<CompositionVersion> supportedVersions = const [],
  }) : supportedVersions = immutableList(supportedVersions);

  final CompositionVersion requiredVersion;
  final List<CompositionVersion> supportedVersions;

  @override
  List<Object?> get components => [
        requiredVersion,
        supportedVersions.length,
        ...supportedVersions,
      ];
}

final class CompositionMetadata extends ValueObject {
  CompositionMetadata({
    required this.identity,
    required this.version,
    Iterable<CompositionCapability> capabilities = const [],
  }) : capabilities = immutableList(capabilities);

  final CompositionIdentity identity;
  final CompositionVersion version;
  final List<CompositionCapability> capabilities;

  @override
  List<Object?> get components => [
        identity,
        version,
        capabilities.length,
        ...capabilities,
      ];
}

final class CompositionProvenance extends ValueObject {
  const CompositionProvenance({
    required this.source,
    required this.digest,
    required this.metadata,
  });

  final RuntimeIdentifier source;
  final String digest;
  final CompositionMetadata metadata;

  @override
  List<Object?> get components => [source, digest, metadata];
}

final class CompositionContext extends ValueObject {
  const CompositionContext({
    required this.requestId,
    required this.metadata,
    required this.compatibility,
  });

  final RuntimeIdentifier requestId;
  final CompositionMetadata metadata;
  final CompositionCompatibility compatibility;

  @override
  List<Object?> get components => [requestId, metadata, compatibility];
}

final class CompositionResult<TValue extends ValueObject> extends ValueObject {
  const CompositionResult({
    required this.value,
    required this.metadata,
    required this.provenance,
  });

  final TValue value;
  final CompositionMetadata metadata;
  final CompositionProvenance provenance;

  @override
  List<Object?> get components => [value, metadata, provenance];
}

abstract interface class CompositionContract {
  CompositionMetadata get metadata;
}

abstract interface class CompositionComponent<TValue extends ValueObject>
    implements CompositionContract {}
