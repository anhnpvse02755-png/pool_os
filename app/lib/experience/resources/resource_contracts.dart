import '../../shared/foundation/identifier.dart';
import '../../shared/foundation/immutable.dart';
import '../../shared/foundation/value_object.dart';

enum ResourceCapability { text, icon, image, theme }

final class ResourceIdentity extends ValueObject {
  const ResourceIdentity(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class ResourceVersion extends ValueObject {
  const ResourceVersion(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class ResourceCompatibility extends ValueObject {
  ResourceCompatibility({
    required this.requiredVersion,
    Iterable<ResourceVersion> supportedVersions = const [],
  }) : supportedVersions = immutableList(supportedVersions);

  final ResourceVersion requiredVersion;
  final List<ResourceVersion> supportedVersions;

  @override
  List<Object?> get components => [
        requiredVersion,
        supportedVersions.length,
        ...supportedVersions,
      ];
}

final class ResourceMetadata extends ValueObject {
  ResourceMetadata({
    required this.identity,
    required this.version,
    Iterable<ResourceCapability> capabilities = const [],
  }) : capabilities = immutableList(capabilities);

  final ResourceIdentity identity;
  final ResourceVersion version;
  final List<ResourceCapability> capabilities;

  @override
  List<Object?> get components => [
        identity,
        version,
        capabilities.length,
        ...capabilities,
      ];
}

final class ResourceProvenance extends ValueObject {
  const ResourceProvenance({
    required this.source,
    required this.digest,
    required this.metadata,
  });

  final RuntimeIdentifier source;
  final String digest;
  final ResourceMetadata metadata;

  @override
  List<Object?> get components => [source, digest, metadata];
}

final class ResourceContext extends ValueObject {
  const ResourceContext({
    required this.requestId,
    required this.metadata,
    required this.compatibility,
  });

  final RuntimeIdentifier requestId;
  final ResourceMetadata metadata;
  final ResourceCompatibility compatibility;

  @override
  List<Object?> get components => [requestId, metadata, compatibility];
}

final class ResourceResult<TValue extends ValueObject> extends ValueObject {
  const ResourceResult({
    required this.value,
    required this.metadata,
    required this.provenance,
  });

  final TValue value;
  final ResourceMetadata metadata;
  final ResourceProvenance provenance;

  @override
  List<Object?> get components => [value, metadata, provenance];
}

abstract interface class ResourceContract {
  ResourceMetadata get metadata;
}

abstract interface class ResourceProvider implements ResourceContract {}

abstract interface class TextResource implements ResourceContract {}

abstract interface class IconResource implements ResourceContract {}

abstract interface class ImageResource implements ResourceContract {}

abstract interface class ThemeResource implements ResourceContract {}
