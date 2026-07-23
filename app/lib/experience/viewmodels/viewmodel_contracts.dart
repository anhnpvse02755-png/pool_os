import '../../shared/foundation/identifier.dart';
import '../../shared/foundation/immutable.dart';
import '../../shared/foundation/value_object.dart';

enum ProjectionCapability { read, refresh }

final class ViewStateIdentity extends ValueObject {
  const ViewStateIdentity(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class ViewStateVersion extends ValueObject {
  const ViewStateVersion(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class ViewStateMetadata extends ValueObject {
  const ViewStateMetadata({
    required this.identity,
    required this.version,
  });

  final ViewStateIdentity identity;
  final ViewStateVersion version;

  @override
  List<Object?> get components => [identity, version];
}

final class ViewStateCompatibility extends ValueObject {
  ViewStateCompatibility({
    required this.requiredVersion,
    Iterable<ViewStateVersion> supportedVersions = const [],
  }) : supportedVersions = immutableList(supportedVersions);

  final ViewStateVersion requiredVersion;
  final List<ViewStateVersion> supportedVersions;

  @override
  List<Object?> get components => [
        requiredVersion,
        supportedVersions.length,
        ...supportedVersions,
      ];
}

final class ViewModelProvenance extends ValueObject {
  const ViewModelProvenance({
    required this.source,
    required this.digest,
    required this.state,
  });

  final RuntimeIdentifier source;
  final String digest;
  final ViewStateMetadata state;

  @override
  List<Object?> get components => [source, digest, state];
}

final class ViewState<TValue extends ValueObject> extends ValueObject {
  const ViewState({
    required this.value,
    required this.metadata,
    required this.provenance,
  });

  final TValue value;
  final ViewStateMetadata metadata;
  final ViewModelProvenance provenance;

  @override
  List<Object?> get components => [value, metadata, provenance];
}

final class ProjectionMetadata extends ValueObject {
  ProjectionMetadata({
    required this.identity,
    Iterable<ProjectionCapability> capabilities = const [],
  }) : capabilities = immutableList(capabilities);

  final RuntimeIdentifier identity;
  final List<ProjectionCapability> capabilities;

  @override
  List<Object?> get components => [
        identity,
        capabilities.length,
        ...capabilities,
      ];
}

final class ViewProjection<TValue extends ValueObject> extends ValueObject {
  const ViewProjection({
    required this.value,
    required this.metadata,
    required this.provenance,
  });

  final TValue value;
  final ProjectionMetadata metadata;
  final ViewModelProvenance provenance;

  @override
  List<Object?> get components => [value, metadata, provenance];
}

final class RefreshContext extends ValueObject {
  const RefreshContext({
    required this.requestId,
    required this.state,
    required this.compatibility,
  });

  final RuntimeIdentifier requestId;
  final ViewStateMetadata state;
  final ViewStateCompatibility compatibility;

  @override
  List<Object?> get components => [requestId, state, compatibility];
}

final class RefreshResult<TValue extends ValueObject> extends ValueObject {
  const RefreshResult({
    required this.projection,
    required this.provenance,
  });

  final ViewProjection<TValue> projection;
  final ViewModelProvenance provenance;

  @override
  List<Object?> get components => [projection, provenance];
}

abstract interface class ExperienceViewModel<TValue extends ValueObject> {
  ViewState<TValue> get state;

  ViewStateMetadata get metadata;
}

abstract interface class ReadOnlyViewModel<TValue extends ValueObject>
    implements ExperienceViewModel<TValue> {}

abstract interface class EditableViewModel<TValue extends ValueObject>
    implements ExperienceViewModel<TValue> {}
