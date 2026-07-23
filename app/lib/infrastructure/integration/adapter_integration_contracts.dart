import '../../shared/foundation/identifier.dart';
import '../../shared/foundation/immutable.dart';
import '../../shared/foundation/value_object.dart';
import '../contracts/infrastructure_contracts.dart';

final class AdapterVersion extends ValueObject {
  const AdapterVersion(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class AdapterCompatibility extends ValueObject {
  AdapterCompatibility({
    required this.requiredVersion,
    Iterable<AdapterVersion> supportedVersions = const [],
  }) : supportedVersions = immutableList(supportedVersions);

  final AdapterVersion requiredVersion;
  final List<AdapterVersion> supportedVersions;

  @override
  List<Object?> get components => [
        requiredVersion,
        supportedVersions.length,
        ...supportedVersions,
      ];
}

final class AdapterBinding extends ValueObject {
  AdapterBinding({
    required this.identity,
    required this.version,
    Iterable<InfrastructureCapability> capabilities = const [],
  }) : capabilities = immutableList(capabilities);

  final AdapterIdentity identity;
  final AdapterVersion version;
  final List<InfrastructureCapability> capabilities;

  @override
  List<Object?> get components => [
        identity,
        version,
        capabilities.length,
        ...capabilities,
      ];
}

final class AdapterResolutionContract extends ValueObject {
  AdapterResolutionContract({
    required this.requestId,
    required this.identity,
    required this.compatibility,
    Iterable<InfrastructureCapability> requiredCapabilities = const [],
  }) : requiredCapabilities = immutableList(requiredCapabilities);

  final RuntimeIdentifier requestId;
  final AdapterIdentity identity;
  final AdapterCompatibility compatibility;
  final List<InfrastructureCapability> requiredCapabilities;

  @override
  List<Object?> get components => [
        requestId,
        identity,
        compatibility,
        requiredCapabilities.length,
        ...requiredCapabilities,
      ];
}

final class AdapterIntegrationMetadata extends ValueObject {
  AdapterIntegrationMetadata({
    required this.identity,
    required this.version,
    Iterable<AdapterBinding> bindings = const [],
  }) : bindings = immutableList(bindings);

  final AdapterIdentity identity;
  final AdapterVersion version;
  final List<AdapterBinding> bindings;

  @override
  List<Object?> get components => [
        identity,
        version,
        bindings.length,
        ...bindings,
      ];
}

final class AdapterIntegrationProvenance extends ValueObject {
  const AdapterIntegrationProvenance({
    required this.metadata,
    required this.adapter,
  });

  final AdapterIntegrationMetadata metadata;
  final AdapterProvenance adapter;

  @override
  List<Object?> get components => [metadata, adapter];
}

abstract interface class InfrastructureIntegrationAdapter<TRequest,
        TResult extends ValueObject>
    implements InfrastructureAdapter<TRequest, TResult> {
  AdapterIntegrationMetadata get integrationMetadata;
}

abstract interface class AdapterRegistry {
  AdapterIntegrationMetadata get metadata;
}

abstract interface class AdapterCapabilityRegistry {
  AdapterIntegrationMetadata get metadata;
}

abstract interface class InboundAdapterBinding {
  AdapterBinding get binding;
}

abstract interface class OutboundAdapterBinding {
  AdapterBinding get binding;
}

abstract interface class LocalAdapterBinding {
  AdapterBinding get binding;
}
