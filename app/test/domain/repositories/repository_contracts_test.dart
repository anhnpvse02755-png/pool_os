import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/domain/aggregates/coach_aggregate.dart';
import 'package:pool_os/domain/aggregates/configuration_aggregate.dart';
import 'package:pool_os/domain/aggregates/match_aggregate.dart';
import 'package:pool_os/domain/aggregates/training_aggregate.dart';
import 'package:pool_os/domain/aggregates/user_aggregate.dart';
import 'package:pool_os/domain/entities/performance_snapshot.dart';
import 'package:pool_os/domain/repositories/product_repositories.dart';
import 'package:pool_os/domain/repositories/repository_contracts.dart';
import 'package:pool_os/domain/shared/entity_ids.dart';
import 'package:pool_os/domain/shared/scalar_values.dart';

void main() {
  test('RepositoryPageRequest is an immutable validated value object', () {
    final request = RepositoryPageRequest(
      pageSize: PositiveInteger(25),
      cursor: NonEmptyString('cursor-1'),
    );
    expect(
      request,
      RepositoryPageRequest(
        pageSize: PositiveInteger(25),
        cursor: NonEmptyString('cursor-1'),
      ),
    );
    expect(() => PositiveInteger(0), throwsArgumentError);
    expect(() => NonEmptyString(' '), throwsArgumentError);
  });

  test('RepositoryPage defensively copies result records', () {
    final source = [GenericEntityId('record-1')];
    final page = RepositoryPage<GenericEntityId>(
      items: source,
      nextCursor: NonEmptyString('cursor-2'),
    );
    source.add(GenericEntityId('record-2'));

    expect(page.items, [GenericEntityId('record-1')]);
    expect(() => page.items.clear(), throwsUnsupportedError);
    expect(page.nextCursor, NonEmptyString('cursor-2'));
  });

  test('RepositoryWriteReceipt has complete typed value equality', () {
    final receipt = RepositoryWriteReceipt<MatchId>(
      id: MatchId('match-1'),
      previousVersion: VersionNumber(1),
      currentVersion: VersionNumber(2),
    );
    expect(
      receipt,
      RepositoryWriteReceipt<MatchId>(
        id: MatchId('match-1'),
        previousVersion: VersionNumber(1),
        currentVersion: VersionNumber(2),
      ),
    );
    expect(
      receipt,
      isNot(RepositoryWriteReceipt<MatchId>(
        id: MatchId('match-1'),
        previousVersion: VersionNumber(2),
        currentVersion: VersionNumber(3),
      )),
    );
  });

  test('named repository ports retain compile-time aggregate types', () {
    MatchRepository? match;
    TrainingRepository? training;
    CoachRepository? coach;
    UserRepository? user;
    ConfigurationRepository? configuration;
    PerformanceRepository? performance;

    _acceptAggregateRepository<MatchId, MatchAggregate>(match);
    _acceptAggregateRepository<SessionId, TrainingAggregate>(training);
    _acceptAggregateRepository<SessionId, CoachAggregate>(coach);
    _acceptAggregateRepository<GenericEntityId, UserAggregate>(user);
    _acceptAggregateRepository<GenericEntityId, ConfigurationAggregate>(
        configuration);
    _acceptReadRepository<GenericEntityId, PerformanceSnapshot>(performance);

    expect(
      [match, training, coach, user, configuration, performance],
      everyElement(isNull),
    );
  });
}

void _acceptAggregateRepository<TId extends EntityId, TAggregate>(
  AggregateRepository<TId, TAggregate>? repository,
) {}

void _acceptReadRepository<TId extends EntityId, TRecord>(
  ReadRepository<TId, TRecord>? repository,
) {}
