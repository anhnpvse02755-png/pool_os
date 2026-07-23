import '../../shared/foundation/identifier.dart';
import '../../shared/foundation/immutable.dart';
import '../../shared/foundation/result.dart';
import '../../shared/foundation/value_object.dart';
import '../contracts/infrastructure_contracts.dart';

enum PlatformAvailability { unknown, available, unavailable, restricted }

final class PlatformCapabilityIdentity extends ValueObject {
  const PlatformCapabilityIdentity(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class PlatformCapabilityVersion extends ValueObject {
  const PlatformCapabilityVersion(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class PlatformCapability extends ValueObject {
  const PlatformCapability({
    required this.identity,
    required this.version,
  });

  final PlatformCapabilityIdentity identity;
  final PlatformCapabilityVersion version;

  @override
  List<Object?> get components => [identity, version];
}

final class PlatformFeatureMetadata extends ValueObject {
  PlatformFeatureMetadata({
    required this.capability,
    Iterable<RuntimeIdentifier> declarations = const [],
  }) : declarations = immutableList(declarations);

  final PlatformCapability capability;
  final List<RuntimeIdentifier> declarations;

  @override
  List<Object?> get components => [
        capability,
        declarations.length,
        ...declarations,
      ];
}

final class PlatformPermissionContract extends ValueObject {
  const PlatformPermissionContract({
    required this.identity,
    required this.version,
  });

  final RuntimeIdentifier identity;
  final RuntimeIdentifier version;

  @override
  List<Object?> get components => [identity, version];
}

final class PlatformCapabilityProvenance extends ValueObject {
  const PlatformCapabilityProvenance({
    required this.capability,
    required this.adapter,
  });

  final PlatformCapability capability;
  final AdapterProvenance adapter;

  @override
  List<Object?> get components => [capability, adapter];
}

final class PlatformOperation<TCapability extends ValueObject>
    extends ValueObject {
  const PlatformOperation({
    required this.operationId,
    required this.capability,
  });

  final RuntimeIdentifier operationId;
  final TCapability capability;

  @override
  List<Object?> get components => [operationId, capability];
}

final class PlatformExecutionContext extends ValueObject {
  const PlatformExecutionContext({
    required this.requestId,
    required this.adapter,
    required this.permission,
    required this.availability,
  });

  final RuntimeIdentifier requestId;
  final AdapterExecutionContext adapter;
  final PlatformPermissionContract permission;
  final PlatformAvailability availability;

  @override
  List<Object?> get components => [
        requestId,
        adapter,
        permission,
        availability,
      ];
}

final class PlatformExecutionResult<TCapability extends ValueObject>
    extends ValueObject {
  const PlatformExecutionResult({
    required this.operation,
    required this.provenance,
    required this.availability,
  });

  final PlatformOperation<TCapability> operation;
  final PlatformCapabilityProvenance provenance;
  final PlatformAvailability availability;

  @override
  List<Object?> get components => [operation, provenance, availability];
}

abstract interface class PlatformAdapter<TCapability extends ValueObject> {
  PlatformFeatureMetadata get metadata;

  Future<Result<PlatformExecutionResult<TCapability>>> execute(
    PlatformOperation<TCapability> operation,
    PlatformExecutionContext context,
  );
}

abstract interface class DeviceAdapter<TCapability extends ValueObject>
    implements PlatformAdapter<TCapability> {}

abstract interface class PlatformFeatureAdapter<TCapability extends ValueObject>
    implements PlatformAdapter<TCapability> {}

abstract interface class PermissionAdapter<TCapability extends ValueObject>
    implements PlatformAdapter<TCapability> {}

abstract interface class LocalCapabilityAdapter<TCapability extends ValueObject>
    implements PlatformAdapter<TCapability> {}
