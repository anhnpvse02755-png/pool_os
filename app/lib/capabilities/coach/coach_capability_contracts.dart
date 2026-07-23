import '../../shared/foundation/identifier.dart';
import '../../shared/foundation/immutable.dart';
import '../../shared/foundation/value_object.dart';

enum CoachCapabilityKind {
  sessionLifecycle,
  adviceGeneration,
  performanceReview,
  recommendationRequest,
  feedbackCollection,
  validation,
}

final class CoachCapabilityIdentity extends ValueObject {
  const CoachCapabilityIdentity(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class CoachCapabilityVersion extends ValueObject {
  const CoachCapabilityVersion(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class CoachCapabilityCompatibility extends ValueObject {
  CoachCapabilityCompatibility({
    required this.requiredVersion,
    Iterable<CoachCapabilityVersion> supportedVersions = const [],
  }) : supportedVersions = immutableList(supportedVersions);

  final CoachCapabilityVersion requiredVersion;
  final List<CoachCapabilityVersion> supportedVersions;

  @override
  List<Object?> get components => [
        requiredVersion,
        supportedVersions.length,
        ...supportedVersions,
      ];
}

final class CoachCapabilityMetadata extends ValueObject {
  CoachCapabilityMetadata({
    required this.identity,
    required this.version,
    Iterable<CoachCapabilityKind> kinds = const [],
  }) : kinds = immutableList(kinds);

  final CoachCapabilityIdentity identity;
  final CoachCapabilityVersion version;
  final List<CoachCapabilityKind> kinds;

  @override
  List<Object?> get components => [
        identity,
        version,
        kinds.length,
        ...kinds,
      ];
}

final class CoachCapabilityProvenance extends ValueObject {
  const CoachCapabilityProvenance({
    required this.source,
    required this.digest,
    required this.metadata,
  });

  final RuntimeIdentifier source;
  final String digest;
  final CoachCapabilityMetadata metadata;

  @override
  List<Object?> get components => [source, digest, metadata];
}

final class CoachCapabilityContext extends ValueObject {
  const CoachCapabilityContext({
    required this.requestId,
    required this.metadata,
    required this.compatibility,
  });

  final RuntimeIdentifier requestId;
  final CoachCapabilityMetadata metadata;
  final CoachCapabilityCompatibility compatibility;

  @override
  List<Object?> get components => [requestId, metadata, compatibility];
}

final class CoachCapabilityResult<TValue extends ValueObject>
    extends ValueObject {
  const CoachCapabilityResult({
    required this.value,
    required this.metadata,
    required this.provenance,
  });

  final TValue value;
  final CoachCapabilityMetadata metadata;
  final CoachCapabilityProvenance provenance;

  @override
  List<Object?> get components => [value, metadata, provenance];
}

abstract interface class CoachCapabilityContract {
  CoachCapabilityMetadata get metadata;
}

abstract interface class CoachSessionLifecycleCapability
    implements CoachCapabilityContract {}

abstract interface class AdviceGenerationCapability
    implements CoachCapabilityContract {}

abstract interface class PerformanceReviewCapability
    implements CoachCapabilityContract {}

abstract interface class RecommendationRequestCapability
    implements CoachCapabilityContract {}

abstract interface class FeedbackCollectionCapability
    implements CoachCapabilityContract {}

abstract interface class CoachValidationCapability
    implements CoachCapabilityContract {}
