import '../../shared/foundation/identifier.dart';
import '../../shared/foundation/immutable.dart';
import '../../shared/foundation/value_object.dart';

enum StateCapability { readOnly, mutable, local, shared, session }

final class StateIdentity extends ValueObject {
  const StateIdentity(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class StateVersion extends ValueObject {
  const StateVersion(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class StateCompatibility extends ValueObject {
  StateCompatibility({
    required this.requiredVersion,
    Iterable<StateVersion> supportedVersions = const [],
  }) : supportedVersions = immutableList(supportedVersions);

  final StateVersion requiredVersion;
  final List<StateVersion> supportedVersions;

  @override
  List<Object?> get components => [
        requiredVersion,
        supportedVersions.length,
        ...supportedVersions,
      ];
}

final class StateMetadata extends ValueObject {
  StateMetadata({
    required this.identity,
    required this.version,
    Iterable<StateCapability> capabilities = const [],
  }) : capabilities = immutableList(capabilities);

  final StateIdentity identity;
  final StateVersion version;
  final List<StateCapability> capabilities;

  @override
  List<Object?> get components => [
        identity,
        version,
        capabilities.length,
        ...capabilities,
      ];
}

final class StateProvenance extends ValueObject {
  const StateProvenance({
    required this.source,
    required this.digest,
    required this.metadata,
  });

  final RuntimeIdentifier source;
  final String digest;
  final StateMetadata metadata;

  @override
  List<Object?> get components => [source, digest, metadata];
}

final class StateContext extends ValueObject {
  const StateContext({
    required this.requestId,
    required this.metadata,
    required this.compatibility,
  });

  final RuntimeIdentifier requestId;
  final StateMetadata metadata;
  final StateCompatibility compatibility;

  @override
  List<Object?> get components => [requestId, metadata, compatibility];
}

final class StateSnapshot<TValue extends ValueObject> extends ValueObject {
  const StateSnapshot({
    required this.value,
    required this.metadata,
    required this.provenance,
  });

  final TValue value;
  final StateMetadata metadata;
  final StateProvenance provenance;

  @override
  List<Object?> get components => [value, metadata, provenance];
}

abstract interface class ExperienceState<TValue extends ValueObject> {
  StateMetadata get metadata;

  StateSnapshot<TValue> get snapshot;
}

abstract interface class ReadOnlyState<TValue extends ValueObject>
    implements ExperienceState<TValue> {}

abstract interface class MutableState<TValue extends ValueObject>
    implements ExperienceState<TValue> {}

abstract interface class LocalState<TValue extends ValueObject>
    implements ExperienceState<TValue> {}

abstract interface class SharedState<TValue extends ValueObject>
    implements ExperienceState<TValue> {}

abstract interface class SessionState<TValue extends ValueObject>
    implements ExperienceState<TValue> {}
