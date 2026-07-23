import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/domain/aggregates/coach_aggregate.dart';
import 'package:pool_os/domain/aggregates/configuration_aggregate.dart';
import 'package:pool_os/domain/aggregates/match_aggregate.dart';
import 'package:pool_os/domain/aggregates/training_aggregate.dart';
import 'package:pool_os/domain/aggregates/user_aggregate.dart';
import 'package:pool_os/domain/entities/match_entity.dart';
import 'package:pool_os/domain/factories/aggregate_factory.dart';
import 'package:pool_os/domain/factories/product_factories.dart';
import 'package:pool_os/domain/shared/entity_ids.dart';
import 'package:pool_os/domain/shared/scalar_values.dart';
import 'package:pool_os/domain/shared/temporal_values.dart';

void main() {
  test('Match creation specification defensively copies references', () {
    final source = [SessionId('rack-1')];
    final specification = MatchCreationSpecification(
      root: ProductMatch(
        id: MatchId('match-1'),
        version: VersionNumber(1),
        createdAt: UtcTimestamp(DateTime.utc(2026, 7, 23)),
        lifecycleState: NonEmptyString('created'),
      ),
      rackSessionIds: source,
    );
    source.add(SessionId('rack-2'));

    expect(specification.rackSessionIds, [SessionId('rack-1')]);
    expect(
      () => specification.rackSessionIds.clear(),
      throwsUnsupportedError,
    );
  });

  test('named factory ports retain compile-time specification types', () {
    MatchFactory? match;
    TrainingFactory? training;
    CoachFactory? coach;
    UserFactory? user;
    ConfigurationFactory? configuration;

    _acceptFactory<MatchCreationSpecification, MatchAggregate>(match);
    _acceptFactory<TrainingCreationSpecification, TrainingAggregate>(training);
    _acceptFactory<CoachCreationSpecification, CoachAggregate>(coach);
    _acceptFactory<UserCreationSpecification, UserAggregate>(user);
    _acceptFactory<ConfigurationCreationSpecification, ConfigurationAggregate>(
      configuration,
    );

    expect(
      [match, training, coach, user, configuration],
      everyElement(isNull),
    );
  });
}

void _acceptFactory<TSpecification, TAggregate>(
  AggregateFactory<TSpecification, TAggregate>? factory,
) {}
