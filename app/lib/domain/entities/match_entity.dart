import '../../shared/foundation/immutable.dart';
import '../shared/entity_ids.dart';
import '../shared/scalar_values.dart';
import 'entity.dart';

final class ProductMatch extends Entity<MatchId> {
  ProductMatch({
    required super.id,
    required super.version,
    required super.createdAt,
    required this.lifecycleState,
    Iterable<PlayerId> participantIds = const [],
    Iterable<SessionId> sessionIds = const [],
  })  : participantIds = immutableList(participantIds),
        sessionIds = immutableList(sessionIds);

  final NonEmptyString lifecycleState;
  final List<PlayerId> participantIds;
  final List<SessionId> sessionIds;
}
