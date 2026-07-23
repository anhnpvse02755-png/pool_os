import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/experience/resources/resource_contracts.dart';
import 'package:pool_os/shared/foundation/identifier.dart';

void main() {
  test('resource contracts defensively copy metadata collections', () {
    final capabilities = [ResourceCapability.text];
    final versions = [_version('v1')];
    final metadata = ResourceMetadata(
      identity: _identity(),
      version: versions.single,
      capabilities: capabilities,
    );
    final compatibility = ResourceCompatibility(
      requiredVersion: versions.single,
      supportedVersions: versions,
    );

    capabilities.add(ResourceCapability.image);
    versions.add(_version('v2'));

    expect(metadata.capabilities, [ResourceCapability.text]);
    expect(compatibility.supportedVersions, [_version('v1')]);
    expect(() => metadata.capabilities.clear(), throwsUnsupportedError);
    expect(
      () => compatibility.supportedVersions.clear(),
      throwsUnsupportedError,
    );
  });

  test('resource markers retain compile-time contract boundaries', () {
    ResourceContract? contract;
    ResourceProvider? provider;
    TextResource? textResource;
    IconResource? iconResource;
    ImageResource? imageResource;
    ThemeResource? themeResource;

    _acceptContract(contract);
    _acceptContract(provider);
    _acceptContract(textResource);
    _acceptContract(iconResource);
    _acceptContract(imageResource);
    _acceptContract(themeResource);

    expect(
      [
        contract,
        provider,
        textResource,
        iconResource,
        imageResource,
        themeResource,
      ],
      everyElement(isNull),
    );
  });
}

void _acceptContract(ResourceContract? contract) {}

RuntimeIdentifier _id(String namespace, String value) =>
    RuntimeIdentifier(namespace: namespace, value: value);

ResourceIdentity _identity() =>
    ResourceIdentity(_id('experience.resource.identity', 'foundation'));

ResourceVersion _version(String value) =>
    ResourceVersion(_id('experience.resource.version', value));
