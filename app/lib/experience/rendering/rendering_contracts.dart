import '../../shared/foundation/identifier.dart';
import '../../shared/foundation/immutable.dart';
import '../../shared/foundation/value_object.dart';

enum RenderingCapability { staticContent, dynamicContent, composite }

final class RenderingIdentity extends ValueObject {
  const RenderingIdentity(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class RenderingVersion extends ValueObject {
  const RenderingVersion(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class RenderingCompatibility extends ValueObject {
  RenderingCompatibility({
    required this.requiredVersion,
    Iterable<RenderingVersion> supportedVersions = const [],
  }) : supportedVersions = immutableList(supportedVersions);

  final RenderingVersion requiredVersion;
  final List<RenderingVersion> supportedVersions;

  @override
  List<Object?> get components => [
        requiredVersion,
        supportedVersions.length,
        ...supportedVersions,
      ];
}

final class RenderingMetadata extends ValueObject {
  RenderingMetadata({
    required this.identity,
    required this.version,
    Iterable<RenderingCapability> capabilities = const [],
  }) : capabilities = immutableList(capabilities);

  final RenderingIdentity identity;
  final RenderingVersion version;
  final List<RenderingCapability> capabilities;

  @override
  List<Object?> get components => [
        identity,
        version,
        capabilities.length,
        ...capabilities,
      ];
}

final class RenderingProvenance extends ValueObject {
  const RenderingProvenance({
    required this.source,
    required this.digest,
    required this.metadata,
  });

  final RuntimeIdentifier source;
  final String digest;
  final RenderingMetadata metadata;

  @override
  List<Object?> get components => [source, digest, metadata];
}

final class RenderingContext extends ValueObject {
  const RenderingContext({
    required this.requestId,
    required this.metadata,
    required this.compatibility,
  });

  final RuntimeIdentifier requestId;
  final RenderingMetadata metadata;
  final RenderingCompatibility compatibility;

  @override
  List<Object?> get components => [requestId, metadata, compatibility];
}

final class RenderingResult<TValue extends ValueObject> extends ValueObject {
  const RenderingResult({
    required this.value,
    required this.metadata,
    required this.provenance,
  });

  final TValue value;
  final RenderingMetadata metadata;
  final RenderingProvenance provenance;

  @override
  List<Object?> get components => [value, metadata, provenance];
}

abstract interface class RenderingContract {
  RenderingMetadata get metadata;
}

abstract interface class RenderingComponent<TValue extends ValueObject>
    implements RenderingContract {}
