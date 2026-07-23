import '../../shared/foundation/identifier.dart';
import '../../shared/foundation/immutable.dart';
import '../../shared/foundation/result.dart';
import '../../shared/foundation/value_object.dart';
import '../contracts/infrastructure_contracts.dart';

enum SerializationCapability { serialize, deserialize, codec }

final class SerializationIdentity extends ValueObject {
  const SerializationIdentity(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class SerializationVersion extends ValueObject {
  const SerializationVersion(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class SerializationFormat extends ValueObject {
  const SerializationFormat({
    required this.identity,
    required this.version,
  });

  final SerializationIdentity identity;
  final SerializationVersion version;

  @override
  List<Object?> get components => [identity, version];
}

final class SerializationMetadata extends ValueObject {
  SerializationMetadata({
    required this.adapter,
    required this.format,
    Iterable<SerializationCapability> capabilities = const [],
  }) : capabilities = immutableList(capabilities);

  final AdapterIdentity adapter;
  final SerializationFormat format;
  final List<SerializationCapability> capabilities;

  @override
  List<Object?> get components => [
        adapter,
        format,
        capabilities.length,
        ...capabilities,
      ];
}

final class SerializationCompatibility extends ValueObject {
  SerializationCompatibility({
    required this.requiredVersion,
    Iterable<SerializationVersion> supportedVersions = const [],
  }) : supportedVersions = immutableList(supportedVersions);

  final SerializationVersion requiredVersion;
  final List<SerializationVersion> supportedVersions;

  @override
  List<Object?> get components => [
        requiredVersion,
        supportedVersions.length,
        ...supportedVersions,
      ];
}

final class SerializationProvenance extends ValueObject {
  const SerializationProvenance({
    required this.metadata,
    required this.adapter,
  });

  final SerializationMetadata metadata;
  final AdapterProvenance adapter;

  @override
  List<Object?> get components => [metadata, adapter];
}

final class SerializationContext extends ValueObject {
  const SerializationContext({
    required this.requestId,
    required this.adapter,
    required this.compatibility,
  });

  final RuntimeIdentifier requestId;
  final AdapterExecutionContext adapter;
  final SerializationCompatibility compatibility;

  @override
  List<Object?> get components => [requestId, adapter, compatibility];
}

final class SerializationResult<T extends ValueObject> extends ValueObject {
  const SerializationResult({
    required this.value,
    required this.metadata,
    required this.provenance,
  });

  final T value;
  final SerializationMetadata metadata;
  final SerializationProvenance provenance;

  @override
  List<Object?> get components => [value, metadata, provenance];
}

abstract interface class SerializationAdapter<T extends ValueObject> {
  SerializationMetadata get metadata;
}

abstract interface class Serializer<T extends ValueObject>
    implements SerializationAdapter<T> {
  Future<Result<SerializationResult<T>>> serialize(
    T value,
    SerializationContext context,
  );
}

abstract interface class Deserializer<T extends ValueObject>
    implements SerializationAdapter<T> {
  Future<Result<T>> deserialize(
    SerializationResult<T> value,
    SerializationContext context,
  );
}

abstract interface class Codec<T extends ValueObject>
    implements Serializer<T>, Deserializer<T> {}
