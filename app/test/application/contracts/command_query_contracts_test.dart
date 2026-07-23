import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/application/contracts/command_query_contracts.dart';
import 'package:pool_os/application/contracts/message_metadata.dart';
import 'package:pool_os/application/foundation/application_messages.dart';
import 'package:pool_os/shared/foundation/identifier.dart';

void main() {
  final correlationId = RuntimeIdentifier(
    namespace: 'application.correlation',
    value: 'correlation-1',
  );
  final payload = RuntimeIdentifier(
    namespace: 'application.payload',
    value: 'payload-1',
  );

  test('command metadata canonicalizes and protects attributes', () {
    final source = {'z': 'last', 'a': 'first'};
    final metadata = CommandMetadata(
      id: CommandId('command-1'),
      correlationId: correlationId,
      createdAtUtc: DateTime.utc(2026, 7, 23),
      attributes: source,
    );
    source['later'] = 'ignored';

    expect(metadata.attributes.keys, ['a', 'z']);
    expect(() => metadata.attributes.clear(), throwsUnsupportedError);
  });

  test('command and query envelopes are typed immutable values', () {
    final command = CommandEnvelope<RuntimeIdentifier, String>(
      metadata: CommandMetadata(
        id: CommandId('command-1'),
        correlationId: correlationId,
        createdAtUtc: DateTime.utc(2026, 7, 23),
      ),
      payload: payload,
    );
    final query = QueryEnvelope<RuntimeIdentifier, int>(
      metadata: QueryMetadata(
        id: QueryId('query-1'),
        correlationId: correlationId,
        createdAtUtc: DateTime.utc(2026, 7, 23),
      ),
      payload: payload,
    );

    _acceptCommand<String>(command);
    _acceptQuery<int>(query);
    expect(
        command,
        CommandEnvelope<RuntimeIdentifier, String>(
          metadata: command.metadata,
          payload: payload,
        ));
    expect(query.metadata.id, QueryId('query-1'));
  });
}

void _acceptCommand<TResult>(ApplicationCommand<TResult> command) {}

void _acceptQuery<TResult>(ApplicationQuery<TResult> query) {}
