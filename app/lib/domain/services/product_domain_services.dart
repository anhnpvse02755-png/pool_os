import '../aggregates/coach_aggregate.dart';
import '../aggregates/configuration_aggregate.dart';
import '../aggregates/match_aggregate.dart';
import '../aggregates/training_aggregate.dart';
import '../entities/performance_snapshot.dart';
import 'domain_service_contracts.dart';

/// Typed Match Domain service port. No Match rules are implemented here.
abstract interface class MatchDomainService
    implements DomainService<MatchAggregate, MatchAggregate> {}

/// Typed Training Domain service port. No Training rules are implemented here.
abstract interface class TrainingDomainService
    implements DomainService<TrainingAggregate, TrainingAggregate> {}

/// Typed Coach Domain service port. No Coach or AI behavior is implemented.
abstract interface class CoachDomainService
    implements DomainService<CoachAggregate, CoachAggregate> {}

/// Typed Analytics Domain service port. No calculations are implemented here.
abstract interface class AnalyticsDomainService
    implements DomainService<PerformanceSnapshot, PerformanceSnapshot> {}

/// Typed Configuration Domain service port. No policy resolution is present.
abstract interface class ConfigurationDomainService
    implements DomainService<ConfigurationAggregate, ConfigurationAggregate> {}

/// Generic validation port. Validation rules and implementations are absent.
abstract interface class ValidationDomainService<TCandidate>
    implements DomainService<TCandidate, TCandidate> {}
