import '../../shared/foundation/identifier.dart';
import '../../shared/foundation/immutable.dart';
import '../../shared/foundation/value_object.dart';

final class ProductRuntimeIdentity extends ValueObject {
  const ProductRuntimeIdentity(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class ProductRuntimeVersion extends ValueObject {
  const ProductRuntimeVersion(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class ProductRuntimeCompatibility extends ValueObject {
  ProductRuntimeCompatibility({
    required this.requiredVersion,
    Iterable<ProductRuntimeVersion> supportedVersions = const [],
  }) : supportedVersions = immutableList(supportedVersions);

  final ProductRuntimeVersion requiredVersion;
  final List<ProductRuntimeVersion> supportedVersions;

  @override
  List<Object?> get components => [
        requiredVersion,
        supportedVersions.length,
        ...supportedVersions,
      ];
}

final class ProductRuntimeCapability extends ValueObject {
  const ProductRuntimeCapability(this.identity);

  final RuntimeIdentifier identity;

  @override
  List<Object?> get components => [identity];
}

final class ProductRuntimeMetadata extends ValueObject {
  ProductRuntimeMetadata({
    required this.identity,
    required this.version,
    Iterable<ProductRuntimeCapability> capabilities = const [],
  }) : capabilities = immutableList(capabilities);

  final ProductRuntimeIdentity identity;
  final ProductRuntimeVersion version;
  final List<ProductRuntimeCapability> capabilities;

  @override
  List<Object?> get components => [
        identity,
        version,
        capabilities.length,
        ...capabilities,
      ];
}

final class ProductRuntimeConfiguration extends ValueObject {
  ProductRuntimeConfiguration({
    required this.identity,
    required this.version,
    Iterable<ProductRuntimeCapability> capabilities = const [],
  }) : capabilities = immutableList(capabilities);

  final RuntimeIdentifier identity;
  final ProductRuntimeVersion version;
  final List<ProductRuntimeCapability> capabilities;

  @override
  List<Object?> get components => [
        identity,
        version,
        capabilities.length,
        ...capabilities,
      ];
}

final class ProductRuntimeProvenance extends ValueObject {
  const ProductRuntimeProvenance({
    required this.source,
    required this.digest,
    required this.metadata,
  });

  final RuntimeIdentifier source;
  final String digest;
  final ProductRuntimeMetadata metadata;

  @override
  List<Object?> get components => [source, digest, metadata];
}

abstract interface class ProductRuntimeAssemblyContract {
  ProductRuntimeMetadata get metadata;
}
