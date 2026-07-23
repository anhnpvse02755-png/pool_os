import '../../shared/foundation/identifier.dart';
import '../../shared/foundation/immutable.dart';
import '../../shared/foundation/value_object.dart';

final class FeatureCompositionIdentity extends ValueObject {
  const FeatureCompositionIdentity(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class FeatureCompositionVersion extends ValueObject {
  const FeatureCompositionVersion(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class FeatureCompositionCompatibility extends ValueObject {
  FeatureCompositionCompatibility({
    required this.requiredVersion,
    Iterable<FeatureCompositionVersion> supportedVersions = const [],
  }) : supportedVersions = immutableList(supportedVersions);

  final FeatureCompositionVersion requiredVersion;
  final List<FeatureCompositionVersion> supportedVersions;

  @override
  List<Object?> get components => [
        requiredVersion,
        supportedVersions.length,
        ...supportedVersions,
      ];
}

final class FeatureCompositionCapability extends ValueObject {
  const FeatureCompositionCapability(this.identity);

  final RuntimeIdentifier identity;

  @override
  List<Object?> get components => [identity];
}

final class FeatureCompositionDependency extends ValueObject {
  const FeatureCompositionDependency({
    required this.source,
    required this.target,
  });

  final FeatureCompositionIdentity source;
  final FeatureCompositionIdentity target;

  @override
  List<Object?> get components => [source, target];
}

final class FeatureCompositionMetadata extends ValueObject {
  FeatureCompositionMetadata({
    required this.identity,
    required this.version,
    Iterable<FeatureCompositionCapability> capabilities = const [],
  }) : capabilities = immutableList(capabilities);

  final FeatureCompositionIdentity identity;
  final FeatureCompositionVersion version;
  final List<FeatureCompositionCapability> capabilities;

  @override
  List<Object?> get components => [
        identity,
        version,
        capabilities.length,
        ...capabilities,
      ];
}

final class FeatureCompositionConfiguration extends ValueObject {
  FeatureCompositionConfiguration({
    required this.identity,
    required this.version,
    Iterable<FeatureCompositionCapability> capabilities = const [],
    Iterable<FeatureCompositionDependency> dependencies = const [],
  })  : capabilities = immutableList(capabilities),
        dependencies = immutableList(dependencies);

  final RuntimeIdentifier identity;
  final FeatureCompositionVersion version;
  final List<FeatureCompositionCapability> capabilities;
  final List<FeatureCompositionDependency> dependencies;

  @override
  List<Object?> get components => [
        identity,
        version,
        capabilities.length,
        ...capabilities,
        dependencies.length,
        ...dependencies,
      ];
}

final class FeatureCompositionProvenance extends ValueObject {
  const FeatureCompositionProvenance({
    required this.source,
    required this.digest,
    required this.metadata,
  });

  final RuntimeIdentifier source;
  final String digest;
  final FeatureCompositionMetadata metadata;

  @override
  List<Object?> get components => [source, digest, metadata];
}

abstract interface class FeatureCompositionContract {
  FeatureCompositionMetadata get metadata;
}
