import '../../shared/foundation/immutable.dart';
import '../entities/match_entity.dart';
import '../shared/entity_ids.dart';
import 'aggregate_root.dart';

/// Structural Match composition only. Executable invariants are not authorized.
final class MatchAggregate extends AggregateRoot<MatchId, ProductMatch> {
  MatchAggregate({
    required super.root,
    Iterable<SessionId> rackSessionIds = const [],
  }) : rackSessionIds = immutableList(rackSessionIds);

  final List<SessionId> rackSessionIds;
}
