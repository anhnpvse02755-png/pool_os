import '../../shared/foundation/identifier.dart';
import '../../shared/foundation/immutable.dart';
import '../../shared/foundation/result.dart';
import '../../shared/foundation/value_object.dart';
import '../contracts/infrastructure_contracts.dart';

enum ConfigurationCapability { provide, snapshot, source }

final class ConfigurationIdentity extends ValueObject {
  const ConfigurationIdentity(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class ConfigurationVersion extends ValueObject {
  const ConfigurationVersion(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class ConfigurationSource extends ValueObject {
  const ConfigurationSource({
    required this.identity,
    required this.version,
  });

  final ConfigurationIdentity identity;
  final ConfigurationVersion version;

  @override
  List<Object?> get components => [identity, version];
}

final class ConfigurationMetadata extends ValueObject {
  ConfigurationMetadata({
    required this.adapter,
    required this.source,
    Iterable<ConfigurationCapability> capabilities = const [],
  }) : capabilities = immutableList(capabilities);

  final AdapterIdentity adapter;
  final ConfigurationSource source;
  final List<ConfigurationCapability> capabilities;

  @override
  List<Object?> get components => [
        adapter,
        source,
        capabilities.length,
        ...capabilities,
      ];
}

final class ConfigurationCompatibility extends ValueObject {
  ConfigurationCompatibility({
    required this.requiredVersion,
    Iterable<ConfigurationVersion> supportedVersions = const [],
  }) : supportedVersions = immutableList(supportedVersions);

  final ConfigurationVersion requiredVersion;
  final List<ConfigurationVersion> supportedVersions;

  @override
  List<Object?> get components => [
        requiredVersion,
        supportedVersions.length,
        ...supportedVersions,
      ];
}

final class ConfigurationProvenance extends ValueObject {
  const ConfigurationProvenance({
    required this.metadata,
    required this.adapter,
  });

  final ConfigurationMetadata metadata;
  final AdapterProvenance adapter;

  @override
  List<Object?> get components => [metadata, adapter];
}

final class ConfigurationSnapshot<TConfiguration extends ValueObject>
    extends ValueObject {
  const ConfigurationSnapshot({
    required this.value,
    required this.version,
    required this.provenance,
  });

  final TConfiguration value;
  final ConfigurationVersion version;
  final ConfigurationProvenance provenance;

  @override
  List<Object?> get components => [value, version, provenance];
}

final class ConfigurationExecutionContext extends ValueObject {
  const ConfigurationExecutionContext({
    required this.requestId,
    required this.adapter,
    required this.compatibility,
  });

  final RuntimeIdentifier requestId;
  final AdapterExecutionContext adapter;
  final ConfigurationCompatibility compatibility;

  @override
  List<Object?> get components => [requestId, adapter, compatibility];
}

final class ConfigurationExecutionResult<TConfiguration extends ValueObject>
    extends ValueObject {
  const ConfigurationExecutionResult({
    required this.snapshot,
    required this.capability,
    required this.provenance,
  });

  final ConfigurationSnapshot<TConfiguration> snapshot;
  final ConfigurationCapability capability;
  final ConfigurationProvenance provenance;

  @override
  List<Object?> get components => [snapshot, capability, provenance];
}

abstract interface class ConfigurationAdapter<
    TConfiguration extends ValueObject> {
  ConfigurationMetadata get metadata;
}

abstract interface class ConfigurationProvider<
        TConfiguration extends ValueObject>
    implements ConfigurationAdapter<TConfiguration> {
  Future<Result<ConfigurationExecutionResult<TConfiguration>>> provide(
    ConfigurationExecutionContext context,
  );
}
