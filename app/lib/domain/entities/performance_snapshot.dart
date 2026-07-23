import '../../shared/foundation/immutable.dart';
import '../shared/entity_ids.dart';
import '../shared/scalar_values.dart';
import 'entity.dart';

final class PerformanceSnapshot extends Entity<GenericEntityId> {
  PerformanceSnapshot({
    required super.id,
    required super.version,
    required super.createdAt,
    required this.playerId,
    required this.digest,
    required this.lifecycleState,
    Iterable<GenericEntityId> sourceReferenceIds = const [],
  }) : sourceReferenceIds = immutableList(sourceReferenceIds);

  final PlayerId playerId;
  final NonEmptyString digest;
  final NonEmptyString lifecycleState;
  final List<GenericEntityId> sourceReferenceIds;
}
