import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/experience/presentation/presentation_contracts.dart';
import 'package:pool_os/shared/foundation/identifier.dart';

void main() {
  test('presentation contracts defensively copy metadata collections', () {
    final capabilities = [PresentationCapability.staticContent];
    final versions = [_version('v1')];
    final descriptor = PresentationDescriptor(
      identity: _identity(),
      version: versions.single,
      capabilities: capabilities,
    );
    final compatibility = PresentationCompatibility(
      requiredVersion: versions.single,
      supportedVersions: versions,
    );

    capabilities.add(PresentationCapability.composite);
    versions.add(_version('v2'));

    expect(descriptor.capabilities, [PresentationCapability.staticContent]);
    expect(compatibility.supportedVersions, [_version('v1')]);
    expect(() => descriptor.capabilities.clear(), throwsUnsupportedError);
    expect(
        () => compatibility.supportedVersions.clear(), throwsUnsupportedError);
  });

  test('presentation interfaces retain compile-time contract boundaries', () {
    PresentationContract? contract;
    PresentationComponent<RuntimeIdentifier>? component;
    StaticPresentation? staticPresentation;
    DynamicPresentation? dynamicPresentation;
    CompositePresentation? compositePresentation;

    _acceptContract(contract);
    _acceptContract(component);
    _acceptContract(staticPresentation);
    _acceptContract(dynamicPresentation);
    _acceptContract(compositePresentation);

    expect(
      [
        contract,
        component,
        staticPresentation,
        dynamicPresentation,
        compositePresentation,
      ],
      everyElement(isNull),
    );
  });
}

void _acceptContract(PresentationContract? contract) {}

RuntimeIdentifier _id(String namespace, String value) =>
    RuntimeIdentifier(namespace: namespace, value: value);

PresentationIdentity _identity() =>
    PresentationIdentity(_id('presentation.identity', 'foundation'));

PresentationVersion _version(String value) =>
    PresentationVersion(_id('presentation.version', value));
