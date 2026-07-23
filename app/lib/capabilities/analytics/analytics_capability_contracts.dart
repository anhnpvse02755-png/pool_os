import '../../shared/foundation/identifier.dart';
import '../../shared/foundation/immutable.dart';
import '../../shared/foundation/value_object.dart';

enum AnalyticsCapabilityKind {
  lifecycle,
  statisticsCollection,
  performanceAnalysis,
  trendAnalysis,
  reporting,
  validation,
}

final class AnalyticsCapabilityIdentity extends ValueObject {
  const AnalyticsCapabilityIdentity(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class AnalyticsCapabilityVersion extends ValueObject {
  const AnalyticsCapabilityVersion(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class AnalyticsCapabilityCompatibility extends ValueObject {
  AnalyticsCapabilityCompatibility({
    required this.requiredVersion,
    Iterable<AnalyticsCapabilityVersion> supportedVersions = const [],
  }) : supportedVersions = immutableList(supportedVersions);

  final AnalyticsCapabilityVersion requiredVersion;
  final List<AnalyticsCapabilityVersion> supportedVersions;

  @override
  List<Object?> get components => [
        requiredVersion,
        supportedVersions.length,
        ...supportedVersions,
      ];
}

final class AnalyticsCapabilityMetadata extends ValueObject {
  AnalyticsCapabilityMetadata({
    required this.identity,
    required this.version,
    Iterable<AnalyticsCapabilityKind> kinds = const [],
  }) : kinds = immutableList(kinds);

  final AnalyticsCapabilityIdentity identity;
  final AnalyticsCapabilityVersion version;
  final List<AnalyticsCapabilityKind> kinds;

  @override
  List<Object?> get components => [
        identity,
        version,
        kinds.length,
        ...kinds,
      ];
}

final class AnalyticsCapabilityProvenance extends ValueObject {
  const AnalyticsCapabilityProvenance({
    required this.source,
    required this.digest,
    required this.metadata,
  });

  final RuntimeIdentifier source;
  final String digest;
  final AnalyticsCapabilityMetadata metadata;

  @override
  List<Object?> get components => [source, digest, metadata];
}

final class AnalyticsCapabilityContext extends ValueObject {
  const AnalyticsCapabilityContext({
    required this.requestId,
    required this.metadata,
    required this.compatibility,
  });

  final RuntimeIdentifier requestId;
  final AnalyticsCapabilityMetadata metadata;
  final AnalyticsCapabilityCompatibility compatibility;

  @override
  List<Object?> get components => [requestId, metadata, compatibility];
}

final class AnalyticsCapabilityResult<TValue extends ValueObject>
    extends ValueObject {
  const AnalyticsCapabilityResult({
    required this.value,
    required this.metadata,
    required this.provenance,
  });

  final TValue value;
  final AnalyticsCapabilityMetadata metadata;
  final AnalyticsCapabilityProvenance provenance;

  @override
  List<Object?> get components => [value, metadata, provenance];
}

abstract interface class AnalyticsCapabilityContract {
  AnalyticsCapabilityMetadata get metadata;
}

abstract interface class AnalyticsLifecycleCapability
    implements AnalyticsCapabilityContract {}

abstract interface class StatisticsCollectionCapability
    implements AnalyticsCapabilityContract {}

abstract interface class PerformanceAnalysisCapability
    implements AnalyticsCapabilityContract {}

abstract interface class TrendAnalysisCapability
    implements AnalyticsCapabilityContract {}

abstract interface class ReportingCapability
    implements AnalyticsCapabilityContract {}

abstract interface class AnalyticsValidationCapability
    implements AnalyticsCapabilityContract {}
