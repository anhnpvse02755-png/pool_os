import '../../shared/foundation/value_object.dart';
import '../shared/entity_ids.dart';
import '../shared/scalar_values.dart';
import '../shared/temporal_values.dart';

final class DomainEventId extends ValueObject
    implements Comparable<DomainEventId> {
  DomainEventId(String value) : value = NonEmptyString(value);

  final NonEmptyString value;

  @override
  List<Object?> get components => [value];

  @override
  int compareTo(DomainEventId other) => value.compareTo(other.value);

  @override
  String toString() => value.value;
}

final class DomainEventMetadata<TSourceId extends EntityId>
    extends ValueObject {
  const DomainEventMetadata({
    required this.eventId,
    required this.eventVersion,
    required this.occurredAt,
    required this.sourceAggregateId,
  });

  final DomainEventId eventId;
  final VersionNumber eventVersion;
  final UtcTimestamp occurredAt;
  final TSourceId sourceAggregateId;

  @override
  List<Object?> get components => [
        eventId,
        eventVersion,
        occurredAt,
        sourceAggregateId,
      ];
}

/// Immutable Domain event contract only. It has no publishing or replay logic.
abstract class DomainEvent<TSourceId extends EntityId> extends ValueObject {
  const DomainEvent({required this.metadata});

  final DomainEventMetadata<TSourceId> metadata;

  String get eventType;

  List<Object?> get payloadComponents;

  @override
  List<Object?> get components => [metadata, eventType, ...payloadComponents];
}
