import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/infrastructure/platform/platform_adapter_contracts.dart';
import 'package:pool_os/shared/foundation/identifier.dart';

void main() {
  test('platform feature metadata defensively copies declarations', () {
    final declarations = [_id('platform.declaration', 'declared')];
    final metadata = PlatformFeatureMetadata(
      capability: _capability(),
      declarations: declarations,
    );

    declarations.add(_id('platform.declaration', 'additional'));

    expect(metadata.declarations, [_id('platform.declaration', 'declared')]);
    expect(() => metadata.declarations.clear(), throwsUnsupportedError);
  });

  test('platform adapter markers retain compile-time generic boundaries', () {
    PlatformAdapter<PlatformCapability>? adapter;
    DeviceAdapter<PlatformCapability>? device;
    PlatformFeatureAdapter<PlatformCapability>? feature;
    PermissionAdapter<PlatformCapability>? permission;
    LocalCapabilityAdapter<PlatformCapability>? local;

    _acceptAdapter(adapter);
    _acceptAdapter(device);
    _acceptAdapter(feature);
    _acceptAdapter(permission);
    _acceptAdapter(local);

    expect(
      [adapter, device, feature, permission, local],
      everyElement(isNull),
    );
  });
}

void _acceptAdapter(PlatformAdapter<PlatformCapability>? adapter) {}

RuntimeIdentifier _id(String namespace, String value) =>
    RuntimeIdentifier(namespace: namespace, value: value);

PlatformCapability _capability() => PlatformCapability(
      identity: PlatformCapabilityIdentity(
        _id('platform.capability', 'local-capability'),
      ),
      version: PlatformCapabilityVersion(
        _id('platform.version', 'v1'),
      ),
    );
