import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/domain/events/domain_event.dart';
import 'package:pool_os/domain/events/product_domain_events.dart';
import 'package:pool_os/domain/shared/entity_ids.dart';
import 'package:pool_os/domain/shared/scalar_values.dart';
import 'package:pool_os/domain/shared/temporal_values.dart';

void main() {
  final occurredAt = UtcTimestamp(DateTime.utc(2026, 7, 23));

  test('DomainEventId is validated and value comparable', () {
    expect(DomainEventId('event-1'), DomainEventId('event-1'));
    expect(DomainEventId('event-1').compareTo(DomainEventId('event-2')), -1);
    expect(() => DomainEventId(' '), throwsArgumentError);
  });

  test('event metadata is immutable typed value data', () {
    final metadata = DomainEventMetadata<MatchId>(
      eventId: DomainEventId('event-1'),
      eventVersion: VersionNumber(1),
      occurredAt: occurredAt,
      sourceAggregateId: MatchId('match-1'),
    );

    expect(
      metadata,
      DomainEventMetadata<MatchId>(
        eventId: DomainEventId('event-1'),
        eventVersion: VersionNumber(1),
        occurredAt: occurredAt,
        sourceAggregateId: MatchId('match-1'),
      ),
    );
    expect(
      () => UtcTimestamp(DateTime(2026, 7, 23)),
      throwsArgumentError,
    );
  });

  test('Match events retain type, version and source identity', () {
    final metadata = _metadata(MatchId('match-1'), occurredAt, 'event-1');
    final created = MatchCreated(
      metadata: metadata,
      aggregateVersion: VersionNumber(1),
    );
    final updated = MatchUpdated(
      metadata: metadata,
      aggregateVersion: VersionNumber(2),
    );

    expect(created.eventType, 'match.created');
    expect(created.metadata.sourceAggregateId, MatchId('match-1'));
    expect(created.aggregateVersion, VersionNumber(1));
    expect(updated.eventType, 'match.updated');
    expect(updated.aggregateVersion, VersionNumber(2));
    expect(created, isNot(updated));
  });

  test('typed Product event payload references are preserved', () {
    final training = TrainingSessionCreated(
      metadata: _metadata(SessionId('training-1'), occurredAt, 'event-2'),
      playerId: PlayerId('player-1'),
    );
    final coach = CoachSessionRequested(
      metadata: _metadata(SessionId('coach-1'), occurredAt, 'event-3'),
      aiSessionReferenceId: GenericEntityId('ai-session-1'),
    );
    final configuration = ConfigurationChanged(
      metadata: _metadata(
        GenericEntityId('settings-1'),
        occurredAt,
        'event-4',
      ),
      userProfileId: GenericEntityId('user-1'),
    );
    final user = UserProfileUpdated(
      metadata: _metadata(
        GenericEntityId('user-1'),
        occurredAt,
        'event-5',
      ),
      playerId: PlayerId('player-1'),
    );

    expect(training.playerId, PlayerId('player-1'));
    expect(coach.aiSessionReferenceId, GenericEntityId('ai-session-1'));
    expect(configuration.userProfileId, GenericEntityId('user-1'));
    expect(user.playerId, PlayerId('player-1'));
    expect(
      [
        training.eventType,
        coach.eventType,
        configuration.eventType,
        user.eventType
      ],
      [
        'training.session.created',
        'coach.session.requested',
        'configuration.changed',
        'user.profile.updated',
      ],
    );
  });
}

DomainEventMetadata<TSourceId> _metadata<TSourceId extends EntityId>(
  TSourceId sourceAggregateId,
  UtcTimestamp occurredAt,
  String eventId,
) =>
    DomainEventMetadata<TSourceId>(
      eventId: DomainEventId(eventId),
      eventVersion: VersionNumber(1),
      occurredAt: occurredAt,
      sourceAggregateId: sourceAggregateId,
    );
