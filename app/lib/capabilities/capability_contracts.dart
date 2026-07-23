import '../shared/foundation/identifier.dart';
import '../shared/foundation/immutable.dart';
import '../shared/foundation/value_object.dart';

enum CapabilityKind {
  match,
  training,
  coach,
  knowledge,
  analytics,
  simulation,
}

final class CapabilityIdentity extends ValueObject {
  const CapabilityIdentity(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class CapabilityVersion extends ValueObject {
  const CapabilityVersion(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class CapabilityCompatibility extends ValueObject {
  CapabilityCompatibility({
    required this.requiredVersion,
    Iterable<CapabilityVersion> supportedVersions = const [],
  }) : supportedVersions = immutableList(supportedVersions);

  final CapabilityVersion requiredVersion;
  final List<CapabilityVersion> supportedVersions;

  @override
  List<Object?> get components => [
        requiredVersion,
        supportedVersions.length,
        ...supportedVersions,
      ];
}

final class CapabilityMetadata extends ValueObject {
  CapabilityMetadata({
    required this.identity,
    required this.version,
    Iterable<CapabilityKind> kinds = const [],
  }) : kinds = immutableList(kinds);

  final CapabilityIdentity identity;
  final CapabilityVersion version;
  final List<CapabilityKind> kinds;

  @override
  List<Object?> get components => [
        identity,
        version,
        kinds.length,
        ...kinds,
      ];
}

final class CapabilityProvenance extends ValueObject {
  const CapabilityProvenance({
    required this.source,
    required this.digest,
    required this.metadata,
  });

  final RuntimeIdentifier source;
  final String digest;
  final CapabilityMetadata metadata;

  @override
  List<Object?> get components => [source, digest, metadata];
}

final class CapabilityContext extends ValueObject {
  const CapabilityContext({
    required this.requestId,
    required this.metadata,
    required this.compatibility,
  });

  final RuntimeIdentifier requestId;
  final CapabilityMetadata metadata;
  final CapabilityCompatibility compatibility;

  @override
  List<Object?> get components => [requestId, metadata, compatibility];
}

final class CapabilityResult<TValue extends ValueObject> extends ValueObject {
  const CapabilityResult({
    required this.value,
    required this.metadata,
    required this.provenance,
  });

  final TValue value;
  final CapabilityMetadata metadata;
  final CapabilityProvenance provenance;

  @override
  List<Object?> get components => [value, metadata, provenance];
}

abstract interface class CapabilityContract {
  CapabilityMetadata get metadata;
}

abstract interface class MatchCapability implements CapabilityContract {}

abstract interface class TrainingCapability implements CapabilityContract {}

abstract interface class CoachCapability implements CapabilityContract {}

abstract interface class KnowledgeCapability implements CapabilityContract {}

abstract interface class AnalyticsCapability implements CapabilityContract {}

abstract interface class SimulationCapability implements CapabilityContract {}
