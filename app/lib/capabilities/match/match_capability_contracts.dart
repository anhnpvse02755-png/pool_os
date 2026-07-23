import '../../shared/foundation/identifier.dart';
import '../../shared/foundation/immutable.dart';
import '../../shared/foundation/value_object.dart';

enum MatchCapabilityKind {
  lifecycle,
  rackManagement,
  scoring,
  validation,
  statistics,
}

final class MatchCapabilityIdentity extends ValueObject {
  const MatchCapabilityIdentity(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class MatchCapabilityVersion extends ValueObject {
  const MatchCapabilityVersion(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class MatchCapabilityCompatibility extends ValueObject {
  MatchCapabilityCompatibility({
    required this.requiredVersion,
    Iterable<MatchCapabilityVersion> supportedVersions = const [],
  }) : supportedVersions = immutableList(supportedVersions);

  final MatchCapabilityVersion requiredVersion;
  final List<MatchCapabilityVersion> supportedVersions;

  @override
  List<Object?> get components => [
        requiredVersion,
        supportedVersions.length,
        ...supportedVersions,
      ];
}

final class MatchCapabilityMetadata extends ValueObject {
  MatchCapabilityMetadata({
    required this.identity,
    required this.version,
    Iterable<MatchCapabilityKind> kinds = const [],
  }) : kinds = immutableList(kinds);

  final MatchCapabilityIdentity identity;
  final MatchCapabilityVersion version;
  final List<MatchCapabilityKind> kinds;

  @override
  List<Object?> get components => [
        identity,
        version,
        kinds.length,
        ...kinds,
      ];
}

final class MatchCapabilityProvenance extends ValueObject {
  const MatchCapabilityProvenance({
    required this.source,
    required this.digest,
    required this.metadata,
  });

  final RuntimeIdentifier source;
  final String digest;
  final MatchCapabilityMetadata metadata;

  @override
  List<Object?> get components => [source, digest, metadata];
}

final class MatchCapabilityContext extends ValueObject {
  const MatchCapabilityContext({
    required this.requestId,
    required this.metadata,
    required this.compatibility,
  });

  final RuntimeIdentifier requestId;
  final MatchCapabilityMetadata metadata;
  final MatchCapabilityCompatibility compatibility;

  @override
  List<Object?> get components => [requestId, metadata, compatibility];
}

final class MatchCapabilityResult<TValue extends ValueObject>
    extends ValueObject {
  const MatchCapabilityResult({
    required this.value,
    required this.metadata,
    required this.provenance,
  });

  final TValue value;
  final MatchCapabilityMetadata metadata;
  final MatchCapabilityProvenance provenance;

  @override
  List<Object?> get components => [value, metadata, provenance];
}

abstract interface class MatchCapabilityContract {
  MatchCapabilityMetadata get metadata;
}

abstract interface class MatchLifecycleCapability
    implements MatchCapabilityContract {}

abstract interface class RackManagementCapability
    implements MatchCapabilityContract {}

abstract interface class MatchScoringCapability
    implements MatchCapabilityContract {}

abstract interface class MatchValidationCapability
    implements MatchCapabilityContract {}

abstract interface class MatchStatisticsCapability
    implements MatchCapabilityContract {}
