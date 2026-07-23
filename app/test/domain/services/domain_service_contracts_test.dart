import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/domain/aggregates/coach_aggregate.dart';
import 'package:pool_os/domain/aggregates/configuration_aggregate.dart';
import 'package:pool_os/domain/aggregates/match_aggregate.dart';
import 'package:pool_os/domain/aggregates/training_aggregate.dart';
import 'package:pool_os/domain/entities/performance_snapshot.dart';
import 'package:pool_os/domain/services/domain_service_contracts.dart';
import 'package:pool_os/domain/services/product_domain_services.dart';

void main() {
  test('named Domain service ports retain compile-time boundary types', () {
    MatchDomainService? match;
    TrainingDomainService? training;
    CoachDomainService? coach;
    AnalyticsDomainService? analytics;
    ConfigurationDomainService? configuration;
    ValidationDomainService<MatchAggregate>? validation;

    _acceptDomainService<MatchAggregate, MatchAggregate>(match);
    _acceptDomainService<TrainingAggregate, TrainingAggregate>(training);
    _acceptDomainService<CoachAggregate, CoachAggregate>(coach);
    _acceptDomainService<PerformanceSnapshot, PerformanceSnapshot>(analytics);
    _acceptDomainService<ConfigurationAggregate, ConfigurationAggregate>(
      configuration,
    );
    _acceptDomainService<MatchAggregate, MatchAggregate>(validation);

    expect(
      [match, training, coach, analytics, configuration, validation],
      everyElement(isNull),
    );
  });
}

void _acceptDomainService<TInput, TOutput>(
  DomainService<TInput, TOutput>? service,
) {}
