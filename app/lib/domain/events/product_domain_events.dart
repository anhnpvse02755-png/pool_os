import '../shared/entity_ids.dart';
import '../shared/scalar_values.dart';
import 'domain_event.dart';

final class MatchCreated extends DomainEvent<MatchId> {
  const MatchCreated({
    required super.metadata,
    required this.aggregateVersion,
  });

  final VersionNumber aggregateVersion;

  @override
  String get eventType => 'match.created';

  @override
  List<Object?> get payloadComponents => [aggregateVersion];
}

final class MatchUpdated extends DomainEvent<MatchId> {
  const MatchUpdated({
    required super.metadata,
    required this.aggregateVersion,
  });

  final VersionNumber aggregateVersion;

  @override
  String get eventType => 'match.updated';

  @override
  List<Object?> get payloadComponents => [aggregateVersion];
}

final class TrainingSessionCreated extends DomainEvent<SessionId> {
  const TrainingSessionCreated({
    required super.metadata,
    required this.playerId,
  });

  final PlayerId playerId;

  @override
  String get eventType => 'training.session.created';

  @override
  List<Object?> get payloadComponents => [playerId];
}

final class CoachSessionRequested extends DomainEvent<SessionId> {
  const CoachSessionRequested({
    required super.metadata,
    required this.aiSessionReferenceId,
  });

  final GenericEntityId aiSessionReferenceId;

  @override
  String get eventType => 'coach.session.requested';

  @override
  List<Object?> get payloadComponents => [aiSessionReferenceId];
}

final class ConfigurationChanged extends DomainEvent<GenericEntityId> {
  const ConfigurationChanged({
    required super.metadata,
    required this.userProfileId,
  });

  final GenericEntityId userProfileId;

  @override
  String get eventType => 'configuration.changed';

  @override
  List<Object?> get payloadComponents => [userProfileId];
}

final class UserProfileUpdated extends DomainEvent<GenericEntityId> {
  const UserProfileUpdated({
    required super.metadata,
    this.playerId,
  });

  final PlayerId? playerId;

  @override
  String get eventType => 'user.profile.updated';

  @override
  List<Object?> get payloadComponents => [playerId];
}
