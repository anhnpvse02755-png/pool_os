import '../aggregates/coach_aggregate.dart';
import '../aggregates/configuration_aggregate.dart';
import '../aggregates/match_aggregate.dart';
import '../aggregates/training_aggregate.dart';
import '../aggregates/user_aggregate.dart';
import '../entities/performance_snapshot.dart';
import '../shared/entity_ids.dart';
import 'repository_contracts.dart';

/// Persistence-neutral Match aggregate port.
abstract interface class MatchRepository
    implements AggregateRepository<MatchId, MatchAggregate> {}

/// Persistence-neutral Training aggregate port.
abstract interface class TrainingRepository
    implements AggregateRepository<SessionId, TrainingAggregate> {}

/// Persistence-neutral Coach aggregate port.
abstract interface class CoachRepository
    implements AggregateRepository<SessionId, CoachAggregate> {}

/// Persistence-neutral Product User aggregate port.
abstract interface class UserRepository
    implements AggregateRepository<GenericEntityId, UserAggregate> {}

/// Persistence-neutral Product Configuration aggregate port.
abstract interface class ConfigurationRepository
    implements AggregateRepository<GenericEntityId, ConfigurationAggregate> {}

/// Read-only port for immutable Performance projections.
abstract interface class PerformanceRepository
    implements ReadRepository<GenericEntityId, PerformanceSnapshot> {}
