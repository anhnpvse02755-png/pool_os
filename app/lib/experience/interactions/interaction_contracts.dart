import '../../shared/foundation/identifier.dart';
import '../../shared/foundation/immutable.dart';
import '../../shared/foundation/value_object.dart';

enum InteractionCapability { user, system, background }

final class InteractionIdentity extends ValueObject {
  const InteractionIdentity(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class InteractionVersion extends ValueObject {
  const InteractionVersion(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class InteractionCompatibility extends ValueObject {
  InteractionCompatibility({
    required this.requiredVersion,
    Iterable<InteractionVersion> supportedVersions = const [],
  }) : supportedVersions = immutableList(supportedVersions);

  final InteractionVersion requiredVersion;
  final List<InteractionVersion> supportedVersions;

  @override
  List<Object?> get components => [
        requiredVersion,
        supportedVersions.length,
        ...supportedVersions,
      ];
}

final class InteractionMetadata extends ValueObject {
  InteractionMetadata({
    required this.identity,
    required this.version,
    Iterable<InteractionCapability> capabilities = const [],
  }) : capabilities = immutableList(capabilities);

  final InteractionIdentity identity;
  final InteractionVersion version;
  final List<InteractionCapability> capabilities;

  @override
  List<Object?> get components => [
        identity,
        version,
        capabilities.length,
        ...capabilities,
      ];
}

final class InteractionProvenance extends ValueObject {
  const InteractionProvenance({
    required this.source,
    required this.digest,
    required this.metadata,
  });

  final RuntimeIdentifier source;
  final String digest;
  final InteractionMetadata metadata;

  @override
  List<Object?> get components => [source, digest, metadata];
}

final class InteractionContext extends ValueObject {
  const InteractionContext({
    required this.requestId,
    required this.metadata,
    required this.compatibility,
  });

  final RuntimeIdentifier requestId;
  final InteractionMetadata metadata;
  final InteractionCompatibility compatibility;

  @override
  List<Object?> get components => [requestId, metadata, compatibility];
}

final class InteractionResult<TValue extends ValueObject> extends ValueObject {
  const InteractionResult({
    required this.value,
    required this.metadata,
    required this.provenance,
  });

  final TValue value;
  final InteractionMetadata metadata;
  final InteractionProvenance provenance;

  @override
  List<Object?> get components => [value, metadata, provenance];
}

abstract interface class InteractionContract {
  InteractionMetadata get metadata;
}

abstract interface class InteractionHandler implements InteractionContract {}

abstract interface class InteractionCoordinator
    implements InteractionContract {}

abstract interface class UserInteraction implements InteractionContract {}

abstract interface class SystemInteraction implements InteractionContract {}

abstract interface class BackgroundInteraction implements InteractionContract {}
