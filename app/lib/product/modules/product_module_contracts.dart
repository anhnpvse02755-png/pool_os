import '../../shared/foundation/identifier.dart';
import '../../shared/foundation/immutable.dart';
import '../../shared/foundation/value_object.dart';

final class ProductModuleIdentity extends ValueObject {
  const ProductModuleIdentity(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class ProductModuleVersion extends ValueObject {
  const ProductModuleVersion(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class ProductModuleCompatibility extends ValueObject {
  ProductModuleCompatibility({
    required this.requiredVersion,
    Iterable<ProductModuleVersion> supportedVersions = const [],
  }) : supportedVersions = immutableList(supportedVersions);

  final ProductModuleVersion requiredVersion;
  final List<ProductModuleVersion> supportedVersions;

  @override
  List<Object?> get components => [
        requiredVersion,
        supportedVersions.length,
        ...supportedVersions,
      ];
}

final class ProductModuleCapability extends ValueObject {
  const ProductModuleCapability(this.identity);

  final RuntimeIdentifier identity;

  @override
  List<Object?> get components => [identity];
}

final class ProductModuleDependency extends ValueObject {
  const ProductModuleDependency({
    required this.source,
    required this.target,
  });

  final ProductModuleIdentity source;
  final ProductModuleIdentity target;

  @override
  List<Object?> get components => [source, target];
}

final class ProductModuleMetadata extends ValueObject {
  ProductModuleMetadata({
    required this.identity,
    required this.version,
    Iterable<ProductModuleCapability> capabilities = const [],
  }) : capabilities = immutableList(capabilities);

  final ProductModuleIdentity identity;
  final ProductModuleVersion version;
  final List<ProductModuleCapability> capabilities;

  @override
  List<Object?> get components => [
        identity,
        version,
        capabilities.length,
        ...capabilities,
      ];
}

final class ProductModuleConfiguration extends ValueObject {
  ProductModuleConfiguration({
    required this.identity,
    required this.version,
    Iterable<ProductModuleCapability> capabilities = const [],
    Iterable<ProductModuleDependency> dependencies = const [],
  })  : capabilities = immutableList(capabilities),
        dependencies = immutableList(dependencies);

  final RuntimeIdentifier identity;
  final ProductModuleVersion version;
  final List<ProductModuleCapability> capabilities;
  final List<ProductModuleDependency> dependencies;

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

final class ProductModuleProvenance extends ValueObject {
  const ProductModuleProvenance({
    required this.source,
    required this.digest,
    required this.metadata,
  });

  final RuntimeIdentifier source;
  final String digest;
  final ProductModuleMetadata metadata;

  @override
  List<Object?> get components => [source, digest, metadata];
}

abstract interface class ProductModuleContract {
  ProductModuleMetadata get metadata;
}
