import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/experience/foundation/experience_foundation_contracts.dart';
import 'package:pool_os/shared/foundation/identifier.dart';

void main() {
  test('experience metadata defensively copies contract collections', () {
    final capabilities = [_id('experience.capability', 'present')];
    final versions = [_version('v1')];
    final metadata = ExperienceMetadata(
      identity: _identity(),
      version: versions.single,
      capabilities: capabilities,
    );
    final compatibility = ExperienceCompatibility(
      requiredVersion: versions.single,
      supportedVersions: versions,
    );

    capabilities.add(_id('experience.capability', 'additional'));
    versions.add(_version('v2'));

    expect(metadata.capabilities, [_id('experience.capability', 'present')]);
    expect(compatibility.supportedVersions, [_version('v1')]);
    expect(() => metadata.capabilities.clear(), throwsUnsupportedError);
    expect(
        () => compatibility.supportedVersions.clear(), throwsUnsupportedError);
  });

  test('experience interfaces retain compile-time generic boundaries', () {
    ExperienceComponent<RuntimeIdentifier>? component;
    ExperienceContext? context;
    ExperienceState<RuntimeIdentifier>? state;
    ExperienceEvent<RuntimeIdentifier>? event;
    ExperienceLifecycle<RuntimeIdentifier>? lifecycle;
    ExperienceCapability? capability;

    _acceptComponent(component);
    _acceptContext(context);
    _acceptState(state);
    _acceptEvent(event);
    _acceptLifecycle(lifecycle);
    _acceptCapability(capability);

    expect(
      [component, context, state, event, lifecycle, capability],
      everyElement(isNull),
    );
  });
}

void _acceptComponent(ExperienceComponent<RuntimeIdentifier>? component) {}

void _acceptContext(ExperienceContext? context) {}

void _acceptState(ExperienceState<RuntimeIdentifier>? state) {}

void _acceptEvent(ExperienceEvent<RuntimeIdentifier>? event) {}

void _acceptLifecycle(ExperienceLifecycle<RuntimeIdentifier>? lifecycle) {}

void _acceptCapability(ExperienceCapability? capability) {}

RuntimeIdentifier _id(String namespace, String value) =>
    RuntimeIdentifier(namespace: namespace, value: value);

ExperienceIdentity _identity() =>
    ExperienceIdentity(_id('experience.identity', 'foundation'));

ExperienceVersion _version(String value) =>
    ExperienceVersion(_id('experience.version', value));
