import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/experience/interactions/interaction_contracts.dart';
import 'package:pool_os/shared/foundation/identifier.dart';

void main() {
  test('interaction contracts defensively copy metadata collections', () {
    final capabilities = [InteractionCapability.user];
    final versions = [_version('v1')];
    final metadata = InteractionMetadata(
      identity: _identity(),
      version: versions.single,
      capabilities: capabilities,
    );
    final compatibility = InteractionCompatibility(
      requiredVersion: versions.single,
      supportedVersions: versions,
    );

    capabilities.add(InteractionCapability.system);
    versions.add(_version('v2'));

    expect(metadata.capabilities, [InteractionCapability.user]);
    expect(compatibility.supportedVersions, [_version('v1')]);
    expect(() => metadata.capabilities.clear(), throwsUnsupportedError);
    expect(
        () => compatibility.supportedVersions.clear(), throwsUnsupportedError);
  });

  test('interaction interfaces retain compile-time contract boundaries', () {
    InteractionContract? contract;
    InteractionHandler? handler;
    InteractionCoordinator? coordinator;
    UserInteraction? user;
    SystemInteraction? system;
    BackgroundInteraction? background;

    _acceptContract(contract);
    _acceptContract(handler);
    _acceptContract(coordinator);
    _acceptContract(user);
    _acceptContract(system);
    _acceptContract(background);

    expect(
      [contract, handler, coordinator, user, system, background],
      everyElement(isNull),
    );
  });
}

void _acceptContract(InteractionContract? contract) {}

RuntimeIdentifier _id(String namespace, String value) =>
    RuntimeIdentifier(namespace: namespace, value: value);

InteractionIdentity _identity() =>
    InteractionIdentity(_id('interaction.identity', 'foundation'));

InteractionVersion _version(String value) =>
    InteractionVersion(_id('interaction.version', value));
