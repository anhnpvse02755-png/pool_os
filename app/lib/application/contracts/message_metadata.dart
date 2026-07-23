import '../../shared/foundation/identifier.dart';
import '../../shared/foundation/immutable.dart';
import '../../shared/foundation/value_object.dart';

final class CommandId extends ValueObject {
  CommandId(String value)
      : identifier = RuntimeIdentifier(
          namespace: 'application.command',
          value: value,
        );

  final RuntimeIdentifier identifier;

  @override
  List<Object?> get components => [identifier];
}

final class QueryId extends ValueObject {
  QueryId(String value)
      : identifier = RuntimeIdentifier(
          namespace: 'application.query',
          value: value,
        );

  final RuntimeIdentifier identifier;

  @override
  List<Object?> get components => [identifier];
}

abstract class MessageMetadata<TId extends ValueObject> extends ValueObject {
  MessageMetadata({
    required this.id,
    required this.correlationId,
    required this.createdAtUtc,
    Map<String, String> attributes = const {},
  }) : attributes = immutableCanonicalMap(attributes);

  final TId id;
  final RuntimeIdentifier correlationId;
  final DateTime createdAtUtc;
  final Map<String, String> attributes;

  @override
  List<Object?> get components => [
        id,
        correlationId,
        createdAtUtc.microsecondsSinceEpoch,
        attributes.length,
        for (final entry in attributes.entries) ...[entry.key, entry.value],
      ];
}

final class CommandMetadata extends MessageMetadata<CommandId> {
  CommandMetadata({
    required super.id,
    required super.correlationId,
    required super.createdAtUtc,
    super.attributes,
  });
}

final class QueryMetadata extends MessageMetadata<QueryId> {
  QueryMetadata({
    required super.id,
    required super.correlationId,
    required super.createdAtUtc,
    super.attributes,
  });
}
