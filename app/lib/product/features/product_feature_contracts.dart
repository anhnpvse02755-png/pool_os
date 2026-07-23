import '../../shared/foundation/identifier.dart';
import '../../shared/foundation/immutable.dart';
import '../../shared/foundation/value_object.dart';

final class ProductFeatureIdentity extends ValueObject {
  const ProductFeatureIdentity(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class ProductFeatureVersion extends ValueObject {
  const ProductFeatureVersion(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class ProductFeatureCompatibility extends ValueObject {
  ProductFeatureCompatibility({
    required this.requiredVersion,
    Iterable<ProductFeatureVersion> supportedVersions = const [],
  }) : supportedVersions = immutableList(supportedVersions);

  final ProductFeatureVersion requiredVersion;
  final List<ProductFeatureVersion> supportedVersions;

  @override
  List<Object?> get components => [
        requiredVersion,
        supportedVersions.length,
        ...supportedVersions,
      ];
}

final class ProductFeatureCapability extends ValueObject {
  const ProductFeatureCapability(this.identity);

  final RuntimeIdentifier identity;

  @override
  List<Object?> get components => [identity];
}

final class ProductFeatureDependency extends ValueObject {
  const ProductFeatureDependency({
    required this.source,
    required this.target,
  });

  final ProductFeatureIdentity source;
  final ProductFeatureIdentity target;

  @override
  List<Object?> get components => [source, target];
}

final class ProductFeatureMetadata extends ValueObject {
  ProductFeatureMetadata({
    required this.identity,
    required this.version,
    Iterable<ProductFeatureCapability> capabilities = const [],
  }) : capabilities = immutableList(capabilities);

  final ProductFeatureIdentity identity;
  final ProductFeatureVersion version;
  final List<ProductFeatureCapability> capabilities;

  @override
  List<Object?> get components => [
        identity,
        version,
        capabilities.length,
        ...capabilities,
      ];
}

final class ProductFeatureConfiguration extends ValueObject {
  ProductFeatureConfiguration({
    required this.identity,
    required this.version,
    Iterable<ProductFeatureCapability> capabilities = const [],
    Iterable<ProductFeatureDependency> dependencies = const [],
  })  : capabilities = immutableList(capabilities),
        dependencies = immutableList(dependencies);

  final RuntimeIdentifier identity;
  final ProductFeatureVersion version;
  final List<ProductFeatureCapability> capabilities;
  final List<ProductFeatureDependency> dependencies;

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

final class ProductFeatureProvenance extends ValueObject {
  const ProductFeatureProvenance({
    required this.source,
    required this.digest,
    required this.metadata,
  });

  final RuntimeIdentifier source;
  final String digest;
  final ProductFeatureMetadata metadata;

  @override
  List<Object?> get components => [source, digest, metadata];
}

abstract interface class ProductFeatureContract {
  ProductFeatureMetadata get metadata;
}
