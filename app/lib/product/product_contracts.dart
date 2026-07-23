import '../shared/foundation/identifier.dart';
import '../shared/foundation/immutable.dart';
import '../shared/foundation/value_object.dart';

final class ProductIdentity extends ValueObject {
  const ProductIdentity(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class ProductVersion extends ValueObject {
  const ProductVersion(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class ProductCompatibility extends ValueObject {
  ProductCompatibility({
    required this.requiredVersion,
    Iterable<ProductVersion> supportedVersions = const [],
  }) : supportedVersions = immutableList(supportedVersions);

  final ProductVersion requiredVersion;
  final List<ProductVersion> supportedVersions;

  @override
  List<Object?> get components => [
        requiredVersion,
        supportedVersions.length,
        ...supportedVersions,
      ];
}

final class ProductMetadata extends ValueObject {
  const ProductMetadata({
    required this.identity,
    required this.version,
  });

  final ProductIdentity identity;
  final ProductVersion version;

  @override
  List<Object?> get components => [identity, version];
}

final class ProductCapabilityBinding extends ValueObject {
  const ProductCapabilityBinding({
    required this.productIdentity,
    required this.moduleIdentity,
    required this.capabilityIdentity,
  });

  final ProductIdentity productIdentity;
  final RuntimeIdentifier moduleIdentity;
  final RuntimeIdentifier capabilityIdentity;

  @override
  List<Object?> get components => [
        productIdentity,
        moduleIdentity,
        capabilityIdentity,
      ];
}

final class ProductConfiguration extends ValueObject {
  ProductConfiguration({
    required this.identity,
    required this.version,
    Iterable<ProductCapabilityBinding> capabilityBindings = const [],
  }) : capabilityBindings = immutableList(capabilityBindings);

  final RuntimeIdentifier identity;
  final ProductVersion version;
  final List<ProductCapabilityBinding> capabilityBindings;

  @override
  List<Object?> get components => [
        identity,
        version,
        capabilityBindings.length,
        ...capabilityBindings,
      ];
}

final class ProductProvenance extends ValueObject {
  const ProductProvenance({
    required this.source,
    required this.digest,
    required this.metadata,
  });

  final RuntimeIdentifier source;
  final String digest;
  final ProductMetadata metadata;

  @override
  List<Object?> get components => [source, digest, metadata];
}

abstract interface class ProductContract {
  ProductMetadata get metadata;
}

abstract interface class ProductComposition implements ProductContract {}

abstract interface class ProductModule implements ProductContract {}
