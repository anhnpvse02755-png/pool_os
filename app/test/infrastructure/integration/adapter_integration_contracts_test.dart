import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/infrastructure/contracts/infrastructure_contracts.dart';
import 'package:pool_os/infrastructure/integration/adapter_integration_contracts.dart';
import 'package:pool_os/shared/foundation/identifier.dart';

void main() {
  test('adapter integration values defensively copy contract collections', () {
    final capabilities = [InfrastructureCapability.read];
    final bindings = [_binding()];
    final binding = AdapterBinding(
      identity: _identity(),
      version: _version(),
      capabilities: capabilities,
    );
    final metadata = AdapterIntegrationMetadata(
      identity: _identity(),
      version: _version(),
      bindings: bindings,
    );

    capabilities.add(InfrastructureCapability.write);
    bindings.clear();

    expect(binding.capabilities, [InfrastructureCapability.read]);
    expect(metadata.bindings, [_binding()]);
    expect(() => binding.capabilities.clear(), throwsUnsupportedError);
    expect(() => metadata.bindings.clear(), throwsUnsupportedError);
  });

  test('integration interfaces retain compile-time contract boundaries', () {
    InfrastructureIntegrationAdapter<String, RuntimeIdentifier>? adapter;
    AdapterRegistry? registry;
    AdapterCapabilityRegistry? capabilities;
    InboundAdapterBinding? inbound;
    OutboundAdapterBinding? outbound;
    LocalAdapterBinding? local;

    _acceptAdapter(adapter);
    _acceptRegistry(registry);
    _acceptCapabilityRegistry(capabilities);
    _acceptBinding(inbound);
    _acceptBinding(outbound);
    _acceptBinding(local);

    expect(
      [adapter, registry, capabilities, inbound, outbound, local],
      everyElement(isNull),
    );
  });
}

void _acceptAdapter(
  InfrastructureAdapter<String, RuntimeIdentifier>? adapter,
) {}

void _acceptRegistry(AdapterRegistry? registry) {}

void _acceptCapabilityRegistry(AdapterCapabilityRegistry? registry) {}

void _acceptBinding(Object? binding) {}

RuntimeIdentifier _id(String namespace, String value) =>
    RuntimeIdentifier(namespace: namespace, value: value);

AdapterIdentity _identity() => AdapterIdentity(
      id: _id('infrastructure.adapter', 'integration'),
      version: _id('infrastructure.version', 'v1'),
    );

AdapterVersion _version() =>
    AdapterVersion(_id('adapter.integration.version', 'v1'));

AdapterBinding _binding() => AdapterBinding(
      identity: _identity(),
      version: _version(),
      capabilities: const [InfrastructureCapability.read],
    );
