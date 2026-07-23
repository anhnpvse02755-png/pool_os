import '../shared/entity_ids.dart';
import '../shared/scalar_values.dart';
import 'entity.dart';

final class PlayerProfile extends Entity<PlayerId> {
  const PlayerProfile({
    required super.id,
    required super.version,
    required super.createdAt,
    required this.displayName,
    required this.lifecycleState,
  });

  final NonEmptyString displayName;
  final NonEmptyString lifecycleState;
}
