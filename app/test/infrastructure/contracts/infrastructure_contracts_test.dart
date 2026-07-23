import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/infrastructure/contracts/infrastructure_contracts.dart';
import 'package:pool_os/shared/foundation/identifier.dart';

void main() {
  test('adapter capability metadata defensively copies capabilities', () {
    final source = [InfrastructureCapability.read];
    final metadata = AdapterCapabilityMetadata(
      identity: AdapterIdentity(
        id: RuntimeIdentifier(
          namespace: 'infrastructure.adapter',
          value: 'adapter-1',
        ),
        version: RuntimeIdentifier(
          namespace: 'infrastructure.version',
          value: 'v1',
        ),
      ),
      capabilities: source,
    );
    source.add(InfrastructureCapability.write);

    expect(metadata.capabilities, [InfrastructureCapability.read]);
    expect(() => metadata.capabilities.clear(), throwsUnsupportedError);
  });

  test('adapter ports retain compile-time generic boundaries', () {
    InfrastructurePort<String, RuntimeIdentifier>? port;
    InfrastructureAdapter<String, RuntimeIdentifier>? adapter;
    ReadAdapter<String, RuntimeIdentifier>? read;
    WriteAdapter<String, RuntimeIdentifier>? write;
    ExternalAdapter<String, RuntimeIdentifier>? external;
    LocalAdapter<String, RuntimeIdentifier>? local;

    _acceptPort(port);
    _acceptPort(adapter);
    _acceptPort(read);
    _acceptPort(write);
    _acceptPort(external);
    _acceptPort(local);

    expect(
      [port, adapter, read, write, external, local],
      everyElement(isNull),
    );
  });
}

void _acceptPort(
  InfrastructurePort<String, RuntimeIdentifier>? port,
) {}
