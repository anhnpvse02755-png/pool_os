import '../../shared/foundation/identifier.dart';
import '../../shared/foundation/immutable.dart';
import '../../shared/foundation/result.dart';
import '../../shared/foundation/value_object.dart';
import '../contracts/infrastructure_contracts.dart';

enum MessageCapability { publish, subscribe, inbound, outbound, internal }

final class MessageIdentity extends ValueObject {
  const MessageIdentity(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class MessageVersion extends ValueObject {
  const MessageVersion(this.value);

  final RuntimeIdentifier value;

  @override
  List<Object?> get components => [value];
}

final class MessageMetadata extends ValueObject {
  const MessageMetadata({
    required this.identity,
    required this.version,
    required this.capability,
  });

  final MessageIdentity identity;
  final MessageVersion version;
  final MessageCapability capability;

  @override
  List<Object?> get components => [identity, version, capability];
}

final class MessagingCapabilityMetadata extends ValueObject {
  MessagingCapabilityMetadata({
    required this.adapter,
    Iterable<MessageCapability> capabilities = const [],
  }) : capabilities = immutableList(capabilities);

  final AdapterIdentity adapter;
  final List<MessageCapability> capabilities;

  @override
  List<Object?> get components => [
        adapter,
        capabilities.length,
        ...capabilities,
      ];
}

final class MessageCompatibility extends ValueObject {
  MessageCompatibility({
    required this.requiredVersion,
    Iterable<MessageVersion> supportedVersions = const [],
  }) : supportedVersions = immutableList(supportedVersions);

  final MessageVersion requiredVersion;
  final List<MessageVersion> supportedVersions;

  @override
  List<Object?> get components => [
        requiredVersion,
        supportedVersions.length,
        ...supportedVersions,
      ];
}

final class MessageProvenance extends ValueObject {
  const MessageProvenance({
    required this.message,
    required this.adapter,
  });

  final MessageMetadata message;
  final AdapterProvenance adapter;

  @override
  List<Object?> get components => [message, adapter];
}

final class MessageEnvelope<TMessage extends ValueObject> extends ValueObject {
  const MessageEnvelope({
    required this.payload,
    required this.metadata,
    required this.provenance,
  });

  final TMessage payload;
  final MessageMetadata metadata;
  final MessageProvenance provenance;

  @override
  List<Object?> get components => [payload, metadata, provenance];
}

final class MessageExecutionContext extends ValueObject {
  const MessageExecutionContext({
    required this.requestId,
    required this.adapter,
    required this.compatibility,
  });

  final RuntimeIdentifier requestId;
  final AdapterExecutionContext adapter;
  final MessageCompatibility compatibility;

  @override
  List<Object?> get components => [requestId, adapter, compatibility];
}

final class MessageExecutionResult<TMessage extends ValueObject>
    extends ValueObject {
  const MessageExecutionResult({
    required this.envelope,
    required this.capability,
    required this.provenance,
  });

  final MessageEnvelope<TMessage> envelope;
  final MessageCapability capability;
  final MessageProvenance provenance;

  @override
  List<Object?> get components => [envelope, capability, provenance];
}

abstract interface class MessagingAdapter<TMessage extends ValueObject> {
  MessagingCapabilityMetadata get metadata;
}

abstract interface class MessagePublisher<TMessage extends ValueObject>
    implements MessagingAdapter<TMessage> {
  Future<Result<MessageExecutionResult<TMessage>>> publish(
    MessageEnvelope<TMessage> envelope,
    MessageExecutionContext context,
  );
}

abstract interface class MessageSubscriber<TMessage extends ValueObject>
    implements MessagingAdapter<TMessage> {
  Future<Result<MessageExecutionResult<TMessage>>> consume(
    MessageEnvelope<TMessage> envelope,
    MessageExecutionContext context,
  );
}

abstract interface class InboundMessagingAdapter<TMessage extends ValueObject>
    implements MessagingAdapter<TMessage> {}

abstract interface class OutboundMessagingAdapter<TMessage extends ValueObject>
    implements MessagingAdapter<TMessage> {}

abstract interface class InternalMessagingAdapter<TMessage extends ValueObject>
    implements MessagingAdapter<TMessage> {}
