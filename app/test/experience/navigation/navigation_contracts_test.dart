import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/experience/foundation/experience_foundation_contracts.dart';
import 'package:pool_os/experience/navigation/navigation_contracts.dart';
import 'package:pool_os/shared/foundation/identifier.dart';

void main() {
  test('navigation metadata defensively copies contract collections', () {
    final capabilities = [NavigationCapability.root];
    final versions = [_routeVersion('v1')];
    final metadata = NavigationMetadata(
      identity: _navigationIdentity(),
      experience: _experienceMetadata(),
      capabilities: capabilities,
    );
    final compatibility = RouteCompatibility(
      requiredVersion: versions.single,
      supportedVersions: versions,
    );

    capabilities.add(NavigationCapability.modal);
    versions.add(_routeVersion('v2'));

    expect(metadata.capabilities, [NavigationCapability.root]);
    expect(compatibility.supportedVersions, [_routeVersion('v1')]);
    expect(() => metadata.capabilities.clear(), throwsUnsupportedError);
    expect(
        () => compatibility.supportedVersions.clear(), throwsUnsupportedError);
  });

  test('navigation interfaces retain compile-time contract boundaries', () {
    NavigationContract? contract;
    NavigationAdapter? adapter;
    NavigationCoordinator? coordinator;
    NavigationResolver? resolver;
    NavigationGuard? guard;
    RootNavigation? root;
    ModalNavigation? modal;
    DeepLinkNavigation? deepLink;

    _acceptContract(contract);
    _acceptContract(adapter);
    _acceptContract(coordinator);
    _acceptContract(resolver);
    _acceptContract(guard);
    _acceptContract(root);
    _acceptContract(modal);
    _acceptContract(deepLink);

    expect(
      [contract, adapter, coordinator, resolver, guard, root, modal, deepLink],
      everyElement(isNull),
    );
  });
}

void _acceptContract(NavigationContract? contract) {}

RuntimeIdentifier _id(String namespace, String value) =>
    RuntimeIdentifier(namespace: namespace, value: value);

NavigationIdentity _navigationIdentity() =>
    NavigationIdentity(_id('navigation.identity', 'foundation'));

RouteVersion _routeVersion(String value) =>
    RouteVersion(_id('navigation.route.version', value));

ExperienceMetadata _experienceMetadata() => ExperienceMetadata(
      identity: ExperienceIdentity(_id('experience.identity', 'foundation')),
      version: ExperienceVersion(_id('experience.version', 'v1')),
    );
