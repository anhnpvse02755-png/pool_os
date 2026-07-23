import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/experience/rendering/rendering_contracts.dart';
import 'package:pool_os/shared/foundation/identifier.dart';
import 'package:pool_os/shared/foundation/value_object.dart';

void main() {
  test('rendering contracts defensively copy metadata collections', () {
    final capabilities = [RenderingCapability.staticContent];
    final versions = [_version('v1')];
    final metadata = RenderingMetadata(
      identity: _identity(),
      version: versions.single,
      capabilities: capabilities,
    );
    final compatibility = RenderingCompatibility(
      requiredVersion: versions.single,
      supportedVersions: versions,
    );

    capabilities.add(RenderingCapability.dynamicContent);
    versions.add(_version('v2'));

    expect(metadata.capabilities, [RenderingCapability.staticContent]);
    expect(compatibility.supportedVersions, [_version('v1')]);
    expect(() => metadata.capabilities.clear(), throwsUnsupportedError);
    expect(
      () => compatibility.supportedVersions.clear(),
      throwsUnsupportedError,
    );
  });

  test('rendering interfaces retain compile-time contract boundaries', () {
    RenderingContract? contract;
    RenderingComponent<_RenderingValue>? component;

    _acceptContract(contract);
    _acceptContract(component);

    expect([contract, component], everyElement(isNull));
  });
}

void _acceptContract(RenderingContract? contract) {}

RuntimeIdentifier _id(String namespace, String value) =>
    RuntimeIdentifier(namespace: namespace, value: value);

RenderingIdentity _identity() =>
    RenderingIdentity(_id('experience.rendering.identity', 'foundation'));

RenderingVersion _version(String value) =>
    RenderingVersion(_id('experience.rendering.version', value));

final class _RenderingValue extends ValueObject {
  const _RenderingValue(this.value);

  final String value;

  @override
  List<Object?> get components => [value];
}
