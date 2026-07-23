import '../../shared/foundation/identifier.dart';
import '../../shared/foundation/immutable.dart';
import '../../shared/foundation/value_object.dart';

enum TrainingCapabilityKind {
  lifecycle,
  exerciseManagement,
  sessionPlanning,
  progressTracking,
  validation,
  statistics,
}

final class TrainingCapabilityIdentity extends ValueObject {
  const TrainingCapabilityIdentity(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class TrainingCapabilityVersion extends ValueObject {
  const TrainingCapabilityVersion(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class TrainingCapabilityCompatibility extends ValueObject {
  TrainingCapabilityCompatibility({
    required this.requiredVersion,
    Iterable<TrainingCapabilityVersion> supportedVersions = const [],
  }) : supportedVersions = immutableList(supportedVersions);

  final TrainingCapabilityVersion requiredVersion;
  final List<TrainingCapabilityVersion> supportedVersions;

  @override
  List<Object?> get components => [
        requiredVersion,
        supportedVersions.length,
        ...supportedVersions,
      ];
}

final class TrainingCapabilityMetadata extends ValueObject {
  TrainingCapabilityMetadata({
    required this.identity,
    required this.version,
    Iterable<TrainingCapabilityKind> kinds = const [],
  }) : kinds = immutableList(kinds);

  final TrainingCapabilityIdentity identity;
  final TrainingCapabilityVersion version;
  final List<TrainingCapabilityKind> kinds;

  @override
  List<Object?> get components => [
        identity,
        version,
        kinds.length,
        ...kinds,
      ];
}

final class TrainingCapabilityProvenance extends ValueObject {
  const TrainingCapabilityProvenance({
    required this.source,
    required this.digest,
    required this.metadata,
  });

  final RuntimeIdentifier source;
  final String digest;
  final TrainingCapabilityMetadata metadata;

  @override
  List<Object?> get components => [source, digest, metadata];
}

final class TrainingCapabilityContext extends ValueObject {
  const TrainingCapabilityContext({
    required this.requestId,
    required this.metadata,
    required this.compatibility,
  });

  final RuntimeIdentifier requestId;
  final TrainingCapabilityMetadata metadata;
  final TrainingCapabilityCompatibility compatibility;

  @override
  List<Object?> get components => [requestId, metadata, compatibility];
}

final class TrainingCapabilityResult<TValue extends ValueObject>
    extends ValueObject {
  const TrainingCapabilityResult({
    required this.value,
    required this.metadata,
    required this.provenance,
  });

  final TValue value;
  final TrainingCapabilityMetadata metadata;
  final TrainingCapabilityProvenance provenance;

  @override
  List<Object?> get components => [value, metadata, provenance];
}

abstract interface class TrainingCapabilityContract {
  TrainingCapabilityMetadata get metadata;
}

abstract interface class TrainingLifecycleCapability
    implements TrainingCapabilityContract {}

abstract interface class ExerciseManagementCapability
    implements TrainingCapabilityContract {}

abstract interface class SessionPlanningCapability
    implements TrainingCapabilityContract {}

abstract interface class ProgressTrackingCapability
    implements TrainingCapabilityContract {}

abstract interface class TrainingValidationCapability
    implements TrainingCapabilityContract {}

abstract interface class TrainingStatisticsCapability
    implements TrainingCapabilityContract {}
