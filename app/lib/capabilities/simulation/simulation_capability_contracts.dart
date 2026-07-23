import '../../shared/foundation/identifier.dart';
import '../../shared/foundation/immutable.dart';
import '../../shared/foundation/value_object.dart';

enum SimulationCapabilityKind {
  lifecycle,
  scenarioPreparation,
  execution,
  resultCollection,
  scenarioValidation,
  statistics,
}

final class SimulationCapabilityIdentity extends ValueObject {
  const SimulationCapabilityIdentity(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class SimulationCapabilityVersion extends ValueObject {
  const SimulationCapabilityVersion(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class SimulationCapabilityCompatibility extends ValueObject {
  SimulationCapabilityCompatibility({
    required this.requiredVersion,
    Iterable<SimulationCapabilityVersion> supportedVersions = const [],
  }) : supportedVersions = immutableList(supportedVersions);

  final SimulationCapabilityVersion requiredVersion;
  final List<SimulationCapabilityVersion> supportedVersions;

  @override
  List<Object?> get components => [
        requiredVersion,
        supportedVersions.length,
        ...supportedVersions,
      ];
}

final class SimulationCapabilityMetadata extends ValueObject {
  SimulationCapabilityMetadata({
    required this.identity,
    required this.version,
    Iterable<SimulationCapabilityKind> kinds = const [],
  }) : kinds = immutableList(kinds);

  final SimulationCapabilityIdentity identity;
  final SimulationCapabilityVersion version;
  final List<SimulationCapabilityKind> kinds;

  @override
  List<Object?> get components => [
        identity,
        version,
        kinds.length,
        ...kinds,
      ];
}

final class SimulationCapabilityProvenance extends ValueObject {
  const SimulationCapabilityProvenance({
    required this.source,
    required this.digest,
    required this.metadata,
  });

  final RuntimeIdentifier source;
  final String digest;
  final SimulationCapabilityMetadata metadata;

  @override
  List<Object?> get components => [source, digest, metadata];
}

final class SimulationCapabilityContext extends ValueObject {
  const SimulationCapabilityContext({
    required this.requestId,
    required this.metadata,
    required this.compatibility,
  });

  final RuntimeIdentifier requestId;
  final SimulationCapabilityMetadata metadata;
  final SimulationCapabilityCompatibility compatibility;

  @override
  List<Object?> get components => [requestId, metadata, compatibility];
}

final class SimulationCapabilityResult<TValue extends ValueObject>
    extends ValueObject {
  const SimulationCapabilityResult({
    required this.value,
    required this.metadata,
    required this.provenance,
  });

  final TValue value;
  final SimulationCapabilityMetadata metadata;
  final SimulationCapabilityProvenance provenance;

  @override
  List<Object?> get components => [value, metadata, provenance];
}

abstract interface class SimulationCapabilityContract {
  SimulationCapabilityMetadata get metadata;
}

abstract interface class SimulationLifecycleCapability
    implements SimulationCapabilityContract {}

abstract interface class ScenarioPreparationCapability
    implements SimulationCapabilityContract {}

abstract interface class SimulationExecutionCapability
    implements SimulationCapabilityContract {}

abstract interface class ResultCollectionCapability
    implements SimulationCapabilityContract {}

abstract interface class ScenarioValidationCapability
    implements SimulationCapabilityContract {}

abstract interface class SimulationStatisticsCapability
    implements SimulationCapabilityContract {}
