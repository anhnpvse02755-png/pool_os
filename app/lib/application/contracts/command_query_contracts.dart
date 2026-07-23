import '../../shared/foundation/value_object.dart';
import '../foundation/application_messages.dart';
import 'message_metadata.dart';

abstract interface class Command<TResult>
    implements ApplicationCommand<TResult> {
  CommandMetadata get metadata;
}

abstract interface class Query<TResult> implements ApplicationQuery<TResult> {
  QueryMetadata get metadata;
}

final class CommandEnvelope<TPayload extends ValueObject, TResult>
    extends ValueObject implements Command<TResult> {
  const CommandEnvelope({required this.metadata, required this.payload});

  @override
  final CommandMetadata metadata;
  final TPayload payload;

  @override
  List<Object?> get components => [metadata, payload];
}

final class QueryEnvelope<TPayload extends ValueObject, TResult>
    extends ValueObject implements Query<TResult> {
  const QueryEnvelope({required this.metadata, required this.payload});

  @override
  final QueryMetadata metadata;
  final TPayload payload;

  @override
  List<Object?> get components => [metadata, payload];
}
