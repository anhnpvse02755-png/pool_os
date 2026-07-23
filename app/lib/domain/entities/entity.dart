import '../../shared/foundation/value_object.dart';
import '../shared/entity_ids.dart';
import '../shared/scalar_values.dart';
import '../shared/temporal_values.dart';

abstract class Entity<TId extends EntityId> extends ValueObject {
  const Entity({
    required this.id,
    required this.version,
    required this.createdAt,
  });

  final TId id;
  final VersionNumber version;
  final UtcTimestamp createdAt;

  @override
  List<Object?> get components => [id];
}
