import '../shared/entity_ids.dart';
import '../shared/scalar_values.dart';
import 'entity.dart';

final class CoachSession extends Entity<SessionId> {
  const CoachSession({
    required super.id,
    required super.version,
    required super.createdAt,
    required this.aiSessionReferenceId,
    required this.aiSessionDigest,
    required this.lifecycleState,
  });

  final GenericEntityId aiSessionReferenceId;
  final NonEmptyString aiSessionDigest;
  final NonEmptyString lifecycleState;
}
