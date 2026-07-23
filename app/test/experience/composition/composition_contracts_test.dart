import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/experience/composition/composition_contracts.dart';
import 'package:pool_os/shared/foundation/identifier.dart';
import 'package:pool_os/shared/foundation/value_object.dart';

void main() {
  test('composition contracts defensively copy metadata collections', () {
    final capabilities = [CompositionCapability.atomic];
    final versions = [_version('v1')];
    final metadata = CompositionMetadata(
      identity: _identity(),
      version: versions.single,
      capabilities: capabilities,
    );
    final compatibility = CompositionCompatibility(
      requiredVersion: versions.single,
      supportedVersions: versions,
    );

    capabilities.add(CompositionCapability.aggregate);
    versions.add(_version('v2'));

    expect(metadata.capabilities, [CompositionCapability.atomic]);
    expect(compatibility.supportedVersions, [_version('v1')]);
    expect(() => metadata.capabilities.clear(), throwsUnsupportedError);
    expect(
      () => compatibility.supportedVersions.clear(),
      throwsUnsupportedError,
    );
  });

  test('composition interfaces retain compile-time contract boundaries', () {
    CompositionContract? contract;
    CompositionComponent<_CompositionValue>? component;

    _acceptContract(contract);
    _acceptContract(component);

    expect([contract, component], everyElement(isNull));
  });
}

void _acceptContract(CompositionContract? contract) {}

RuntimeIdentifier _id(String namespace, String value) =>
    RuntimeIdentifier(namespace: namespace, value: value);

CompositionIdentity _identity() =>
    CompositionIdentity(_id('experience.composition.identity', 'foundation'));

CompositionVersion _version(String value) =>
    CompositionVersion(_id('experience.composition.version', value));

final class _CompositionValue extends ValueObject {
  const _CompositionValue(this.value);

  final String value;

  @override
  List<Object?> get components => [value];
}
