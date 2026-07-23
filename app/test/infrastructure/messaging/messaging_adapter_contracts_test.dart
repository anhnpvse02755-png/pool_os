import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/infrastructure/contracts/infrastructure_contracts.dart';
import 'package:pool_os/infrastructure/messaging/messaging_adapter_contracts.dart';
import 'package:pool_os/shared/foundation/identifier.dart';

void main() {
  test('messaging metadata defensively copies contract collections', () {
    final capabilities = [MessageCapability.publish];
    final versions = [_version('v1')];
    final metadata = MessagingCapabilityMetadata(
      adapter: _adapterIdentity(),
      capabilities: capabilities,
    );
    final compatibility = MessageCompatibility(
      requiredVersion: versions.single,
      supportedVersions: versions,
    );

    capabilities.add(MessageCapability.subscribe);
    versions.add(_version('v2'));

    expect(metadata.capabilities, [MessageCapability.publish]);
    expect(compatibility.supportedVersions, [_version('v1')]);
    expect(() => metadata.capabilities.clear(), throwsUnsupportedError);
    expect(
        () => compatibility.supportedVersions.clear(), throwsUnsupportedError);
  });

  test('messaging adapter markers retain compile-time generic boundaries', () {
    MessagingAdapter<RuntimeIdentifier>? adapter;
    MessagePublisher<RuntimeIdentifier>? publisher;
    MessageSubscriber<RuntimeIdentifier>? subscriber;
    InboundMessagingAdapter<RuntimeIdentifier>? inbound;
    OutboundMessagingAdapter<RuntimeIdentifier>? outbound;
    InternalMessagingAdapter<RuntimeIdentifier>? internal;

    _acceptAdapter(adapter);
    _acceptAdapter(publisher);
    _acceptAdapter(subscriber);
    _acceptAdapter(inbound);
    _acceptAdapter(outbound);
    _acceptAdapter(internal);

    expect(
      [adapter, publisher, subscriber, inbound, outbound, internal],
      everyElement(isNull),
    );
  });
}

void _acceptAdapter(MessagingAdapter<RuntimeIdentifier>? adapter) {}

RuntimeIdentifier _id(String namespace, String value) =>
    RuntimeIdentifier(namespace: namespace, value: value);

MessageVersion _version(String value) =>
    MessageVersion(_id('message.version', value));

AdapterIdentity _adapterIdentity() => AdapterIdentity(
      id: _id('infrastructure.adapter', 'messaging'),
      version: _id('infrastructure.version', 'v1'),
    );
