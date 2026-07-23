import '../../shared/foundation/immutable.dart';
import '../aggregates/coach_aggregate.dart';
import '../aggregates/configuration_aggregate.dart';
import '../aggregates/match_aggregate.dart';
import '../aggregates/training_aggregate.dart';
import '../aggregates/user_aggregate.dart';
import '../entities/coach_session.dart';
import '../entities/external_references.dart';
import '../entities/match_entity.dart';
import '../entities/settings_profile.dart';
import '../entities/training_session.dart';
import '../entities/user_profile.dart';
import '../shared/entity_ids.dart';
import 'aggregate_factory.dart';

final class MatchCreationSpecification {
  MatchCreationSpecification({
    required this.root,
    Iterable<SessionId> rackSessionIds = const [],
  }) : rackSessionIds = immutableList(rackSessionIds);

  final ProductMatch root;
  final List<SessionId> rackSessionIds;
}

final class TrainingCreationSpecification {
  TrainingCreationSpecification({
    required this.root,
    Iterable<KnowledgeReference> knowledgeReferences = const [],
    Iterable<EvidenceReference> evidenceReferences = const [],
    Iterable<GenericEntityId> simulationRequestIds = const [],
  })  : knowledgeReferences = immutableList(knowledgeReferences),
        evidenceReferences = immutableList(evidenceReferences),
        simulationRequestIds = immutableList(simulationRequestIds);

  final TrainingSession root;
  final List<KnowledgeReference> knowledgeReferences;
  final List<EvidenceReference> evidenceReferences;
  final List<GenericEntityId> simulationRequestIds;
}

final class CoachCreationSpecification {
  CoachCreationSpecification({
    required this.root,
    Iterable<GenericEntityId> responseReferenceIds = const [],
    Iterable<GenericEntityId> executionReferenceIds = const [],
  })  : responseReferenceIds = immutableList(responseReferenceIds),
        executionReferenceIds = immutableList(executionReferenceIds);

  final CoachSession root;
  final List<GenericEntityId> responseReferenceIds;
  final List<GenericEntityId> executionReferenceIds;
}

final class UserCreationSpecification {
  UserCreationSpecification({
    required this.root,
    Iterable<GenericEntityId> profileReferenceIds = const [],
  }) : profileReferenceIds = immutableList(profileReferenceIds);

  final UserProfile root;
  final List<GenericEntityId> profileReferenceIds;
}

final class ConfigurationCreationSpecification {
  ConfigurationCreationSpecification({
    required this.root,
    Iterable<GenericEntityId> configurationReferenceIds = const [],
  }) : configurationReferenceIds = immutableList(configurationReferenceIds);

  final SettingsProfile root;
  final List<GenericEntityId> configurationReferenceIds;
}

abstract interface class MatchFactory
    implements AggregateFactory<MatchCreationSpecification, MatchAggregate> {}

abstract interface class TrainingFactory
    implements
        AggregateFactory<TrainingCreationSpecification, TrainingAggregate> {}

abstract interface class CoachFactory
    implements AggregateFactory<CoachCreationSpecification, CoachAggregate> {}

abstract interface class UserFactory
    implements AggregateFactory<UserCreationSpecification, UserAggregate> {}

abstract interface class ConfigurationFactory
    implements
        AggregateFactory<ConfigurationCreationSpecification,
            ConfigurationAggregate> {}
