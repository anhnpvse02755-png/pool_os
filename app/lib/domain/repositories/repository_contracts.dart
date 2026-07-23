import '../../shared/foundation/immutable.dart';
import '../../shared/foundation/result.dart';
import '../../shared/foundation/value_object.dart';
import '../shared/entity_ids.dart';
import '../shared/scalar_values.dart';

final class RepositoryPageRequest extends ValueObject {
  const RepositoryPageRequest({
    required this.pageSize,
    this.cursor,
  });

  final PositiveInteger pageSize;
  final NonEmptyString? cursor;

  @override
  List<Object?> get components => [pageSize, cursor];
}

final class RepositoryPage<T> {
  RepositoryPage({
    required Iterable<T> items,
    this.nextCursor,
  }) : items = immutableList(items);

  final List<T> items;
  final NonEmptyString? nextCursor;
}

final class RepositoryWriteReceipt<TId extends EntityId> extends ValueObject {
  const RepositoryWriteReceipt({
    required this.id,
    required this.previousVersion,
    required this.currentVersion,
  });

  final TId id;
  final VersionNumber previousVersion;
  final VersionNumber currentVersion;

  @override
  List<Object?> get components => [id, previousVersion, currentVersion];
}

abstract interface class ReadRepository<TId extends EntityId, TRecord> {
  Future<Result<TRecord>> getById(TId id);

  Future<Result<RepositoryPage<TRecord>>> list(RepositoryPageRequest request);
}

abstract interface class AggregateRepository<TId extends EntityId, TAggregate>
    implements ReadRepository<TId, TAggregate> {
  Future<Result<RepositoryWriteReceipt<TId>>> save(
    TAggregate aggregate, {
    required VersionNumber expectedVersion,
  });
}
