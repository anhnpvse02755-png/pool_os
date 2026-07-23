import '../../shared/foundation/immutable.dart';
import '../shared/entity_ids.dart';
import '../shared/scalar_values.dart';
import 'entity.dart';

final class TrainingSession extends Entity<SessionId> {
  TrainingSession({
    required super.id,
    required super.version,
    required super.createdAt,
    required this.playerId,
    required this.lifecycleState,
    Iterable<GenericEntityId> targetReferenceIds = const [],
  }) : targetReferenceIds = immutableList(targetReferenceIds);

  final PlayerId playerId;
  final NonEmptyString lifecycleState;
  final List<GenericEntityId> targetReferenceIds;
}
