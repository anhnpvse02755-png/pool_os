import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/infrastructure/contracts/infrastructure_contracts.dart';
import 'package:pool_os/infrastructure/serialization/serialization_contracts.dart';
import 'package:pool_os/shared/foundation/identifier.dart';

void main() {
  test('serialization metadata defensively copies contract collections', () {
    final capabilities = [SerializationCapability.serialize];
    final versions = [_version('v1')];
    final metadata = SerializationMetadata(
      adapter: _adapterIdentity(),
      format: _format(),
      capabilities: capabilities,
    );
    final compatibility = SerializationCompatibility(
      requiredVersion: versions.single,
      supportedVersions: versions,
    );

    capabilities.add(SerializationCapability.deserialize);
    versions.add(_version('v2'));

    expect(metadata.capabilities, [SerializationCapability.serialize]);
    expect(compatibility.supportedVersions, [_version('v1')]);
    expect(() => metadata.capabilities.clear(), throwsUnsupportedError);
    expect(
        () => compatibility.supportedVersions.clear(), throwsUnsupportedError);
  });

  test('serialization interfaces retain compile-time generic boundaries', () {
    SerializationAdapter<RuntimeIdentifier>? adapter;
    Serializer<RuntimeIdentifier>? serializer;
    Deserializer<RuntimeIdentifier>? deserializer;
    Codec<RuntimeIdentifier>? codec;

    _acceptAdapter(adapter);
    _acceptAdapter(serializer);
    _acceptAdapter(deserializer);
    _acceptAdapter(codec);

    expect([adapter, serializer, deserializer, codec], everyElement(isNull));
  });
}

void _acceptAdapter(SerializationAdapter<RuntimeIdentifier>? adapter) {}

RuntimeIdentifier _id(String namespace, String value) =>
    RuntimeIdentifier(namespace: namespace, value: value);

SerializationVersion _version(String value) =>
    SerializationVersion(_id('serialization.version', value));

SerializationFormat _format() => SerializationFormat(
      identity: SerializationIdentity(
        _id('serialization.format', 'opaque-format'),
      ),
      version: _version('v1'),
    );

AdapterIdentity _adapterIdentity() => AdapterIdentity(
      id: _id('infrastructure.adapter', 'serialization'),
      version: _id('infrastructure.version', 'v1'),
    );
