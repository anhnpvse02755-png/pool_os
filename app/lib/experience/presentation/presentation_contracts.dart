import '../../shared/foundation/identifier.dart';
import '../../shared/foundation/immutable.dart';
import '../../shared/foundation/value_object.dart';

enum PresentationCapability { staticContent, dynamicContent, composite }

final class PresentationIdentity extends ValueObject {
  const PresentationIdentity(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class PresentationVersion extends ValueObject {
  const PresentationVersion(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class PresentationCompatibility extends ValueObject {
  PresentationCompatibility({
    required this.requiredVersion,
    Iterable<PresentationVersion> supportedVersions = const [],
  }) : supportedVersions = immutableList(supportedVersions);

  final PresentationVersion requiredVersion;
  final List<PresentationVersion> supportedVersions;

  @override
  List<Object?> get components => [
        requiredVersion,
        supportedVersions.length,
        ...supportedVersions,
      ];
}

final class PresentationDescriptor extends ValueObject {
  PresentationDescriptor({
    required this.identity,
    required this.version,
    Iterable<PresentationCapability> capabilities = const [],
  }) : capabilities = immutableList(capabilities);

  final PresentationIdentity identity;
  final PresentationVersion version;
  final List<PresentationCapability> capabilities;

  @override
  List<Object?> get components => [
        identity,
        version,
        capabilities.length,
        ...capabilities,
      ];
}

final class PresentationMetadata extends ValueObject {
  const PresentationMetadata({
    required this.identity,
    required this.descriptor,
  });

  final PresentationIdentity identity;
  final PresentationDescriptor descriptor;

  @override
  List<Object?> get components => [identity, descriptor];
}

final class PresentationProvenance extends ValueObject {
  const PresentationProvenance({
    required this.source,
    required this.digest,
    required this.metadata,
  });

  final RuntimeIdentifier source;
  final String digest;
  final PresentationMetadata metadata;

  @override
  List<Object?> get components => [source, digest, metadata];
}

final class PresentationContext extends ValueObject {
  const PresentationContext({
    required this.requestId,
    required this.metadata,
    required this.compatibility,
  });

  final RuntimeIdentifier requestId;
  final PresentationMetadata metadata;
  final PresentationCompatibility compatibility;

  @override
  List<Object?> get components => [requestId, metadata, compatibility];
}

final class PresentationResult<TValue extends ValueObject> extends ValueObject {
  const PresentationResult({
    required this.value,
    required this.metadata,
    required this.provenance,
  });

  final TValue value;
  final PresentationMetadata metadata;
  final PresentationProvenance provenance;

  @override
  List<Object?> get components => [value, metadata, provenance];
}

abstract interface class PresentationContract {
  PresentationMetadata get metadata;
}

abstract interface class PresentationComponent<TValue extends ValueObject>
    implements PresentationContract {
  PresentationDescriptor get descriptor;
}

abstract interface class StaticPresentation implements PresentationContract {}

abstract interface class DynamicPresentation implements PresentationContract {}

abstract interface class CompositePresentation
    implements PresentationContract {}
