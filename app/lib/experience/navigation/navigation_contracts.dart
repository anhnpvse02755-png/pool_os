import '../../shared/foundation/identifier.dart';
import '../../shared/foundation/immutable.dart';
import '../../shared/foundation/value_object.dart';
import '../foundation/experience_foundation_contracts.dart';

enum NavigationCapability { root, modal, deepLink }

final class NavigationIdentity extends ValueObject {
  const NavigationIdentity(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class RouteIdentity extends ValueObject {
  const RouteIdentity(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class RouteVersion extends ValueObject {
  const RouteVersion(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class RouteCompatibility extends ValueObject {
  RouteCompatibility({
    required this.requiredVersion,
    Iterable<RouteVersion> supportedVersions = const [],
  }) : supportedVersions = immutableList(supportedVersions);

  final RouteVersion requiredVersion;
  final List<RouteVersion> supportedVersions;

  @override
  List<Object?> get components => [
        requiredVersion,
        supportedVersions.length,
        ...supportedVersions,
      ];
}

final class RouteProvenance extends ValueObject {
  const RouteProvenance({
    required this.identity,
    required this.source,
    required this.digest,
  });

  final RouteIdentity identity;
  final RuntimeIdentifier source;
  final String digest;

  @override
  List<Object?> get components => [identity, source, digest];
}

final class RouteDescriptor extends ValueObject {
  const RouteDescriptor({
    required this.identity,
    required this.version,
    required this.compatibility,
    required this.provenance,
  });

  final RouteIdentity identity;
  final RouteVersion version;
  final RouteCompatibility compatibility;
  final RouteProvenance provenance;

  @override
  List<Object?> get components => [
        identity,
        version,
        compatibility,
        provenance,
      ];
}

final class NavigationDestination extends ValueObject {
  const NavigationDestination({
    required this.identity,
    required this.route,
  });

  final NavigationIdentity identity;
  final RouteDescriptor route;

  @override
  List<Object?> get components => [identity, route];
}

final class NavigationMetadata extends ValueObject {
  NavigationMetadata({
    required this.identity,
    required this.experience,
    Iterable<NavigationCapability> capabilities = const [],
  }) : capabilities = immutableList(capabilities);

  final NavigationIdentity identity;
  final ExperienceMetadata experience;
  final List<NavigationCapability> capabilities;

  @override
  List<Object?> get components => [
        identity,
        experience,
        capabilities.length,
        ...capabilities,
      ];
}

final class NavigationContext extends ValueObject {
  const NavigationContext({
    required this.requestId,
    required this.experience,
    required this.metadata,
  });

  final RuntimeIdentifier requestId;
  final ExperienceExecutionContext experience;
  final NavigationMetadata metadata;

  @override
  List<Object?> get components => [requestId, experience, metadata];
}

final class NavigationResult extends ValueObject {
  const NavigationResult({
    required this.destination,
    required this.metadata,
    required this.provenance,
  });

  final NavigationDestination destination;
  final NavigationMetadata metadata;
  final RouteProvenance provenance;

  @override
  List<Object?> get components => [destination, metadata, provenance];
}

abstract interface class NavigationContract {
  NavigationMetadata get metadata;
}

abstract interface class NavigationAdapter implements NavigationContract {}

abstract interface class NavigationCoordinator implements NavigationContract {}

abstract interface class NavigationResolver implements NavigationContract {
  RouteDescriptor get descriptor;
}

abstract interface class NavigationGuard implements NavigationContract {}

abstract interface class RootNavigation implements NavigationContract {}

abstract interface class ModalNavigation implements NavigationContract {}

abstract interface class DeepLinkNavigation implements NavigationContract {}
