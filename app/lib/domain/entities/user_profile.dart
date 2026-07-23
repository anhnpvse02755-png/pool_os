import '../shared/entity_ids.dart';
import '../shared/scalar_values.dart';
import 'entity.dart';

final class UserProfile extends Entity<GenericEntityId> {
  const UserProfile({
    required super.id,
    required super.version,
    required super.createdAt,
    required this.displayName,
    required this.lifecycleState,
    this.playerId,
  });

  final NonEmptyString displayName;
  final NonEmptyString lifecycleState;
  final PlayerId? playerId;
}
